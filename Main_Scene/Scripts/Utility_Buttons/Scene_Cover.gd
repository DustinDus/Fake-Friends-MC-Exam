extends Panel
# To stop the user from doing stuff in the scene while a menu is open

# Start hidden
func _ready(): hide()

# Appear
func _cover_scene():
	show()
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1,1,1,.2), .2)

# Disappear (and close menu)
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_parent().get_node("Settings_Menu").close()
		OS.hide_virtual_keyboard()
		modulate = Color(1,1,1,0)
		hide()
