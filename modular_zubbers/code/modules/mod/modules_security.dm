/obj/item/mod/module/pepper_shoulders
	overlay_icon_file = 'modular_skyrat/master_files/icons/mob/clothing/modsuit/mod_modules.dmi'
	overlay_state_inactive = "module_pepper"
	overlay_state_use = "module_pepper_used"

/obj/item/mod/module/pepper_shoulders/generate_worn_overlay(mutable_appearance/standing)
	if(mod.skin == "security")
		overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
		overlay_state_use = "[initial(overlay_state_use)]-[mod.skin]"
	else
		overlay_state_inactive = "[initial(overlay_state_inactive)]"
		overlay_state_use = "[initial(overlay_state_use)]"
	return ..()

/obj/item/mod/module/dispenser/mirage
	overlay_icon_file = 'modular_skyrat/master_files/icons/mob/clothing/modsuit/mod_modules.dmi'
	overlay_state_inactive = "module_mirage_grenade"

/obj/item/mod/module/dispenser/mirage/generate_worn_overlay(mutable_appearance/standing)
	if(mod.skin == "security")
		overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	else
		overlay_state_inactive = "[initial(overlay_state_inactive)]"
	return ..()

/obj/item/mod/module/shooting_assistant/ert
	complexity = 0
	removable = FALSE
	desc = "这款射击辅助模块改良自少见的 BEPIS 资助型号。它原本打算供应地球政府海军陆战队等外部武装，但一直未能量产，最终成了纳米传讯应急响应部队的装备。"
