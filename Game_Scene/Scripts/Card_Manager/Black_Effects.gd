extends Node2D
# Reads card names and activates the corresponding effect

# To extrapolate data
var game_manager: Node2D
# Aux for effects
var aux_effs

# IDs mapped to Card Names
enum {PLUS_1A,PLUS_1B,MINUS_1A,MINUS_1B,PLUS_2A
	  PLUS_2B,MINUS_2A,MINUS_2B,PLUS_3A,PLUS_3B
	  MINUS_3A,MINUS_3B,PLUS_4A,PLUS_4B,MINUS_4A
	  MINUS_4B,PLUS_5A,PLUS_5B,MINUS_5A,MINUS_5B
	  PLUS_6,MINUS_6,ILL_FATE,REVERSAL,REVERSAL_2
	  SWAPAIN,SWAPLEASURE,PRANKZ,PRANKZ_2,MISFORTUNE
	  BACK_TO_THE_STORE,RECONCILIATION,DOUBLE_OR_NOTHING,ALL_OR_NOTHING,A_BAD_DAY
	  WHAT_A_TERRIBLE_DAY,A_GOOD_DAY,LAG,SIKE,SCRIPTED_MATCH
	  SHOTS_FIRED,GIRL_ON_FIRE,RESET,THIS_IS_A_FINE,MEMZ,
	  GO_TO_JAIL,ITS_ALL_OVER,PAINFUL_SACRIFICE,ON_THE_LOOSE,GONNA_GET_YA}
# Player effects
enum {VISIBLE_CARDS,RED_IMMUNITY,BLACK_IMMUNITY,STOPPED,IMPRISONED
	  CROUPIER,NEGATIVE_MOVEMENT,HALVED_MOVEMENT}

# Signal to request actons from aux effs
signal question

# Init aux_effs
func initialize(aux_effs_ref):
	game_manager = $"../../.."
	aux_effs = aux_effs_ref

# Finds and uses the logic behind a card's effect
func get_effect(activator_id: int, card_id: int, targets: Array):
	match card_id:
		# 0-9
		PLUS_1A: move_player(activator_id,+1,targets)
		PLUS_1B: move_player(activator_id,+1,targets)
		MINUS_1A: move_player(activator_id,-1,targets)
		MINUS_1B: move_player(activator_id,-1,targets)
		PLUS_2A: move_player(activator_id,+2,targets)
		PLUS_2B: move_player(activator_id,+2,targets)
		MINUS_2A: move_player(activator_id,-2,targets)
		MINUS_2B: move_player(activator_id,-2,targets)
		PLUS_3A: move_player(activator_id,+3,targets)
		PLUS_3B: move_player(activator_id,+3,targets)
		# 10-19
		MINUS_3A: move_player(activator_id,-3,targets)
		MINUS_3B: move_player(activator_id,-3,targets)
		PLUS_4A: move_player(activator_id,+4,targets)
		PLUS_4B: move_player(activator_id,+4,targets)
		MINUS_4A: move_player(activator_id,-4,targets)
		MINUS_4B: move_player(activator_id,-4,targets)
		PLUS_5A: move_player(activator_id,+5,targets)
		PLUS_5B: move_player(activator_id,+5,targets)
		MINUS_5A: move_player(activator_id,-5,targets)
		MINUS_5B: move_player(activator_id,-5,targets)
		# 20-29
		PLUS_6: move_player(activator_id,+6,targets)
		MINUS_6: move_player(activator_id,-6,targets)
		ILL_FATE: Ill_Fate(activator_id,targets)
		REVERSAL: reversal(activator_id)
		REVERSAL_2: reversal(activator_id)
		SWAPAIN: swap(activator_id,targets)
		SWAPLEASURE: swap(activator_id,targets)
		PRANKZ: discard(activator_id,targets,1)
		PRANKZ_2: discard(activator_id,targets,1)
		MISFORTUNE: discard(activator_id,targets,2)
		# 30-39
		BACK_TO_THE_STORE: Back_to_the_Store(activator_id,targets)
		RECONCILIATION: Reconciliation(activator_id,targets)
		DOUBLE_OR_NOTHING: Double_Or_Nothing(activator_id,targets)
		ALL_OR_NOTHING: All_Or_Nothing(activator_id,targets)
		A_BAD_DAY: A_Bad_Day(1,activator_id,targets)
		WHAT_A_TERRIBLE_DAY: A_Bad_Day(2,activator_id,targets)
		A_GOOD_DAY: A_Good_Day(activator_id,targets)
		LAG: LAG_Met(activator_id,targets)
		SIKE: SIKE_Met(1,activator_id,targets)
		SCRIPTED_MATCH: SIKE_Met(3,activator_id,targets)
		# 40-49
		SHOTS_FIRED: Shots_Fired(activator_id,targets)
		GIRL_ON_FIRE: This_Girl_is_on_Fire(activator_id,targets)
		RESET: Reset(activator_id,targets)
		THIS_IS_A_FINE: This_is_a_Fine(game_manager.cardManager.red_deck.player_hands[activator_id].size(),activator_id,targets)
		MEMZ: MEMZ_Met(activator_id,targets)
		GO_TO_JAIL: Go_to_Jail(activator_id,targets)
		ITS_ALL_OVER: Its_All_Over(activator_id,targets)
		PAINFUL_SACRIFICE: Painful_Sacrifice(activator_id,targets)
		ON_THE_LOOSE: On_The_Loose(activator_id)
		GONNA_GET_YA: Gonna_Get_Ya(activator_id)
		# Error
		_:
			game_manager.end_turn(activator_id)
			print("!!! Black Card Effect not recognized !!!")

#########
# Effects
#########

######
# 0-29

# 0-21
func move_player(activator_id: int, v: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Move player
	yield(game_manager.move_player(v,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 22
func Ill_Fate(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Wait for roll UI to appear
	var activator_unique_id = PlayersList.get_player_unique_id(activator_id)
	emit_signal("question", "roll_start", activator_unique_id, "1")
	var roll = yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	roll = yield(aux_effs,"answer")
	# Wait for roll UI to disappear
	emit_signal("question", "roll_close", activator_unique_id, "X")
	yield(aux_effs,"answer")
	# Move player
	yield(game_manager.move_player(-roll,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 23-24
func reversal(activator_id: int):
	game_manager.playerManager.turnOrder*=-1
	# Log
	game_manager.action_log.add_line(tr("THE TURN ORDER IS REVERSED"))
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 25-26
func swap(activator_id: int, targets: Array):
	# If activator is unaffected
	if targets.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Wait for roll UI to appear
	var activator_unique_id = PlayersList.get_player_unique_id(activator_id)
	emit_signal("question", "roll_start", activator_unique_id, "1")
	var roll = yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	roll = yield(aux_effs,"answer")
	# Wait for roll UI to disappear
	emit_signal("question", "roll_close", activator_unique_id, "X")
	yield(aux_effs,"answer")
	# Get target
	var turn_order: int = game_manager.playerManager.turnOrder
	var target_number: int = targets.size()
	while roll>target_number: roll-=target_number
	var target_id: int
	if turn_order==-1: targets.invert()
	target_id = targets[roll-1]
	# Shake
	shake([activator_id,target_id])
	# Activator trades hand with target
	yield(game_manager.trade_hands(activator_id,target_id),"completed")
	#yield(game_manager.cardManager.red_deck.trade_hands(activator_id,target_id),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 27-28-29
func discard(activator_id: int, target: Array, card_number: int):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Discard loop
	for n in card_number:
		# Wait for activator to choose card to discard
		emit_signal("question", "card_selection", PlayersList.get_player_unique_id(activator_id), [[false,false], game_manager.cardManager.red_deck.get_player_cards(activator_id)])
		var chosen_card_index = yield(aux_effs,"answer")
		yield(game_manager.discard_card(activator_id,chosen_card_index),"completed")
		#yield(game_manager.cardManager.red_deck.discard_card(activator_id,chosen_card_index),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

#######
# 30-39
#######

# 30
func Back_to_the_Store(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Teleport player
	yield(game_manager.teleport_player(game_manager.playerManager.get_player_previous_tile(activator_id),activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 31
func Reconciliation(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Draw
	yield(game_manager.draw_red(activator_id),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 32
func Double_Or_Nothing(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Wait for a value to be chosen
	emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), ["Negate","x2 or x0"])
	var chosen_value = yield(aux_effs,"answer")
	# Execute effect 1: Negate
	if chosen_value==1:
		# Log
		game_manager.action_log.add_line(tr("THE CARD IS NEGATED"))
		# End
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
	# Execute effect 2: Roll
	else:
		# Wait for roll UI to appear
		emit_signal("question", "roll_start", PlayersList.get_player_unique_id(activator_id), "1")
		yield(aux_effs,"answer")
		# Roll
		emit_signal("question", "roll_allow", PlayersList.get_player_unique_id(activator_id), "-1")
		var roll = yield(aux_effs,"answer")
		# Wait for roll UI to disappear
		emit_signal("question", "roll_close", PlayersList.get_player_unique_id(activator_id), "X")
		yield(aux_effs,"answer")
		# Even
		if roll%2==0: yield(game_manager.move_player(game_manager.playerManager.get_player(activator_id).movement_roll_this_turn,activator_id,false),"completed")
		# Odd
		else: yield(game_manager.move_player(-game_manager.playerManager.get_player(activator_id).movement_roll_this_turn,activator_id,false),"completed")
		# End
		yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 33
func All_Or_Nothing(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Wait for a value to be chosen
	emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), ["Skip2Turns","x5 or BackToStart"])
	var chosen_value = yield(aux_effs,"answer")
	# Execute effect 1: Negate
	if chosen_value==1:
		game_manager.add_effect(activator_id,STOPPED,2)
		# End
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
	# Execute effect 2: Roll
	else:
		# Wait for roll UI to appear
		emit_signal("question", "roll_start", PlayersList.get_player_unique_id(activator_id), "1")
		yield(aux_effs,"answer")
		# Roll
		emit_signal("question", "roll_allow", PlayersList.get_player_unique_id(activator_id), "-1")
		var roll = yield(aux_effs,"answer")
		# Wait for roll UI to disappear
		emit_signal("question", "roll_close", PlayersList.get_player_unique_id(activator_id), "X")
		yield(aux_effs,"answer")
		# Even
		if roll%2==0: yield(game_manager.move_player(5*game_manager.playerManager.get_player(activator_id).movement_roll_this_turn,activator_id,false),"completed")
		# Odd
		else: yield(game_manager.teleport_player(1,activator_id,false),"completed")
		# End
		yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 34-35
func A_Bad_Day(v: int, activator_id: int, target: Array): # also What_a_Terrible_Day
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Effect
	game_manager.add_effect(activator_id,STOPPED,v)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 36
func A_Good_Day(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Wait for roll UI to appear
	var activator_unique_id = PlayersList.get_player_unique_id(activator_id)
	emit_signal("question", "roll_start", activator_unique_id, "1")
	var roll = yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	roll = yield(aux_effs,"answer")
	# Wait for roll UI to disappear
	emit_signal("question", "roll_close", activator_unique_id, "X")
	yield(aux_effs,"answer")
	# Execute effect
	yield(game_manager.move_player(roll,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 37
func LAG_Met(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Wait for roll UI to appear
	var activator_unique_id = PlayersList.get_player_unique_id(activator_id)
	emit_signal("question", "roll_start", activator_unique_id, "1")
	var roll = yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	roll = yield(aux_effs,"answer")
	# Wait for roll UI to disappear
	emit_signal("question", "roll_close", activator_unique_id, "X")
	yield(aux_effs,"answer")
	# Shake
	shake(target)
	# Execute effect
	game_manager.add_effect(activator_id,STOPPED,roll/2)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 38-39
func SIKE_Met(v: int, activator_id: int, target: Array): # also Scripted Match
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Effect
	var target_tile = game_manager.playerManager.get_player_tile(activator_id)
	for n in v:
		#if target_tile<12:
		#	target_tile = 4
		#	break
		target_tile = game_manager.mapManager.find_previous_type_specific_tile(target_tile,1)
	yield(game_manager.teleport_player(target_tile,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

#######
# 40-49

# 40
func Shots_Fired(activator_id: int, targets: Array):
	# If activator is unaffected
	if targets.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Wait for a target to be selected
	emit_signal("question", "target", PlayersList.get_player_unique_id(activator_id), [0,targets])
	var target_id = yield(aux_effs,"answer")
	# Target Animation
	game_manager.playerManager.target(target_id)
	yield(get_tree().create_timer(1.5),"timeout")
	# Wait for roll UI to appear
	var activator_unique_id = PlayersList.get_player_unique_id(activator_id)
	emit_signal("question", "roll_start", activator_unique_id, "1")
	var roll = yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	roll = yield(aux_effs,"answer")
	# Wait for roll UI to disappear
	emit_signal("question", "roll_close", activator_unique_id, "X")
	yield(aux_effs,"answer")
	# Shake
	shake([activator_id,target_id])
	# Move players
	yield(game_manager.move_player(roll,activator_id,false),"completed")
	yield(game_manager.move_player(-roll,target_id,false),"completed")
	# Resolve
	yield(resolve_chain_reaction(activator_id,activator_id,false),"completed")
	yield(resolve_chain_reaction(activator_id,target_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 41
func This_Girl_is_on_Fire(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Wait for roll UI to appear
	var activator_unique_id = PlayersList.get_player_unique_id(activator_id)
	emit_signal("question", "roll_start", activator_unique_id, "3")
	var roll = yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	roll += yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	roll += yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	roll += yield(aux_effs,"answer")
	# Wait for roll UI to disappear
	emit_signal("question", "roll_close", activator_unique_id, "X")
	yield(aux_effs,"answer")
	# Effect
	yield(game_manager.move_player(roll,activator_id,false),"completed")
	game_manager.next_tile_eff[activator_id] = -1
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 42
func Reset(activator_id: int, targets: Array):
	# If there are no targets
	if targets.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(targets)
	# Remember each player's card number
	var hand_sizes: Array = []
	for id in targets: hand_sizes.append(game_manager.cardManager.red_deck.get_player_card_number(id))
	# Shuffle everyones's hands starting from activator
	for id in targets: 
		yield(game_manager.shuffle_hand(id),"completed")
		#yield(game_manager.cardManager.red_deck.shuffle_hand(id),"completed")
	game_manager.cardManager.red_deck.cards_in_deck.shuffle()
	# Everyone draws as many cards as they had
	for n in targets.size():
		for m in hand_sizes[n]:
			yield(game_manager.draw_red(targets[n]),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 43 !!! !!!
func This_is_a_Fine(v: int, activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	
	# New effect
	# Shake
	shake(target)
	# Move player
	yield(game_manager.move_player(-4*v,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")
	
	# !!! Original effect removed as it breaks the game when drawing into itself !!!
	# Shake
	#shake(target)
	# Start Prep
	#var activator_black_cards_activated = game_manager.black_cards_activated[activator_id]
	#var activator_initial_tile = game_manager.playerManager.get_player_tile(activator_id)
	#game_manager.black_cards_activated[activator_id] = -7
	#game_manager.block_tiles = true
	# Draw + Activate loop
	#for n in v:
	#	game_manager.next_tile_eff[activator_id] = 1
	#	yield(resolve_chain_reaction(activator_id,activator_id,false),"completed")
	# End Prep
	#game_manager.block_tiles = false
	#game_manager.black_cards_activated[activator_id] = activator_black_cards_activated
	#var activator_final_tile = game_manager.playerManager.get_player_tile(activator_id)
	# End
	#if activator_final_tile!=activator_initial_tile:
	#	game_manager.next_tile_eff[activator_id] = game_manager.get_tile_eff(activator_final_tile,activator_id)
	#	yield(resolve_chain_reaction(activator_id,activator_id),"completed")
	#else:
	#	if game_manager.chain_number>0: game_manager.chain_number-=1
	#	else: end_chain(activator_id)

# 44
func MEMZ_Met(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Teleport
	yield(game_manager.teleport_player(21,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 45
func Go_to_Jail(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Teleport
	yield(game_manager.teleport_player(22,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 46
func Its_All_Over(activator_id: int, target: Array):
	# If activator is unaffected
	if target.empty():
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Shake
	shake(target)
	# Teleport
	yield(game_manager.teleport_player(game_manager.playerManager.get_player_tile(activator_id)/2,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 47
func Painful_Sacrifice(activator_id: int, targets: Array):
	# If activator is unaffected / there aren't enough targets
	if targets.size()<2:
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
		return
	# Setup
	var chosen_value
	# Player has card(s) in hand, they can choose an effect
	if game_manager.cardManager.red_deck.player_has_cards(activator_id):
		# Wait for a value to be chosen
		emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), ["U Discard Two -15","U -15 Two Discard"])
		chosen_value = yield(aux_effs,"answer")
	# Else they are forced to get effect 2
	else: chosen_value = 2
	# Choose targets
	emit_signal("question", "target", PlayersList.get_player_unique_id(activator_id), [2,targets])
	var target_ids = yield(aux_effs,"answer")
	# Execute effect 1: You discard, two others -15
	if chosen_value==1:
		# Shake 1
		shake([activator_id])
		# You discard all cards in hand
		for n in game_manager.cardManager.red_deck.get_player_card_number(activator_id):
			yield(game_manager.discard_card(activator_id,0),"completed")
			#yield(game_manager.cardManager.red_deck.discard_card(activator_id,0),"completed")
		# Shake 2
		shake([target_ids[0]])
		# A target goes -15
		yield(game_manager.move_player(-15,target_ids[0],false),"completed")
		# Shake 3
		shake([target_ids[1]])
		# The other target goes -15
		yield(game_manager.move_player(-15,target_ids[1],false),"completed")
		# Tile eff chains
		yield(resolve_chain_reaction(activator_id,target_ids[0],false),"completed")
		yield(resolve_chain_reaction(activator_id,target_ids[1],false),"completed")
		# End
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(activator_id)
	# Execute effect 2: You -15, two others discard
	else:
		# Shake 1
		shake([activator_id])
		# You go -15
		yield(game_manager.move_player(-15,activator_id,false),"completed")
		# Shake 2
		shake([target_ids[0]])
		# A target discards all cards in hand
		for n in game_manager.cardManager.red_deck.get_player_card_number(target_ids[0]):
			yield(game_manager.discard_card(target_ids[0],0),"completed")
			#yield(game_manager.cardManager.red_deck.discard_card(target_ids[0],0),"completed")
		# Shake 3
		shake([target_ids[1]])
		# The other target discards all cards in hand
		for n in game_manager.cardManager.red_deck.get_player_card_number(target_ids[1]):
			yield(game_manager.discard_card(target_ids[1],0),"completed")
			#yield(game_manager.cardManager.red_deck.discard_card(target_ids[1],0),"completed")
		# End
		yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 48
func On_The_Loose(activator_id):
	# Spawn the rabbit pawn
	yield(game_manager.playerManager.spawn_card_pawn(2),"completed")
	# Log
	game_manager.action_log.add_line(tr("A NEW PAWN HAS ENTERED THE BOARD"))
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 49
func Gonna_Get_Ya(activator_id):
	# Spawn the bull pawn
	yield(game_manager.playerManager.spawn_card_pawn(1),"completed")
	# Log
	game_manager.action_log.add_line(tr("A NEW PAWN HAS ENTERED THE BOARD"))
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

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
	if game_manager.rolled: game_manager.end_turn(activator_id)
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
		game_manager.bot_turn()
