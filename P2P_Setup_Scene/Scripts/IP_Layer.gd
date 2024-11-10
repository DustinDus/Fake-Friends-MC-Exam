extends CanvasLayer
# Shows the user's IP

var user_ip: Label
var show: Button
var t: float

# Prep
func _ready():
	$Label.text = tr("YOUR IP")
	user_ip = $User_IP
	show = $Show
	set_process(false)
	t = 0.0
	show()

# Reset button if not confirmed
func _process(delta):
	t+=delta
	if t>3.0:
		set_process(false)
		show.text = tr("SHOW")
		t = 0.0

# Show button effect
func _show_ip():
	# Ask confirmation
	if t==0.0:
		AudioController.play_camera_shutter_button() # Sound
		show.text = tr("REALLY?")
		set_process(true)
	# Hide IP
	elif t<0.0:
		AudioController.play_old_camera_shutter_button() # Sound
		t=0.0
		show.text = tr("SHOW")
		user_ip.text = "???.???.???.???"
	# Show IP
	else:
		AudioController.play_camera_shutter_button() # Sound
		t = -1.0
		show.text = tr("HIDE")
		user_ip.text = Network.ip_address
		set_process(false)

# Open
func pull_up():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"offset",Vector2(0,0),.3)
# Close
func pull_down():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"offset",Vector2(0,170),.3)
