/obj/item/radio/server

/obj/item/radio/server/can_receive(frequency,levels)
	return FALSE // The server's radio isn't for receiving, it's for outputting. For now.

/obj/machinery/telecomms/server
	//NTSL-related stuffs
	var/datum/TCS_Compiler/Compiler	// the compiler that compiles and runs the code
	var/autoruncode = FALSE		// 1 if the code is set to run every time a signal is picked up
	var/list/memory = list()	// stored memory, for mem() in NTSL
	var/rawcode = ""	// the code to compile (raw-ass text)
	var/compiledcode = ""	//the last compiled code (also raw-ass text)
	var/obj/item/radio/server/server_radio // Allows the server to talk on the radio, via broadcast() in NTSL
	var/last_signal = 0 // Marks the last time an NTSL script called signal() from this server, to stop spam.
	var/list/compile_warnings = list()
	//End-NTSL
	COOLDOWN_DECLARE(compile_cooldown)

//NTSL-related procs
/obj/machinery/telecomms/server/Initialize(mapload)
	Compiler = new()
	Compiler.Holder = src
	server_radio = new()
	return ..()

/obj/machinery/telecomms/server/Destroy()
	QDEL_NULL(Compiler)
	QDEL_NULL(server_radio)
	memory = null
	return ..()

/obj/machinery/telecomms/server/proc/update_logs()
	if(length(log_entries) >= 400) // If so, start deleting at least, hopefully, one log entry
		log_entries.Cut(1, 2)
	/*
		for(var/i = 1, i <= length(log_entries), i++) // locate the first garbage collectable log entry and remove it
			var/datum/comm_log_entry/L = log_entries[i]
			if(L.garbage_collector)
				log_entries.Remove(L)
				break
	*/

/obj/machinery/telecomms/server/proc/add_entry(content, input)
	var/datum/comm_log_entry/log = new
	var/identifier = num2text( rand(-1000,1000) + world.time )
	log.name = "[chinese_telecomms_label(input)]（[md5(identifier)]）"
	log.input_type = input
	log.parameters["message"] = content
	log.parameters["language"] = /datum/language/common
	log_entries.Add(log)
	update_logs()

/obj/machinery/telecomms/server/proc/compile(mob/user = usr) as /list
	///Maximum amount of characters that can be in a script
	var/max_characters = 15000
	///The character count of the code being compiled
	var/code_length = length(rawcode)
	if(is_banned_from(user.ckey, JOB_TELECOMMS_SPECIALIST))
		to_chat(user, span_warning("你已被禁止使用 NTSL。"))
		return "访问未获授权。"
	if(QDELETED(Compiler))
		return
	//Check if it has any bad characters in it
	if(!reject_bad_ntsl_text(rawcode, require_pretty = FALSE, allow_newline = TRUE, allow_code = TRUE))
		rawcode = null
		return "请只使用银河通用语字符。"
	//Check if it is over the character limit which is 15000 due to TGUI having a hard time handling bigger scripts
	if(code_length > max_characters)
		rawcode = null
		return "字符数超出限制：[code_length]/[max_characters]"
	if(!COOLDOWN_FINISHED(src, compile_cooldown))
		return "服务器正在充能，请稍候。"
	var/list/compileerrors = Compiler.Compile(rawcode)
	COOLDOWN_START(src, compile_cooldown, 2 SECONDS)
	if(!length(compileerrors) && (compiledcode != rawcode))
		logger.Log(LOG_CATEGORY_NTSL, "[user] 上传了代码：[rawcode]")
		compiledcode = rawcode
	if(istype(user.mind?.assigned_role, /datum/job/telecomms_specialist)) //achivement description says only Signal Technician gets the achivement
		var/freq = length(freq_listening) ? freq_listening[1] : 1459
		var/atom/movable/M = new()
		var/atom/movable/virtualspeaker/speaker = new(null, M, server_radio)
		speaker.name = "Poly"
		speaker.job = ""
		var/datum/signal/subspace/vocal/signal = new(src, freq, speaker, /datum/language/common, "test", list(), )
		signal.data["server"] = src
		Compiler.Run(signal)
		if(signal.data["reject"] == TRUE)
			signal.data["name"] = ""
			signal.data["reject"] = FALSE
			Compiler.Run(signal)
			if(signal.data["reject"] == FALSE)
				user.client.give_award(/datum/award/achievement/jobs/Poly_silent, user)
		else
			for(var/sample in signal.data["spans"])
				if(sample == SPAN_COMMAND)
					user.client.give_award(/datum/award/achievement/jobs/Poly_loud, user)
					break // Not having this break leaves us open to a potential DoS attack.
		signal.data["reject"] = TRUE //Don't pass achievement signals.
	return compileerrors
//end-NTSL
