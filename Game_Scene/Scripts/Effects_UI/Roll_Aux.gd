extends Control
# Aux for rolling effects UI

# Logic, Button, UI
var roll_aux_plate: Panel
var roll_button: TextureButton
var dice_color: int
# Signal for Eff classes
signal communicate_answer

# Init
func initialize():
	roll_aux_plate = $Roll_Aux_Plate
	roll_aux_plate.initialize()
	roll_button = $Roll_Button
	roll_button.initialize(-1)
	dice_color = -1

# How many rolls
func pre_setup_UI(type: String):
	# Reset button
	roll_button.change(1)
	roll_button.disabled = true
	roll_button.disable_color(true)
	roll_button.rect_position = Vector2(600,-120)
	yield(get_tree().create_timer(.25),"timeout")
	# UI
	setup_UI(int(type))

# Sets up UI
func setup_UI(required_rolls: int):
	# Pull the plate(s) up
	yield(roll_aux_plate.setup_UI(required_rolls),"completed")
	# Pull the dice up
	roll_button.rect_position = Vector2(600,300)
	roll_button.modulate = Color(1,1,1,0)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(roll_button, "modulate", Color(1,1,1,.7), .5)
	yield(get_tree().create_timer(.55),"timeout")
	emit_signal("communicate_answer")

# Allow someone to roll
func allow_to_roll(activator_unique_id: int, color: String):
	dice_color = int(color)
	if PlayersList.get_my_unique_id()==activator_unique_id:
		roll_button.disable_color(false,dice_color)
		roll_button.disabled = false
	else: roll_button.disable_color(true,dice_color)

# Close the UI
func close_UI():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(roll_button, "modulate", Color(1,1,1,0), .5)
	yield(get_tree().create_timer(.55),"timeout")
	roll_button.rect_position = Vector2(600,-120)
	yield(roll_aux_plate.remove_UI(),"completed")
	emit_signal("communicate_answer")

# Activator rolls
func _roll():
	get_parent().done = true # Stop timer
	roll_button.disabled = true
	var v: int = RNGController.unique_roll(1,6)
	if PlayersList.am_on(): rpc("answer",v)
	yield(answer(v),"completed")
	yield(get_tree().create_timer(.5),"timeout")
# Everyone returns the answer
remote func answer(answer):
	yield(roll_button.roll(answer),"completed")
	roll_aux_plate.change(answer,dice_color)
	yield(get_tree().create_timer(.5),"timeout")
	emit_signal("communicate_answer",answer)
