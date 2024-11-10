extends Control
# Demo to show how rolling progresses the turn order

var curr: int
var colors: Array
var dice: TextureButton

func _ready():
	for n in 4: colors.append(get_child(n))
	curr = 0
	colors[0].disabled = false
	dice = $Roll_Button

func _change_turn():
	while dice.disabled: yield(get_tree().create_timer(.1),"timeout")
	colors[curr].disabled = true
	curr = (curr+1)%4
	colors[curr].disabled = false
	AudioController.play_bloop_1() # Sound
