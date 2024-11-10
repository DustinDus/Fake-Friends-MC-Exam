extends Node2D
# Manages pawns and related data

# Mantains the players in an array in order by number
var players: Array = []
# Turn-related info
var current: int # Acts as index for player array
var turnOrder: int # 1 == Clockwise  -1 == Counter-Clockwise
var turnCounter: int
# UI updating nodes
var player_dashboards: Control
var effect_clouds: Control
var match_info: Control
# Card pawn vars
var card_pawn

# Sets up players and turns
func initialize1(first: int):
	# Init turn vars
	current = first
	turnOrder = 1
	turnCounter = 1
	# Get players
	var player_red = $Red_Pawn.initialize(846,98,"res://Game_Scene/Textures/Player_Icons/redIcon.png")
	players.append(player_red)
	var player_blue = $Blue_Pawn.initialize(882,98,"res://Game_Scene/Textures/Player_Icons/blueIcon.png")
	players.append(player_blue)
	var player_green = $Green_Pawn.initialize(882,134,"res://Game_Scene/Textures/Player_Icons/greenIcon.png")
	players.append(player_green)
	var player_yellow = $Yellow_Pawn.initialize(846,134,"res://Game_Scene/Textures/Player_Icons/yellowIcon.png")
	players.append(player_yellow)
	for n in 4: players[n].modulate = Color(1,1,1,0)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	for n in 4: tween.tween_property(players[n],"modulate",Color(1,1,1,1),.3)
	# Card Pawn
	card_pawn = $Card_Pawn
	# Get UI
	player_dashboards = $"../Player_Dashboards"
	player_dashboards.initialize(current)
	yield(get_tree().create_timer(1.2),"timeout")

# Sets up the info UIs
func initialize2():
	effect_clouds = $"../Effect_Clouds"
	effect_clouds.initialize()
	match_info = $"../Info_Layer/Match_Info"
	match_info.initialize(current)
	$"../Info_Layer/Action_Log".initialize() # Only init the Action Log, Game_Manager is the one writing
	yield(get_tree().create_timer(.6),"timeout")

# Updates turn and returns result
func upd_turn():
	turnCounter+=1
	current = (current+turnOrder)%4
	if current<0: current = 3
	upd_turn_UI()
	return current
# Updates turn-related UI
func upd_turn_UI():
	match_info.upd_turn(turnCounter,current)
	player_dashboards.upd_turn(current)
	upd_crown(current)
# Shake a dashboard
func shake(id: int): player_dashboards.shake(id)
# Target a player's avatar
func target(id: int): player_dashboards.target(id)

# Updates the crown to indicate which player is further
# NOTE: If multiple players are the furthest then the turn player has priority and that follows the turn order
func upd_crown(turn_player: int):
	var player_further_ahead: int = turn_player
	for n in range(1,4):
		var next = get_next(turn_player,n)
		if (players[next].tile)>(players[player_further_ahead].tile):
			player_further_ahead = next
	player_dashboards.upd_crown(player_further_ahead)
# Aux function to calculate the next player according to turn order
func get_next(start: int, step: int) -> int:
	var next: int
	next = (start+(step*turnOrder))%4
	if next<0: next = 4+next
	return next

###################
# Basic player data
###################

# Get/Set/Update player tile
func get_player_tile(id: int) -> int:
	return players[id].tile
func set_player_tile(id: int, tile: int):
	players[id].set_tile(tile)
	upd_player_tile_UI(id, tile)
func upd_player_tile(id: int, tile: int) -> int:
	tile = players[id].upd_tile(tile)
	upd_player_tile_UI(id, tile)
	return tile
func get_player_previous_tile(id: int) -> int:
	return players[id].previous_tile
# Update player-related UI
func upd_player_tile_UI(id: int, tile: int):
	match_info.upd_tile(id,tile)

# Get/Set player position
func get_player_pos(id: int) -> Vector2:
	return players[id].position
func set_player_pos(id: int, pos: Vector2):
	players[id].position = pos

# Return Player
func get_player(id: int) -> Sprite:
	return players[id]

# Return farthest player's tile
func get_farthest_players_tile() -> int:
	var tile: int = 1
	for player in players: if player.tile>tile: tile = player.tile
	return tile

################
# Player effects 
################

# Does a player have to skip/serve turns?
func has_to_skip_turns(player_id: int) -> bool: return players[player_id].has_to_skip_turns()
func has_to_serve_turns(player_id: int) -> bool: return players[player_id].has_to_serve_turns()

# Does a player have red/black immunity?
func has_red_immunity(player_id: int) -> bool: return players[player_id].has_red_immunity()
func has_black_immunity(player_id: int) -> bool: return players[player_id].has_black_immunity()

# Can a player play red cards?
func can_play_red_cards(player_id: int) -> bool: return players[player_id].can_play_red_cards()

# Reset player's movement roll this turn
func reset_movement_roll(player_id: int): players[player_id].reset_movement_roll()

# Multiply a player's dice multiplier
func multiply_multiplier(player_id: int, multiplier: int):
	players[player_id].multiply_multiplier(multiplier)

# Setup a player's dice multiplier in accordance to their effects
func setup_multiplier(player_id: int):
	players[player_id].setup_multiplier()

# Add an effect to a player for a certain number of turns
func add_effect(player_id: int, effect_number: int, turn_number: int):
	players[player_id].add_effect(effect_number,turn_number)
	yield(effect_clouds.add_effect(player_id,effect_number,turn_number),"completed")

# Remove an effect from a player
func remove_effect(player_id: int, effect_number: int):
	players[player_id].remove_effect(effect_number)
	yield(effect_clouds.remove_effect(player_id,effect_number),"completed")

# Reduce each effect of a player
func reduce_effects(player_id: int):
	players[player_id].reduce_effects()
	yield(effect_clouds.reduce_effects(player_id),"completed")

# Get a player's effects and check which have to be removed
func clean_effects(player_id: int):
	var over_effects: Array = players[player_id].get_over_effects()
	for effect in over_effects: yield(effect_clouds.remove_effect(player_id,effect),"completed")
	yield(get_tree(),"idle_frame")

#################
# Card pawn stuff
#################

# Spawn/Despawn pawn
func spawn_card_pawn(type: int): yield(card_pawn.initialize(type),"completed")
func despawn_card_pawn(): yield(card_pawn.deinitialize(),"completed")

# Check if pawn is active
func card_pawn_is_active() -> bool: return card_pawn.get_type()!=0

# Getters
func get_card_pawn() -> Sprite: return card_pawn
func get_card_pawn_tile() -> int: return card_pawn.get_tile()
func get_card_pawn_movement() -> int: return card_pawn.get_movement()
func get_card_pawn_pos() -> Vector2: return card_pawn.position

# Check if it moved this turn
func card_pawn_has_moved() -> bool: return card_pawn.check_has_moved()
# Resets the movement bool
func reset_card_pawn_has_moved() : card_pawn.reset_has_moved()

# Move pawn and activate effect if it didn't leave the board
func move_card_pawn(game_manager):
	card_pawn.move(game_manager)
	if card_pawn.get_type()!=0: exec_pawn_eff(game_manager)
	else: game_manager.end_turn(game_manager.curr)
# Check for players on the card pawn's tile, activates effect if any are
func exec_pawn_eff(game_manager):
	# Check for players
	var card_pawn_tile = get_card_pawn_tile()
	var player_ids: Array = []
	for player_id in range(0,4):
		if players[player_id].tile==card_pawn_tile:
			player_ids.append(player_id)
	# Execute effect if any
	if player_ids.empty(): game_manager.end_turn(game_manager.curr)
	else: card_pawn.get_action(player_ids, game_manager)
# Check for pawn's effect
func get_pawn_eff(game_manager, player_id: int):
	game_manager.next_tile_eff[player_id] = card_pawn.get_type()

#

####################
# Bot-Handling Stuff
####################

# Bot up dashboard and pawn
func bot_up_player(id: int):
	player_dashboards.bot_up_dashboard(id)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(players[id],"modulate",Color(.6,.6,.6),.3)
	shake(id)
