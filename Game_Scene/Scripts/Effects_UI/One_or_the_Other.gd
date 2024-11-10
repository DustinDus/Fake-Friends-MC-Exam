extends Control
# Animation+Logic to select one of several options

# Load images and position buttons
func prepare_choice(images: Array, button_number: int):
	# Load imaged
	load_images(images,button_number)
	# Prepare buttons
	if button_number==2:
		get_child(0).rect_position = Vector2(-240,-100)
		get_child(1).rect_position = Vector2(40,-100)
		get_child(2).hide()
		get_child(3).hide()
	elif button_number==3:
		get_child(0).rect_position = Vector2(-210,-165)
		get_child(1).rect_position = Vector2(10,-165)
		get_child(2).rect_position = Vector2(-100,25)
		get_child(2).show()
		get_child(3).hide()
	elif button_number==4:
		get_child(0).rect_position = Vector2(-210,-210)
		get_child(1).rect_position = Vector2(10,-210)
		get_child(2).rect_position = Vector2(-210,10)
		get_child(3).rect_position = Vector2(10,10)
		get_child(2).show()
		get_child(3).show()

# Store the right images in the sprites
func load_images(images: Array, image_number: int):
	for n in image_number:
		# It's a tile number or a +/- effect
		if images[n].length()<4:
			get_child(n).get_child(0).hide()
			get_child(n).get_child(1).show()
			get_child(n).get_child(1).text = images[n]
		# It's a more complex effect
		else:
			get_child(n).get_child(0).show()
			get_child(n).get_child(1).hide()
			get_child(n).get_child(0).texture = load("res://Game_Scene/Textures/Choices/"+images[n]+".png")

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

# Pull down UI
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
