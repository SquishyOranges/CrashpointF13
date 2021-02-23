/datum/species/ghoul
	name = "Ghoul"
	id = "ghoul"
	say_mod = "rasps"
	limbs_id = "ghoul"
	species_traits = list(HAIR,FACEHAIR)
	inherent_traits = list(TRAIT_RADIMMUNE/*, TRAIT_NOBREATH*/)
	inherent_biotypes = list(MOB_INORGANIC, MOB_HUMANOID)
	punchstunthreshold = 9
	use_skintones = 0
	sexes = 1
	armor = -15
	disliked_food = GROSS
	liked_food = JUNKFOOD | FRIED | RAW

/datum/species/ghoul/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "radium")//The healing here stacks with spec_life, as it adds additional radiaiton as it processes, providing double the healing.
		H.adjustCloneLoss(-1)
		H.adjustToxLoss(-1)
		H.adjustFireLoss(-1)
		H.adjustBruteLoss(-1)
		if(prob(15))
			to_chat(H, "<span class='notice'>Your skin glows faintly as you feel your wounds mending themselves.</span>")
		return 1

/datum/species/ghoul/spec_life(mob/living/carbon/human/H)
	var/datum/component/radioactive/radiation = GetComponent(/datum/component/radioactive)
	if(radiation)
		if(radiation > RAD_MOB_HEAL)//Have to chug radioactive material. The only way for a Ghoul to get this state.
			H.adjustToxLoss(-2)
			H.adjustFireLoss(-1)
			H.adjustBruteLoss(-1)
			H.adjustCloneLoss(-1)
			if(prob(15))
				to_chat(H, "<span class='notice'>Your skin glows faintly as you feel your wounds mending themselves.</span>")

			return 1

//Ghouls have weak limbs.
/datum/species/ghoul/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	for(var/obj/item/bodypart/b in C.bodyparts)
		b.max_damage -= 10
	C.faction |= "ghoul"

/datum/species/ghoul/on_species_loss(mob/living/carbon/C)
	..()
	C.faction -= "ghoul"
	for(var/obj/item/bodypart/b in C.bodyparts)
		b.max_damage = initial(b.max_damage)

/datum/species/ghoul/qualifies_for_rank(rank, list/features)
	if(rank in GLOB.legion_positions) /* legion HATES these ghoul */
		return 0
	if(rank in GLOB.brotherhood_positions) //don't hate them, just tolorate.
		return 0
	if(rank in GLOB.vault_positions) //purest humans left in america. supposedly.
		return 0
	return ..()

/datum/species/ghoul/glowing
	name = "Glowing Ghoul"
	id = "glowghoul"
	limbs_id = "glowghoul"
	armor = -30
	speedmod = 0.5
	brutemod = 1.3
	punchdamagehigh = 6
	punchstunthreshold = 6
	use_skintones = 0
	sexes = 1
	blacklisted = FALSE//Change to true if you don't want this playable. Or, y'know, change the config.
	var/last_event = 0
	var/active = null

//Ghouls have weak limbs.
/datum/species/ghoul/glowing/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	for(var/obj/item/bodypart/b in C.bodyparts)
		b.max_damage -= 15
	C.faction |= "ghoul"
	C.set_light(2, 1, LIGHT_COLOR_GREEN)
	SSradiation.processing += C

/datum/species/ghoul/glowing/on_species_loss(mob/living/carbon/C)
	..()
	C.set_light(0)
	C.faction -= "ghoul"
	for(var/obj/item/bodypart/b in C.bodyparts)
		b.max_damage = initial(b.max_damage)
	SSradiation.processing -= C

/datum/species/ghoul/glowing/spec_life(mob/living/carbon/human/H)
	var/datum/component/radioactive/radiation = GetComponent(/datum/component/radioactive)
//Quite literally just ripped from Uranium Golem. You'd think it redundant because of the above, but it's not.
	if(!active)
		if(world.time > last_event+30)
			active = 1
			radiation_pulse(H, 50)
			last_event = world.time
			active = null
	if(radiation)
		if(radiation > RAD_MOB_HEAL)//Have to chug radioactive material. The only way for a Ghoul to get this state.
			H.adjustToxLoss(-2)
			H.adjustFireLoss(-1)
			H.adjustBruteLoss(-1)
			H.adjustCloneLoss(-1)
			if(prob(15))
				to_chat(H, "<span class='notice'>Your skin glows faintly as you feel your wounds mending themselves.</span>")

			return 1
	..()