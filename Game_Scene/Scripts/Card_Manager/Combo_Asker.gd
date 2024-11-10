extends Control
# UI to ask the player wether they want to activate a combo or not

# UI nodes
var panel: Panel
var confirm_button: Button
var refuse_button: Button
# Signals
signal answer

# Start off hidden
func _ready(): hide()

# Init
func initialize():
	panel = get_child(0)
	confirm_button = get_child(1)
	refuse_button = get_child(2)

# Setup + Appear animation
func appear(question: String):
	show()
	panel.get_child(0).text = question
	AudioController.play_generic_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel,"modulate",Color(1,1,1,1),.2)
	tween.tween_property(confirm_button,"modulate",Color(1,1,1,1),.2)
	tween.tween_property(refuse_button,"modulate",Color(1,1,1,1),.2)
	confirm_button.disabled = false
	refuse_button.disabled = false

# Fixup + Disappear animation
func disappear():
	confirm_button.disabled = true
	refuse_button.disabled = true
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel,"modulate",Color(1,1,1,0),.2)
	tween.tween_property(confirm_button,"modulate",Color(1,1,1,0),.2)
	tween.tween_property(refuse_button,"modulate",Color(1,1,1,0),.2)
	yield(get_tree().create_timer(.6),"timeout")
	hide()

# Confirm
func _confirm_combo():
	disappear()
	AudioController.play_heavier_button() # Sound
	yield(get_tree().create_timer(.65),"timeout")
	emit_signal("answer",true)

# Refuse
func _refuse_combo():
	disappear()
	AudioController.play_clackier_button() # Sound
	yield(get_tree().create_timer(.65),"timeout")
	emit_signal("answer",false)
