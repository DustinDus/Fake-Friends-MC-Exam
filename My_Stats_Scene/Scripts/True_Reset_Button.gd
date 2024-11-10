extends Button
# Button to reset stats

var asking_for_confirmation: bool
var timer: float

func _ready():
	set_process(false)
	asking_for_confirmation = false
	timer = .0

func _process(delta):
	timer+=delta
	if timer>2.0:
		set_process(false)
		asking_for_confirmation = false
		timer = 0
		text = "RESET"

func _pressed():
	AudioController.play_heavier_button() # Sound
	if asking_for_confirmation:
		disabled = true
		$"..".set_process_input(false)
		User.reset_info()
		UserStats.reset_info()
		User.load_info()
		UserStats.load_info()
		$"../../..".reset()
	else:
		asking_for_confirmation = true
		set_process(true)
		text = tr("U SURE?")
