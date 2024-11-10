extends MarginContainer
# A card in a selection box can be inspected and chosen for whatever reason it's selectable in the first place

# Data for info panel
var card_color: String
var card_id: int
var card_name: String
# Reference to info panel
var info_panel
# Great-grandpa's name to tell if card is actually selectable or just viewable
var great_gramps: String

# Is the card meant to be hidden?
var covered: bool

# Init
func initialize(card_info: Array, passed_info_panel):
	# Vars
	card_id = card_info[0]
	card_color = card_info[1]
	card_name = card_info[2]
	info_panel = passed_info_panel
	great_gramps = get_parent().get_parent().get_parent().name
	# Signals
	set_process(true)
	if get_node("Cover").connect("gui_input",self,"_gui_input")!=0:
		print("!!! Player_Hand_Card can't connect a signal !!!")
	if get_node("Cover").connect("mouse_entered",self,"_on_mouse_entered")!=0:
		print("!!! Player_Hand_Card can't connect a signal !!!")
	if get_node("Cover").connect("mouse_exited",self,"_on_mouse_exited")!=0:
		print("!!! Player_Hand_Card can't connect a signal !!!")

# To show info
func _gui_input(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("click"):
		AudioController.play_card_shove_1() # Sound
		if not covered: info_panel.show_info(card_name,card_color,card_id)
		if great_gramps!="Card_View_Aux": get_parent().get_parent().get_parent()._select_card(get_index())
		# Animation
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(get_child(0),"self_modulate",Color(.6,.6,.6),.2)
		tween.tween_property(get_child(0),"self_modulate",Color(1,1,1),.2)

# Light/Dull border
func _on_mouse_entered():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(get_child(0),"self_modulate",Color(.8,.8,.8),.2)
func _on_mouse_exited():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(get_child(0),"self_modulate",Color(1,1,1),.2)

# Cover card
func cover():
	# Set up cover
	var card_back = Sprite.new()
	card_back.name = "card_back"
	card_back.texture = load("res://Card_Factory/Textures/"+card_color+"Back.png")
	card_back.position = Vector2(125,175)
	card_back.scale = Vector2(.2,.2)
	self.add_child(card_back)
	move_child(card_back,0)
	covered = true
	# Delete the rest
	get_node("Architecture").queue_free()
	get_node("Background").queue_free()

# Pass main info in an array: [ID,color,name]
func get_info() -> Array: return [card_id,card_color,card_name]
# Just get the id
func get_id() -> int: return card_id
