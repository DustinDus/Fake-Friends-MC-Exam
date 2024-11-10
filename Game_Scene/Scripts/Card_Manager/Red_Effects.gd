extends Node2D
# Reads card names and activates the corresponding effect (also asks the user to choose its target(s) if any)

# IDs mapped to Card Names
enum {FU,GRAVEDIGGER,GRAVEROBBER,TORNADO,BONK
	  CARDMAGEDDON,RNGALLOWS,YING,YANG,JUDGE
	  HEART_OF_THE_CARDS,KOBE,DOUBLE_UP,TRIPLE_IT,QUICK_MATHS
	  THE_MAGICIAN,DICE_TAX,JAILBREAK,DUAL_CHANCE,MALUS
	  BACKPOCKET_PAIN,YEET,RULES_OF_NATURE,ITS_TIME_TO_STOP,CROUPIER
	  PARKING_METER,MINEFIELD,MAKE_IT_RAIN,MOMS_CREDIT_CARD,X_FACTOR
	  SWITCH,TOPSY_TURVY,UNAWARENESS,TABULA_RASA,MIRROR_CARD
	  KEBAB,SAUCE,BREAD,NO_U,ROULETTE
	  INSTANT_KARMA,OBJECTION,IMMUNITY,IMMUNITY_2,BREAK_IN_BLACK
	  GIMME_THAT,EXEMPTION,ROCK_SOLID,INDECLINABLE_OFFER,CONTROLLED_BURN}
# + Combo IDs
enum {YING_AND_YANG = -1, DONER_DELIGHT = -2}
# Player effects
enum {VISIBLE_CARDS,RED_IMMUNITY,BLACK_IMMUNITY,STOPPED,IMPRISONED
	  CROUPIER_EFF,NEGATIVE_MOVEMENT,HALVED_MOVEMENT,CANT_PLAY_RED}

# To extrapolate data
var game_manager: Node2D
# Aux for effects
var aux_effs
# For Mirror Card
var last_card_used: int

# Signal to request actons from aux effs
signal question # Use is: "Action Name", activator's id, activator's unique id, "Specification (if necessary)"

# Init aux_effs
func initialize(aux_effs_ref):
	game_manager = $"../../.."
	aux_effs = aux_effs_ref
	last_card_used = -255

#########
# Targets
#########

# Extrapolates how many targets are required
func get_target(activator_id: int, card_id: int, available_targets: Array) -> Array:
	var target_ids: Array
	match card_id:
		# Single target
		FU,BONK,RNGALLOWS,YING,YANG,BACKPOCKET_PAIN,YEET,X_FACTOR,SWITCH,TOPSY_TURVY,KEBAB,SAUCE,BREAD,INDECLINABLE_OFFER: target_ids = yield(get_target_aux(activator_id,available_targets,0),"completed")
		# Two targets
		JUDGE,ITS_TIME_TO_STOP: target_ids = yield(get_target_aux(activator_id,available_targets,2),"completed")
		# Mirror Card replicates the last card used
		MIRROR_CARD: target_ids = yield(get_target(activator_id,last_card_used,available_targets),"completed")
		# Dual Chance may or may not have a target
		DUAL_CHANCE:
			# Eff Choice
			var chosen_value: int
			if not available_targets.empty():
				emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), ["+5","-5"])
				chosen_value = yield(aux_effs,"answer")
			else: chosen_value = 1
			# Get targets
			if chosen_value==1:
				target_ids = [activator_id]
				yield(get_tree(),"idle_frame")
			else:
				target_ids = yield(get_target_aux(activator_id,available_targets,0),"completed")
		# Doesn't target anybody
		_:
			target_ids = available_targets
			yield(get_tree(),"idle_frame")
	return target_ids

# Get target(s)
# NOTE: 'how_many' is 0 for single targets, 2 for two targets
func get_target_aux(activator_id: int, available_targets: Array, how_many: int) -> Array:
	# Get
	emit_signal("question", "target", PlayersList.get_player_unique_id(activator_id), [how_many,available_targets])
	var target_ids: Array = []
	if how_many==0: target_ids.append(yield(aux_effs,"answer"))
	else: target_ids.append_array(yield(aux_effs,"answer"))
	# Give
	for target_id in target_ids: game_manager.playerManager.target(target_id)
	yield(get_tree().create_timer(1.5),"timeout")
	return target_ids

#########
# Effects
#########

# Finds and uses the logic behind a card's effect
func get_effect(activator_id: int, card_id: int, targets: Array):
	match card_id:
		# 0-9
		FU: FU_Met(activator_id,targets)
		GRAVEDIGGER: Gravedigger(activator_id)
		GRAVEROBBER: Graverobber(activator_id,targets)
		TORNADO: Tornado(activator_id,targets)
		BONK: BONK_Met(activator_id,targets)
		CARDMAGEDDON: Cardmageddon(activator_id,targets)
		RNGALLOWS: RNGAllows(activator_id,targets)
		YING: Ying_or_Yang(activator_id,targets)
		YANG: Ying_or_Yang(activator_id,targets)
		JUDGE: Judge(activator_id,targets)
		# 10-19
		HEART_OF_THE_CARDS: Heart_of_the_Cards(activator_id)
		KOBE: Kobe(activator_id)
		DOUBLE_UP: Double_Up(activator_id)
		TRIPLE_IT: Triple_It(activator_id)
		QUICK_MATHS: Quick_Maths(activator_id)
		THE_MAGICIAN: The_Magician(activator_id,targets)
		DICE_TAX: Dice_Tax(activator_id,targets)
		JAILBREAK: Jailbreak(activator_id,targets)
		DUAL_CHANCE: Dual_Chance(activator_id,targets)
		MALUS: Malus(activator_id,targets)
		# 20-29
		BACKPOCKET_PAIN: Backpocket_Pain(activator_id,targets)
		YEET: Yeet(activator_id,targets)
		RULES_OF_NATURE: Rules_of_Nature(activator_id,targets)
		ITS_TIME_TO_STOP: Its_Time_to_Stop(activator_id,targets)
		CROUPIER: Croupier(activator_id)
		PARKING_METER: Parking_Meter(activator_id)
		MINEFIELD: Minefield(activator_id)
		MAKE_IT_RAIN: Make_it_Rain(activator_id)
		MOMS_CREDIT_CARD: Moms_Credit_Card(activator_id)
		X_FACTOR: X_Factor(activator_id,targets)
		# 30-39
		SWITCH: Switch(activator_id,targets)
		TOPSY_TURVY: Topsy_Turvy(activator_id,targets)
		UNAWARENESS: Unawareness(activator_id)
		TABULA_RASA: Tabula_Rasa(activator_id,targets)
		MIRROR_CARD: Mirror_Card(activator_id,targets)
		KEBAB: Kebab_Sauce_or_Bread(activator_id,targets)
		SAUCE: Kebab_Sauce_or_Bread(activator_id,targets)
		BREAD: Kebab_Sauce_or_Bread(activator_id,targets)
		NO_U,ROULETTE:
			print("!!! A reaction somehow passed? !!!")
			enable_roll_button(activator_id)
		# 40-49
		INSTANT_KARMA,OBJECTION,IMMUNITY,IMMUNITY_2,BREAK_IN_BLACK,GIMME_THAT,EXEMPTION:
			print("!!! A reaction somehow passed? !!!")
			enable_roll_button(activator_id)
		ROCK_SOLID: Rock_Solid(activator_id)
		INDECLINABLE_OFFER: Indeclinable_Offer(activator_id,targets)
		CONTROLLED_BURN: Controlled_Burn(activator_id,targets)
		# Combos
		YING_AND_YANG: Ying_and_Yang(activator_id,targets)
		DONER_DELIGHT: Doner_Delight(activator_id)
		# Error
		_:
			print("!!! Red Card Effect not recognized !!!")
			enable_roll_button(activator_id)
	# To duplicate an effect with Mirror Card
	if card_id!=MIRROR_CARD: last_card_used = card_id

#####
# 0-9

# 0
func FU_Met(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# Eff
	UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),1) # Update Stats
	yield(game_manager.teleport_player(1,target_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,target_id),"completed")

# 1
func Gravedigger(activator_id: int):
	# Eff
	emit_signal("question", "card_selection", PlayersList.get_player_unique_id(activator_id), [[false,false], game_manager.cardManager.red_deck.get_cards_in_pile()])
	var chosen_card_index = yield(aux_effs,"answer")
	yield(game_manager.retrieve_card(activator_id,chosen_card_index),"completed")
	#yield(game_manager.cardManager.red_deck.retrieve_card(activator_id,chosen_card_index),"completed")
	# End
	game_manager.end_turn(activator_id)

# 2
func Graverobber(activator_id: int, targets: Array):
	# Card select
	emit_signal("question", "card_selection", PlayersList.get_player_unique_id(activator_id), [[false,false], game_manager.cardManager.black_deck.get_cards_in_pile()])
	var chosen_card_index = yield(aux_effs,"answer")
	# Target select
	emit_signal("question", "target", PlayersList.get_player_unique_id(activator_id), [0,targets])
	var target_id = yield(aux_effs,"answer")
	# Shake
	shake([target_id])
	# Activate card as if the target drew it
	# The activator starts a chain with their next_tile_eff set to a non-existant type
	# This way it executes no effect and awaits for the black card's chain to end
	game_manager.next_tile_eff[activator_id] = -2
	resolve_chain_reaction(activator_id,activator_id)
	yield(game_manager.reuse_black_card(activator_id,target_id,chosen_card_index),"completed")
	#yield(game_manager.cardManager.black_deck.retrieve_card(target_id,chosen_card_index),"completed")
	# No need for end, the chain started by the black card will do it instead

# 3
func Tornado(activator_id: int, targets: Array):
	# Prep
	var avg: int = 0
	for id in targets: avg += game_manager.playerManager.get_player_tile(id)
	avg /= targets.size()
	shake(targets)
	# Eff no tile effs
	for target_id in targets:
		UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),avg) # Update Stats
		yield(game_manager.teleport_player(avg,target_id,false),"completed")
	# Tile effs
	for target_id in targets: yield(resolve_chain_reaction(activator_id,target_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 4
func BONK_Met(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# Eff
	UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),22) # Update Stats
	yield(game_manager.teleport_player(22,target_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,target_id),"completed")

# 5
func Cardmageddon(activator_id: int, targets: Array):
	# UI appear
	var activator_unique_id = PlayersList.get_player_unique_id(activator_id)
	emit_signal("question", "roll_start", activator_unique_id, "1")
	var roll = yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	roll = yield(aux_effs,"answer")/2
	# UI disappear
	emit_signal("question", "roll_close", activator_unique_id, "X")
	yield(aux_effs,"answer")
	# Shake activator on a roll of 1 (failure)
	if roll==0: shake([activator_id])
	# Proceed otherwise
	else: for target_id in targets:
		# Shake target
		shake([target_id])
		# Discard loop
		for n in roll:
			emit_signal("question", "card_selection", PlayersList.get_player_unique_id(target_id), [[false,false], game_manager.cardManager.red_deck.get_player_cards(target_id)])
			var chosen_card_index = yield(aux_effs,"answer")
			yield(game_manager.discard_card(target_id,chosen_card_index),"completed")
			#yield(game_manager.cardManager.red_deck.discard_card(id,chosen_card_index),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 6
func RNGAllows(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# Target selects card
	emit_signal("question", "card_selection", PlayersList.get_player_unique_id(target_id), [[false,false], game_manager.cardManager.red_deck.get_player_cards(target_id)])
	var chosen_card_index = yield(aux_effs,"answer")
	# Discard card
	yield(game_manager.discard_card(target_id,chosen_card_index),"completed")
	#yield(game_manager.cardManager.red_deck.discard_card(target_id,chosen_card_index),"completed")
	# Draw Black + End
	game_manager.next_tile_eff[target_id] = 1
	yield(resolve_chain_reaction(activator_id,target_id),"completed")

# 7-8
func Ying_or_Yang(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# Activator randomly selects card
	emit_signal("question", "card_selection", PlayersList.get_player_unique_id(activator_id), [[false,true], game_manager.cardManager.red_deck.get_player_cards(target_id)])
	var chosen_card_index = yield(aux_effs,"answer")
	# Steal said card
	if chosen_card_index!=-1: UserStats.player_stole(activator_id) # Update Stats
	yield(game_manager.give_card(target_id,activator_id,chosen_card_index),"completed")
	#yield(game_manager.cardManager.red_deck.trade_card(target_id,activator_id,chosen_card_index),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 9
func Judge(activator_id: int, targets: Array):
	# Won't work if a target got exempted
	if targets.size()!=2:
		shake([activator_id])
		game_manager.action_log.add_line(tr("THE CARD IS NEGATED"))
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
	# Prep
	shake(targets)
	# Eff
	yield(game_manager.trade_hands(targets[0],targets[1]),"completed")
	#yield(game_manager.cardManager.red_deck.trade_hands(targets[0],targets[1]),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

#######
# 10-19

# 10
func Heart_of_the_Cards(activator_id: int):
	# Draw
	yield(game_manager.draw_red(activator_id),"completed")
	# Check to draw again
	var is_lowest: bool = true
	var activator_tile = game_manager.playerManager.get_player_tile(activator_id)
	for n in range(1,4):
		if is_lowest: is_lowest = activator_tile<=game_manager.playerManager.get_player_tile((activator_id+n)%4)
		else: break
	if is_lowest: yield(game_manager.draw_red(activator_id),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 11
func Kobe(activator_id: int):
	# Value select
	emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), "1_to_6")
	var chosen_value = yield(aux_effs,"answer")
	# Eff
	game_manager.rolled = true
	yield(game_manager.move_player(chosen_value,activator_id),"completed")
	# No need for an end, the movement acts as the movement roll

# 12
func Double_Up(activator_id: int):
	# Eff
	game_manager.playerManager.multiply_multiplier(activator_id,2)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 13
func Triple_It(activator_id: int):
	# Eff
	game_manager.playerManager.multiply_multiplier(activator_id,3)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 14
func Quick_Maths(activator_id: int):
	# Prep
	var stringed_activator_tile: String = str(game_manager.playerManager.get_player_tile(activator_id))
	var sum = 0
	for n in stringed_activator_tile.length(): sum+=int(stringed_activator_tile[n])
	# Eff
	yield(game_manager.move_player(sum,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 15
func The_Magician(activator_id: int, targets: Array):
	# Value select
	emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), "1_to_6")
	var chosen_value = yield(aux_effs,"answer")
	# UI appear
	emit_signal("question", "roll_start", PlayersList.get_player_unique_id(activator_id), str(targets.size()))
	yield(aux_effs,"answer")
	# Each target rolls
	var rolls: Array = []
	for id in targets:
		emit_signal("question", "roll_allow", PlayersList.get_player_unique_id(id), str(id))
		rolls.append(yield(aux_effs,"answer"))
	# Move accordingly
	for n in rolls.size():
		if rolls[n]==chosen_value:
			yield(game_manager.move_player(1,targets[n],false),"completed")
			game_manager.next_tile_eff[targets[n]] = -1
		else:
			yield(game_manager.move_player(2,activator_id,false),"completed")
			game_manager.next_tile_eff[activator_id] = -1
	# UI disappear
	emit_signal("question", "roll_close", PlayersList.get_player_unique_id(activator_id), "X")
	yield(aux_effs,"answer")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 16
func Dice_Tax(activator_id: int, targets: Array):
	# UI appear
	emit_signal("question", "roll_start", PlayersList.get_player_unique_id(activator_id), str(targets.size()))
	var roll = yield(aux_effs,"answer")
	# Each other player rolls
	var sum: int = 0
	for id in targets:
		emit_signal("question", "roll_allow", PlayersList.get_player_unique_id(id), str(id))
		roll = yield(aux_effs,"answer")
		sum+=roll
	# UI disappear
	emit_signal("question", "roll_close", PlayersList.get_player_unique_id(activator_id), "X")
	roll = yield(aux_effs,"answer")
	# Move
	yield(game_manager.move_player(sum,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 17
func Jailbreak(activator_id: int, targets: Array):
	# Prep
	for target_id in targets: game_manager.playerManager.remove_effect(target_id,4)
	var jailed: int = targets.size()
	targets.erase(activator_id)
	# Move
	for target_id in targets: yield(game_manager.move_player(2,target_id,false),"completed")
	yield(game_manager.move_player(3*jailed,activator_id,false),"completed")
	# End
	for target_id in targets: yield(resolve_chain_reaction(activator_id,target_id,false),"completed")
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 18
func Dual_Chance(activator_id: int, targets: Array):
	# Execute effect 1: U +5
	if targets[0]==activator_id:
		# Eff
		yield(game_manager.move_player(5,activator_id,false),"completed")
		# End
		yield(resolve_chain_reaction(activator_id,activator_id),"completed")
	# Execute effect 2: Else -5
	else:
		# Prep
		var target_id = targets[0]
		shake(targets)
		# Execute effect
		UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),game_manager.playerManager.get_player_tile(target_id)-5) # Update Stats
		yield(game_manager.move_player(-5,target_id,false),"completed")
		# End
		yield(resolve_chain_reaction(activator_id,target_id),"completed")

# 19
func Malus(activator_id: int, targets: Array):
	# Prep
	shake(targets)
	# Eff
	for id in targets: game_manager.add_effect(id,NEGATIVE_MOVEMENT,1)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

#######
# 20-29

# 20
func Backpocket_Pain(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# Eff
	game_manager.add_effect(target_id,HALVED_MOVEMENT,3)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 21
func Yeet(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# UI appear
	var target_unique_id: int = PlayersList.get_player_unique_id(target_id)
	emit_signal("question", "roll_start", target_unique_id, "4")
	var roll = yield(aux_effs,"answer")
	var evens: int = 0
	# Target roll 1
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	roll = yield(aux_effs,"answer")
	if roll%2==0: evens+=1
	# Target roll 2
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	roll = yield(aux_effs,"answer")
	if roll%2==0: evens+=1
	# Target roll 3
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	roll = yield(aux_effs,"answer")
	if roll%2==0: evens+=1
	# Target roll 4 if they can still save themselves
	if evens==1 or evens==2:
		emit_signal("question", "roll_allow", target_unique_id, str(target_id))
		roll = yield(aux_effs,"answer")
		if roll%2==0: evens+=1
	# UI disappear
	emit_signal("question", "roll_close", target_unique_id, "X")
	roll = yield(aux_effs,"answer")
	# Execute effect + End
	if evens!=2:
		UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),game_manager.playerManager.get_player_tile(target_id)-7) # Update Stats
		yield(game_manager.move_player(-7,target_id,false),"completed")
		yield(resolve_chain_reaction(activator_id,target_id),"completed")
	else:
		game_manager.action_log.add_line(tr("THE CARD IS NEGATED"))
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)

# 22
func Rules_of_Nature(activator_id: int, targets: Array):
	# Move no tile effs
	for target_id in targets:
		shake([target_id])
		UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),game_manager.playerManager.get_player_tile(target_id)-5) # Update Stats
		yield(game_manager.move_player(-5,target_id,false),"completed")
	# Tile effs but last
	var last_target_id: int = targets.pop_back()
	for target_id in targets: yield(resolve_chain_reaction(activator_id,target_id,false),"completed")
	# Last tile eff + End
	yield(resolve_chain_reaction(activator_id,last_target_id),"completed")

# 23
func Its_Time_to_Stop(activator_id: int, targets: Array):
	# Prep
	shake(targets)
	# Execute effect
	for target_id in targets: game_manager.add_effect(target_id,STOPPED,1)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 24
func Croupier(activator_id: int):
	# Eff
	game_manager.add_effect(activator_id,CROUPIER_EFF,1)
	# End
	enable_roll_button(activator_id)

# 25
func Parking_Meter(activator_id: int):
	# Eff
	emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), "board_number")
	var chosen_tile = yield(aux_effs,"answer")
	game_manager.add_card_tile(activator_id,chosen_tile,14)
	#game_manager.mapManager.add_card_tile(activator_id,chosen_tile,14)
	#game_manager.mapManager.add_card_tile(activator_id,chosen_tile+1,14)
	#game_manager.mapManager.add_card_tile(activator_id,chosen_tile-1,14)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 26
func Minefield(activator_id: int):
	# Eff
	emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), "board_number")
	var chosen_tile = yield(aux_effs,"answer")
	game_manager.add_card_tile(activator_id,chosen_tile,15)
	#game_manager.mapManager.add_card_tile(activator_id,chosen_tile,15)
	#game_manager.mapManager.add_card_tile(activator_id,chosen_tile+1,15)
	#game_manager.mapManager.add_card_tile(activator_id,chosen_tile-1,15)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 27
func Make_it_Rain(activator_id: int):
	# Discard 1
	var discarded_cards = 1
	# Discard 2/3?
	for n in 2:
		emit_signal("question", "card_selection", PlayersList.get_player_unique_id(activator_id), [[true,false], game_manager.cardManager.red_deck.get_player_cards(activator_id)])
		var chosen_card_index = yield(aux_effs,"answer")
		yield(game_manager.discard_card(activator_id,chosen_card_index),"completed")
		#yield(game_manager.cardManager.red_deck.discard_card(activator_id,chosen_card_index),"completed")
		if chosen_card_index==-1: break
		else: discarded_cards+=1
	# Move
	yield(game_manager.move_player(4*discarded_cards,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 28
func Moms_Credit_Card(activator_id: int):
	# Value select (can't go back less tiles than requested)
	var chosen_value = 1
	var player_tile = game_manager.playerManager.get_player_tile(activator_id)
	if player_tile>12:
		emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), ["-4","-8","-12"])
		chosen_value = yield(aux_effs,"answer")
	elif player_tile>8:
		emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), ["-4","-8"])
		chosen_value = yield(aux_effs,"answer")
	# Move
	yield(game_manager.move_player(-4*chosen_value,activator_id,false),"completed")
	# Draw
	# NOTE: There is a bug where, if a for cycle with a variable is used
	#       then the drawn card has their initial position set to offscreen
	#       until I understand why, or change the hand_card hover functions
	#       this will have to do
	yield(game_manager.draw_red(activator_id),"completed")
	if chosen_value>1: yield(game_manager.draw_red(activator_id),"completed")
	if chosen_value>2: yield(game_manager.draw_red(activator_id),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 29
func X_Factor(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	var adjacent_tiles_int = game_manager.mapManager.get_adjacent_tiles(game_manager.playerManager.get_player_tile(target_id))
	var adjacent_tiles_str = []
	for tile in adjacent_tiles_int: adjacent_tiles_str.append(str(tile))
	# Adjacent tile select
	emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), adjacent_tiles_str)
	var chosen_tile = adjacent_tiles_int[yield(aux_effs,"answer")-1]
	# UI appear
	var target_unique_id: int = PlayersList.get_player_unique_id(target_id)
	emit_signal("question", "roll_start", target_unique_id, "4")
	var roll = yield(aux_effs,"answer")
	var evens: int = 0
	# Target roll 1
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	roll = yield(aux_effs,"answer")
	if roll%2==0: evens+=1
	# Target roll 2
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	roll = yield(aux_effs,"answer")
	if roll%2==0: evens+=1
	# Target roll 3
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	roll = yield(aux_effs,"answer")
	if roll%2==0: evens+=1
	# Target roll 4 if they can still save themselves
	if evens==1 or evens==2:
		emit_signal("question", "roll_allow", target_unique_id, str(target_id))
		roll = yield(aux_effs,"answer")
		if roll%2==0: evens+=1
	# UI disappear
	emit_signal("question", "roll_close", target_unique_id, "X")
	roll = yield(aux_effs,"answer")
	# Teleport + End
	if evens!=2:
		UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),chosen_tile) # Update Stats
		yield(game_manager.teleport_player(chosen_tile,target_id,false),"completed")
		yield(resolve_chain_reaction(activator_id,target_id),"completed")
	else:
		game_manager.action_log.add_line(tr("THE CARD IS NEGATED"))
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)

#######
# 30-39

# 30
func Switch(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# UI appear
	var target_unique_id: int = PlayersList.get_player_unique_id(target_id)
	emit_signal("question", "roll_start", target_unique_id, "3")
	yield(aux_effs,"answer")
	# Attack roll
	emit_signal("question", "roll_allow", PlayersList.get_player_unique_id(activator_id), str(activator_id))
	var attack_roll = yield(aux_effs,"answer")
	# Defense roll 1
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	var defense_roll = yield(aux_effs,"answer")
	# Defense roll 2 if necessary
	if defense_roll<attack_roll:
		emit_signal("question", "roll_allow", target_unique_id, str(target_id))
		defense_roll = yield(aux_effs,"answer")
	# UI disappear
	emit_signal("question", "roll_close", target_unique_id, "X")
	yield(aux_effs,"answer")
	# Execute effect + End
	if attack_roll>defense_roll:
		# Switch
		var activator_tile: int = game_manager.playerManager.get_player_tile(activator_id)
		var target_tile: int = game_manager.playerManager.get_player_tile(target_id)
		UserStats.player_moved_another_player(activator_id,target_tile,activator_tile) # Update Stats
		yield(game_manager.teleport_player(target_tile,activator_id,false),"completed")
		yield(game_manager.teleport_player(activator_tile,target_id,false),"completed")
		# End
		yield(resolve_chain_reaction(activator_id,target_id,false),"completed")
		yield(resolve_chain_reaction(activator_id,activator_id),"completed")
	else:
		game_manager.action_log.add_line(tr("THE CARD IS NEGATED"))
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)

# 31
func Topsy_Turvy(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# UI appear
	var target_unique_id: int = PlayersList.get_player_unique_id(target_id)
	emit_signal("question", "roll_start", target_unique_id, "4")
	var roll = yield(aux_effs,"answer")
	var evens: int = 0
	# Target roll 1
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	roll = yield(aux_effs,"answer")
	if roll%2==0: evens+=1
	# Target roll 2
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	roll = yield(aux_effs,"answer")
	if roll%2==0: evens+=1
	# Target roll 3
	emit_signal("question", "roll_allow", target_unique_id, str(target_id))
	roll = yield(aux_effs,"answer")
	if roll%2==0: evens+=1
	# Target roll 4 if they can still save themselves
	if evens==1 or evens==2:
		emit_signal("question", "roll_allow", target_unique_id, str(target_id))
		roll = yield(aux_effs,"answer")
		if roll%2==0: evens+=1
	# UI disappear
	emit_signal("question", "roll_close", target_unique_id, "X")
	roll = yield(aux_effs,"answer")
	# Execute effect + End
	if evens!=2: 
		var tile: int = game_manager.playerManager.get_player_tile(target_id)
		if tile>9:
			var units: int = tile%10
			# warning-ignore:integer_division
			var tens: int = (tile-units)/10
			tile = (units*10)+tens
		# End
		UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),tile) # Update Stats
		yield(game_manager.teleport_player(tile,target_id,false),"completed")
		yield(resolve_chain_reaction(activator_id,target_id),"completed")
	else:
		game_manager.action_log.add_line(tr("THE CARD IS NEGATED"))
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)

# 32
func Unawareness(activator_id: int):
	# Eff
	game_manager.add_effect(activator_id,RED_IMMUNITY,3)
	game_manager.add_effect(activator_id,CANT_PLAY_RED,3)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 33
func Tabula_Rasa(activator_id: int, targets: Array):
	# Eff
	for id in targets: game_manager.add_effect(id,VISIBLE_CARDS,2)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 34
func Mirror_Card(activator_id: int, targets: Array):
	get_effect(activator_id,last_card_used,targets)

# 35-36-37
func Kebab_Sauce_or_Bread(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# Draw Black + End
	game_manager.next_tile_eff[target_id] = 1
	yield(resolve_chain_reaction(activator_id,target_id),"completed")

# 38..46 are reactions

# 47
func Rock_Solid(activator_id: int):
	# Eff
	game_manager.add_effect(activator_id,BLACK_IMMUNITY,3)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 48
func Indeclinable_Offer(activator_id: int, targets: Array):
	# Prep
	var target_id = targets[0]
	shake(targets)
	# Value select
	emit_signal("question", "choice", PlayersList.get_player_unique_id(target_id), "1_to_6")
	var chosen_value = yield(aux_effs,"answer")
	# Move no effs
	UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),game_manager.playerManager.get_player_tile(target_id)+chosen_value) # Update Stats
	yield(game_manager.move_player(chosen_value,target_id,false),"completed")
	yield(game_manager.move_player(2*chosen_value,activator_id,false),"completed")
	# Tile effs + End
	yield(resolve_chain_reaction(activator_id,target_id,false),"completed")
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 49
func Controlled_Burn(activator_id: int, targets: Array):
	# Value select
	emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), "1_to_6")
	var chosen_value = yield(aux_effs,"answer")
	# Shake + Move no tile effs
	for target_id in targets:
		shake([target_id])
		UserStats.player_moved_another_player(activator_id,game_manager.playerManager.get_player_tile(target_id),game_manager.playerManager.get_player_tile(target_id)-chosen_value) # Update Stats
		yield(game_manager.move_player(-chosen_value,target_id,false),"completed")
	# Tile effs but last
	var last_target_id: int = targets.pop_back()
	for target_id in targets: yield(resolve_chain_reaction(activator_id,target_id,false),"completed")
	# Last tile eff + End
	yield(resolve_chain_reaction(activator_id,last_target_id),"completed")

########
# Combos

# Ying+Yang
func Ying_and_Yang(activator_id: int, targets: Array):
	# Log
	$"../../..".play_combo(activator_id)
	# Steal loop
	for target_id in targets:
		# Make sure the activator hasn't reached the hand limit
		if get_parent().get_player_card_number(activator_id)>6: break
		# Shake
		game_manager.playerManager.shake(target_id)
		# Activator random card select
		emit_signal("question", "card_selection", PlayersList.get_player_unique_id(activator_id), [[false,true], game_manager.cardManager.red_deck.get_player_cards(target_id)])
		var chosen_card_index = yield(aux_effs,"answer")
		# Steal said card
		if chosen_card_index!=-1: UserStats.player_stole(activator_id) # Update Stats
		yield(game_manager.give_card(target_id,activator_id,chosen_card_index),"completed")
		#yield(game_manager.cardManager.red_deck.trade_card(id,activator_id,chosen_card_index),"completed")
	# End
	enable_roll_button(activator_id)

# Kebab+Sauce+Bread
func Doner_Delight(activator_id: int):
	# Log
	$"../../..".play_combo(activator_id)
	# Eff
	yield(game_manager.teleport_player(58,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

#################
# Other functions
#################

# Shake each targets' dashboard
func shake(targets: Array): for id in targets: game_manager.playerManager.shake(id)

# Resolves tile effs on the target
# Returns control to activator if they have yet to roll and is_final
func resolve_chain_reaction(activator_id: int, target_id: int, is_final: bool = true):
	# Prep
	var my_chain_number: int = game_manager.chain_number
	game_manager.chain_number+=1
	# Exec
	if game_manager.next_tile_eff[target_id]!=-1:
		game_manager.exec_tile_eff(game_manager.next_tile_eff[target_id],target_id)
		game_manager.next_tile_eff[target_id] = -1
	else: game_manager.chain_number-=1
	# End
	while game_manager.chain_number!=my_chain_number: yield(get_tree().create_timer(.2),"timeout")
	if my_chain_number>0: game_manager.chain_number-=1
	elif is_final: end_chain(activator_id)
	yield(get_tree(),"idle_frame")

# Aux to re-enable activator's roll button
func end_chain(activator_id: int):
	if game_manager.bot_card_is_in_play: # Special check in this version of end_chain to allow bots to play cards
		game_manager.bot_card_is_in_play=false
	elif game_manager.rolled:
		game_manager.end_turn(activator_id)
	else:
		# Ended up in prison?
		if game_manager.playerManager.has_to_serve_turns(activator_id) and game_manager.mapManager.is_prison(game_manager.playerManager.get_player_tile(activator_id)):
			game_manager.switch_dice()
		# Was in prison but now isn't
		elif game_manager.escape_button.visible==true:
			yield(game_manager.switch_dice(false),"completed")
		# Button fix for curr
		enable_roll_button(activator_id)

# Aux to re-enable activator's roll button
func enable_roll_button(activator_id: int):
	if PlayersList.get_my_unique_id()==PlayersList.get_player_unique_id(activator_id):
		game_manager.roll_button.disable_color(false)
		game_manager.enable_button()
		# Check for croupier
		if game_manager.playerManager.get_player(activator_id).hasCroupier: game_manager.play_area.show()
	# Check if bot
	elif PlayersList.is_bot(activator_id):
		yield(get_tree().create_timer(1),"timeout")
		#game_manager.bot_allowed_to_play = true
		game_manager.bot_turn()
