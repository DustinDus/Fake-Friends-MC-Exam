extends Control
# Aux for targeting effects UI

# Buttons to choose target
var color_buttons: Array
# Used for the double target effects
var one_or_two: int # 0 = One, 1 = Two, waiting second, 2 = Two, waiting first
var stored_targets: Array
# Signal for Eff classes
signal communicate_answer

# Init
func initialize():
	for n in 4: color_buttons.append(get_child(n))
	stored_targets = [0,0]

# Identifies what kind of targeting is required
func pre_setup_UI(type):
	one_or_two = type[0]
	setup_UI(type[1])

# Sets up UI
func setup_UI(targets: Array):
	# Enable targets' buttons
	for id in targets: color_buttons[id].get_child(0).disabled = false
	# Color buttons appear
	AudioController.play_camera_shutter_button() # Sound
	var x: int
	var y: int
	for id in targets:
		if id%3==0: x = 165
		else: x = 944
		if id<2: y = 162
		else: y = 392
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(color_buttons[id], "rect_position", Vector2(x,y), .2)
	yield(get_tree().create_timer(.25),"timeout")

# Activator chooses an answer
func _button_pressed(c: int):
	AudioController.play_opening_software_interface_button() # Sound
	check_answer(c)
# Check the requirements
func check_answer(answer):
	# One target is enough
	if one_or_two==0:
		start_answering(answer)
	# Two targets selected
	elif one_or_two==1:
		stored_targets[1] = answer
		start_answering(answer)
	# One target selected, need a second
	elif one_or_two==2:
		color_buttons[answer].get_child(0).disabled = true
		stored_targets[0] = answer
		one_or_two-=1
		var x: int
		var y: int
		if answer%3==0: x = 30
		else: x = 1079
		if answer<2: y = 162
		else: y = 392
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(color_buttons[answer], "rect_position", Vector2(x,y), .2)
# Activator communicates the answer
func start_answering(answer):
	get_parent().done = true # Stop timer
	# Immediately disable the buttons
	for n in 4: color_buttons[n].get_child(0).disabled = true
	# Hide the wheel
	var x: int
	var y: int
	var m: int
	for n in 4:
		m = (answer+n)%4
		if m%3==0: x = -180
		else: x = 1289
		if m<2: y = 162
		else: y = 392
		color_buttons[m].get_child(0).disabled = true
		if color_buttons[m].rect_position!=Vector2(x,y): # Only for shown buttons
			AudioController.play_old_camera_shutter_button() # Sound
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(color_buttons[m], "rect_position", Vector2(x,y), .2)
		yield(get_tree().create_timer(.25),"timeout")
	# Communicate answer
	if one_or_two==0:
		if PlayersList.am_on(): rpc("answer",answer)
		answer(answer)
	else:
		if PlayersList.am_on(): rpc("answer",stored_targets)
		answer(stored_targets)
# Everyone returns the answer
remote func answer(answer): emit_signal("communicate_answer",answer)
