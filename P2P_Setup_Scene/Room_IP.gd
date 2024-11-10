extends LineEdit
# To insert the room's IP

var panel: Panel
var hide_show_button: Button
var sprites: Array = []

# Prep
func _ready():
	set_process(false)
	panel = $"../Panel"
	hide_show_button = $Show_Hide_IP
	sprites.append(load("res://P2P_Setup_Scene/Textures/ShowText.png"))
	sprites.append(load("res://P2P_Setup_Scene/Textures/HideText.png"))

# Show/Hide the IP LineEdit
func _show_hide_IP():
	if is_secret():
		hide_show_button.set_button_icon(sprites[1])
		set_secret(false)
	else:
		hide_show_button.set_button_icon(sprites[0])
		set_secret(true)

# Highlight LineEdit
func _focus_entered():
	panel.show()
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2(379,148),.2)
	tween.parallel().tween_property(self,"rect_scale",Vector2(2,2),.2)
	tween.parallel().tween_property(panel,"modulate",Color(1,1,1,.4),.2)
	yield(get_tree().create_timer(.2),"timeout")
	set_process(true)

# Return LineEdit to normal on "done"
# warning-ignore:unused_argument
func _text_entered(new_text):
	set_process(false)
	.release_focus()
	yield(get_tree().create_timer(.2),"timeout")
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2(790,400),.2)
	tween.parallel().tween_property(self,"rect_scale",Vector2(1,1),.2)
	tween.parallel().tween_property(panel,"modulate",Color(1,1,1,0),.2)
	yield(get_tree().create_timer(.2),"timeout")
	panel.hide()
# Return LineEdit to normal when keyboard is hidden
func _process(_delta):
	if OS.get_virtual_keyboard_height()==0: _text_entered("")
# Return LineEdit to normal on "back" (Android only)
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: _text_entered("")
