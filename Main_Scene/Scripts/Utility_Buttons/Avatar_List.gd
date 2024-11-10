extends MarginContainer
# Lists avatars, allows changes and shows unlock conditions

var avatars
var player_avatar

var closed_pos: Vector2
var opened_pos: Vector2

# Setup avatars (minus text)
func _ready():
	# Vars
	avatars = $Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
	player_avatar = $"../Profile_Menu/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/Player_Avatar"
	var unlocked_instance = $Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Unlocked_Panel
	var locked_instance = $Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Locked_Panel
	# Check and prepare title nodes
	var user_avatars = User.get_avatars()
	var unlockables = UnlockablesInfo.AVATARS
	for n in user_avatars.size():
		if user_avatars[n]:
			var new_instance = unlocked_instance.duplicate()
			new_instance.get_child(0).get_child(0).get_child(0).texture = load(unlockables[n][0])
			if new_instance.get_child_count()>1:
				new_instance.get_child(1).text = tr("CHANGE")
				new_instance.get_child(1).connect("pressed",self,"_change_avatar",[n])
				if User.current_avatar==n: new_instance.get_child(1).disabled = true
			avatars.add_child(new_instance)
			new_instance.show()
		else:
			var new_instance = locked_instance.duplicate()
			new_instance.get_child(0).get_child(0).get_child(0).texture = load(unlockables[-1][0])
			new_instance.get_child(1).text = tr(unlockables[n][1])
			avatars.add_child(new_instance)
			new_instance.show()
	unlocked_instance.queue_free()
	locked_instance.queue_free()
	show()

# Translation
func translate():
	var unlockables = UnlockablesInfo.AVATARS
	for child in $Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer.get_children():
		if child.get_child_count()==1: pass
		elif child.get_child(1) is Button: child.get_child(1).text = tr("CHANGE")
		else: child.get_child(1).text = tr(unlockables[child.get_index()][1])

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

# Change disabled button and tell player_avatar to do the rest of the work
func _change_avatar(avatar: int):
	AudioController.play_hard_typewriter_button() # Sound
	avatars.get_child(User.current_avatar).get_child(1).disabled = false
	avatars.get_child(avatar).get_child(1).disabled = true
	player_avatar._change_avatar(avatar)
