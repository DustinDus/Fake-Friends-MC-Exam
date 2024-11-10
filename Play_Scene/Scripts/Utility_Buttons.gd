extends CanvasLayer
# The "back" and "settings" buttons

var back_button
var settings_button

func _ready():
	back_button = $Back/Back_Button
	settings_button = $Settings/Settings_Button
	#yield(get_tree(),"idle_frame")
	translate()

func initialize(direction: int):
	if get_node_or_null("Settings/Settings_Menu")!=null: $Settings/Settings_Menu.initialize(direction)
	if get_node_or_null("Settings/Profile_Menu")!=null: $Settings/Profile_Menu.initialize(direction)
	if get_node_or_null("Settings/Title_List")!=null: $Settings/Title_List.initialize(direction)
	if get_node_or_null("Settings/Avatar_List")!=null: $Settings/Avatar_List.initialize(direction)
	if get_node_or_null("Settings/Audio_Menu")!=null: $Settings/Audio_Menu.initialize(direction)

func translate():
	$Settings/Settings_Menu.translate()
	$Settings/Profile_Menu/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/Player_Name.translate()
	$Settings/Profile_Menu/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/Player_Title.translate()
	$Settings/Profile_Menu/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/Player_Avatar.translate()
	#$Settings/Title_List.translate() - The lists translate themselves on _ready(), their translate() methods
	#$Settings/Avatar_List.translate() - are needed in main, where locale is loaded and can be changed

###################
# Hide/Show Buttons

func disable_buttons():
	back_button.disabled = true
	settings_button.disabled = true

func close_all_menus():
	$Settings/Settings_Menu.close()
	$Settings/Profile_Menu.close()
	$Settings/Title_List.close()
	$Settings/Avatar_List.close()

func hide_back():
	back_button.disabled = true
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(back_button, "rect_position", Vector2(15,-80), .4)

func show_back():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(back_button, "rect_position", Vector2(15,15), .4)
	yield(get_tree().create_timer(.4),"timeout")
	back_button.disabled = false
