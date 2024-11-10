extends Node2D
const card_template = preload("res://Card_Factory/Card.tscn")
const card_database = preload("res://Card_Factory/Card_Databases/Orange_Card_Database.gd")
const pile_card_script = preload("res://Card_Factory/Pile_Card.gd")
# Manages Orange Cards

var my_id: int
var effects: Node2D # Extracts card effects from card name
# Deck-Related
var cards_in_deck: Array
var deck_number_label
# Pile-Related
var cards_in_pile: Array
var pile_number_label
var pile_UI
# Other UI stuff
var info_panel # Just to re-init cards
var click_or_wait_layer # To give players time to read
var reaction_handler # Verify players' ability to react
var red_deck # To react to Black Cards

# To synchronize players
var sync_n = 0

# Init
func initialize(aux_effs):
	# Deck
	#for n in range(7,10):
	#for n in [0]:
	for n in card_database.DATA.size():
		# Create a new card from the template
		var card = card_template.instance()
		card.initialize("Orange",card_database.DATA[n])
		# Set it up
		cards_in_deck.append(card)
	cards_in_deck.shuffle()
	# Other Vars
	my_id = PlayersList.get_my_id()
	effects = get_child(0)
	effects.initialize(aux_effs)
	deck_number_label = $"../../Map_Manager/Left_Deck_Holder/Panel/Orange_Panel/Deck_Space/Number"
	pile_number_label = $"../../Map_Manager/Left_Deck_Holder/Panel/Orange_Panel/Discard_Pile/Number"
	pile_UI = $"../../Card_UI/Piles_UI/Orange_Pile"
	pile_UI.initialize()
	# UI support nodes
	info_panel = $"../../Card_UI/Info_Panel_UI/Card_Info"
	click_or_wait_layer = $"../../Click_Or_Wait_Layer"
	reaction_handler = $"../../Reaction_Handler"
	red_deck = $"../Red_Deck"
	# Animation
	update_deck_number_label()
	update_pile_number_label()
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(deck_number_label, "modulate", Color(1,1,1,.2), .15)
	tween.tween_property(pile_number_label, "modulate", Color(1,1,1,.2), .15)
	yield(get_tree().create_timer(.3),"timeout")

# Make Click_or_Wait appear
func trigger_click_or_wait(time_limit: float = 2.0) -> Vector2:
	click_or_wait_layer.appear_to_let_player_read(time_limit)
	return yield(click_or_wait_layer,"disappeared")

# Synchronize players
func synchronize():
	var t=0
	if PlayersList.am_on(): rpc("im_ready")
	while sync_n<(PlayersList.get_apn()-1):
		yield(get_tree().create_timer(.2),"timeout")
		t+=.2
		if t==1.0: click_or_wait_layer.appear_to_tell_to_wait()
	sync_n = 0
	if t>=1.0: click_or_wait_layer.disappear()
	yield(get_tree().create_timer(.1),"timeout")
remote func im_ready(): sync_n+=1

#################
# Main play funcs
#################

# Action + Animation
func draw_card() -> Array:
	######
	# PREP
	# Shuffle deck if empty
	if cards_in_deck.empty():
		AudioController.play_shuffle() # Sound
		for card in pile_UI.card_list.get_children():
			var card_to_put_back = replace(card)
			cards_in_deck.append(card_to_put_back)
			cards_in_pile.remove(0)
			update_deck_number_label()
			update_pile_number_label()
			yield(get_tree().create_timer(.1),"timeout")
		cards_in_deck.shuffle()
	# Get Top Card
	var card = cards_in_deck.pop_front()
	# Place card over red deck space
	card.rect_rotation = -90
	card.rect_scale = Vector2(.35,.35)
	card.rect_position = Vector2(233,247)
	card.modulate = Color(1,1,1,0)
	card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
	card.cover()
	add_child(card)
	yield(get_tree().create_timer(.5),"timeout")
	#
	###########
	# ANIMATION
	# Make Card appear
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "modulate", Color(1,1,1,1), .3)
	# Update UI after it appeared (looks good)
	tween.tween_callback(self,"update_deck_number_label")
	# Move card to middle of the screen
	tween.tween_callback(AudioController,"play_cardsoundflick") # Sound
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/5.5,card.rect_position.y), .5)
	tween.parallel().tween_property(card, "rect_rotation", 0, .5)
	# Reveal card
	#  Blink
	tween.tween_callback(AudioController,"play_jobro_heartbeat") # Sound
	tween.tween_property(card, "modulate", Color(1,1,1,0), .5)
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/3.32,card.rect_position.y-33), .5)
	tween.parallel().tween_property(card, "rect_scale", Vector2(.6,.6), .5)
	tween.tween_property(card, "modulate", Color(1,1,1,1), .5)
	#  Blink
	tween.tween_callback(AudioController,"play_jobro_heartbeat") # Sound
	tween.tween_property(card, "modulate", Color(1,1,1,0), .5)
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/2.5,card.rect_position.y-66), .5)
	tween.parallel().tween_property(card, "rect_scale", Vector2(.8,.8), .5)
	tween.tween_property(card, "modulate", Color(1,1,1,1), .5)
	#  Blink and reveal
	tween.tween_callback(AudioController,"play_jobro_heartbeat") # Sound
	tween.tween_property(card, "modulate", Color(1,1,1,0), .5)
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/2,card.rect_position.y-100), .5)
	tween.parallel().tween_property(card, "rect_scale", Vector2(1,1), .5)
	tween.tween_property(card.get_node("card_back"), "modulate", Color(1,1,1,0), .5)
	tween.parallel().tween_property(card.get_node("Architecture"), "modulate", Color(1,1,1,1), .5) # Revealed
	tween.tween_property(card, "modulate", Color(1,1,1,1), .5)
	tween.parallel().tween_callback(AudioController,"play_heartbeat_v2") # Sound
	# Await and fixup
	yield(get_tree().create_timer(6),"timeout")
	#
	#########
	# PROCEED
	card.uncover()
	# Trigger Click_or_Wait
	var click: Vector2 = yield(trigger_click_or_wait(),"completed")
	# Show info if clicked the card
	if Rect2(card.get_position(),card.get_size()).has_point(click):
		info_panel.show_info(card.get_card_name(),"Orange",card.get_id())
	# Put card in pile
	yield(play_card(card),"completed")
	# Return Card Name
	return [card.get_id(),card.get_info()[2]]

# Move card to pile and fix its script
func play_card(card):
	######
	# PREP
	# Set script
	var card_info: Array = card.get_info()
	card.set_script(pile_card_script)
	card.initialize(card_info,info_panel)
	#
	###########
	# ANIMATION
	card.rect_pivot_offset = card.rect_size/2
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "rect_position", Vector2(640,340)-card.rect_size/2, .2)
	tween.parallel().tween_property(card, "rect_scale", Vector2(0,0), .8)
	tween.parallel().tween_property(card, "rect_rotation", 360, .8)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_weapon_1") # Sound
	yield(get_tree().create_timer(1),"timeout")
	#
	#########
	# PROCEED
	remove_child(card)
	# Add card to discard pile
	cards_in_pile.push_front(card)
	update_pile_number_label()
	pile_UI.add_card(card)
	# Sync
	yield(synchronize(),"completed")

# Find and execute card effect
func activate_card(id: int, card_id: int):
	################
	# ALLOW REACTION + Sync
	for n in 4: reaction_handler.registered_reactions[n] = 0
	# "targets_only_me" is always false, not that it matters
	yield(red_deck.check_and_allow_reactions("Unspecified",[-1]),"completed")
	# Reaction priority follows turn order
	var reaction: int = 0
	var reactor_id: int
	for n in range(0,4):
		reactor_id = (my_id+n)%4
		if reaction_handler.registered_reactions[reactor_id]!=reaction:
			reaction = reaction_handler.registered_reactions[reactor_id]
			break
	#
	#################
	# ACTIVATE EFFECT
	if reaction==0: effects.get_effect(id,card_id)
	else: red_deck.activate_reaction(-1,card_id,reactor_id,reaction,[],2)

###################
# Other logic funcs
###################

# Replace an existing Card with a copy
func replace(card, delete_original: bool = true) -> MarginContainer:
	# Extract card info
	var card_info: Array = []
	card_info.append(card.get_node("Architecture/Name_Container/Panel/Name").get("custom_fonts/font").get("size"))
	card_info.append(card.get_node("Architecture/Effect_Container/Panel/Effect").get("custom_fonts/font").get("size"))
	var og_card_info: Array = card.get_info()
	card_info.append(og_card_info[0]) # ID
	card_info.append(og_card_info[2]) # Name
	if delete_original: card.queue_free()
	# Create copy of the card
	var new_card = card_template.instance()
	new_card.initialize("Orange",card_info)
	return new_card

###########
# Update UI
###########

# Manage Number on Deck
func update_deck_number_label():
	if cards_in_deck.size()<10: deck_number_label.get("custom_fonts/font").extra_spacing_space = -6
	else: deck_number_label.get("custom_fonts/font").extra_spacing_space = -4
	deck_number_label.text = " "+str(+cards_in_deck.size())
func _on_mouse_entered_deck():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(deck_number_label, "modulate", Color(1,1,1,1), .5)
func _on_mouse_exited_deck():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(deck_number_label, "modulate", Color(1,1,1,.2), .5)

# Manage Number on Pile
func update_pile_number_label():
	if cards_in_pile.size()<10: pile_number_label.get("custom_fonts/font").extra_spacing_space = -6
	else: pile_number_label.get("custom_fonts/font").extra_spacing_space = -4
	pile_number_label.text = " "+str(+cards_in_pile.size())
func _on_mouse_entered_pile():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(pile_number_label, "modulate", Color(1,1,1,1), .5)
func _on_mouse_exited_pile():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(pile_number_label, "modulate", Color(1,1,1,.2), .5)
