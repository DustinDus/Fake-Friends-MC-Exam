extends CanvasLayer
# Plays at the beginning of a new turn

var turn_panel: Panel
var turn_label: Label

enum {RED, BLUE, GREEN, YELLOW}

# Init
func initialize():
	# Children + Get the label out of the way
	turn_panel = get_child(0)
	turn_panel.modulate = Color(1,1,1,0)
	turn_label = get_child(1)

# Animation
func play(id: int):
	# Set up panel
	turn_label.rect_position.x = 1280
	turn_panel.visible = true
	# Set up label
	turn_label.visible = true
	turn_label.text = tr("'S TURN")%[str(PlayersList.get_player_username(id))]
	turn_label.add_color_override("font_color", get_color(id))
	# Animation
	AudioController.play_transition_coat() # Sound
	panel_play()
	label_play()
	yield(get_tree().create_timer(1.2),"timeout")
	# Reset panel
	turn_panel.visible = false
	# Reset label
	turn_label.visible = false

# Panel part of the animation
func panel_play():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(turn_panel, "modulate", Color(1,1,1,.8), .6)
	tween.tween_property(turn_panel, "modulate", Color(1,1,1,0), .6)

# Label part of the animation
func label_play():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(turn_label, "rect_position", Vector2(0,245), .6)
	tween.tween_property(turn_label, "rect_position", Vector2(-1280,245), .6)

# Get color based on player id
func get_color(id: int) -> Color:
	match id:
		RED: return Color.red
		BLUE: return Color.blue
		GREEN: return Color.green
		YELLOW: return Color.yellow
		_:
			print("!!! Unexpected color for Next_Turn animation !!!")
			return Color.black
