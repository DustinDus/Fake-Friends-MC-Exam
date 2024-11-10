extends Control
# Coordinates players for color selection

# Player data
var p_ids: Array # IDs
var p_cols: Array # Colors
# (each color will be in corresponding p_ids index)
# Who's choosing color
var curr: int
# Nodes
var color_wheel: Control
var panel: Panel
var label: Label

# Timer stuff
var t: float = 0.0
var timebar: TextureProgress

# Signals
signal color_selected
signal colors_are_ready

# Stop process immediately
func _ready(): set_process(false)

# Init
func initialize(player_IDs: Array):
	# Vars
	p_ids = player_IDs.duplicate()
	p_cols = ["BLACK", "BLACK", "BLACK", "BLACK"]
	curr = 0
	color_wheel = get_child(0)
	panel = get_child(1)
	label = get_child(2)
	timebar = color_wheel.get_child(1)
	# Prep
	color_wheel.rect_scale = Vector2(0,0)
	color_wheel.rect_rotation = -360
	label.text = ""
	show()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(color_wheel,"rect_scale",Vector2(1,1),.6)
	tween.parallel().tween_property(color_wheel,"rect_rotation",360,.6)
	yield(get_tree().create_timer(.6),"timeout")
	# Start
	who_is_next()

#########################
# Roll-handling functions

# Prepares wheel for next player + Animations
func who_is_next():
	if multiplayer.get_network_unique_id()==p_ids[curr]:
		label.text = "Choose your Color!"
		var wheel_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		wheel_tween.tween_property(color_wheel,"modulate",Color(1,1,1),.4)
		wheel_tween.parallel().tween_property(panel,"modulate",Color(1,1,1,0),.4)
		yield(get_tree().create_timer(.4),"timeout")
		start_timer()
		panel.hide()
	else:
		panel.show()
		label.text = "Another player is choosing their color..."
		var wheel_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		wheel_tween.tween_property(color_wheel,"modulate",Color(.8,.8,.8),.4)
		wheel_tween.parallel().tween_property(panel,"modulate",Color(1,1,1,.2),.4)
	# Label animation
	var x = label.rect_position.x
	var y = label.rect_position.y
	var label_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	label_tween.tween_property(label,"rect_position",Vector2(x+5,y),.05)
	label_tween.tween_property(label,"rect_position",Vector2(x-5,y),.05)
	label_tween.tween_property(label,"rect_position",Vector2(x+5,y),.05)
	label_tween.tween_property(label,"rect_position",Vector2(x-5,y),.05)
	label_tween.tween_property(label,"rect_position",Vector2(x,y),.05)

# Color selection buttons
func _on_color_button_pressed(color: String):
	stop_timer()
	var chooser_id = multiplayer.get_network_unique_id()
	_on_color_selected(chooser_id,color)
	rpc("_on_color_selected", chooser_id,color)

# When a color is selected...
remote func _on_color_selected(chooser_id: int, color: String):
	AudioController.play_opening_software_interface_button() # Sound
	# Store it (relative to the player)
	p_cols[p_ids.find(chooser_id)] = color
	# Disable its button
	disable_color_button(color)
	# Pull up its part of background
	emit_signal("color_selected",color)

# Disable button of a taken color
remote func disable_color_button(color: String):
	match color:
		"RED": color_wheel.get_child(2).get_child(0).disabled = true
		"BLUE": color_wheel.get_child(2).get_child(1).disabled = true
		"GREEN": color_wheel.get_child(2).get_child(2).disabled = true
		"YELLOW": color_wheel.get_child(2).get_child(3).disabled = true
		_: print("Unexpected color selected")
	curr+=1
	if curr==4:
		# Disappear animation
		$"../Utility_Buttons".disable_buttons()
		$"../Utility_Buttons".close_all_menus()
		yield(get_tree().create_timer(.5),"timeout")
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self,"modulate",Color(1,1,1,0),.4)
		tween.tween_property(label,"modulate",Color(1,1,1,0),.4)
		AudioController.play_heavier_button() # Sound
		yield(get_tree().create_timer(1),"timeout")
		# Signal for next step
		emit_signal("colors_are_ready", p_cols)
		self.queue_free()
	else:
		who_is_next()

#########################
# Timer-related functions

# Animation and check
func _process(delta):
	t+=delta
	timebar.value = (t/10)*100
	if t>10: $"../Room_Config"._exit_room()

# Start
func start_timer():
	AudioController.play_back_tick() # Sound
	t = .0
	timebar.value = .0
	set_process(true)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(timebar,"modulate",Color(.2,.2,.2,.2),.3)
	yield(get_tree().create_timer(.3),"timeout")

# Stop
func stop_timer():
	set_process(false)
	print("STOPPED")
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(timebar,"modulate",Color(.2,.2,.2,.1),.3)
	yield(get_tree().create_timer(.3),"timeout")
