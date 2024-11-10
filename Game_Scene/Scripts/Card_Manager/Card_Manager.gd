extends Node2D
# Manages the decks

# Nodes
var red_deck
var black_deck
var orange_deck

# Init
func initialize():
	$"../Card_UI/Info_Panel_UI/Card_Info".initialize()
	# Set up cards
	var aux_effs = $"../Effects_UI" # Reference to pass to decks
	AudioController.play_shuffle() # Sound
	red_deck = get_child(0)
	yield(red_deck.initialize(aux_effs),"completed")
	black_deck = get_child(1)
	yield(black_deck.initialize(aux_effs),"completed")
	orange_deck = get_child(2)
	yield(orange_deck.initialize(aux_effs),"completed")
	aux_effs.initialize(red_deck.effects,black_deck.effects,orange_deck.effects) # Actually init it

# Draw cards
func draw_red_card(id: int) -> String:
	return red_deck.draw_card(id)
func draw_black_card(id: int) -> String:
	return black_deck.draw_card(id)
func draw_orange_card() -> String:
	return orange_deck.draw_card()

# Activate cards
#func activate_red_card(id: int, card_index: int): # Only used for bots
#	return red_deck.play_card(id,card_index)
func activate_black_card(id: int, card_id: int, targets: Array):
	return black_deck.activate_card(id,card_id,targets)
func activate_orange_card(id: int, card_id: int):
	return orange_deck.activate_card(id,card_id)

# Check if a player has any red cards
func player_has_cards(id: int) -> bool:
	return red_deck.player_has_cards(id)
func get_player_card_number(id: int) -> int:
	return red_deck.get_player_card_number(id)

# Check card number in piles
func get_cards_in_red_pile_number() -> int:
	return red_deck.get_cards_in_pile_number()
func get_cards_in_black_pile_number() -> int:
	return black_deck.get_cards_in_pile_number()
