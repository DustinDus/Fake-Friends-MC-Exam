extends Panel
const selectable_card_script = preload("res://Card_Factory/Selectable_Card.gd")
# Lets one view an opponent's cards

# Nodes
var red_deck
var info_panel: Panel
var container: ScrollContainer

# Get vars
func _ready():
	set_process_input(false)
	red_deck = $"../../Card_Manager/Red_Deck"
	info_panel = $"../../Card_UI/Info_Panel_UI/Card_Info"
	container = get_child(0)

# Adjust size and cards
func setup_UI(player_id: int):
	# Checks
	if rect_position.y!=760: return # Already active
	if player_id==red_deck.my_id: return # It's my hand
	var cards = red_deck.player_hands[player_id]
	if cards.empty(): return # Hand is empty
	# Setup panel
	set_process_input(true)
	var card_num = cards.size()
	if card_num>7: card_num=7 # Max size
	rect_size = Vector2(40+card_num*145,rect_size.y)
	container.rect_size = Vector2(card_num*145*2,container.rect_size.y)
	rect_position = Vector2((1280-rect_size.x)/2,rect_position.y)
	# Setup cards
	for card_to_view in cards:
		var card = red_deck.replace(card_to_view,false)
		container.get_node("HBoxContainer").add_child(card)
		var card_info = card_to_view.get_info()
		card.set_script(selectable_card_script)
		card.initialize(card_info,info_panel)
	# Appear
	AudioController.play_card_slide_7() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2(rect_position.x,325),.5)

# Closes GUI if open and
# a click is made outside its area
func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		if rect_position.y!=760:
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
				AudioController.play_card_slide_8() # Sound
				set_process_input(false)
				var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "rect_position", Vector2(rect_position.x,760), .4)
				for card in container.get_node("HBoxContainer").get_children(): card.queue_free()
				yield(get_tree().create_timer(.4),"timeout")
