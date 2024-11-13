extends Panel
const selectable_card_script = preload("res://Card_Factory/Selectable_Card.gd")
# Aux for card selection effects UI

# Selected card (child index)
var card_index: int
# Nodes
var info_panel: Panel
var container: ScrollContainer
var choose_button: Button
var stop_button: Button
var pull_up_pull_down_button: TextureButton
# Signal choice
signal communicate_answer

# Get vars
func initialize():
	info_panel = $"../../Card_UI/Info_Panel_UI/Card_Info"
	container = get_child(0)
	choose_button = get_child(1)
	choose_button.text = tr("CHOOSE")
	stop_button = get_child(2)
	stop_button.text = tr("STOP")
	pull_up_pull_down_button = get_child(3)
	choose_button.disabled = true
	stop_button.disabled = true
	stop_button.hide()

# Tidy up pool for specifications
func pre_setup_UI(info_pool: Array):
	var specifications = info_pool[0]
	var card_pool = info_pool[1]
	var card_num = card_pool.size()
	card_index = -1
	# Stop if hand is empty
	if card_num==0:
		_confirm_card()
	# Proceed otherwise
	else:
		if card_num==1: card_num+=1 # Add space for the buttons
		setup_UI(card_pool, card_num, specifications[0], specifications[1])

# Adjust size and cards
func setup_UI(card_pool: Array, card_num:int, is_stoppable: bool, cover_cards: bool):
	# Setup panel
	if card_num>7: card_num=7 # Max size
	rect_size = Vector2(40+card_num*150,rect_size.y)
	container.rect_size = Vector2(card_num*150*2,container.rect_size.y)
	rect_position = Vector2((1280-rect_size.x)/2,rect_position.y)
	# Setup button(s)
	choose_button.rect_position = Vector2((rect_size.x-choose_button.rect_size.x)/2,choose_button.rect_position.y)
	pull_up_pull_down_button.rect_position = Vector2(rect_size.x/2-pull_up_pull_down_button.rect_size.x/8,pull_up_pull_down_button.rect_position.y)
	if is_stoppable:
		choose_button.rect_position = Vector2((rect_size.x-choose_button.rect_size.x)/2-70,choose_button.rect_position.y)
		stop_button.rect_position = Vector2((rect_size.x-stop_button.rect_size.x)/2+70,stop_button.rect_position.y)
		stop_button.disabled = false
		stop_button.show()
	# Setup cards
	if cover_cards:
		card_pool.shuffle()
	for card in card_pool:
		container.get_node("HBoxContainer").add_child(card)
		var card_info = card.get_info()
		card.set_script(selectable_card_script)
		card.initialize(card_info,info_panel)
	if cover_cards:
		for card in container.get_node("HBoxContainer").get_children(): card.cover()
	# Appear
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
	choose_button.disabled = false
	card_index = index

# Communicate choice and disappear
func _confirm_card():
	get_parent().done = true # Stop timer
	AudioController.play_card_slide_8() # Sound
	# Disappear
	choose_button.disabled = true
	stop_button.disabled = true
	pull_up_pull_down_button.disabled = true
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2(rect_position.x,745),.5)
	yield(get_tree().create_timer(.5),"timeout")
	stop_button.hide()
	# Empty pool
	for card in container.get_node("HBoxContainer").get_children(): card.queue_free()
	# Answer
	if PlayersList.am_on(): rpc("answer",card_index)
	answer(card_index)
# Everyone else returns the answer
remote func answer(answer): emit_signal("communicate_answer",answer)

# Stop choosing cards
func _stop():
	card_index = -1
	_confirm_card()

# Pull up/down GUI (when active)
func _pull_up_pull_down():
	AudioController.play_turnpage() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	# Pull down
	if rect_position.y==325:  tween.tween_property(self,"rect_position",Vector2(rect_position.x,720),.5)
	# Pull up
	else: tween.tween_property(self,"rect_position",Vector2(rect_position.x,325),.5)
