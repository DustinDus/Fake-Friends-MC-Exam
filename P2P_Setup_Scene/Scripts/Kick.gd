extends TextureButton
# Button built to kick a specific player

var id: int

signal kick_player(id)

func initialize(p_id: int, room_config: Control):
	var ok = self.connect("kick_player", room_config, "_kick_player")
	if ok!=0: print("!!! Kick can't connect a signal !!!")
	id = p_id

func _pressed():
	AudioController.play_clackier_button() # Sound
	emit_signal("kick_player", id)
