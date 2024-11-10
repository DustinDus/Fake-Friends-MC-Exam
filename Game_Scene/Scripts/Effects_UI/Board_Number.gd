extends Control
# Animation+Logic to select a number on the grid

var unique_id: int
var choice: int
# GUI Nodes
var back_panel: Panel
var label_panel: Panel
var confirm_button: Button
var confirm_panel: Panel
var touch_grid: Panel 
# Signals
signal tile_was_chosen

# Init
func initialize():
	# Get nodes
	back_panel = $Back_Panel
	label_panel = $Label_Panel
	confirm_button = $Confirm_Panel/Confirm_Button
	confirm_panel = $Confirm_Panel
	touch_grid = $Touch_Grid
	$Instruction.text = tr("CLICK ON THE MAP TO SELECT A TILE")
	# Connect signals
	if touch_grid.connect("tile_was_chosen",self,"_register_tile")!=0:
		print("!!! Board_Number can't connect a signal !!!")
	if connect("tile_was_chosen",get_parent(),"_answer_x")!=0:
		print("!!! Board_Number can't connect a signal !!!")

# Appear
func pull_up(activator_unique_id: int):
	# Preparation
	label_panel.get_child(0).text = "?"
	unique_id = activator_unique_id
	rect_position = Vector2(0,0)
	modulate = Color(1,1,1,0)
	label_panel.modulate = Color(1,1,1,0)
	confirm_panel.modulate = Color(1,1,1,0)
	confirm_button.modulate = Color(1,1,1,0)
	confirm_button.disabled = true
	# Animation
	AudioController.play_generic_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate",Color(1,1,1,1),.5)
	tween.tween_property(label_panel,"modulate",Color(1,1,1,1),.5)
	tween.parallel().tween_property(confirm_panel,"modulate",Color(1,1,1,1),.5)
	yield(get_tree().create_timer(1.1),"timeout")

# Register the chosen tile
func _register_tile(n: int):
	if PlayersList.get_my_unique_id()==unique_id:
		choice = n
		if PlayersList.am_on(): rpc("update_label",n)
		update_label(n)
		confirm_button.disabled = false
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(confirm_button,"modulate",Color(1,1,1,.5),.5)
# Update text on the label panel
remote func update_label(n: int): label_panel.get_child(0).text = str(n)

# Confirm choice and send answer
func pull_down():
	# Disappear
	AudioController.play_heavier_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(confirm_panel,"modulate",Color(1,1,1,0),.5)
	tween.tween_property(label_panel,"modulate",Color(1,1,1,0),.5)
	tween.tween_property(self,"modulate",Color(1,1,1,0),.5)
	yield(get_tree().create_timer(1.5),"timeout")
	rect_position = Vector2(0,-1000)

# Give the answer
func _pass_choice(): emit_signal("tile_was_chosen",choice)
