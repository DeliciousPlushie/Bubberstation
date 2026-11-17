/atom/proc/chinese_hover_name()
	return name

/mob/living/basic/slime/chinese_hover_name()
	return get_visible_name()

/obj/item/slimecross/chinese_hover_name()
	return get_visible_name()

/obj/item/slime_extract/chinese_hover_name()
	return get_visible_name()

/obj/item/autoslime/chinese_hover_name()
	return get_visible_name()

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

/obj/item/slime_extract/get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
	. = ..()
	if(!recurring || HAS_TRAIT(src, TRAIT_WAS_RENAMED))
		return
	var/static/regex/recurring_name = regex("^recurring (\[a-z-]+) extract$")
	if(!recurring_name.Find(.))
		return
	var/raw_color = recurring_name.group[1]
	var/display_color = chinese_slime_color_display(raw_color)
	if(display_color != raw_color)
		return "[chinese_slime_crossbreed_display("recurring")][display_color]史莱姆提取物"

/obj/item/autoslime/get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WAS_RENAMED))
		return
	var/static/regex/auto_name = regex("^自维持 (\[a-z-]+) 提取物$")
	if(!auto_name.Find(.))
		return
	var/raw_color = auto_name.group[1]
	var/display_color = chinese_slime_color_display(raw_color)
	if(display_color != raw_color)
		return "[chinese_slime_crossbreed_display("self-sustaining")][display_color]史莱姆提取物"

/proc/chinese_autoslime_reaction_choice(mob/user, list/choices)
	var/list/display_choices = list()
	var/list/repeat_items = list()
	for(var/key in choices)
		var/datum/chemical_reaction/slime/recipe = choices[key]
		var/list/reagent_names = list()
		for(var/datum/reagent/reagent_type as anything in recipe.required_reagents)
			reagent_names += chinese_reagent_display(initial(reagent_type.name))
		var/label = avoid_assoc_duplicate_keys(jointext(reagent_names, "、"), repeat_items)
		display_choices[label] = key
	var/selection = tgui_input_list(user, "选择用于触发反应的试剂。", "自给型提取物反应", display_choices)
	return isnull(selection) ? null : display_choices[selection]
