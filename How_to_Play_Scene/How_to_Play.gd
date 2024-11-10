extends Control
# Shows how to play and offers a few demos to test in-game mechanics

var utility_buttons: CanvasLayer
var button_container: MarginContainer
var rules_container: MarginContainer

func _ready():
	# Vars + Prep
	utility_buttons =  $Utility_Buttons
	utility_buttons.initialize(1)
	utility_buttons.offset = Vector2(0,-100)
	button_container = $Button_Container
	button_container.modulate = Color(1,1,1,0)
	rules_container = $Rules_Container
	rules_container.modulate = Color(1,1,1,0)
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(utility_buttons,"offset",Vector2(0,0),.4)
	tween.tween_property(button_container,"modulate",Color(1,1,1,1),.4)
	tween.parallel().tween_property(rules_container,"modulate",Color(1,1,1,1),.4)

func _back():
	AudioController.play_mouse_close_button() # Sound
	var rules_cards: Array = $Rules_Container/Cards_Rules.get_children().slice(6,9)
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(utility_buttons,"offset",Vector2(0,-100),.4)
	tween.tween_property(button_container,"modulate",Color(1,1,1,0),.4)
	tween.parallel().tween_property(rules_container,"modulate",Color(1,1,1,0),.4)
	tween.parallel().tween_property($Rules_Container/Turns_Rules/Hand_Card_Layer/Hand_Card, "modulate", Color(1,1,1,0), .4)
	for rules_card in rules_cards:  tween.parallel().tween_property(rules_card.get_child(0), "modulate", Color(1,1,1,0), .4)
	tween.tween_property($Background/Solid_Color.get("custom_styles/panel"), "bg_color", Color("#dcdcdc"), .4)
	yield(get_tree().create_timer(1.2),"timeout")
	# Change Scene
	if get_tree().change_scene("res://Main_Scene/Main.tscn")!=0:
		print("!!! P2P_Setup can't change scene to Main !!!")
