extends Control

var utility_buttons: CanvasLayer
var credits_container: MarginContainer
var sprites: Control

func _ready():
	# Vars + Prep
	utility_buttons =  $Utility_Buttons
	utility_buttons.initialize(1)
	utility_buttons.offset = Vector2(0,-100)
	credits_container = $Credits_Container
	credits_container.modulate = Color(1,1,1,0)
	sprites = $Sprites
	sprites.get_node("Board").modulate = Color(1,1,1,0)
	for n in range(1,4):
		for m in 7:
			sprites.get_node("Row"+str(n)).get_child(m).modulate = Color(1,1,1,0)
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(utility_buttons,"offset",Vector2(0,0),.4)
	tween.tween_callback(self,"cards",[.05])
	tween.tween_property(sprites.get_node("Board"),"modulate",Color(1,1,1,.4),.2)
	tween.parallel().tween_property(credits_container,"modulate",Color(1,1,1,1),.4)

func _back():
	utility_buttons.disable_buttons()
	AudioController.play_mouse_close_button() # Sound
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_callback(self,"cards",[0])
	tween.tween_property(sprites.get_node("Board"),"modulate",Color(1,1,1,0),.2)
	tween.parallel().tween_property(credits_container,"modulate",Color(1,1,1,0),.4)
	tween.tween_property(utility_buttons,"offset",Vector2(0,-100),.4)
	yield(get_tree().create_timer(1),"timeout")
	# Change Scene
	if get_tree().change_scene("res://Main_Scene/Main.tscn")!=0:
		print("!!! P2P_Setup can't change scene to Main !!!")

func cards(modulation: float):
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprites.get_node("Row1").get_child(0),"modulate",Color(1,1,1,modulation),.05)
	tween.tween_property(sprites.get_node("Row1").get_child(1),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row2").get_child(0),"modulate",Color(1,1,1,modulation),.05)
	tween.tween_property(sprites.get_node("Row1").get_child(2),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row2").get_child(1),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row3").get_child(0),"modulate",Color(1,1,1,modulation),.05)
	tween.tween_property(sprites.get_node("Row1").get_child(3),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row2").get_child(2),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row3").get_child(1),"modulate",Color(1,1,1,modulation),.05)
	tween.tween_property(sprites.get_node("Row1").get_child(4),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row2").get_child(3),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row3").get_child(2),"modulate",Color(1,1,1,modulation),.05)
	tween.tween_property(sprites.get_node("Row1").get_child(5),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row2").get_child(4),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row3").get_child(3),"modulate",Color(1,1,1,modulation),.05)
	tween.tween_property(sprites.get_node("Row1").get_child(6),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row2").get_child(5),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row3").get_child(4),"modulate",Color(1,1,1,modulation),.05)
	tween.tween_property(sprites.get_node("Row2").get_child(6),"modulate",Color(1,1,1,modulation),.05)
	tween.parallel().tween_property(sprites.get_node("Row3").get_child(5),"modulate",Color(1,1,1,modulation),.05)
	tween.tween_property(sprites.get_node("Row3").get_child(6),"modulate",Color(1,1,1,modulation),.05)
