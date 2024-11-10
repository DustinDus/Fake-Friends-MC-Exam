extends MarginContainer
# Lists and pulls up single settings menus

var closed_pos: Vector2
var opened_pos: Vector2

# Init
func _ready():
	show()

# Translation
func translate():
	$Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/Profile.text = tr("PROFILE")
	$Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/Audio.text = tr("AUDIO")

# Sets up positions
func initialize(direction: int):
	if direction==0:
		closed_pos = Vector2(1280,0)
		opened_pos = Vector2(1040,0)
	else:
		closed_pos = Vector2(1040,-260)
		opened_pos = Vector2(1040,-60)

# Opens menu
func _Pull_Up_Settings():
	AudioController.play_camera_shutter_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", opened_pos, .4)

# Closes menu
func close():
	AudioController.play_old_camera_shutter_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", closed_pos, .4)
