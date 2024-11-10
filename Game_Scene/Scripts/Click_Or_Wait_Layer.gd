extends CanvasLayer
# Used to stop the player's actions / tell the player some things

# Timer
var t: float = 0.0
var limit: float = 0.0
# Nodes
var timer: Control
var wait: Control
var panel: Panel
var bar: TextureProgress
# 0=hand, 1=clock
var timer_sprite: Sprite
var timer_sprites: Array
# Signals
signal disappeared

# Init
func _ready():
	hide()
	set_process(false)
	set_process_input(false)
	timer = get_child(0)
	wait = get_child(1)
	panel = get_child(2)
	bar = timer.get_child(0)
	# Sprites
	timer_sprite = $Timer/Sprite
	timer_sprites = []
	timer_sprites.append(load("res://Game_Scene/Textures/Click_or_Wait_Layer/Touch.png"))
	timer_sprites.append(load("res://Game_Scene/Textures/Click_or_Wait_Layer/Clock.png"))

# Disappear after reaching limit
func _process(delta):
	t+=delta
	bar.value = (t/limit)*100
	if t>limit:
		set_process(false)
		set_process_input(false)
		disappear()

# Disappear on click
func _input(event):
	if event is InputEventMouseButton and event.pressed: disappear(event.position)

# Disappear
func disappear(click: Vector2 = Vector2(0,0)):
	set_process(false)
	set_process_input(false)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(timer,"rect_position",Vector2(61,769),.2)
	tween.parallel().tween_property(wait,"rect_position",Vector2(1219,769),.2)
	tween.parallel().tween_property(panel,"modulate",Color(1,1,1,0),.2)
	yield(get_tree().create_timer(.2),"timeout")
	wait.get_child(1).set_playing(false)
	t = 0.0
	hide()
	panel.show()
	emit_signal("disappeared", click)

func change_sprite(n: int):
	match n:
		0: timer_sprite.scale = Vector2(1,1)
		1: timer_sprite.scale = Vector2(.9,.9)
	timer_sprite.texture = timer_sprites[n]

###########################################
# Appear to give players time to read cards
# Disappear after some time or on click
#######################################

# Appear+setup to let players read a card (stops on click)
func appear_to_let_player_read(time_limit: float):
	change_sprite(0)
	show()
	AudioController.play_back_tick() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(timer,"rect_position",Vector2(61,659),.2)
	tween.parallel().tween_property(panel,"modulate",Color(1,1,1,.2),.2)
	yield(get_tree().create_timer(.2),"timeout")
	limit = time_limit
	set_process(true)
	set_process_input(true)

####################################################
# Appear to tell players to wait for synchronization
# Disappear after players synchronized
######################################

# Appear during player synchronization
func appear_to_tell_to_wait():
	panel.hide()
	show()
	wait.get_child(1).set_playing(true)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(wait,"rect_position",Vector2(1219,659),.2)
	yield(get_tree().create_timer(.2),"timeout")

##################################################################
# Appear to tell players how much time they got to play a reaction
# Disappear after some time or on a reaction being played
#########################################################

# Appear+setup to let players read a card
func appear_to_tell_player_time_left(time_limit: float):
	change_sprite(1)
	panel.hide()
	show()
	AudioController.play_back_tick() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(timer,"rect_position",Vector2(61,659),.2)
	yield(get_tree().create_timer(.2),"timeout")
	limit = time_limit
	set_process(true)
