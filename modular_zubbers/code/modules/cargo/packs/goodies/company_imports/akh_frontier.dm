/datum/supply_pack/company_import/akh_frontier
	subcategory = "Akh Frontier"

/datum/supply_pack/company_import/akh_frontier/basic
	cost = PAYCHECK_COMMAND

/datum/supply_pack/company_import/akh_frontier/basic/omni_drill
	item_type = /obj/item/screwdriver/omni_drill
	cost = PAYCHECK_CREW * 5

/datum/supply_pack/company_import/akh_frontier/basic/arc_welder
	item_type = /obj/item/weldingtool/electric/arc_welder
	cost = PAYCHECK_CREW * 3

/datum/supply_pack/company_import/akh_frontier/basic/prybar
	item_type = /obj/item/crowbar/large/colony_prybar
	cost = PAYCHECK_CREW * 5

/datum/supply_pack/company_import/akh_frontier/basic/multitool
	item_type = /obj/item/multitool/colony
	cost = PAYCHECK_COMMAND

/datum/supply_pack/company_import/akh_frontier/basic/compact_drill
	item_type = /obj/item/pickaxe/drill/compact
	cost = PAYCHECK_CREW * 5

/datum/supply_pack/company_import/akh_frontier/deployables_fab/rapid_construction_fabricator
	item_type = /obj/item/flatpacked_machine
	name = "快速建造机（RCF）"
	desc = "内含一台平板包装的快速建造机，附带已充电的电池，便于在各处使用。无法在空间站上部署。"
	cost = CARGO_CRATE_VALUE * 30

/datum/supply_pack/company_import/akh_frontier/deployables_fab/foodricator
	item_type = /obj/item/flatpacked_machine/organics_ration_printer
	desc = "内含一台平板包装的有机口粮打印机，无法在空间站上部署。"
	cost = CARGO_CRATE_VALUE * 2

/datum/supply_pack/company_import/akh_frontier/appliances
	cost = PAYCHECK_COMMAND

/datum/supply_pack/company_import/akh_frontier/appliances/charger
	item_type = /obj/item/wallframe/cell_charger_multi
	cost = PAYCHECK_CREW

/datum/supply_pack/company_import/akh_frontier/appliances/water_synth
	item_type = /obj/item/flatpacked_machine/water_synth
	desc = "内含一台平板包装的水合成器，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/appliances/hydro_synth
	item_type = /obj/item/flatpacked_machine/hydro_synth
	desc = "内含一台平板包装的水培化学品合成器，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/appliances/sustenance_dispenser
	item_type = /obj/item/flatpacked_machine/sustenance_machine
	cost = PAYCHECK_COMMAND * 2
	desc = "内含一台平板包装的饮食分配器，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/deployables_misc
	cost = PAYCHECK_COMMAND

/datum/supply_pack/company_import/akh_frontier/deployables_misc/arc_furnace
	item_type = /obj/item/flatpacked_machine/arc_furnace
	desc = "内含一台平板包装的电弧炉，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/deployables_misc/thermomachine
	item_type = /obj/item/flatpacked_machine/thermomachine
	desc = "内含一台平板包装的大气温度调节器，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/deployables_misc/co2_cracker
	item_type = /obj/item/flatpacked_machine/co2_cracker
	desc = "内含一台平板包装的 CO2 裂解机，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/deployables_misc/recycler
	item_type = /obj/item/flatpacked_machine/recycler
	desc = "内含一台平板包装的回收机，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/deployables
	cost = PAYCHECK_COMMAND

/datum/supply_pack/company_import/akh_frontier/deployables/solar
	item_type = /obj/item/flatpacked_machine/solar
	cost = PAYCHECK_CREW
	desc = "内含一块平板包装的太阳能板，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/deployables/solar_tracker
	item_type = /obj/item/flatpacked_machine/solar_tracker
	desc = "内含一台平板包装的太阳能追踪器，无法在空间站上部署。"
	cost = PAYCHECK_CREW

/datum/supply_pack/company_import/akh_frontier/deployables/station_battery
	item_type = /obj/item/flatpacked_machine/station_battery
	desc = "内含一台平板包装的固定式电池，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/deployables/big_station_battery
	item_type = /obj/item/flatpacked_machine/large_station_battery
	desc = "内含一台平板包装的大型固定式电池，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/deployables/solids_generator
	item_type = /obj/item/flatpacked_machine/fuel_generator
	desc = "内含一台平板包装的燃料发电机，无法在空间站上部署。"

/datum/supply_pack/company_import/akh_frontier/deployables/rtg
	item_type = /obj/item/flatpacked_machine/rtg
	desc = "内含一台平板包装的放射性同位素热电发电机（RTG），无法在空间站上部署。"
