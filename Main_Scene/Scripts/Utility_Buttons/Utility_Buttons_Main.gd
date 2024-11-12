extends CanvasLayer
# The "back" and "settings" buttons (different tweeners and no translation on _ready in main)

func _ready():
	$Settings/Settings_Button.rect_position = Vector2(1290,100)
	show()

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
	$Settings/Title_List.translate()
	$Settings/Avatar_List.translate()
	$Settings/Audio_Menu.translate()

func appear():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Settings/Settings_Button, "rect_position", Vector2(1170,100), .4)

func disappear():
	$Settings/Settings_Button.disabled = true
	yield(get_tree().create_timer(.3),"timeout")
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Settings/Settings_Button, "rect_position", Vector2(1290,100), .4) 
