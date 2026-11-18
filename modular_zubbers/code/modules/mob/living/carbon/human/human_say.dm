/mob/living/carbon/human/get_alt_name(for_display = FALSE)
	if(name != get_voice())
		return for_display ? "（显示身份：[get_id_name("未知")]）" : " (as [get_id_name("Unknown")])"
