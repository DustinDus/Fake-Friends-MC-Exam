extends MarginContainer
# Lists titles, allows changes and shows unlock conditions

var titles
var player_title

var closed_pos: Vector2
var opened_pos: Vector2

# Setup titles (minus text)
func _ready():
	# Vars
	titles = $Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
	player_title = $"../Profile_Menu/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/Player_Title"
	var unlocked_instance = $Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Unlocked_Panel
	var locked_instance = $Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Locked_Panel
	# Check and prepare title nodes
	var user_titles = User.get_titles()
	var unlockables = UnlockablesInfo.TITLES
	for n in user_titles.size():
		if user_titles[n]:
			var new_instance = unlocked_instance.duplicate()
			new_instance.get_child(0).text = tr(unlockables[n][0])
			if new_instance.get_child(0) is Button:
				new_instance.get_child(0).connect("pressed",self,"_change_title",[n])
				if User.current_title==n: new_instance.get_child(0).disabled = true
			titles.add_child(new_instance)
			new_instance.show()
		else:
			var new_instance = locked_instance.duplicate()
			new_instance.get_child(1).text = tr(unlockables[n][1])
			titles.add_child(new_instance)
			new_instance.show()
	unlocked_instance.queue_free()
	locked_instance.queue_free()
	show()

# Translation
func translate():
	var index: int
	var user_titles = User.get_titles()
	var unlockables = UnlockablesInfo.TITLES
	for child in $Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer.get_children():
		index = child.get_index()
		if user_titles[index]: child.get_child(0).text = tr(unlockables[index][0])
		else: child.get_child(1).text = tr(unlockables[index][1])

# Sets up positions
func initialize(direction: int):
	if direction==0:
		closed_pos = Vector2(-352,70)
		opened_pos = Vector2(0,70)
	else:
		closed_pos = Vector2(0,-580)
		opened_pos = Vector2(0,10)

# Pulls up menu
func _pull_up():
	AudioController.play_camera_shutter_button() # Sound
	if rect_position==closed_pos:
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rect_position", opened_pos, .2)

# Closes menu if open and
# a click is made outside its area
func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		if rect_position!=closed_pos:
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
				close()

# Closes menu
func close():
	AudioController.play_old_camera_shutter_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", closed_pos, .2)

# Change disabled button and tell player_title to do the rest of the work
func _change_title(title: int):
	AudioController.play_hard_typewriter_button() # Sound
	titles.get_child(User.current_title).get_child(0).disabled = false
	titles.get_child(title).get_child(0).disabled = true
	player_title._change_title(title)
