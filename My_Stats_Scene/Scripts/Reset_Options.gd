extends Panel
# Panel to reset stats

var scene_cover: Panel

func _ready():
	set_process_input(false)
	scene_cover = $"../Scene_Cover"
	scene_cover.hide()
	hide()

func _pull_up():
	AudioController.play_clackier_button() # Sound
	# Prep
	scene_cover.modulate = Color(1,1,1,0)
	modulate = Color(1,1,1,0)
	scene_cover.show()
	show()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(scene_cover,"modulate",Color(1,1,1,.8),.4)
	tween.tween_property(self,"modulate",Color(1,1,1,1),.4)
	yield(get_tree().create_timer(.8),"timeout")
	set_process_input(true)

# Closes menu if open and
# a click is made outside its area
func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		if modulate==Color(1,1,1,1):
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
				close()

# Aux to close
func close():
	AudioController.play_generic_button() # Sound
	set_process_input(false)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate",Color(1,1,1,0),.4)
	tween.tween_property(scene_cover,"modulate",Color(1,1,1,0),.4)
	yield(get_tree().create_timer(.8),"timeout")
	scene_cover.hide()
	hide()
