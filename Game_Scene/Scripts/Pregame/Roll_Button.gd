extends TextureButton
# Roll animations

var faces: Array

func initialize():
	for i in range(1,7):
		var face = load("res://Game_Scene/Textures/Dice_Faces/"+str(i)+"Face.png")
		faces.append(face)
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"rect_position",Vector2(580,100),.2)
	tween.tween_property(self,"rect_position",Vector2(380,300),.2)
	tween.tween_property(self,"rect_position",Vector2(580,500),.2)
	tween.tween_property(self,"rect_position",Vector2(780,300),.2)
	tween.tween_property(self,"rect_position",Vector2(580,300),.2)
	yield(get_tree().create_timer(1),"timeout")

# Roll animation
remote func roll(res: int):
	var prev: int # Stops same results from dulling the animation
	var v: int
	for i in 10:
		v = RNGController.common_roll(1,6)
		texture_disabled = faces[v-1]
		if v!=prev: yield(get_tree().create_timer(.1),"timeout")
		prev = v
	change(res)
	shake()

# Updates shown face
func change(v: int):
	texture_normal = faces[v-1]
	texture_pressed = faces[v-1]
	texture_hover = faces[v-1]
	texture_disabled = faces[v-1]

# End of roll animation
func shake():
	var x = rect_position.x
	var y = rect_position.y
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"rect_position",Vector2(x+5,y),.05)
	tween.tween_property(self,"rect_position",Vector2(x-5,y),.05)
	tween.tween_property(self,"rect_position",Vector2(x+5,y),.05)
	tween.tween_property(self,"rect_position",Vector2(x-5,y),.05)
	tween.tween_property(self,"rect_position",Vector2(x,y),.05)

# Dulls/Brightens button
func disable_color(b: bool):
	var c: Color
	if b==true: c = Color(1,1,1,.7)
	else: c = Color(1,1,1,1)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", c, .2)

# Moves in position of Game Roll_Button
func move_out():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"rect_position",Vector2(260,470),1)
	tween.parallel().tween_property(self,"rect_scale",Vector2(.4,.4),1)
