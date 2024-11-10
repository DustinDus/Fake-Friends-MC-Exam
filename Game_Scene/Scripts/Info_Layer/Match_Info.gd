extends Control
# Keeps track of: whose turn it is, turn number and each player's tile number

enum {P0_TILE, P1_TILE, P2_TILE, P3_TILE}

# Container
var info_panel: Panel
# Turn-related info
var counter: Label
var current: Label
# Player-related info
var p0_tile: Label
var p1_tile: Label
var p2_tile: Label
var p3_tile: Label

# Preparations
func _ready(): get_child(1).rect_position = Vector2(-7,-33)

# Set up comps
func initialize(first: int):
	# Vars
	info_panel = $Info_Panel
	# Turn-related labels
	counter = $Info_Panel/Info_Lines/Turn_Lines/Counter
	current = $Info_Panel/Info_Lines/Turn_Lines/Current
	upd_turn(1,first)
	# Player-related labels
	p0_tile = $Info_Panel/Info_Lines/Tile_Lines/P0_Tile
	p0_tile.text = tr("RED'S TILE")+": 1"
	p1_tile = $Info_Panel/Info_Lines/Tile_Lines/P1_Tile
	p1_tile.text = tr("BLUE'S TILE")+": 1"
	p2_tile = $Info_Panel/Info_Lines/Tile_Lines/P2_Tile
	p2_tile.text = tr("GREEN'S TILE")+": 1"
	p3_tile = $Info_Panel/Info_Lines/Tile_Lines/P3_Tile
	p3_tile.text = tr("YELLOW'S TILE")+": 1"
	# Move the button to position
	AudioController.play_hard_typewriter_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(get_child(1), "rect_position", Vector2(-7,0), .5)
	yield(get_tree().create_timer(.6), "timeout")

# Update turn info
func upd_turn(count: int, curr: int):
	counter.text = tr("TURNO")+": "+str(count)
	match curr:
		0: current.text = tr("CURRENT")+": "+tr("RED")
		1: current.text = tr("CURRENT")+": "+tr("BLUE")
		2: current.text = tr("CURRENT")+": "+tr("VERDE")
		3: current.text = tr("CURRENT")+": "+tr("YELLOW")

# Update a player's tile
func upd_tile(id: int, tile: int):
	match id:
		P0_TILE: p0_tile.text = tr("RED'S TILE")+": "+str(tile)
		P1_TILE: p1_tile.text = tr("BLUE'S TILE")+": "+str(tile)
		P2_TILE: p2_tile.text = tr("GREEN'S TILE")+": "+str(tile)
		P3_TILE: p3_tile.text = tr("YELLOW'S TILE")+": "+str(tile)

# Open/Close info
func trigger_info():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if info_panel.rect_position.y==-208:
		tween.tween_property(info_panel, "rect_position", Vector2(-2,33), .4)
		AudioController.play_camera_shutter_button() # Sound
	else:
		tween.tween_property(info_panel, "rect_position", Vector2(-2,-208), .4)
		AudioController.play_old_camera_shutter_button() # Sound
