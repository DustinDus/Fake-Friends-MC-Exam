extends Node2D
# Reads card names and activates the corresponding effect

# IDs mapped to Card Names
enum {DICE_TOSS,JACKPOT,FULLHOUSE,GRAVETENDER,BANKRUPT
	  PRANKZ_GONE_WRONG,ALMS_DE_RIGUEUR,WHAT_A_HORRIBLE_NIGHT,SWITCHER_DOO,SWITCHER_DEE
	  STRAY_SHOT,HIGH_STAKES}
# Player effects
enum {VISIBLE_CARDS,RED_IMMUNITY,BLACK_IMMUNITY,STOPPED,IMPRISONED
	  CROUPIER,NEGATIVE_MOVEMENT,HALVED_MOVEMENT}

# To extrapolate data
var game_manager: Node2D
# Aux for effects
var aux_effs

# Signal to request actons from aux effs
signal question

# Init aux_effs
func initialize(aux_effs_ref):
	game_manager = $"../../.."
	aux_effs = aux_effs_ref


func get_effect(activator_id: int, card_id: int):
	match card_id:
		# 0-9
		DICE_TOSS: Dice_Toss(activator_id)
		JACKPOT: Jackpot(activator_id)
		FULLHOUSE: Fullhouse(activator_id)
		GRAVETENDER: Gravetender(activator_id)
		BANKRUPT: Bankrupt(activator_id)
		PRANKZ_GONE_WRONG: Prankz_Gone_Wrong(activator_id)
		ALMS_DE_RIGUEUR: Alms_de_Rigueur(activator_id)
		WHAT_A_HORRIBLE_NIGHT: What_a_Horrible_Night(activator_id)
		SWITCHER_DOO: switcher(activator_id,1)
		SWITCHER_DEE: switcher(activator_id,-1)
		# 10-11
		STRAY_SHOT: Stray_Shot(activator_id)
		HIGH_STAKES : High_Stakes(activator_id)
		# Error
		_:
			game_manager.end_turn(activator_id)
			print("!!! Orange Card Effect not recognized !!!")

#########
# Effects
#########

#####
# 0-9

# 0
func Dice_Toss(activator_id: int):
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
	# Execute effect
	yield(game_manager.move_player(roll,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 1
func Jackpot(activator_id: int):
	for n in 3: yield(game_manager.draw_red(activator_id),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 2
func Fullhouse(activator_id: int):
	# You draw
	yield(game_manager.draw_red(activator_id),"completed")
	# Everyone else discards
	var target_id
	for n in range(1,4):
		target_id = (activator_id+n)%4
		# Shake
		shake([target_id])
		# Discard
		emit_signal("question", "card_selection", PlayersList.get_player_unique_id(target_id), [[false,false], game_manager.cardManager.red_deck.get_player_cards(target_id)])
		var chosen_card_index = yield(aux_effs,"answer")
		yield(game_manager.discard_card(target_id,chosen_card_index),"completed")
		#yield(game_manager.cardManager.red_deck.discard_card(target_id,chosen_card_index),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 3
func Gravetender(activator_id: int):
	emit_signal("question", "card_selection", PlayersList.get_player_unique_id(activator_id), [[false,false], game_manager.cardManager.red_deck.get_cards_in_pile()])
	var chosen_card_index = yield(aux_effs,"answer")
	yield(game_manager.retrieve_card(activator_id,chosen_card_index),"completed")
	#yield(game_manager.cardManager.red_deck.retrieve_card(activator_id,chosen_card_id),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 4
func Bankrupt(activator_id: int):
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
	yield(game_manager.move_player(-roll,activator_id,false),"completed")
	var tile = game_manager.playerManager.get_player_tile(activator_id)
	var units: int = tile%10
	# warning-ignore:integer_division
	var tens: int = (tile-units)/10
	tile = units+tens
	# Shake
	shake([activator_id])
	# Teleport
	yield(game_manager.teleport_player(tile,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 5
func Prankz_Gone_Wrong(activator_id: int):
	# Shake
	shake([activator_id])
	# Discsrd loop
	for n in game_manager.cardManager.red_deck.get_player_card_number(activator_id):
		yield(game_manager.discard_card(activator_id,0),"completed")
		#yield(game_manager.cardManager.red_deck.discard_card(activator_id,0),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 6
func Alms_de_Rigueur(activator_id: int):
	# Shake
	shake([activator_id])
	# Give loop
	var taker_id
	var chosen_card_index
	var max_range = game_manager.cardManager.red_deck.get_player_card_number(activator_id)
	if max_range>3: max_range = 3
	for n in range(1,max_range+1):
		taker_id = (activator_id+n)%4
		# Give a card to taker
		emit_signal("question", "card_selection", PlayersList.get_player_unique_id(activator_id), [[false,false], game_manager.cardManager.red_deck.get_player_cards(activator_id)])
		chosen_card_index = yield(aux_effs,"answer")
		yield(game_manager.give_card(activator_id,taker_id,chosen_card_index),"completed")
		#yield(game_manager.cardManager.red_deck.trade_card(activator_id,taker_id,chosen_card_index),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 7
func What_a_Horrible_Night(activator_id: int):
	# Shake
	shake([activator_id])
	# Eff
	game_manager.add_effect(activator_id,STOPPED,3)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

# 8-9
func switcher(activator_id: int, v: int):
	# Get target id
	var trader_id = (activator_id+v*game_manager.playerManager.turnOrder)%4
	if trader_id<0: trader_id = 3
	# Shake
	shake([activator_id,trader_id])
	# Swap hands
	yield(game_manager.trade_hands(activator_id,trader_id),"completed")
	#yield(game_manager.cardManager.red_deck.trade_hands(activator_id,trader_id),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(activator_id)

#######
# 10-11

# 10
func Stray_Shot(activator_id: int):
	# Wait for roll UI to appear
	var activator_unique_id = PlayersList.get_player_unique_id(activator_id)
	emit_signal("question", "roll_start", activator_unique_id, "2")
	yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	var tens = yield(aux_effs,"answer")
	# Roll
	emit_signal("question", "roll_allow", activator_unique_id, "-1")
	var units = yield(aux_effs,"answer")
	# Wait for roll UI to disappear
	emit_signal("question", "roll_close", activator_unique_id, "X")
	yield(aux_effs,"answer")
	# Execute effect
	yield(game_manager.teleport_player((tens*10)+units,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(activator_id,activator_id),"completed")

# 11
func High_Stakes(activator_id: int):
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
	else:
		# Shake
		shake([activator_id])
		# Teleport
		yield(game_manager.teleport_player(1,activator_id,false),"completed")
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
