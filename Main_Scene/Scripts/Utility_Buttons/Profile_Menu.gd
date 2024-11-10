extends MarginContainer
# Shows the user's profile info

var closed_pos: Vector2
var opened_pos: Vector2

func _ready():
	show()

# Sets up positions
func initialize(direction: int):
	if direction==0:
		closed_pos = Vector2(-500,110)
		opened_pos = Vector2(390,110)
	else:
		closed_pos = Vector2(390,-500)
		opened_pos = Vector2(390,10)

# Pulls up menu
func _Pull_Up_Profile():
	AudioController.play_camera_shutter_button() # Sound
	if rect_position==closed_pos:
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rect_position", opened_pos, .4)

# Closes menu if open and
# a click is made outside its area
func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		# Profile_Menu's area
		var evLocal = make_input_local(event)
		# Title_List's area
		var evLocal2 = $"../Title_List".make_input_local(event)
		var rpt = $"../Title_List".rect_position
		rpt.y-=70
		# Avatar_List's area
		var evLocal3 = $"../Avatar_List".make_input_local(event)
		var rpa = $"../Avatar_List".rect_position
		rpa.y-=70
		# Checks
		if rect_position!=closed_pos:
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position) and !Rect2(rpt,$"../Title_List".rect_size).has_point(evLocal2.position) and !Rect2(rpa,$"../Avatar_List".rect_size).has_point(evLocal3.position):
				close()

# Closes menu
func close():
	AudioController.play_old_camera_shutter_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", closed_pos, .4)
