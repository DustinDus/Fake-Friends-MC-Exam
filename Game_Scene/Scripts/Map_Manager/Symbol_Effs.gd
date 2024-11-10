extends Node2D
# Maps, identifies and manages tile effects

# Maps the effects to their tile's IDs
enum {WHITE_SPACE = -1, DRAW_RED, DRAW_BLACK, DRAW_ORANGE, VICTORY
	  PRISON, ROLL_AGAIN, BACK_TO_START, LOSE_A_TURN, EVEN_OR_ODD
	  PLUS_1, PLUS_5_OR_PLUS_6, GIFT_OR_PLUS_1, PLUS_4, PLUS_2
	  PARKING_METER, MINEFIELD}

# Aux for effects
var aux_effs

# Player effects
enum {VISIBLE_CARDS,RED_IMMUNITY,BLACK_IMMUNITY,STOPPED,IMPRISONED
	  CROUPIER,NEGATIVE_MOVEMENT,HALVED_MOVEMENT,CANT_PLAY_RED}

# Signal to request actons from aux effs
signal question

# Connect signals
func initialize():
	aux_effs = $"../../../Effects_UI"
	if connect("question",aux_effs,"_interpret_question")!=0:
		print("!!! Symbol_Effs can't connect a signal !!!")

# Match effects
func exec_tile_eff(type: int, activator_id: int, game_manager: Node2D):
	match type:
		# Colors
		WHITE_SPACE: tile_WHITE_SPACE(activator_id,game_manager)
		DRAW_RED: tile_DRAW_RED(activator_id,game_manager)
		DRAW_BLACK: tile_DRAW_BLACK(activator_id,game_manager)
		DRAW_ORANGE: tile_DRAW_ORANGE(activator_id,game_manager)
		# Basic
		VICTORY: tile_VICTORY(activator_id,game_manager)
		LOSE_A_TURN: tile_LOSE_A_TURN(activator_id,game_manager)
		BACK_TO_START: tile_BACK_TO_START(activator_id,game_manager)
		PRISON: tile_PRISON(activator_id,game_manager)
		PLUS_2: tile_MOVE(activator_id,2,game_manager)
		PLUS_4: tile_MOVE(activator_id,4,game_manager)
		# Complex
		PLUS_5_OR_PLUS_6: tile_PLUS_5_OR_PLUS_6(activator_id,game_manager)
		GIFT_OR_PLUS_1: tile_GIFT_OR_PLUS_1(activator_id,game_manager)
		ROLL_AGAIN: tile_ROLL_AGAIN(activator_id,game_manager)
		EVEN_OR_ODD: tile_EVEN_OR_ODD(activator_id,game_manager)
		# Card
		PARKING_METER: tile_PARKING_METER(activator_id,game_manager)
		MINEFIELD: tile_MINEFIELD(activator_id,game_manager)
		# Non-Existant
		-2: pass
		# Error
		_:
			print("UNEXPECTED TILE")
			game_manager.end_turn(activator_id)

#########
# Effects
#########

########
# Colors

func tile_WHITE_SPACE(activator_id: int, game_manager): # Doesn't get called by Chains
	game_manager.end_turn(activator_id)

func tile_DRAW_RED(activator_id: int, game_manager):
	yield(game_manager.draw_red(activator_id),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(game_manager,activator_id)

func tile_DRAW_BLACK(activator_id: int, game_manager):
	yield(game_manager.draw_black(activator_id),"completed")

func tile_DRAW_ORANGE(activator_id: int, game_manager):
	yield(game_manager.draw_orange(activator_id),"completed")

#######
# Basic

func tile_VICTORY(activator_id: int, game_manager):
	game_manager.declare_victor(activator_id)

func tile_LOSE_A_TURN(activator_id: int, game_manager):
	shake(game_manager,[activator_id])
	game_manager.add_effect(activator_id,STOPPED,1)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(game_manager,activator_id)

func tile_BACK_TO_START(activator_id: int, game_manager):
	shake(game_manager,[activator_id])
	yield(game_manager.teleport_player(1,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(game_manager,activator_id,activator_id),"completed")

func tile_PRISON(activator_id: int, game_manager):
	shake(game_manager,[activator_id])
	UserStats.player_jailed(activator_id) # Update Stats
	if !game_manager.rolled and activator_id==game_manager.curr: game_manager.add_effect(activator_id,IMPRISONED,1) # Already spend this turn in jail
	else: game_manager.add_effect(activator_id,IMPRISONED,2)
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(game_manager,activator_id)

func tile_MOVE(activator_id: int, v: int, game_manager):
	yield(game_manager.move_player(v,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(game_manager,activator_id,activator_id),"completed")

#########
# Complex

func tile_PLUS_5_OR_PLUS_6(activator_id: int, game_manager):
	game_manager.action_log.add_line(str(PlayersList.get_player_username(activator_id))+" "+tr("HAS TO CHOOSE BETWEEN A +5 AND A +6"))
	# Wait for a value to be chosen
	emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), ["+5","+6"])
	var chosen_value = yield(aux_effs,"answer")
	# Execute effect 1: U +5
	if chosen_value==1: yield(game_manager.move_player(5,activator_id,false),"completed")
	# Execute effect 2: Else +6
	else: yield(game_manager.move_player(6,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(game_manager,activator_id,activator_id),"completed")

func tile_GIFT_OR_PLUS_1(activator_id: int, game_manager):
	# Find available targets
	var targets = []
	for n in range(1,4):
		var id = (n+activator_id)%4
		if game_manager.cardManager.player_has_cards(id): targets.append(id)
	# Wait for a value to be chosen
	var chosen_value: int = 2
	if not targets.empty(): # If there are no targets it defaults to +1
		game_manager.action_log.add_line(str(PlayersList.get_player_username(activator_id))+" "+tr("HAS TO CHOOSE BETWEEN A +1 AND GETTING A GIFT"))
		emit_signal("question", "choice", PlayersList.get_player_unique_id(activator_id), ["Gift","+1"])
		chosen_value = yield(aux_effs,"answer")
	# Execute effect 1: Get a gift from someone
	if chosen_value==1:
		game_manager.action_log.add_line(str(PlayersList.get_player_username(activator_id))+" "+tr("GETS A GIFT FROM..."))
		# Wait for a target to be selected
		emit_signal("question", "target", PlayersList.get_player_unique_id(activator_id), [0,targets])
		var target_id = yield(aux_effs,"answer")
		# Shake target
		shake(game_manager,[target_id])
		# Wait for target to choose card to give
		emit_signal("question", "card_selection", PlayersList.get_player_unique_id(target_id), [[false,false], game_manager.cardManager.red_deck.get_player_cards(target_id)])
		var chosen_card_id = yield(aux_effs,"answer")
		# Target gives to activator said card
		game_manager.action_log.add_line(str(PlayersList.get_player_username(target_id))+"!")
		yield(game_manager.cardManager.red_deck.trade_card(target_id,activator_id,chosen_card_id),"completed")
		# End
		if game_manager.chain_number>0: game_manager.chain_number-=1
		else: end_chain(game_manager,activator_id)
	# Execute effect 2: U +1
	else:
		yield(game_manager.move_player(1,activator_id,false),"completed")
		# End
		yield(resolve_chain_reaction(game_manager,activator_id,activator_id),"completed")

func tile_ROLL_AGAIN(activator_id: int, game_manager):
	game_manager.action_log.add_line(str(PlayersList.get_player_username(activator_id))+" "+tr("GETS TO ROLL AGAIN"))
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
	# Move
	yield(game_manager.move_player(roll,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(game_manager,activator_id,activator_id),"completed")

func tile_EVEN_OR_ODD(activator_id: int, game_manager):
	game_manager.action_log.add_line(str(PlayersList.get_player_username(activator_id))+" "+tr("HAS TO ROLL EVEN OR ODD"))
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
	# Teleport
	roll%=2
	if roll==0: yield(game_manager.teleport_player(31,activator_id,false),"completed")
	else: yield(game_manager.teleport_player(61,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(game_manager,activator_id,activator_id),"completed")

######
# Card

func tile_PARKING_METER(activator_id: int, game_manager):
	var tile_number: int = $"../../../Player_Manager".get_player_tile(activator_id)
	var owner_id: int = $"..".get_card_tile_owner(tile_number)
	game_manager.action_log.add_line(tr("A ACTIVATED A C SPACE PLACED BY B")%[PlayersList.get_player_username(activator_id),tr("PARKING METER"),PlayersList.get_player_username(owner_id)],owner_id)
	$"..".remove_card_tile(tile_number)
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
	# Move parking meter original activator forward
	yield(game_manager.move_player(roll,owner_id,false),"completed")
	# End
	yield(resolve_chain_reaction(game_manager,activator_id,owner_id),"completed")

func tile_MINEFIELD(activator_id: int, game_manager):
	var tile_number: int = $"../../../Player_Manager".get_player_tile(activator_id)
	var owner_id: int = $"..".get_card_tile_owner(tile_number)
	game_manager.action_log.add_line(tr("A ACTIVATED A C SPACE PLACED BY B")%[PlayersList.get_player_username(activator_id),tr("MINEFIELD"),PlayersList.get_player_username(owner_id)],owner_id)
	$"..".remove_card_tile(tile_number)
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
	# Move minefield activator backward
	yield(game_manager.move_player(-roll,activator_id,false),"completed")
	# End
	yield(resolve_chain_reaction(game_manager,activator_id,activator_id),"completed")

#################
# Other functions
#################

# Shake each targets' dashboard
func shake(game_manager, targets: Array):
	for id in targets: game_manager.playerManager.shake(id)

# Resolves tile effs on the target
# Returns control to activator if they have yet to roll and is_final
func resolve_chain_reaction(game_manager, activator_id: int, target_id: int, is_final: bool = true):
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
	elif is_final: end_chain(game_manager,activator_id)
	yield(get_tree(),"idle_frame")

# Aux to re-enable activator's roll button
func end_chain(game_manager, activator_id: int):
	if game_manager.rolled: game_manager.end_turn(activator_id)
	else:
		# Ended up in prison?
		if game_manager.playerManager.has_to_serve_turns(activator_id) and game_manager.mapManager.is_prison(game_manager.playerManager.get_player_tile(activator_id)):
			game_manager.switch_dice()
		# Was in prison but now isn't
		elif game_manager.escape_button.visible==true:
			yield(game_manager.switch_dice(false),"completed")
		# Button fix for curr
		enable_roll_button(game_manager,activator_id)

# Aux to re-enable activator's roll button
func enable_roll_button(game_manager, activator_id: int):
	if PlayersList.get_my_unique_id()==PlayersList.get_player_unique_id(activator_id):
		game_manager.roll_button.disable_color(false)
		game_manager.enable_button()
		# Check for croupier
		if game_manager.playerManager.get_player(activator_id).hasCroupier: game_manager.play_area.show()
	# Check if bot
	elif PlayersList.is_bot(activator_id):
		yield(get_tree().create_timer(1),"timeout")
		game_manager.bot_turn()
