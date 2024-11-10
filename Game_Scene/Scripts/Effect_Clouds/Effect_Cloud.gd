extends Sprite
# Cloud animation + Show Cards

# To animate the icons
var t: float = 0.0

# To show cards
signal show_cards

# No need to process at the start
func _ready():
	set_process(false)
	set_process_input(false)

# Make icons change every second (if the player has multiple effects)
func _process(delta):
	t+=delta
	if t>1.0:
		t-=1.0
		var n = get_child_count()-1
		get_child(n).hide()
		move_child(get_child(0),n)
		get_child(n).show()

# Show cards if active
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			emit_signal("show_cards",get_index())
