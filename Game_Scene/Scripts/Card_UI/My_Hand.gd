extends Control
const player_hand_card_script = preload("res://Card_Factory/Hand_Card.gd")
# Handles and sets up cards in hand, asks to show info and verifies hand size

var hand_size: int
var cards_in_hand: Array
var my_id: int
# Other nodes
var info_panel
var play_area
var red_deck
# Just to stop players from rolling during the play animation
var roll_button
var escape_button

# Init
func initialize(id: int):
	my_id = id
	info_panel = $"../Info_Panel_UI/Card_Info"
	play_area = $"../Play_Area"
	red_deck = $"../../Card_Manager/Red_Deck"
	roll_button = $"../../Roll_Button"
	escape_button = $"../../Escape_Button"

# Add a card to hand and fix UI
func add_card(card: MarginContainer):
	# Set up card
	var card_info: Array = card.get_info()
	card.set_script(player_hand_card_script)
	if card.connect("check_drop",self,"_check_drop")!=0:
		print("!!! Player_Hand can't connect a signal !!!")
	card.initialize(card_info,info_panel)
	# Update hand
	hand_size+=1
	cards_in_hand.append(card)
	# Put the card in a CanvasLayer
	var cl = CanvasLayer.new()
	cl.layer = 0
	cl.add_child(card)
	add_child(cl)
	# Order hand
	yield(order_cards(),"completed")

# Animation when card number changes
func order_cards():
	# Stop player from messing around during ordering
	for n in hand_size: cards_in_hand[n].stop_inputs = true
	# Position maths shenanigans
	var cards_to_sort = cards_in_hand.duplicate()
	cards_to_sort.sort_custom(Hand_Sorter,"card_sort")
	var middle = 640-cards_in_hand[0].rect_size.x/4 # Of the hand node
	var distance = cards_in_hand[0].rect_size.x/2 + 10 # Between each card
	var starting_pos = middle-(distance/2)*hand_size + distance/2
	# Group em up
	for n in hand_size:
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(cards_to_sort[n], "rect_position", Vector2(middle,rect_position.y), .3)
	yield(get_tree().create_timer(.2),"timeout")
	# Spread em out
	for n in hand_size:
		cards_to_sort[n].x = starting_pos+distance*n
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(cards_to_sort[n], "rect_position", Vector2(starting_pos+distance*n,rect_position.y), .2)
		yield(get_tree().create_timer(.1),"timeout")
	# Allow player to move cards again
	for n in hand_size: cards_in_hand[n].stop_inputs = false

# Check if a card is dropped in the play area and plays it if possible
func _check_drop(card, position: Vector2):
	if play_area.is_visible() and Rect2(Vector2(400,-380),play_area.rect_size).has_point(position):
		red_deck.play_card(my_id,card,position)

# Discards a card and reorders the hand
func discard_card(card):
	hand_size-=1
	card.get_parent().queue_free()
	cards_in_hand.erase(card)
	if hand_size>0: order_cards()

# Enable/Disable roll button
func disable_roll_button(b: bool):
	if roll_button.visible:
		roll_button.disabled = b
		roll_button.disable_color(b)
	else:
		escape_button.disabled = b
		escape_button.disable_color(b)

# Sorting class
class Hand_Sorter:
	static func card_sort(a: Node,b: Node) -> bool:
		return a.card_name.naturalnocasecmp_to(b.card_name) < 0
