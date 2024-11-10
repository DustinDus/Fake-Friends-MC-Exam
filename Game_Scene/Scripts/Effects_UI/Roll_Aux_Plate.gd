extends Panel
# Animation aux for rolling effs

# Textures
var faces: Array
# Result plates
var results: Array
# Help with UI
var results_to_track: int
var results_tracked: int

# Init
func initialize():
	for i in range(0,7):
		var face = load("res://Game_Scene/Textures/Dice_Faces/"+str(i)+"Face.png")
		faces.append(face)
	for n in 4: results.append(get_child(n))

# Plate first, results them
func setup_UI(dice_to_roll: int):
	for n in 4:
		results[n].rect_position = Vector2(20,20)
		results[n].get_child(0).texture = faces[0]
		results[n].get_child(0).modulate = Color(1,1,1,1)
	results_to_track = dice_to_roll
	results_tracked = 0
	# Move plates
	AudioController.play_chips_handle_6() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"rect_position",Vector2(580,280),.4)
	match results_to_track:
		2:
			tween.tween_callback(AudioController,"play_chip_lay_2") # Sound
			tween.tween_property(results[0],"rect_position",Vector2(-70,-30),.2)
			tween.tween_callback(AudioController,"play_chip_lay_2") # Sound
			tween.tween_property(results[1],"rect_position",Vector2(110,-30),.2)
		3:
			tween.tween_callback(AudioController,"play_chip_lay_2") # Sound
			tween.tween_property(results[0],"rect_position",Vector2(-75,-20),.2)
			tween.tween_callback(AudioController,"play_chip_lay_2") # Sound
			tween.tween_property(results[1],"rect_position",Vector2(20,-85),.2)
			tween.tween_callback(AudioController,"play_chip_lay_2") # Sound
			tween.tween_property(results[2],"rect_position",Vector2(115,-20),.2)
		4:
			tween.tween_callback(AudioController,"play_chip_lay_2") # Sound
			tween.tween_property(results[0],"rect_position",Vector2(-80,0),.2)
			tween.tween_callback(AudioController,"play_chip_lay_2") # Sound
			tween.tween_property(results[1],"rect_position",Vector2(-25,-75),.2)
			tween.tween_callback(AudioController,"play_chip_lay_2") # Sound
			tween.tween_property(results[2],"rect_position",Vector2(65,-75),.2)
			tween.tween_callback(AudioController,"play_chip_lay_2") # Sound
			tween.tween_property(results[3],"rect_position",Vector2(120,0),.2)
	yield(get_tree().create_timer((.2*results_to_track)+.45),"timeout")
	if results_to_track==1: results_to_track = 0

# Results first, plate then
func remove_UI():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	for n in results_to_track:
		tween.tween_callback(AudioController,"play_chip_lay_1") # Sound
		tween.tween_property(results[n],"rect_position",Vector2(20,20),.2)
	tween.tween_callback(AudioController,"play_chips_handle_4") # Sound
	tween.tween_property(self,"rect_position",Vector2(580,-140),.2)
	yield(get_tree().create_timer((.2*results_to_track)+.25),"timeout")

# Updates shown face
func change(v: int, color: int):
	var sprite = results[results_tracked].get_child(0)
	if color!=-1: color_button(sprite,color)
	results_tracked+=1
	var x = sprite.position.x
	var y = sprite.position.y
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite,"position",Vector2(x+5,y),.05)
	tween.tween_property(sprite,"position",Vector2(x-5,y),.05)
	tween.tween_property(sprite,"position",Vector2(x+5,y),.05)
	tween.tween_property(sprite,"position",Vector2(x-5,y),.05)
	tween.tween_property(sprite,"position",Vector2(x,y),.05)
	sprite.texture = faces[v]
# Updates dice's color
func color_button(sprite: Sprite, color: int):
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	match color:
		0: tween.tween_property(sprite, "modulate", Color(1,.6,.6,1), .3)
		1: tween.tween_property(sprite, "modulate", Color(.6,.6,1,1), .3)
		2: tween.tween_property(sprite, "modulate", Color(.6,1,.6,1), .3)
		3: tween.tween_property(sprite, "modulate", Color(1,1,.6,1), .3)
