extends Control
# Writes up what happens during the match

var action_panel: Panel
var log_scroller: ScrollContainer
var log_lines: VBoxContainer
var line: Label # To clone

# Preparations
func _ready(): get_child(1).rect_position = Vector2(-27,-33)

# Set up comps and write something
func initialize():
	action_panel = $Action_Panel
	log_scroller = $Action_Panel/Log_Scroller
	log_lines = $Action_Panel/Log_Scroller/Log_Lines
	line = log_lines.get_child(0)
	line.text = tr("THE MATCH STARTS!")
	add_line("")
	# Move the button to position
	AudioController.play_hard_typewriter_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(get_child(1), "rect_position", Vector2(-27,0), .5)
	yield(get_tree().create_timer(.6), "timeout")

# Write a line on the log
func add_line(text: String, color: int = -1):
	# Checks if scrollbar is at the bottom
	var is_at_bottom: bool = ((log_scroller.get_v_scrollbar().max_value - log_scroller.rect_size.y) - log_scroller.get_v_scrollbar().value) <= 0
	# Writes line
	var new_line: Label = line.duplicate()
	new_line.text = text
	log_lines.add_child(new_line)
	# Changes color if needed
	match color:
		-1: pass
		0: new_line.add_color_override("font_color",Color.red)
		1: new_line.add_color_override("font_color",Color.dodgerblue)
		2: new_line.add_color_override("font_color",Color.green)
		3: new_line.add_color_override("font_color",Color.yellow)
		4: new_line.add_color_override("font_color",Color.lightcoral)
		5: new_line.add_color_override("font_color",Color.gray)
		6: new_line.add_color_override("font_color",Color.darkorange)
		_: pass
	# Autoscrolls to the bottom if yes
	if(is_at_bottom):
		yield(get_tree(),"idle_frame")
		log_scroller.get_v_scrollbar().value = log_scroller.get_v_scrollbar().max_value

# Open/Close log
func trigger_log():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if action_panel.rect_position.y==-412:
		tween.tween_property(action_panel, "rect_position", Vector2(-22,33), .4)
		AudioController.play_camera_shutter_button() # Sound
	else:
		tween.tween_property(action_panel, "rect_position", Vector2(-22,-412), .4)
		AudioController.play_old_camera_shutter_button() # Sound
