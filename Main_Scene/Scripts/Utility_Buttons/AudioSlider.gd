extends HSlider

var bus_index: int

func initialize(bus_name: String) -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	if connect("value_changed",self,"_on_value_changed")!=0:
		print("!!! A slider signal can't be connected !!!")
	if connect("drag_started",self,"_on_drag_started")!=0:
		print("!!! A slider signal can't be connected !!!")
	if connect("drag_ended",self,"_on_drag_ended")!=0:
		print("!!! A slider signal can't be connected !!!")
	match bus_index:
		0: value = User.get_master_volume()
		1: value = User.get_music_volume()
		2: value = User.get_sound_volume()
	AudioServer.set_bus_volume_db(bus_index, linear2db(value))
	#value = db2linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear2db(value))
	match bus_index:
		0: User.set_master_volume(value)
		1: User.set_music_volume(value)
		2: User.set_sound_volume(value)

func _on_drag_started(): AudioController.play_camera_shutter_button() # Sound
func _on_drag_ended(_value_changed: bool = true): AudioController.play_hard_typewriter_button() # Sound
