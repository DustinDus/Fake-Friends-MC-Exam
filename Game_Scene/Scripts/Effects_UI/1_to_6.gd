extends Control
# Animation+Logic to choose a number from 1 to 6

# Pull up UI
func pull_up(activator_unique_id: int):
	# Set some values
	for n in self.get_children(): n.disabled = true
	rect_position = Vector2(640,340)
	modulate = Color(1,1,1,0)
	rect_scale = Vector2(0,0)
	rect_rotation = -360.0
	# Animation
	AudioController.play_whoosh_click01() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate",Color(1,1,1,.7),1)
	tween.parallel().tween_property(self,"rect_scale",Vector2(1,1),1)
	tween.parallel().tween_property(self,"rect_rotation",360.0,1)
	if PlayersList.get_my_unique_id()==activator_unique_id:
		tween.tween_property(self,"modulate",Color(1,1,1,1),.5)
		for n in get_children(): n.disabled = false
	yield(get_tree().create_timer(1.55),"timeout")

# Pull donw UI
func pull_down(answer: int):
	# Animation
	var chosen = get_child(answer-1)
	var x = chosen.rect_position.x
	var y = chosen.rect_position.y
	AudioController.play_heavier_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(chosen,"rect_position",Vector2(x+5,y),.05)
	tween.tween_property(chosen,"rect_position",Vector2(x-5,y),.05)
	tween.tween_property(chosen,"rect_position",Vector2(x+5,y),.05)
	tween.tween_property(chosen,"rect_position",Vector2(x-5,y),.05)
	tween.tween_property(chosen,"rect_position",Vector2(x,y),.05)
	tween.tween_property(self,"modulate",Color(1,1,1,0),1)
	tween.parallel().tween_property(self,"rect_scale",Vector2(0,0),1)
	tween.parallel().tween_property(self,"rect_rotation",-360.0,1)
	yield(get_tree().create_timer(1.3),"timeout")
	# Set some values
	rect_position = Vector2(640,-340)
