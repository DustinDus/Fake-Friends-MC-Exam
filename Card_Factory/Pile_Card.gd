extends Node
# A card in the discard pile can only be inspected

# Info
var card_id: int
var card_color: String
var card_name: String
# To show info
var info_panel

# Init
func initialize(card_info: Array, passed_info_panel):
	# Vars
	card_id = card_info[0]
	card_color = card_info[1]
	card_name = card_info[2]
	info_panel = passed_info_panel
	# Signals
	if get_node("Cover").connect("gui_input",self,"_gui_input")!=0:
		print("!!! Player_Hand_Card can't connect a signal !!!")

# To show info
func _gui_input(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("click"):
		AudioController.play_card_shove_1() # Sound
		info_panel.show_info(card_name,card_color,card_id)

# Pass main info in an array: [ID,color,name]
func get_info() -> Array: return [card_id,card_color,card_name]
# Just get the id
func get_id() -> int: return card_id
