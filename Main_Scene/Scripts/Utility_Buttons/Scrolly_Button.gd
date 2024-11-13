extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	if connect("focus_entered",self,"_on_focus_entered")!=0: print("!!! Can't connect a scrolly button !!!")
	if connect("focus_exited",self,"_on_focus_exited")!=0: print("!!! Can't connect a scrolly button !!!")

# Helps with touch
func _on_focus_entered():
	yield(get_tree().create_timer(.01),"timeout")
	set_action_mode(ACTION_MODE_BUTTON_PRESS)
func _on_focus_exited(): set_action_mode(ACTION_MODE_BUTTON_RELEASE)
