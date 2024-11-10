extends Control
# Menu to choose game mode

# Starting animation
func _ready():
	# Prep
	AudioController.play_music(1) # Music
	var menu_buttons = $Buttons
	var utility_buttons = $Utility_Buttons
	utility_buttons.initialize(1)
	match MiscInfo.get_play_menu_direction():
		0:
			menu_buttons.modulate = Color(1,1,1,0)
			utility_buttons.offset = Vector2(0,-100)
		1: rect_position = Vector2(1280,0) # 840,0
		2: rect_position = Vector2(-1280,0) # -840,0
		3: pass
		4: pass
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	match MiscInfo.get_play_menu_direction():
		0:
			tween.tween_property(menu_buttons, "modulate", Color(1,1,1,1), .4)
			tween.parallel().tween_property(utility_buttons, "offset", Vector2(0,0),.4)
		_: tween.tween_property(self, "rect_position", Vector2(0,0), .3)
	# Translation
	menu_buttons.get_node("Play_With_Friends/Label").text = tr("PLAY WITH FRIENDS")
	menu_buttons.get_node("Bot_Match/Label").text = tr("BOT MATCH")

# Go to P2P_Setup
func _play_with_friends():
	AudioController.play_camera_shutter_button() # Sound
	# Prep
	MiscInfo.set_play_menu_direction(1)
	$Utility_Buttons.disable_buttons()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "rect_position", Vector2(1080,0), .3) # 840,0
	yield(get_tree().create_timer(.3),"timeout")
	# Change Scene
	if get_tree().change_scene("res://P2P_Setup_Scene/P2P_Setup.tscn")!=0:
		print("!!! Play can't change scene to P2P_Setup !!!")

# Got to Bot_Game_Setup
func _play_with_bots():
	AudioController.play_camera_shutter_button() # Sound
	# Prep
	MiscInfo.set_play_menu_direction(2)
	$Utility_Buttons.disable_buttons()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "rect_position", Vector2(-1280,0), .3) # -1080,0 -840,0
	yield(get_tree().create_timer(.3),"timeout")
	# Change Scene
	if get_tree().change_scene("res://Bot_Game_Setup_Scene/Bot_Game_Setup.tscn")!=0:
		print("!!! Play can't change scene to Bot_Game_Setup !!!")

# Back to main
func _back():
	AudioController.play_mouse_close_button() # Sound
	# Prep
	MiscInfo.set_play_menu_direction(0)
	$Utility_Buttons.disable_buttons()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Utility_Buttons, "offset", Vector2(0,-100),.4)
	tween.parallel().tween_property($Buttons, "modulate", Color(1,1,1,0), .4)
	tween.tween_property($Background/Solid_Color.get("custom_styles/panel"), "bg_color", Color("#dcdcdc"), .4)
	yield(get_tree().create_timer(.7),"timeout")
	# Change Scene
	if get_tree().change_scene("res://Main_Scene/Main.tscn")!=0:
		print("!!! P2P_Setup can't change scene to Main !!!")
