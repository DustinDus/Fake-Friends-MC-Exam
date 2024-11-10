extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Starting animation
func _ready():
	# Reset MiscInfo
	AudioController.play_music(0) # Music
	MiscInfo.play_menu_direction = 0
	MiscInfo.room_config_direction = 0
	# Prep
	$Background/Red_Scroller.modulate = Color(1,1,1,0)
	$Background/Black_Scroller.modulate = Color(1,1,1,0)
	$Logo.modulate = Color(1,1,1,0)
	$Menu_Buttons.modulate = Color(1,1,1,0)
	$Utility_Buttons.initialize(0)
	# Translate
	yield(get_tree(),"idle_frame")
	_translate(User.get_language())
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Background/Red_Scroller, "modulate", Color(1,1,1,1), .4)
	tween.parallel().tween_property($Background/Black_Scroller, "modulate", Color(1,1,1,1), .4)
	tween.tween_property($Logo, "modulate", Color(1,1,1,1), .2)
	tween.parallel().tween_property($Menu_Buttons, "modulate", Color(1,1,1,1), .2)
	yield(get_tree().create_timer(.6),"timeout")
	$Utility_Buttons.appear()
	$Language_Buttons.appear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Play Button
func _play():
	AudioController.play_menu_button() # Sound
	# Prep
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Play.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/How_to_Play.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/My_Stats.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Credits.disabled = true
	$Utility_Buttons.disappear()
	$Language_Buttons.disappear()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Logo, "modulate", Color(1,1,1,0), .3)
	tween.parallel().tween_property($Menu_Buttons, "modulate", Color(1,1,1,0), .3)
	tween.tween_property($Background/Solid_Color.get("custom_styles/panel"), "bg_color", Color("#c8c8c8"), .4)
	tween.parallel().tween_property($Background/Red_Scroller, "position", Vector2(0,-40), .4)
	tween.parallel().tween_property($Background/Black_Scroller, "position", Vector2(0,765), .4)
	yield(get_tree().create_timer(.7),"timeout")
	# Change Scene to Game Setup
	if get_tree().change_scene("res://Play_Scene/Play.tscn")!=0:
		print("!!! Main can't change scene !!!")

# How_to_Play Button
func _how_to_play():
	AudioController.play_button_9() # Sound
	# Prep
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Play.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/How_to_Play.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/My_Stats.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Credits.disabled = true
	$Utility_Buttons.disappear()
	$Language_Buttons.disappear()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Logo, "modulate", Color(1,1,1,0), .3)
	tween.parallel().tween_property($Menu_Buttons, "modulate", Color(1,1,1,0), .3)
	tween.tween_property($Background/Solid_Color.get("custom_styles/panel"), "bg_color", Color("#c8c8c8"), .4)
	tween.parallel().tween_property($Background/Red_Scroller, "position", Vector2(0,-40), .4)
	tween.parallel().tween_property($Background/Black_Scroller, "position", Vector2(0,765), .4)
	yield(get_tree().create_timer(.7),"timeout")
	# Change Scene to Game Setup
	if get_tree().change_scene("res://How_to_Play_Scene/How_to_Play.tscn")!=0:
		print("!!! Main can't change scene !!!")

# My_Info Button
func _my_stats():
	AudioController.play_button_9() # Sound
	# Prep
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Play.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/How_to_Play.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/My_Stats.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Credits.disabled = true
	$Utility_Buttons.disappear()
	$Language_Buttons.disappear()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Logo, "modulate", Color(1,1,1,0), .3)
	tween.parallel().tween_property($Menu_Buttons, "modulate", Color(1,1,1,0), .3)
	tween.tween_property($Background/Solid_Color.get("custom_styles/panel"), "bg_color", Color("#c8c8c8"), .4)
	tween.parallel().tween_property($Background/Red_Scroller, "position", Vector2(0,-40), .4)
	tween.parallel().tween_property($Background/Black_Scroller, "position", Vector2(0,765), .4)
	yield(get_tree().create_timer(.7),"timeout")
	# Change Scene to Game Setup
	if get_tree().change_scene("res://My_Stats_Scene/My_Stats.tscn")!=0:
		print("!!! Main can't change scene !!!")

# Credits Button
func _credits():
	AudioController.play_button_9() # Sound
	# Prep
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Play.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/How_to_Play.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/My_Stats.disabled = true
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Credits.disabled = true
	$Utility_Buttons.disappear()
	$Language_Buttons.disappear()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Logo, "modulate", Color(1,1,1,0), .3)
	tween.parallel().tween_property($Menu_Buttons, "modulate", Color(1,1,1,0), .3)
	tween.tween_property($Background/Solid_Color.get("custom_styles/panel"), "bg_color", Color("#c8c8c8"), .4)
	tween.parallel().tween_property($Background/Red_Scroller, "position", Vector2(0,-40), .4)
	tween.parallel().tween_property($Background/Black_Scroller, "position", Vector2(0,765), .4)
	yield(get_tree().create_timer(.7),"timeout")
	# Change Scene to Game Setup
	if get_tree().change_scene("res://Credits_Scene/Credits.tscn")!=0:
		print("!!! Main can't change scene !!!")

# Change language
func _translate(language: int):
	# Set Language
	if language==0: TranslationServer.set_locale("en")
	else: TranslationServer.set_locale("it")
	# Menu
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Play.text = tr("PLAY")
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/How_to_Play.text = tr("HOW TO PLAY")
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer2/My_Stats.text = tr("MY STATS")
	$Menu_Buttons/VBoxContainer/HBoxContainer/VBoxContainer/Credits.text = tr("CREDITS")
	# Buttons
	$Utility_Buttons.translate()
