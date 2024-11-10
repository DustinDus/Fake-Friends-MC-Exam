extends Panel
const selectable_card_script = preload("res://Card_Factory/Selectable_Card.gd")
# Sets up a selection between multiple reaction cards and returns the chosen card's index

# Selected card (child index)
var card_index: int
var card_ids: Array
# Nodes
var info_panel: Panel
var container: ScrollContainer
var react_button: Button
var pass_button: Button
# Signal choice
signal communicate_answer

# Timer before disappearing
var limit: float
var t: float

# To avoid sounds when loading the scene
func _ready(): set_process(false)

# Get vars
func initialize():
	info_panel = $"../../../Card_UI/Info_Panel_UI/Card_Info"
	container = get_child(0)
	react_button = get_child(1)
	react_button.text = tr("REACT!")
	pass_button = get_child(2)
	pass_button.text = tr("PASS")
	react_button.disabled = true
	pass_button.disabled = false
	show()

# Count until it disappears
func _process(delta):
	t+=delta
	if t>limit: _pass_up()

# Tidy up pool for specifications
func pre_setup_UI(card_pool: Array, time_limit: float):
	# Reset
	var card_num = card_pool.size()
	card_index = -1
	card_ids.clear()
	limit = time_limit
	t = 0
	set_process(true)
	# Stop if hand is empty
	if card_num==0:
		_confirm_reaction()
	# Proceed otherwise
	else:
		if card_num==1: card_num+=1 # Add space for the buttons
		setup_UI(card_pool, card_num)

# Adjust size and cards
func setup_UI(card_pool: Array, card_num:int):
	# Setup panel
	rect_size = Vector2(40+card_num*145,rect_size.y)
	container.rect_size = Vector2(card_num*145*2,container.rect_size.y)
	rect_position = Vector2((1280-rect_size.x)/2,rect_position.y)
	# Setup button(s)
	react_button.rect_position = Vector2((rect_size.x-react_button.rect_size.x)/2-70,react_button.rect_position.y)
	pass_button.rect_position = Vector2((rect_size.x-pass_button.rect_size.x)/2+70,pass_button.rect_position.y)
	# Setup cards
	for card in card_pool:
		card_ids.append(card.get_id())
		container.get_node("HBoxContainer").add_child(card)
		var card_info = card.get_info()
		card.set_script(selectable_card_script)
		card.initialize(card_info,info_panel)
	# Appear
	pass_button.disabled = false
	AudioController.play_card_slide_7() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2(rect_position.x,325),.5)

# Get card id + UI change
func _select_card(index: int):
	# Highlight card
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if card_index!=-1: tween.tween_property(container.get_node("HBoxContainer").get_child(card_index).get_child(0),"modulate",Color(1,1,1),.2)
	tween.parallel().tween_property(container.get_node("HBoxContainer").get_child(index).get_child(0),"modulate",Color(.6,.6,.6),.2)
	# Allow confirmation
	react_button.disabled = false
	card_index = index

# Communicate choice and disappear
func _confirm_reaction():
	# Disappear
	set_process(false)
	react_button.disabled = true
	pass_button.disabled = true
	AudioController.play_card_slide_8() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2(rect_position.x,745),.5)
	yield(get_tree().create_timer(.5),"timeout")
	# Empty pool
	for card in container.get_node("HBoxContainer").get_children(): card.queue_free()
	# Answer
	if card_index==-1: emit_signal("communicate_answer",0)
	else: emit_signal("communicate_answer",card_ids[card_index])

# Stop choosing cards
func _pass_up():
	card_index = -1
	_confirm_reaction()
