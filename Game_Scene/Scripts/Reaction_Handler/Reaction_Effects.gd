extends Control
# Handles reaction effects

# To extrapolate data
var game_manager: Node2D
# To redirect effects
var red_effects: Node2D
var black_effects: Node2D
# Aux for effects
var aux_effs

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
	  CROUPIER_EFF,NEGATIVE_MOVEMENT,HALVED_MOVEMENT}

# Init aux_effs
func initialize():
	game_manager = $"../.."
	red_effects = $"../../Card_Manager/Red_Deck/Red_Effects"
	black_effects = $"../../Card_Manager/Black_Deck/Black_Effects"
	aux_effs = $"../../Effects_UI"

###########
# Reactions
###########

# Simply shake the original user's effect
func Objection(instigator_id: int):
	# Log
	game_manager.action_log.add_line(tr("THE CARD IS NEGATED"))
	# Eff + End
	if instigator_id!=-1: shake([instigator_id])
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(game_manager.curr)

# Activate the card with its original activator as the target
func No_U(instigator_id: int, action: int):
	# Log + Eff (includes end)
	game_manager.action_log.add_line(tr("THE CARD IS REFLECTED"))
	red_effects.get_effect(instigator_id,action,[instigator_id])

# Activator the card first on reactor an then on instigator as targets
func Instant_Karma(instigator_id: int, action: int, reactor_id: int):
	# Log
	game_manager.action_log.add_line(tr("THE CARD AFFECTS BOTH PLAYERS"))
	# Eff on reactor
	game_manager.next_tile_eff[reactor_id] = -2
	red_effects.get_effect(instigator_id,action,[reactor_id])
	yield(resolve_chain_reaction(instigator_id,reactor_id,false),"completed")
	# Eff on instigator
	red_effects.get_effect(instigator_id,action,[instigator_id])

# Erase the reactor from the target list
func Exemption(instigator_id: int, action: int, reactor_id: int, targets: Array, color: int):
	# Log
	game_manager.action_log.add_line(PlayersList.get_player_username(reactor_id)+" "+tr("IS EXEMPTED"))
	# Eff + End
	targets.erase(reactor_id)
	if color==0: red_effects.get_effect(instigator_id,action,targets)
	else: black_effects.get_effect(instigator_id,action,targets)

# Reactor chooses a number, then everyone starting from the instigator rolls
# The first to roll the chosen number becomes the nuew target, if none does so negate the effect
func Roulette(instigator_id: int, action: int, reactor_id: int):
	# Value select
	red_effects.emit_signal("question", "choice", PlayersList.get_player_unique_id(reactor_id), "1_to_6")
	var chosen_value = yield(aux_effs,"answer")
	# UI appear
	red_effects.emit_signal("question", "roll_start", PlayersList.get_player_unique_id(reactor_id), "4")
	var roll = yield(aux_effs,"answer")
	# Each player rolls
	var target_id: int = -1
	for n in range(0,4):
		var id = (instigator_id+n)%4
		red_effects.emit_signal("question", "roll_allow", PlayersList.get_player_unique_id(id), str(id))
		roll = yield(aux_effs,"answer")
		if roll==chosen_value:
			target_id = id
			break
	# UI disappear
	red_effects.emit_signal("question", "roll_close", PlayersList.get_player_unique_id(reactor_id), "X")
	roll = yield(aux_effs,"answer")
	# Eff
	if target_id==-1: Objection(instigator_id)
	else: red_effects.get_effect(instigator_id,action,[reactor_id])

# Simply negate the effect
func Immunity():
	# Log
	game_manager.action_log.add_line(tr("THE CARD IS NEGATED"))
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(game_manager.curr)

# Draw a card instead
func Break_in_Black(reactor_id: int):
	# Log
	game_manager.action_log.add_line(tr("THE CARD IS NEGATED"))
	# Eff + End
	yield(game_manager.draw_red(reactor_id),"completed")
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(game_manager.curr)

# Uses the card against another target of the reactor's choice
func Gimme_That(reactor_id: int):
	# Log
	game_manager.action_log.add_line(tr("THE CARD CHANGES TARGET"))
	# Get available targets (42=Reset checks all players)
	var targets: Array = game_manager.cardManager.black_deck.target_checker.get_targets(reactor_id,42)
	# Get chosen target
	red_effects.emit_signal("question", "target", PlayersList.get_player_unique_id(reactor_id), [0,targets])
	var target_id = yield(aux_effs,"answer")
	# Eff
	game_manager.next_tile_eff[reactor_id] = -2
	resolve_chain_reaction(reactor_id,reactor_id)
	yield(game_manager.cardManager.black_deck.retrieve_card(target_id,0),"completed")

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
