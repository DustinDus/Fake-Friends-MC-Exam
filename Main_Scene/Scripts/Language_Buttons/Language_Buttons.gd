extends CanvasLayer
# Handle language menu and buttons

var language_button: TextureButton
var language_panel: Panel

# Init
func _ready():
	# Vars
	language_panel = $Language_Panel
	language_button = $Language_Button
	# Vars' stuff
	language_panel.show()
	language_button.rect_position = Vector2(-100,100)
	var chosen_language_child: TextureButton = $Language_Panel/MarginContainer/VBoxContainer.get_child(User.get_language())
	language_button.texture_normal = chosen_language_child.texture_normal
	language_button.texture_pressed = chosen_language_child.texture_pressed
	language_button.texture_hover = chosen_language_child.texture_hover
	language_button.texture_disabled = chosen_language_child.texture_normal
	chosen_language_child.disabled = true

# Open/Close language menu
func _trigger_panel():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if language_panel.rect_position.x==-150: tween.parallel().tween_property(language_panel, "rect_position", Vector2(0,75), .4)
	else: tween.parallel().tween_property(language_panel, "rect_position", Vector2(-150,75), .4)

# Change the language button's texture
func _change_language(language: int):
	AudioController.play_hard_typewriter_button() # Sound
	$Language_Panel/MarginContainer/VBoxContainer.get_child(User.get_language()).disabled = false
	var chosen_language_child: TextureButton = $Language_Panel/MarginContainer/VBoxContainer.get_child(language)
	language_button.texture_normal = chosen_language_child.texture_normal
	language_button.texture_pressed = chosen_language_child.texture_pressed
	language_button.texture_hover = chosen_language_child.texture_hover
	language_button.texture_disabled = chosen_language_child.texture_normal
	chosen_language_child.disabled = true
	User.set_language(language)

# When loading the scene
func appear():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(language_button, "rect_position", Vector2(30,100), .4)

# When changing scene
func disappear():
	language_button.disabled = true
	yield(get_tree().create_timer(.3),"timeout")
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(language_button, "rect_position", Vector2(-100,100), .4) 
