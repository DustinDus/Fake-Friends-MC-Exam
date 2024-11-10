extends Sprite
# Script to handle special pawns spawned by card effects

# Pawn types
enum {NONE, BULL, RABBIT}

# Current pawn type
var type: int
# Current pawn tile
var tile: int
# How the pawn moves
var movement: int
# Has the pawn moved this turn?
var has_moved: bool

# Pre-Setup
func _ready():
	has_moved = false
	scale = Vector2(0.35,0.35)
	modulate = Color(1,1,1,0)

#################
# "Spawn/Despawn"
#################

# Initialize as correct pawn
func initialize(new_type: int):
	# Inits logic
	if type!=NONE: yield(deinitialize(),"completed")
	type = new_type
	match type:
		BULL:
			texture = load("res://Game_Scene/Textures/Player_Icons/blackIcon.png")
			tile = 64
			position = Vector2(608,308)
			movement = -4
		RABBIT:
			texture = load("res://Game_Scene/Textures/Player_Icons/whiteIcon.png")
			tile = 64
			position = Vector2(608,308)
			movement = -4
	# Spawn animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate",Color(1,1,1,1),.3)
	yield(get_tree().create_timer(.3),"timeout")

# Leave the board
func deinitialize(game_manager = null):
	# Log
	if game_manager!=null: game_manager.action_log.add_line(tr("THE EXTRA PAWN LEFT THE BOARD"))
	# Resets vars
	type = NONE
	tile = -1
	movement = 0
	has_moved = false
	# Despawn animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate",Color(1,1,1,0),.3)
	yield(get_tree().create_timer(.3),"timeout")

#########
# Effects
#########

# Updates current tile and returns result
func move(game_manager) -> int:
	tile += movement
	if tile>64 || tile<1: deinitialize(game_manager)
	else: game_manager.action_log.add_line(tr("THE EXTRA PAWN MOVED TO TILE")+" "+str(tile))
	has_moved = true
	return tile

# Returns has_moved
func check_has_moved():
	return has_moved
# Resets has_moved
func reset_has_moved():
	has_moved = false

# Activate its effect on players that share its tile
func get_action(player_ids: Array, game_manager):
	# Log
	game_manager.action_log.add_line(tr("THE EXTRA PAWN ACTIVATES ITS EFFECT"))
	# Get eff
	match type:
		BULL: bull(player_ids,game_manager)
		RABBIT: rabbit(player_ids,game_manager)
		_: pass

# The bull pawn sends players back to the start
func bull(player_ids: Array, game_manager):
	# Send
	for player_id in player_ids:
		shake(game_manager,[player_id])
		yield(game_manager.teleport_player(1,player_id,false),"completed")
	# Leave
	yield(deinitialize(game_manager),"completed")
	# Effs
	for player_id in player_ids:
		yield(resolve_chain_reaction(game_manager,player_id,player_id,false),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(game_manager,game_manager.curr)

# The rabbit lets players roll for movement
func rabbit(player_ids: Array, game_manager):
	# Draws
	for player_id in player_ids:
		for n in 3:
			yield(game_manager.draw_red(player_id),"completed")
	# Leave
	yield(deinitialize(game_manager),"completed")
	# End
	if game_manager.chain_number>0: game_manager.chain_number-=1
	else: end_chain(game_manager,game_manager.curr)

#################
# Getters/Setters
#################

# Returns current type
func get_type() -> int:
	return type

# Returns current tile
func get_tile() -> int:
	return tile
# Sets current tile
func set_tile(v: int):
	tile = v
	if tile>64 || tile<1: deinitialize()

# Returns movement
func get_movement() -> int:
	return movement

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
