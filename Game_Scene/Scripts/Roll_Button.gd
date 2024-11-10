extends TextureButton
# Roll animations

var faces: Array
var current_face: int

# Init textures and pull up animation
func initialize(animation: int, is_roll: bool = true):
	current_face = 1
	# Regular dice
	if is_roll:
		for i in range(1,7):
			var face = load("res://Game_Scene/Textures/Dice_Faces/"+str(i)+"Face.png")
			faces.append(face)
	# Escape dice
	else:
		for i in range(1,7):
				var face = load("res://Game_Scene/Textures/Dice_Faces/"+str(i)+"JailFace.png")
				faces.append(face)
	# Animation
	# Changes according to who calls
	if animation==0: yield(pregame_animation(),"completed")
	elif animation==1: yield(game_animation(),"completed")
	elif animation==2: yield(generic_animation(),"completed")
# Pregame animation
func pregame_animation():
	AudioController.play_complex_movements_whoosh_6() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"rect_position",Vector2(580,100),.2)
	tween.tween_property(self,"rect_position",Vector2(380,300),.2)
	tween.tween_property(self,"rect_position",Vector2(580,500),.2)
	tween.tween_property(self,"rect_position",Vector2(780,300),.2)
	tween.tween_property(self,"rect_position",Vector2(580,300),.2)
	yield(get_tree().create_timer(1.1),"timeout")
# Game animation
func game_animation():
	shake()
	yield(get_tree().create_timer(.3),"timeout")
# Generic animation, just fades in
func generic_animation():
	modulate = Color(1,1,1,0)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"modulate",Color(1,1,1,1),.4)
	yield(get_tree().create_timer(.5),"timeout")

# Roll animation
remote func roll(res: int):
	AudioController.play_dice_roll() # Sound
	var prev: int # Stops same results from dulling the animation
	var v: int
	for i in 10:
		v = RNGController.unique_roll(1,6)
		texture_disabled = faces[v-1]
		if v!=prev: yield(get_tree().create_timer(.1),"timeout")
		prev = v
	change(res)
	shake()
	current_face = res

# Updates shown face
func change(v: int):
	texture_normal = faces[v-1]
	texture_pressed = faces[v-1]
	texture_hover = faces[v-1]
	texture_disabled = faces[v-1]

# End of roll animation
func shake():
	AudioController.play_cornflakes() # Sound
	var x = rect_position.x
	var y = rect_position.y
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"rect_position",Vector2(x+5,y),.05)
	tween.tween_property(self,"rect_position",Vector2(x-5,y),.05)
	tween.tween_property(self,"rect_position",Vector2(x+5,y),.05)
	tween.tween_property(self,"rect_position",Vector2(x-5,y),.05)
	tween.tween_property(self,"rect_position",Vector2(x,y),.05)

# Dulls/Brightens button
func disable_color(b: bool, color: int = -1):
	var c: Color
	match color:
		-1:
			if b==true: c = Color(1,1,1,.7)
			else: c = Color(1,1,1,1)
		0:
			if b==true: c = Color(1,.6,.6,.7)
			else: c = Color(1,.6,.6,1)
		1:
			if b==true: c = Color(.6,.6,1,.7)
			else: c = Color(.6,.6,1,1)
		2:
			if b==true: c = Color(.6,1,.6,.7)
			else: c = Color(.6,1,.6,1)
		3:
			if b==true: c = Color(1,1,.6,.7)
			else: c = Color(1,1,.6,1)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", c, .2)

# Moves in position of Game Roll_Button
func move_out():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"rect_position",Vector2(260,450),1)
	tween.parallel().tween_property(self,"rect_scale",Vector2(.4,.4),1)
