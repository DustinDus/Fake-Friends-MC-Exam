extends Panel
# Also to stop stuff while a menu is open, the language menu specifically, which is only in main

# Start hidden
func _ready(): hide()

# Appear
func _cover_scene():
	show()
	AudioController.play_camera_shutter_button() # Sound
	$"..".layer = 2 # This line and the next one are to avoid conflicts between the two menus
	$"../../Utility_Buttons/Settings/Settings_Button".mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1,1,1,.2), .2)

# Disappear (and close menu)
func _gui_input(event = null):
	if event is InputEventMouseButton and event.pressed:
		AudioController.play_old_camera_shutter_button() # Sound
		$"..".layer = 1 # This line and the next one are to avoid conflicts between the two menus
		$"../../Utility_Buttons/Settings/Settings_Button".mouse_filter = Control.MOUSE_FILTER_STOP
		$".."._trigger_panel()
		OS.hide_virtual_keyboard()
		modulate = Color(1,1,1,0)
		hide()
