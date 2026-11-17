/proc/chinese_navigation_destination_display(value)
	if(!istext(value))
		return value
	for(var/suffix in list(" （上方）", " （下方）"))
		if(length(value) > length(suffix) && copytext(value, -length(suffix)) == suffix)
			return "[chinese_navigation_destination_display(copytext(value, 1, length(value) - length(suffix) + 1))][suffix]"
	var/static/list/names = list(
		"Clothing Store" = "服装店",
		"Cryopods" = "冷冻休眠舱",
		"Escape" = "逃生区",
		"Escape Pod 1 Dock (Public)" = "1 号逃生舱停靠区（公共）",
		"Escape Pod 2 Dock (Security)" = "2 号逃生舱停靠区（安保）",
		"Escape Pod 4 Dock (Engineering)" = "4 号逃生舱停靠区（工程）",
		"Loopstation Shuttle Access" = "环形站穿梭机通道",
		"Public Lavaland Shuttle Duck" = "公共拉瓦兰穿梭机停靠区",
		"Public Mining Dock" = "公共采矿停靠区",
		"Representative's Office" = "代表办公室",
		"Arcade" = "街机厅", "Armoury" = "军械库", "Atmospherics Foyer" = "大气部门厅",
		"Auxiliary Research" = "辅助研究室", "Backstage" = "后台", "Bar Storage" = "酒吧储藏室", "Barbershop" = "理发店",
		"Blueshield's Office" = "蓝盾办公室", "Blueshield's Quarters" = "蓝盾宿舍", "Bridge Access" = "舰桥入口",
		"Cafe Barista" = "咖啡师工作区", "Canteen Lounge" = "食堂休息区", "Carp Pro Shop" = "太空鲤鱼钓具店",
		"Chemistry Access" = "化学室入口", "Chief Engineer" = "总工程师办公室", "Chief Medical Officer's Quarters" = "首席医疗官宿舍",
		"Circuits Lab" = "电路实验室", "Common Mining Dock" = "公共采矿停靠区", "Construction Zone" = "施工区",
		"Consultant's Quarters" = "顾问宿舍", "Customs Desk" = "海关柜台", "Customs Post" = "海关岗亭",
		"Departure Lounge Airlock" = "离站候船厅气闸", "Departure Lounge Security Post" = "离站候船厅安保岗亭", "Departures Checkpoint" = "离站检查站",
		"Disposal Access" = "废物处理区入口", "Dormitory" = "宿舍", "E.V.A. Storage" = "舱外活动装备储藏室", "Engine Room" = "引擎室",
		"Experimentor Control" = "实验仪控制室", "External Docking Port" = "外部对接口", "Gravity Generator Foyer" = "重力发生器门厅",
		"Head of Personnel" = "人事主管办公室", "Holodeck Door" = "全息甲板入口", "Library Desk" = "图书馆服务台",
		"Material Storage" = "材料储藏室", "Medbay" = "医疗部", "Medbay Clinic" = "医疗部诊所", "MiniSat Access" = "小型卫星入口",
		"MiniSat Transit Tube Access" = "小型卫星运输管道入口", "Night Club" = "夜总会", "Paramedic Dispatch Access" = "急救调度室入口",
		"Permabrig Visitation" = "永久监禁区探视室", "Primary Restroom" = "主洗手间", "Primary Surgical Theatre" = "主手术室",
		"Primary Treatment Centre" = "主治疗中心", "Private Psych Room" = "私人心理咨询室", "Psychology" = "心理咨询室",
		"Public Courtroom Seating" = "法庭旁听席", "Public Garden" = "公共花园", "Public Gym" = "公共健身房",
		"Public Hydroponics Storage" = "公共水培储藏室", "Public Pool" = "公共泳池", "Research and Development Lab" = "研发实验室",
		"Research Director" = "科研主管办公室", "Research Division Access" = "科研部入口", "Security Mech Bay" = "安保机甲舱",
		"Self Care Salon" = "个人护理沙龙", "Service Hall" = "服务部大厅", "Tech Storage" = "技术储藏室", "Technology Storage" = "技术储藏室",
		"Telecommunications" = "电信室", "Teleport Access" = "传送机入口", "Teleportations Access" = "传送机入口",
		"Theater Backstage" = "剧院后台", "Theatre" = "剧院", "Unisex Restrooms" = "男女通用洗手间", "Vault Access" = "金库入口",
		"Vault Door" = "金库大门", "Virology Access" = "病毒研究室入口", "Virology Exterior Airlock" = "病毒研究室外部气闸",
		"Wrestling Ring Entrance" = "摔跤擂台入口", "Xenobiology Lab External Airlock" = "异种生物实验室外部气闸",
	)
	return names[value] || chinese_area_display(value)

/proc/chinese_navigation_destination_choice(mob/user, list/destinations)
	var/list/labels = list()
	var/list/label_counts = list()
	for(var/key in destinations)
		var/label = chinese_navigation_destination_display(key)
		labels[key] = label
		label_counts[label] = (label_counts[label] || 0) + 1
	var/list/display_choices = list()
	for(var/key in destinations)
		var/label = labels[key]
		if(label_counts[label] > 1)
			label = "[label]（[key]）"
		var/base_label = label
		var/duplicate_index = 2
		while(label in display_choices)
			label = "[base_label]（[duplicate_index++]）"
		display_choices[label] = key
	var/selection = tgui_input_list(user, "选择地点", "导航", sort_list(display_choices))
	return isnull(selection) ? null : display_choices[selection]
