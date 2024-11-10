extends Node2D
# Manages animations

var light_modulator: CanvasModulate
var next_turn: CanvasLayer
var victory: CanvasLayer

# Initialize vars and animations
func initialize():
	light_modulator = get_child(0)
	next_turn = $Next_Turn
	next_turn.initialize()
	victory = $Victory
	victory.initialize()

# Next_Turn
func play_next_turn(id: int):
	light_modulator.set_color(Color(1,1,1,.8))
	yield(next_turn.play(id),"completed")
	light_modulator.set_color(Color(1,1,1,1))

# Victory
func play_victory(id: int, username: String):
	yield(victory.play(id,username),"completed")
