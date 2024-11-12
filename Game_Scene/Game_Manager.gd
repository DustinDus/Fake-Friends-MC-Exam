extends Node2D
# Manages player/bot turns, actions and effects with the help of its subordinates

# Movement aux classes
var tweener: Tweener_Creator
# Subordinate managers
var mapManager: Node2D
var playerManager: Node2D
var cardManager: Node2D
var animationManager: Node2D
# Text Log
var action_log: Control
# Play Cards
var play_area: Control
# Buttons
var roll_button: TextureButton
var escape_button: TextureButton
# For the Timer
var click_or_wait_layer: CanvasLayer

# Turn-handling stuff
var curr: int # Turn player's non-unique id
var rolled: bool # Has the turn player rolled this turn?
var chain_number: int # Keeps track on how many effects in a row are resolving
var next_tile_eff: Array # Registers each player's tile type mid-chain
#var block_tiles: bool # Used if multiple actions must resolve at the same time, blocks get_tile_eff from getting tiles (currently only used for Black Card "This is a Fine")
var black_cards_activated: Array # Counts the black cards activated in a single turn for each player (max 3 per player)



# Preparations
func _ready():
	hide()
	# Create aux classes
	tweener = Tweener_Creator.new()
	add_child(tweener)
	# Get buttons
	roll_button = $Roll_Button
	escape_button = $Escape_Button
	# Setup escape button
	escape_button.modulate = Color(1,1,1,0)
	escape_button.disabled = true
	escape_button.hide()

# Setup Game
func initialize(first: int):
	AudioController.stop_music() # Stop Music
	# Initialize dice
	roll_button.disabled = true
	if PlayersList.am_on():
		roll_button.initialize(1)
		roll_button.disable_color(true)
	else: yield(roll_button.initialize(2),"completed")
	escape_button.initialize(-1,false)
	# Initialize subordinate managers
	mapManager = $Map_Manager
	yield(mapManager.initialize(),"completed")
	cardManager = $Card_Manager
	yield(cardManager.initialize(),"completed")
	playerManager = $Player_Manager
	yield(playerManager.initialize1(first),"completed")
	yield(playerManager.initialize2(),"completed")
	animationManager = $Animation_Manager
	animationManager.initialize()
	# Get Play Area
	play_area = $Card_UI/Play_Area # Hide/Show to stop/allow playing cards
	play_area.hide()
	# Get Log
	action_log = $Info_Layer/Action_Log
	# Get Click_Or_Wait_Layer
	click_or_wait_layer = $Click_Or_Wait_Layer
	
	# Init vars
	curr = first
	rolled = false
	chain_number = 0
	next_tile_eff = [-1,-1,-1,-1]
	#block_tiles = false
	black_cards_activated = [0,0,0,0]
	
	# Begin match
	yield(Synchronizer.synchronize_game(),"completed")
	for n in range(0,4): yield(draw_red((curr+n)%4),"completed")
	#for n in 1: yield(draw_red((curr)%4),"completed")
	#for n in 1: yield(draw_red((curr+1)%4),"completed")
	#for n in 1: yield(draw_red((curr+2)%4),"completed")
	#for n in 1: yield(draw_red((curr+3)%4),"completed")
	
	action_log.add_line("")
	yield(animationManager.play_next_turn(curr),"completed")
	AudioController.play_music(2) # Music
	action_log.add_line(str(PlayersList.get_player_username(curr))+" "+tr("STARTS THE MATCH"),curr)
	if PlayersList.get_player_unique_id(curr)==PlayersList.get_my_unique_id():
		play_area.show()
		enable_button()
		roll_button.disable_color(false)

##############
# Player turns
##############

# Called at the start of the turn
func start_turn():
	yield(Synchronizer.synchronize_game(),"completed")
	yield(animationManager.play_next_turn(curr),"completed")
	# Music
	var farthest_player_tile: int = playerManager.get_farthest_players_tile()
	if farthest_player_tile<28: AudioController.play_music(2) # Music
	elif farthest_player_tile<52: AudioController.play_music(3) # Music
	else: AudioController.play_music(4) # Music
	# Is the player a bot?
	if PlayersList.is_bot(curr):
		#bot_allowed_to_play = true
		bot_turn()
		return
	# > Check multipliers
	playerManager.setup_multiplier(curr)
	# > Has to skip turns?
	if playerManager.has_to_skip_turns(curr):
		UserStats.player_skips(curr) # Update Stats
		playerManager.reduce_effects(curr)
		action_log.add_line(str(PlayersList.get_player_username(curr))+" "+tr("SKIPS A TURN"),curr)
		end_turn(curr)
	# > They have to escape prison
	elif playerManager.has_to_serve_turns(curr) and mapManager.is_prison(playerManager.get_player_tile(curr)):
		playerManager.reduce_effects(curr)
		action_log.add_line(str(PlayersList.get_player_username(curr))+" "+tr("IS IN JAIL"),curr)
		# Shows correct button if necessary
		if escape_button.visible==false: switch_dice()
		# Makes sure the correct player can roll
		if PlayersList.get_player_unique_id(curr)==PlayersList.get_my_unique_id():
			play_area.show()
			enable_button(true)
			escape_button.disable_color(false)
		else:
			escape_button.disable_color(true)
	# > They can play
	else:
		playerManager.reduce_effects(curr)
		action_log.add_line(tr("IT'S X'S TURN")%[str(PlayersList.get_player_username(curr))],curr)
		# Shows correct button if necessary
		if escape_button.visible==true: yield(switch_dice(false),"completed")
		# Makes sure the correct player can play
		if PlayersList.get_player_unique_id(curr)==PlayersList.get_my_unique_id():
			play_area.show()
			enable_button()
			roll_button.disable_color(false)
		else:
			roll_button.disable_color(true)

# Called at the end of the turn
func end_turn(id: int):
	# Changes turn for the turn player
	if id==curr:
		# Card Pawn has a turn
		if playerManager.card_pawn_is_active() and not playerManager.card_pawn_has_moved():
			# Animation
			yield(move_card_pawn(playerManager.get_card_pawn_movement()),"completed")
			# Logic + Effect
			playerManager.move_card_pawn(self)
		# Onto the next player
		else:
			# Reset card pawn movement flag if active
			if playerManager.card_pawn_is_active(): playerManager.reset_card_pawn_has_moved()
			# Reset curr's registered roll
			playerManager.reset_movement_roll(curr)
			rolled = false
			# Resets everyone's Black Card counter
			for n in 4: black_cards_activated[n]=0
			for n in 4: next_tile_eff[n]=-1
			# Reduce/Clean player's over effects
			playerManager.clean_effects(curr)
			# Next turn
			action_log.add_line("")
			curr = playerManager.upd_turn()
			start_turn()

# Hides a button and shows the other
func switch_dice(hide_roll_show_escape: bool = true):
	if hide_roll_show_escape:
		# Pre
		var im_curr: bool = PlayersList.get_player_unique_id(curr)==PlayersList.get_my_unique_id()
		var rcf: int = roll_button.current_face
		escape_button.current_face = rcf
		escape_button.change(rcf)
		escape_button.show()
		# Hide Roll show Escape
		var opacity: float
		if im_curr: opacity = 1
		else: opacity = .7
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(roll_button,"modulate",Color(1,1,1,0),.4)
		tween.parallel().tween_property(escape_button,"modulate",Color(1,1,1,opacity),.4)
		# Post
		if im_curr: enable_button(true)
	else:
		# Pre
		roll_button.change(escape_button.current_face)
		roll_button.show()
		# Hide Escape show Roll
		var opacity: float = escape_button.modulate.a
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(escape_button,"modulate",Color(1,1,1,0),.4)
		tween.parallel().tween_property(roll_button,"modulate",Color(1,1,1,opacity),.4)
	yield(get_tree().create_timer(.5),"timeout")
	# Moved this here to avoid problems
	if hide_roll_show_escape: roll_button.hide()
	else: escape_button.hide()

# Enables/Disables button and starts the timer
func enable_button(need_to_escape: bool = false):
	if need_to_escape: escape_button.disabled = false
	else: roll_button.disabled = false
	if PlayersList.am_on(): await_for_roll(need_to_escape)

# Await the player's roll, autoroll when time runs out
func await_for_roll(need_to_escape: bool):
	# Prep
	var t: float = .0
	var m: float
	var button: TextureButton
	if need_to_escape:
		m = 5.0
		button = escape_button
	else:
		m = 10.0
		button = roll_button
	# Wait
	click_or_wait_layer.appear_to_tell_player_time_left(m)
	while true:
		t+=.1
		yield(get_tree().create_timer(.1),"timeout")
		if button.disabled:
			PlayersList.reset_disconnect_countdown() # Disconnect Countdown Shenanigans
			click_or_wait_layer.disappear()
			return
		if t>m:
			if PlayersList.decrease_disconnect_countdown(): $".."._main_menu() # Disconnect Countdown Shenanigans
			else: break
	# Roll
	if need_to_escape: _roll_escape()
	else: _roll_movement()

#################
# Player movement
#################

# Roll action
func _roll_movement():
	# Prep
	play_area.hide()
	roll_button.disabled = true
	roll_button.disable_color(true)
	# Roll Value
	var v: int = RNGController.unique_roll(1,6)
	# Register
	register_roll(v)
	if PlayersList.am_on(): rpc("register_roll",v)
	# Roll Animation
	if PlayersList.am_on(): roll_button.rpc("roll", v)
	yield(roll_button.roll(v),"completed")
	# Move
	v = int(v*playerManager.get_player(curr).diceMultiplier)
	move_player(v,curr)
	if PlayersList.am_on(): rpc("move_player", v, curr)
# Remember the movement roll for some effects
remote func register_roll(v: int): 
	playerManager.get_player(curr).movement_roll_this_turn = v
	rolled = true

# Moves player by v squares
remote func move_player(v: int, id: int, activate_effects: bool = true):
	# Holds the current player tile, gets updated in move loop
	var old_player_tile: int = playerManager.get_player_tile(id)
	UserStats.player_moved(id,old_player_tile,old_player_tile+v) # Update Stats
	# Checks wether the player is moving forwards or backwards or staying still
	var u
	if v>0:
		u = 1
		if v==1: action_log.add_line(PlayersList.get_player_username(id)+" "+tr("ADVANCES 1 TILE"))
		else: action_log.add_line(PlayersList.get_player_username(id)+" "+(tr("ADVANCES X TILES")%[str(v)]))
	elif v<0:
		u = -1
		v = -v
		if v==1: action_log.add_line(PlayersList.get_player_username(id)+" "+tr("GOES BACK 1 TILE"))
		else: action_log.add_line(PlayersList.get_player_username(id)+" "+(tr("GOES BACK X TILES")%[str(v)]))
	else:
		u = 0
		yield(get_tree(),"idle_frame")
		action_log.add_line(PlayersList.get_player_username(id)+" "+tr("DOESN'T MOVE"))
	# Vectors to keep the pawn's correct offsets
	var old_player_pos: Vector2
	var old_tile_pos: Vector2
	var correction_vector: Vector2
	var new_pos: Vector2
	# So you can't go back past tile 1
	if u==-1 and v>=playerManager.get_player_tile(id): v=playerManager.get_player_tile(id)-1
	# Movement loop (nice animation)
	for n in v:
		# Calculates the offset of a pawn within its tile
		old_player_pos = playerManager.get_player_pos(id)
		if u>0: old_tile_pos = mapManager.get_tile_pos(playerManager.get_player_tile(id)+n)
		else: old_tile_pos = mapManager.get_tile_pos(playerManager.get_player_tile(id)-n)
		correction_vector = old_tile_pos - old_player_pos
		# Moves the pawn and updates the old_tile_pos var
		new_pos = mapManager.get_tile_pos(old_player_tile+u)
		AudioController.play_regularfootstep001() # Sound
		if new_pos!=old_player_pos:
			yield(tweener.move_pawn(playerManager.get_player(id), new_pos - correction_vector), "completed")
			old_player_tile+=u
	# Actually updates the player's tile var and gets the new tile
	if u>0:
		v = playerManager.upd_player_tile(id, v)
		action_log.add_line(PlayersList.get_player_username(id)+" "+tr("ADVANCED TO TILE")+" "+str(v))
	elif u<0:
		v = playerManager.upd_player_tile(id, -v)
		action_log.add_line(PlayersList.get_player_username(id)+" "+tr("WENT BACK TO TILE")+" "+str(v))
	else:
		v = playerManager.upd_player_tile(id, v)
		action_log.add_line(PlayersList.get_player_username(id)+" "+tr("STAYS ON TILE")+" "+str(v))
	# Checks effect
	next_tile_eff[id] = get_tile_eff(v,id)
	if activate_effects:
		if playerManager.card_pawn_is_active() and v==playerManager.get_card_pawn_tile():
			playerManager.exec_pawn_eff(self)
		else:
			mapManager.exec_tile_eff(next_tile_eff[id], id, self)
	yield(get_tree(),"idle_frame")

# Teleport player to tile v
func teleport_player(v: int, id: int, activate_effects: bool = true):
	# Check
	if v<1: v=1
	if v>64: v = 64-v%64
	# Calculates the offset of a pawn within its tile
	var old_player_pos = playerManager.get_player_pos(id)
	var old_tile_pos = mapManager.get_tile_pos(playerManager.get_player_tile(id))
	var correction_vector = old_tile_pos - old_player_pos
	# Gets the target tile's position
	var new_pos = mapManager.get_tile_pos(v)
	# Teleports pawn
	UserStats.player_moved(id,playerManager.get_player_tile(id),v) # Update Stats
	AudioController.play_teleport() # Sound
	yield(tweener.tp_pawn_out(playerManager.get_player(id)),"completed")
	playerManager.set_player_pos(id, new_pos - correction_vector)
	playerManager.set_player_tile(id, v)
	action_log.add_line(str(PlayersList.get_player_username(id))+" "+tr("IS SENT TO TILE")+" "+str(v))
	AudioController.play_teleport_reversed() # Sound
	yield(tweener.tp_pawn_in(playerManager.get_player(id)),"completed")
	# Checks effect
	next_tile_eff[id] = get_tile_eff(v,id)
	if activate_effects:
		if playerManager.card_pawn_is_active() and v==playerManager.get_card_pawn_tile():
			playerManager.exec_pawn_eff(self)
		else:
			mapManager.exec_tile_eff(next_tile_eff[id], id, self)
	yield(get_tree(),"idle_frame")

# Get a tile's effect id
func get_tile_eff(v: int, id: int) -> int:
	#if block_tiles: return -1
	return mapManager.get_tile_eff(v,id)

# Aux to activate tiles only after several movements
func exec_tile_eff(type,id):
	if playerManager.card_pawn_is_active() and playerManager.get_player_tile(id)==playerManager.get_card_pawn_tile():
		playerManager.exec_pawn_eff(self)
	else:
		mapManager.exec_tile_eff(type, id, self)

####################
# Card pawn movement
####################

# Animation to move the card pawn
func move_card_pawn(v: int):
	# Checks wether the pawn is moving forwards or backwards
	var u
	if v>0:
		u = 1
	elif v<0:
		u = -1
		v = -v
	# Holds the current player tile, gets updated in move loop
	var old_pawn_tile: int = playerManager.get_card_pawn_tile()
	# Vectors to keep the pawn's correct offsets
	var old_pawn_pos: Vector2
	var old_tile_pos: Vector2
	var correction_vector: Vector2
	var new_pos: Vector2
	# Movement loop (nice animation)
	for n in v:
		# Calculates the offset of a pawn within its tile
		old_pawn_pos = playerManager.get_card_pawn_pos()
		if u>0: old_tile_pos = mapManager.get_tile_pos(playerManager.get_card_pawn_tile()+n)
		else: old_tile_pos = mapManager.get_tile_pos(playerManager.get_card_pawn_tile()-n)
		correction_vector = old_tile_pos - old_pawn_pos
		# Moves the pawn and updates the old_tile_pos var
		new_pos = mapManager.get_tile_pos(old_pawn_tile+u)
		AudioController.play_regularfootstep001() # Sound
		if new_pos!=old_pawn_pos:
			yield(tweener.move_pawn(playerManager.get_card_pawn(), new_pos - correction_vector), "completed")
			old_pawn_tile+=u

#################
# Draw/Play cards
#################

# Draw a red card
func draw_red(id: int):
	var card_name: String = yield(cardManager.draw_red_card(id),"completed")
	# Only the player who actually drew the Card can see its name on the log
	if card_name=="": action_log.add_line(str(PlayersList.get_player_username(id))+" "+tr("CAN'T DRAW ANY MORE RED CARDS"),4)
	elif PlayersList.get_player_unique_id(id)==PlayersList.get_my_unique_id(): action_log.add_line(str(PlayersList.get_player_username(id))+" "+tr("DRAWS A RED CARD")+": "+card_name,4)
	else: action_log.add_line(str(PlayersList.get_player_username(id))+" "+tr("DRAWS A RED CARD"),4)

# Draw (and play) a black card
func draw_black(id: int):
	# But no more than thrice per turn
	if black_cards_activated[id]<3: black_cards_activated[id]+=1
	else:
		action_log.add_line(PlayersList.get_player_username(id)+" "+tr("CAN'T DRAW ANY MORE BLACK CARDS"),5)
		chain_number-=1
		yield(get_tree(),"idle_frame")
		return
	UserStats.player_drew(id,1) # Update Stats
	# Data is [card_id: int, targets: Array]
	var card_data = yield(cardManager.draw_black_card(id),"completed")
	action_log.add_line(PlayersList.get_player_username(id)+" "+tr("DRAWS A BLACK CARD")+": "+card_data[2],5)
	yield(cardManager.activate_black_card(id,card_data[0],card_data[1]),"completed")

# Draw (and play) an orange card
func draw_orange(id: int):
	UserStats.player_drew(id,2) # Update Stats
	var card_data = yield(cardManager.draw_orange_card(),"completed")
	action_log.add_line(PlayersList.get_player_username(id)+" "+tr("DRAWS AN ORANGE CARD")+": "+card_data[1],6)
	cardManager.activate_orange_card(id,card_data[0])

# Play a red card (log only, logic is in Red_Deck)
func play_red(player_id: int, card_name: String):
	action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("ACTIVATES A RED CARD")+": "+card_name,4)

# Play a reaction (log only, logic is in Red_Deck and Reaction_Handler)
func play_reaction():
	action_log.add_line(tr("REACTION!"))

# Play a combo (log only, logic is in Red_Deck)
func play_combo(player_id: int):
	action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("ACTIVATES A COMBO")+"!",4)

#########################
# Other card interactions
#########################

# Discard a red card
func discard_card(id: int, card_index: int):
	if card_index!=-1: action_log.add_line(str(PlayersList.get_player_username(id))+" "+tr("DISCARDS A CARD")+": "+cardManager.red_deck.get_player_card_name(id,card_index))
	yield(cardManager.red_deck.discard_card(id,card_index),"completed")

# Retrieve a red card from the discard pile
func retrieve_card(id: int, card_index: int):
	if card_index!=-1: action_log.add_line(str(PlayersList.get_player_username(id))+" "+tr("RETRIEVES A CARD")+": "+cardManager.red_deck.get_pile_card_name(card_index))
	yield(cardManager.red_deck.retrieve_card(id,card_index),"completed")

# Reuse a black card from the discard pile against a target
func reuse_black_card(activator_id: int, target_id: int, card_index: int):
	if card_index!=-1: action_log.add_line(tr("A REUSES THE BLACK CARD B AGAINST C")%[PlayersList.get_player_username(activator_id),cardManager.black_deck.get_pile_card_name(card_index),PlayersList.get_player_username(target_id)])
	yield(cardManager.black_deck.retrieve_card(target_id,card_index),"completed")

# Give a red card to someone else
func give_card(giver_id: int, taker_id: int, card_index: int):
	if card_index!=-1:
		if giver_id==PlayersList.get_my_id() || taker_id==PlayersList.get_my_id(): action_log.add_line(PlayersList.get_player_username(giver_id)+" "+tr("GIVES A CARD TO")+" "+PlayersList.get_player_username(giver_id)+" ("+cardManager.red_deck.get_player_card_name(giver_id,card_index)+")")
		else: action_log.add_line(PlayersList.get_player_username(giver_id)+" "+tr("GIVES A CARD TO")+" "+PlayersList.get_player_username(giver_id))
	yield(cardManager.red_deck.trade_card(giver_id,taker_id,card_index),"completed")

# Trade hands
func trade_hands(trader_id_1: int, trader_id_2: int):
	action_log.add_line(tr("A AND B TRADE HANDS")%[PlayersList.get_player_username(trader_id_1),PlayersList.get_player_username(trader_id_2)])
	yield(cardManager.red_deck.trade_hands(trader_id_1,trader_id_2),"completed")

# Shuffle hand
func shuffle_hand(player_id: int):
	action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("SHUFFLES THEIR HAND BACK INTO THE DECK"))
	yield(cardManager.red_deck.shuffle_hand(player_id),"completed")

# Add an effect to a player for a certain number of turns
func add_effect(player_id: int, effect_number: int, turn_number: int):
	if effect_number==0:
		action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("PLAYS WITH THEIR HAND REVEALED FOR THE NEXT")+" "+str(turn_number)+" "+tr("TURNS"))
	elif effect_number==1:
		action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("IS IMMUNE TO RED CARDS FOR THE NEXT")+" "+str(turn_number)+" "+tr("TURNS"))
	elif effect_number==2:
		action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("IS IMMUNE TO BLACK CARDS FOR THE NEXT")+" "+str(turn_number)+" "+tr("TURNS"))
	elif effect_number==3:
		if turn_number==1: action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("SKIPS THEIR NEXT TURN"))
		else: action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("SKIPS THEIR NEXT")+" "+str(turn_number)+" "+tr("TURNS"))
	elif effect_number==4:
		action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("GOT JAILED"))
	elif effect_number==6:
		action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("IS MOVING BACKWARDS NEXT TURN"))
	elif effect_number==7:
		action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("HAD THEIR MOVEMENT ROLL HALVED FOR THE NEXT")+" "+str(turn_number)+" "+tr("TURNS"))
	elif effect_number==8:
		action_log.add_line(PlayersList.get_player_username(player_id)+" "+tr("CAN'T PLAY RED CARDS FOR THE NEXT")+" "+str(turn_number)+" "+tr("TURNS"))
	playerManager.add_effect(player_id,effect_number,turn_number)

# Add a special tile
func add_card_tile(player_id: int, chosen_tile_number: int, special_tile_type: int):
	if special_tile_type==14:
		action_log.add_line(tr("A TURNED B AND ITS ADJACENT TILES INTO C")%[PlayersList.get_player_username(player_id),str(chosen_tile_number),tr("PARKING METER SPACES")])
	if special_tile_type==15:
		action_log.add_line(tr("A TURNED B AND ITS ADJACENT TILES INTO C")%[PlayersList.get_player_username(player_id),str(chosen_tile_number),tr("MINEFIELD SPACES")])
	mapManager.add_card_tile(player_id,chosen_tile_number,special_tile_type)
	mapManager.add_card_tile(player_id,chosen_tile_number+1,special_tile_type)
	mapManager.add_card_tile(player_id,chosen_tile_number-1,special_tile_type)

##############
# Prison stuff
##############

# Escape action
func _roll_escape():
	# Disable button
	escape_button.disabled = true
	# Actually roll
	var v: int = RNGController.unique_roll(1,6)
	if PlayersList.am_on(): escape_button.rpc("roll", v)
	yield(escape_button.roll(v),"completed")
	# Register
	register_roll(v)
	if PlayersList.am_on(): rpc("register_roll",v)
	# Try to escape
	v = int(v*playerManager.get_player(curr).diceMultiplier)
	escape_attempt(v)
	if PlayersList.am_on(): rpc("escape_attempt",v)

# Calculates if the player escaped
remote func escape_attempt(v:int):
	# Get Player
	var player: Sprite = playerManager.get_player(curr)
	# Registers this roll if first
	if player.attemptToEscape==0:
		player.attemptToEscape = v
		action_log.add_line(str(PlayersList.get_player_username(curr))+" "+tr("STARTS ESCAPING WITH A")+" "+str(v)+"...")
		if PlayersList.get_player_unique_id(curr)==PlayersList.get_my_unique_id():
			enable_button(true)
	# Checks escape attempt if second
	else:
		action_log.add_line("..."+tr("AND FOLLOWS IT WITH A")+" "+str(v))
		# Success
		if player.attemptToEscape==v:
			player.turnsToServe = 0
			action_log.add_line(str(PlayersList.get_player_username(curr))+" "+tr("ESCAPED!"))
			yield(move_player(v,curr),"completed")
		# Failure
		else:
			#player.turnsToServe+=-1
			if player.turnsToServe==0: action_log.add_line(str(PlayersList.get_player_username(curr))+" "+tr("GOT RELEASED"))
			else: action_log.add_line(str(PlayersList.get_player_username(curr))+" "+tr("STAYS IN JAIL"))
			end_turn(curr)
		# Reset attempt
		player.attemptToEscape = 0

###############
# Other effects
###############

# Announce victor and end game
func declare_victor(id: int):
	# Update stats
	var my_victory = id==PlayersList.get_my_id()
	get_parent().check_for_unlocks(my_victory,self)
	# End the game
	action_log.add_line(str(PlayersList.get_player_username(id))+" "+tr("WINS!"))
	animationManager.play_victory(id,PlayersList.get_player_username(id))

#

####################
# Bot-Handling Stuff
####################

# To allow bots to play cards that resolve multiple chains correctly
var bot_card_is_in_play: bool = false
# Failsafe to check if the bot even CAN play
#var bot_allowed_to_play: bool = true

# Swap a player out for a bot
func turn_into_bot(id):
	# Prep
	PlayersList.make_bot(id)
	playerManager.bot_up_player(id)
	# If an effect was triggered by the now-bot act accordingly
	if $Effects_UI.current_eff[1]==PlayersList.get_player_unique_id(id):
		yield(get_tree().create_timer(3.5),"timeout")
		$Effects_UI.bot_UI_fixup()
	# If there is no effect and it's the bot's turn, they roll
	elif curr==id:
		yield(get_tree().create_timer(3.5),"timeout")
		if playerManager.has_to_serve_turns(curr) and mapManager.is_prison(playerManager.get_player_tile(curr)): bot_escape()
		else: bot_roll()
	# Else the bot doesn't have to do anything

# The way a bot plays their turn
func bot_turn():
	#if chain_number>0 || !bot_allowed_to_play: return # Avoid multiple contemporary calls
	#bot_allowed_to_play = false # Avoid multiple contemporary calls
	# > Check multipliers
	playerManager.setup_multiplier(curr)
	# > Has to skip turns?
	if playerManager.has_to_skip_turns(curr):
		playerManager.reduce_effects(curr)
		action_log.add_line(str(PlayersList.get_player_username(curr))+" "+tr("SKIPS A TURN"),curr)
		end_turn(curr)
	# > They have to escape prison
	elif playerManager.has_to_serve_turns(curr) and mapManager.is_prison(playerManager.get_player_tile(curr)):
		playerManager.reduce_effects(curr)
		action_log.add_line(str(PlayersList.get_player_username(curr))+" "+tr("IS IN JAIL"),curr)
		# Fix up button
		if !escape_button.visible: switch_dice()
		escape_button.disable_color(true)
		# Tries to play Jailbreak if they got it
		var red_deck = cardManager.red_deck
		if red_deck.player_has_card(curr,17) and red_deck.target_checker.can_be_played(curr,17,false)[0]:
			# Plays and resolves it
			bot_card_is_in_play = true
			yield(get_tree().create_timer(.3),"timeout")
			red_deck.bot_plays_a_card(curr,17)
			while bot_card_is_in_play: yield(get_tree().create_timer(.2),"timeout")
			bot_roll_check()
		# Roll
		else: bot_roll_check(true)
	# > They can play
	else:
		playerManager.reduce_effects(curr)
		action_log.add_line(tr("IT'S X'S TURN")%[str(PlayersList.get_player_username(curr))],curr)
		# Tries to play a card
		var red_deck = cardManager.red_deck
		red_deck.bot_tries_to_play_a_card(curr)
		var card_id: int = yield(red_deck,"bot_chose")
		# Fix up button
		if escape_button.visible: switch_dice(false)
		roll_button.disable_color(true)
		# Checks the card's id
		match card_id:
			-1,24: # No card case/Croupier special case
				pass
			35,36,37: # Kebab/Sauce/Bread special case
				yield(get_tree().create_timer(.3),"timeout")
				chain_number+=1
				red_deck.bot_combos(curr,card_id)
				while chain_number>0: yield(get_tree().create_timer(.2),"timeout")
			1,11: # Gravedigger/Kobe special case
				yield(get_tree().create_timer(.3),"timeout")
				red_deck.bot_plays_a_card(curr,card_id)
				return
			_: # General case
				bot_card_is_in_play = true
				yield(get_tree().create_timer(.3),"timeout")
				red_deck.bot_plays_a_card(curr,card_id)
				while bot_card_is_in_play: yield(get_tree().create_timer(.2),"timeout")
		# Roll
		bot_roll_check()

# Check how to roll
# Added because the use of cards may change the needed roll
# NOTE: the "serving" var is set to true if the bot was in jail and didn't use jailbreak
#       it's needed as the effect reduction would otherwise result in the bots escaping one turn ahead of time
func bot_roll_check(serving: bool = false):
	if (serving || playerManager.has_to_serve_turns(curr)) and mapManager.is_prison(playerManager.get_player_tile(curr)):
		if !escape_button.visible: switch_dice(true)
		yield(get_tree().create_timer(.5),"timeout")
		yield(bot_escape(),"completed")
		yield(get_tree().create_timer(.5),"timeout")
		bot_escape()
	else:
		if escape_button.visible: switch_dice(false)
		yield(get_tree().create_timer(.5),"timeout")
		bot_roll()

# Bot rolls for movement
func bot_roll():
	# Roll
	var v: int = RNGController.common_roll(1,6)
	yield(roll_button.roll(v),"completed")
	# Register
	register_roll(v)
	# Move
	v = int(v*playerManager.get_player(curr).diceMultiplier)
	move_player(v,curr)

# Bot rolls to escape
func bot_escape():
	# Actually roll
	var v: int = RNGController.common_roll(1,6)
	yield(escape_button.roll(v),"completed")
	# Register
	register_roll(v)
	# Try to escape
	v = int(v*playerManager.get_player(curr).diceMultiplier)
	escape_attempt(v)
