/obj/item/circuitboard/computer/comm_traffic
	name = "电信流量控制台"
	build_path = /obj/machinery/computer/telecomms/traffic

/datum/design/board/traffic
	name = "电信流量控制台"
	desc = "用于建造电信流量控制台。"
	build_path = /obj/item/circuitboard/computer/comm_traffic
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/obj/machinery/computer/telecomms/traffic
	name = "电信流量控制计算机"
	desc = "用于编写和部署通信服务器的信号处理脚本。"
	req_access = list(ACCESS_TCOMMS)
	circuit = /obj/item/circuitboard/computer/comm_traffic

	/// The servers located by the computer
	var/list/obj/machinery/telecomms/server/servers = list()
	/// The network to probe
	var/network = "NULL"
	/// The current code being used
	var/storedcode = "def process_signal(sig){return sig;}"
	/// The name and job on the ID used to log in
	var/user_name = ""
	/// Logs for users logging in/out or compiling code
	var/list/access_log = list()
	/// Output from compiling to the servers
	var/list/compiler_output = list()

	var/unlimited_range = FALSE

/obj/machinery/computer/telecomms/traffic/Initialize(mapload)
	. = ..()
	if(length(GLOB.pretty_filter_items) == 0)
		setup_pretty_filter()
	if(mapload)
		unlimited_range = TRUE
	return INITIALIZE_HINT_LATELOAD

/*
/obj/machinery/computer/telecomms/traffic/LateInitialize(mapload_arg)
	. = ..()
	refresh_servers()
	for(var/obj/machinery/telecomms/server/new_server in servers)
		new_server.autoruncode = TRUE
*/

/obj/machinery/computer/telecomms/traffic/Destroy()
	servers = null
	return ..()

/obj/machinery/computer/telecomms/traffic/proc/create_log(entry)
	if(!user_name)
		CRASH("[type] tried to create a log with no user_name!")
	access_log += "\[[round_timestamp()]\] [user_name] [entry]"

/obj/machinery/computer/telecomms/traffic/ui_interact(mob/user, datum/tgui/ui)
	if(is_banned_from(user.ckey, JOB_TELECOMMS_SPECIALIST))
		to_chat(user, span_warning("你已被禁止使用 NTSL 控制台。"))
		return "你已被禁止使用 NTSL。"

	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NTSLCoding")
		ui.open()

/obj/machinery/computer/telecomms/traffic/ui_data(mob/user)
	var/list/data = list()
	var/list/server_data = list()
	for(var/obj/machinery/telecomms/server/server in servers)
		server_data.Add(list(list(
			"server" = REF(server),
			"server_id" = server.id,
			"server_name" = server.name,
			"run_code" = server.autoruncode,
		)))
	data["server_data"] = server_data
	data["stored_code"] = storedcode
	data["network"] = network
	data["user_name"] = user_name
	data["access_log"] = access_log.Copy()
	data["compiler_output"] = compiler_output.Copy()
	data["emagged"] = ((obj_flags & EMAGGED) > 0)

	data["admin_view"] = FALSE
	if(user.client.holder) // enables an admin-only button in case of severe grief
		data["admin_view"] = TRUE

	return data

/obj/machinery/computer/telecomms/traffic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/living/user = ui.user

	if(issilicon(user) || isAI(user) || iscyborg(user) || ispAI(user))
		to_chat(user, span_warning("防火墙似乎拦截了硅基生命的访问请求！"))
		return

	if(action == "admin_reset") // something to note, this will runtime when clicked on by an admin ghost. But still works.
		if(!user.client.holder)
			message_admins("[key_name_admin(user)] 尝试在电信流量控制台调用管理员专用的 \"admin_reset\"。该用户没有管理员权限，可能尝试了 JavaScript 注入。")
			return
		network = "tcommsat"
		refresh_servers()
		for(var/obj/machinery/telecomms/server/server as anything in servers)
			server.rawcode = "def process_signal(sig){ return sig;" // bare minimum
		compiler_output.Cut()
		compiler_output = compile_all(user)
		var/message = "[key_name_admin(user)] 已使用管理员权限清空 NTSL 控制台代码并重新编译。此操作仅应用于处理严重违规行为。"
		message_admins(message)
		logger.Log(LOG_CATEGORY_NTSL, "[key_name(src)] [message] [loc_name(src)]")
		access_log += "\[[round_timestamp()]\] 错误：纳米传讯工作人员已远程清空 NTSL 代码！"
		return TRUE

	if(.)
		return

	playsound(src, SFX_TERMINAL_TYPE, 15, FALSE)
	switch(action)
		if("refresh_servers")
			refresh_servers()
			return TRUE
		if("toggle_code_execution")
			var/obj/machinery/telecomms/server/selected_server = locate(params["selected_server"])
			selected_server.autoruncode = !selected_server.autoruncode
			return TRUE
		if("save_code")
			storedcode = params["saved_code"]
			compiler_output += "代码已保存"
			log_telecomms("[user] 在电信流量控制台保存了以下代码：\n [storedcode]")
			return TRUE
		if("compile_code")
			if(!user_name)
				message_admins("[key_name_admin(user)] 尝试在未登录时编译 NTSL 代码。") // tell admins that someone tried a javascript injection
				return
			for(var/obj/machinery/telecomms/server/server as anything in servers)
				if(istext(storedcode))
					server.rawcode = storedcode
			compiler_output.Cut()
			compiler_output = compile_all(user)
			log_telecomms("[user] 在电信流量控制台编译了代码。")
			return TRUE
		if("set_network")
			if(!user_name)
				return
			network = params["new_network"]
			return TRUE
		if("log_in")
			if(HAS_SILICON_ACCESS(user))
				user_name = "系统管理员"
			else if(allowed(user))
				var/obj/item/card/id/user_id = user.get_idcard(TRUE)
				if(user_id)
					user_name = "[user_id?.registered_name]（[chinese_job_display(user_id?.assignment)]）"
				else
					user_name = "[user.name]（未知）"
			if(!user_name)
				balloon_alert(user, "权限不足！")
				return TRUE
			create_log("已登录。")
			return TRUE
		if("log_out")
			if(obj_flags & EMAGGED)
				return TRUE
			create_log("已退出登录。")
			user_name = null
			return TRUE
		if("clear_logs")
			if(!user_name)
				message_admins("[key_name_admin(user)] 尝试在未登录时清空 NTSL 日志。")
				return
			access_log.Cut()
			create_log("清空了访问日志。")
			return TRUE

/obj/machinery/computer/telecomms/traffic/proc/refresh_servers()
	servers.Cut()
	for(var/obj/machinery/telecomms/server/new_server as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/telecomms/server))
		if(new_server.network != network)
			continue
		if(!unlimited_range && get_dist(src, new_server) > 15)
			continue
		servers.Add(new_server)

/obj/machinery/computer/telecomms/traffic/proc/compile_all(mob/user)
	if(is_banned_from(user.ckey, JOB_TELECOMMS_SPECIALIST))
		return list("你已被禁止使用 NTSL。")
	if(!length(servers))
		return list("未找到服务器。")
	for(var/obj/machinery/telecomms/server/server as anything in servers)
		var/list/compile_errors = server.compile(user)
		if(!compile_errors)
			return list("发生致命错误，请联系本地网络管理员。")
		if(istext(compile_errors))
			return splittext(compile_errors, "\n")
		var/list/text_list = list()
		for(var/datum/scriptError/error in compile_errors)
			text_list.Add(error.message)
		if(length(text_list))
			return text_list
	create_log("已在网络 [chinese_telecomms_label(network)] 的所有已连接服务器上编译代码。")
	return list("编译完成。")

/obj/machinery/computer/telecomms/traffic/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	user_name = "系统管理员"
	create_log("已登录。")
	playsound(src.loc, 'sound/effects/sparks/sparks4.ogg', 75, 1)
	to_chat(user, span_notice("你绕过了控制台的安全协议。"))
