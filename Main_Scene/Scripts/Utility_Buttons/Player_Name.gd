extends Control
# Shows current username

var current_name # User's current name
var name_input # LineEdit containing new name
var name_error # Error message

# Init
func _ready():
	current_name = get_node("Current_Name")
	current_name.text = User.get_username()
	name_input = get_node_or_null("Name_Input")
	name_error = get_node_or_null("Name_Error")

# Translation
func translate():
	$Option_Name.text = tr("USERNAME") + ": "
	if get_node_or_null("Name_Input")!=null: $Name_Input.placeholder_text = tr("NEW NAME HERE")
	if get_node_or_null("Change_Name")!=null: $Change_Name.text = tr("CHANGE")

# Change stored name
func change_name():
	if name_input.text=="":
		AudioController.play_clackier_button() # Sound
		name_error.text = tr("PLEASE TYPE A NAME")
		if !name_error.is_visible(): show_error()
		else: error_life = .0
		return
	if name_input.text.length()>12:
		AudioController.play_clackier_button() # Sound
		name_error.text = tr("PLEASE TYPE A NAME SHORTER THAN 12 CHARACTERS")
		if !name_error.is_visible(): show_error()
		else: error_life = .0
		return
	AudioController.play_hard_typewriter_button() # Sound
	User.set_username(name_input.text)
	current_name.text = name_input.text
	name_input.text = ""

# Keep track of error's time
var error_life: float = .0
# Show error and hide it on a timer
func show_error():
	name_error.visible = true
	while error_life<3.0:
		yield(get_tree().create_timer(.2),"timeout")
		error_life+=.2
	name_error.visible = false
	error_life = .0
