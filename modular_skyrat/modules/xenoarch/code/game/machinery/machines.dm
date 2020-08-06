//T4 Parts are what are in mind.
//

/obj/machinery/xenoarch
	name = "parent xenoarch machine"
	desc = "You shouldn't be able to see this."
	icon = 'modular_skyrat/modules/xenoarch/icons/obj/machines/machines.dmi'
	icon_state = "machine_empty"
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 250

	//this var is affected by the rating of the laser, affects the amount of time it takes to complete its task.
	var/process_time

/obj/machinery/xenoarch/proc/process_rocks()
	return

/obj/machinery/xenoarch/rock_scanner
	name = "strange rock scanner"
	desc = "A machine that scans rocks that are placed within it."
	circuit = /obj/item/circuitboard/machine/xenoarch/scanner

	//max process time: 8 seconds
	//min process time: 2 seconds
	process_time = 8 SECONDS
	var/precise = FALSE
	//ref in a way to the strange rock in the contents
	var/obj/item/strangerock/target_rock

/obj/machinery/xenoarch/rock_scanner/RefreshParts()
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		process_time = 10 SECONDS - (2 SECONDS * L.rating)
		if(L.rating >= 4)
			precise = TRUE

/obj/machinery/xenoarch/rock_scanner/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/strangerock))
		if(target_rock)
			audible_message("<span class='notice'>[src] is full!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		target_rock = I
		addtimer(CALLBACK(src, .proc/process_rocks), process_time)
	return ..()

/obj/machinery/xenoarch/rock_scanner/process_rocks()
	audible_message("<span class='notice'>Base depth is: [target_rock.itembasedepth] cm.</span>")
	audible_message("<span class='notice'>Safe depth is: [target_rock.itemsafedepth] cm.</span>")
	audible_message("<span class='notice'>Current depth is: [target_rock.dugdepth] cm.</span>")
	if(precise)
		audible_message("<span class='notice'>Relic depth is: [target_rock.itemactualdepth] cm.</span>")
	target_rock.forceMove(get_turf(src))
	target_rock = null

/obj/machinery/xenoarch/rock_openner
	name = "strange rock openner"
	desc = "A machine that will automatically open rocks placed inside it."
	circuit = /obj/item/circuitboard/machine/xenoarch/openner

	//max process time: 16 seconds
	//min process time: 4 seconds
	process_time = 16 SECONDS
	//ref in a way to the strange rock in the contents
	var/obj/item/strangerock/target_rock

/obj/machinery/xenoarch/rock_openner/RefreshParts()
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		process_time = 20 SECONDS - (4 SECONDS * L.rating)

/obj/machinery/xenoarch/rock_openner/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/strangerock))
		if(target_rock)
			audible_message("<span class='notice'>[src] is full!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		target_rock = I
		addtimer(CALLBACK(src, .proc/process_rocks), process_time)
	return ..()

/obj/machinery/xenoarch/rock_openner/process_rocks()
	var/obj/item/chosen_item = target_rock.chosenitem
	new chosen_item(get_turf(src))
	target_rock = null

/obj/machinery/xenoarch/rock_recycler
	name = "strange rock recycler"
	desc = "A machine that will somehow recycle strange rocks."
	circuit = /obj/item/circuitboard/machine/xenoarch/recycler

	//max procees time: 8 seconds
	//min process time: 2 seconds
	process_time = 8 SECONDS
	//max required amount: 8 rocks
	//min required amount: 2 rocks
	var/req_amount = 8
	//the current amount of rocks stored
	var/rock_amount = 0

/obj/machinery/xenoarch/rock_recycler/RefreshParts()
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		process_time = 10 SECONDS - (2 SECONDS * L.rating)
		req_amount = 10 - (2 * L.rating)

/obj/machinery/xenoarch/rock_recycler/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/strangerock))
		if(rock_amount < req_amount)
			rock_amount++
			qdel(I)
			return
		if(rock_amount >= req_amount)
			audible_message("<span class='notice'>[src] is full!</span>")
			return
	return ..()

/obj/machinery/xenoarch/rock_recycler/attack_hand(mob/living/user)
	if(rock_amount != req_amount)
		var/amount_left = req_amount - rock_amount
		audible_message("<span class='notice'>[src] requires [amount_left] more strange rock(s).</span>")
		return
	addtimer(CALLBACK(src, .proc/process_rocks), process_time)
	return ..()

/obj/machinery/xenoarch/rock_recycler/process_rocks()
	rock_amount = 0
	new /obj/item/strangerock(get_turf(src))

