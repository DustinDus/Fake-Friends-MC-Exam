extends TextureButton
# Demo to roll a button

var faces: Array

func _ready():
	for i in range(1,7):
		var face = load("res://Game_Scene/Textures/Dice_Faces/"+str(i)+"Face.png")
		faces.append(face)

func _pressed():
	disabled = true
	AudioController.play_dice_roll() # Sound
	var prev: int # Stops same results from dulling the animation
	var v: int
	for i in 10:
		v = RNGController.unique_roll(1,6)
		texture_disabled = faces[v-1]
		if v!=prev: yield(get_tree().create_timer(.1),"timeout")
		prev = v
	change(v)
	shake()

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
	yield(get_tree().create_timer(.25),"timeout")
	disabled = false
