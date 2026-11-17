/proc/chinese_slime_color_display(value)
	var/static/list/colors = list(
		SLIME_TYPE_ADAMANTINE = "精金", SLIME_TYPE_BLACK = "黑色", SLIME_TYPE_BLUE = "蓝色",
		SLIME_TYPE_BLUESPACE = "蓝空间", SLIME_TYPE_CERULEAN = "蔚蓝", SLIME_TYPE_DARK_BLUE = "深蓝色",
		SLIME_TYPE_DARK_PURPLE = "深紫色", SLIME_TYPE_GOLD = "金色", SLIME_TYPE_GREEN = "绿色",
		SLIME_TYPE_GREY = "灰色", SLIME_TYPE_LIGHT_PINK = "浅粉色", SLIME_TYPE_METAL = "金属",
		SLIME_TYPE_OIL = "油质", SLIME_TYPE_ORANGE = "橙色", SLIME_TYPE_PINK = "粉色",
		SLIME_TYPE_PURPLE = "紫色", SLIME_TYPE_PYRITE = "黄铁矿", SLIME_TYPE_RAINBOW = "彩虹",
		SLIME_TYPE_RED = "红色", SLIME_TYPE_SEPIA = "棕褐色", SLIME_TYPE_SILVER = "银色", SLIME_TYPE_YELLOW = "黄色",
	)
	return colors[value] || value

/mob/living/basic/slime/get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WAS_RENAMED))
		return
	var/static/regex/generated_name = regex("^(\[a-z-]+) (baby|adult) slime \\((\\d+)\\)$")
	if(!generated_name.Find(.))
		return
	var/slime_color = generated_name.group[1]
	var/stage = generated_name.group[2]
	var/slime_id = generated_name.group[3]
	var/color_display = chinese_slime_color_display(slime_color)
	if(color_display == slime_color)
		return
	return "[color_display][stage == SLIME_LIFE_STAGE_ADULT ? "成年" : "幼年"]史莱姆（[slime_id]）"

/obj/item/slimecross/get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WAS_RENAMED) || . != "[effect] [colour] extract")
		return
	var/color_display = chinese_slime_color_display(colour)
	var/effect_display = chinese_slime_crossbreed_display(effect)
	if(color_display == colour || effect_display == effect)
		return
	return "[effect_display][color_display]史莱姆提取物"
