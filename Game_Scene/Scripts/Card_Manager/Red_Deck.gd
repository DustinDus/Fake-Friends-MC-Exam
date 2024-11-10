extends Node2D
const card_template = preload("res://Card_Factory/Card.tscn")
const card_database = preload("res://Card_Factory/Card_Databases/Red_Card_Database.gd")
const pile_card_script = preload("res://Card_Factory/Pile_Card.gd")
# Manages Red Cards


var my_id # To remember who the player is
var my_hand # Holds visible cards
var player_hands: Array # Array of arrays to keep track of each player's hand
var target_checker: Node2D # Checks a card can be used
var combo_checker: Node2D # Checks combo components and asks if players want to use a combo
var effects: Node2D # Extracts card effects from card name
# Deck-Related
var cards_in_deck: Array
var deck_number_label
# Pile-Related
var cards_in_pile: Array
var pile_number_label
var pile_UI
# Other UI stuff
var player_dashboards # Just for positions
var info_panel # Just to re-init cards
var click_or_wait_layer # To give players time to read
var reaction_handler # Verify players' ability to react

# To synchronize players
var sync_n = 0

# Init
func initialize(aux_effs):
	# Deck
	#for n in range(5,45):
	#for n in [11,2,2,2,2,2,2,18,17,18,1,1,1,1,1,1,1]:
	for n in card_database.DATA.size():
		# Create a new card from the template
		var card = card_template.instance()
		card.initialize("Red",card_database.DATA[n])
		# Set it up
		cards_in_deck.append(card)
	cards_in_deck.shuffle()
	# Other Vars
	my_id = PlayersList.get_my_id()
	my_hand = $"../../Card_UI/My_Hand"
	my_hand.initialize(my_id)
	player_hands = [[],[],[],[]]
	target_checker = get_child(0)
	target_checker.initialize()
	combo_checker = get_child(1)
	combo_checker.initialize()
	effects = get_child(2)
	effects.initialize(aux_effs)
	#
	deck_number_label = $"../../Map_Manager/Right_Deck_Holder/Panel/Red_Panel/Deck_Space/Number"
	pile_number_label = $"../../Map_Manager/Right_Deck_Holder/Panel/Red_Panel/Discard_Pile/Number"
	player_dashboards = $"../../Player_Dashboards".get_children()
	pile_UI = $"../../Card_UI/Piles_UI/Red_Pile"
	pile_UI.initialize()
	# UI support nodes
	info_panel = $"../../Card_UI/Info_Panel_UI/Card_Info"
	click_or_wait_layer = $"../../Click_Or_Wait_Layer"
	reaction_handler = $"../../Reaction_Handler"
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

#############
# Draw a card
#############

# Logic only and part of the UI update
# The called functions do the animation and remainding UI updates
# NB Hand logic is done by my_hand, not this function
func draw_card(id: int) -> String:
	# Hand limit? Do nothing!
	if player_hands[id].size()>6:
		yield(synchronize(),"completed")
		return ""
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
	# Get top card
	var card = cards_in_deck.pop_front()
	# Add to someone's hand
	#if player_hands[id].size()<7:
	if id==my_id: yield(i_draw(card),"completed")
	else: yield(someone_else_draws(id, card),"completed")
	player_hands[id].append(card)
	UserStats.player_drew(id,0) # Update Stats
	if player_hands[id].size()==7: UserStats.player_held_seven_cards(id) # Update Stats
	# Update Dashboard UI
	player_dashboards[id].get_node("Card_Icons/Card_Number").text = str(player_hands[id].size())
	# Sync
	yield(synchronize(),"completed")
	# Return Card Name
	return card.get_node("Architecture/Name_Container/Panel/Name").text

# Animation for "me" drawing
func i_draw(card: MarginContainer):
	######
	# PREP
	# Place card over red deck space
	card.rect_rotation = 90
	card.rect_scale = Vector2(.35,.35)
	card.rect_position = Vector2(1048,159)
	card.modulate = Color(1,1,1,0)
	card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
	card.cover()
	add_child(card)
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
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/5.5,card.rect_position.y+88), .4)
	tween.parallel().tween_property(card, "rect_rotation", 0, .4)
	# Reveal card
	tween.tween_property(card.get_node("card_back"), "modulate", Color(1,0,0,1), .5)
	tween.parallel().tween_property(card, "rect_position", Vector2(640-card.rect_size.x/2,card.rect_position.y-12), .5)
	tween.parallel().tween_property(card, "rect_scale", Vector2(1,1), .5)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
	tween.tween_property(card.get_node("card_back"), "modulate", Color(1,0,0,0), .5)
	tween.parallel().tween_property(card.get_node("Architecture"), "modulate", Color(1,1,1,1), .5) # Revealed
	tween.parallel().tween_callback(AudioController,"play_interface_1") # Sound
	# Move card to middle of the hand
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/4,my_hand.rect_position.y), .3)
	tween.parallel().tween_property(card, "rect_scale", Vector2(.5,.5), .3)
	# Await and fixup
	yield(get_tree().create_timer(2),"timeout")
	card.uncover()
	#
	#########
	# PROCEED
	# Add card to hand
	remove_child(card)
	yield(my_hand.add_card(card),"completed")

# Animation for "someone else" drawing
func someone_else_draws(id: int, card):
	######
	# PREP
	# Place card over red deck space
	card.rect_scale = Vector2(.35,.35)
	card.modulate = Color(1,1,1,0)
	card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
	if id==0 or id==3:
		card.rect_rotation = 90
		card.rect_position = Vector2(1048,159)
	else:
		card.rect_rotation = -90
		card.rect_position = Vector2(925,247)
	card.cover()
	add_child(card)
	# Setup Drew_A_Card icon
	if id==0 or id==3: player_dashboards[5].position = Vector2(player_dashboards[id].rect_position.x+player_dashboards[id].rect_size.x,player_dashboards[id].rect_position.y+player_dashboards[id].rect_size.y)
	else: player_dashboards[5].position = Vector2(player_dashboards[id].rect_position.x-player_dashboards[id].rect_size.x,player_dashboards[id].rect_position.y+player_dashboards[id].rect_size.y)
	#
	###########
	# ANIMATION 
	# Make Card appear
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "modulate", Color(1,1,1,1), .3)
	# Update UI after it appeared and set up the Drew_A_Card icon
	tween.tween_callback(self,"update_deck_number_label")
	# Move Card to the player's dashboard and trigger the Drew_A_Card icon
	tween.tween_callback(AudioController,"play_cardsoundflick") # Sound
	tween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,1), .3)
	if id==0 or id==3: tween.tween_property(card, "rect_position", Vector2(player_dashboards[id].rect_position.x+player_dashboards[id].rect_size.x,player_dashboards[id].rect_position.y+player_dashboards[id].rect_size.y), .5)
	else: tween.tween_property(card, "rect_position", Vector2(player_dashboards[id].rect_position.x-player_dashboards[id].rect_size.x,player_dashboards[id].rect_position.y+player_dashboards[id].rect_size.y), .5)
	tween.parallel().tween_property(card, "rect_rotation", 0, .5)
	tween.parallel().tween_property(card, "rect_scale", Vector2(0,0), 1)
	tween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,0), .3)
	# Await and fixup
	yield(get_tree().create_timer(2),"timeout")
	card.get_node("Architecture").modulate = Color(1,1,1,1) # Revealed
	card.uncover()

#############
# Play a card (logic)
#############

# Animation + Logic for "me" playing a Red Card
func play_card(id: int, card, position: Vector2):
	###############
	# CHECK TARGETS
	# This name can change in case of combos
	var card_id = card.get_id()
	# Extrapolate data [can_be_played: bool, available_targets: Array, reactability: String]
	var check_info: Array = target_checker.can_be_played(id,card_id)
	# Can't be played, nothing to do
	if check_info[0]==false: return
	# Can be played, proceed
	my_hand.disable_roll_button(true)
	my_hand.play_area.hide()
	#
	##############
	# CHECK COMBOS
	# Can a combo even be made?
	var can_combo = combo_checker.can_combo(id,card_id)
	#
	###########
	# PLAY CARD
	# Card combo
	if can_combo:
		# Extrapolate data [card/combo_name: bool, component(s): Array]
		combo_checker.ask_to_combo(id,card_id)
		var combo_info = yield(combo_checker,"answer")
		card_id = combo_info[0]
		# Execute combo
		if PlayersList.am_on(): rpc("someone_else_combos",id,combo_info[1])
		yield(i_combo(combo_info[1]),"completed")
	# Single card
	else:
		if PlayersList.am_on(): rpc("someone_else_plays",id,card_id)
		yield(i_play(card,position),"completed")
	#
	######################
	# GET TARGET(S) IF ANY
	var targets = yield(effects.get_target(my_id,card_id,check_info[1]),"completed")
	# Dual Chance's reactability is 'Single Enemy Target' by default, this changes if the first effect is chosen
	if card_id==18 and targets.empty(): check_info[2] = "Unspecified"
	#
	################
	# ALLOW REACTION + Sync
	for n in 4: reaction_handler.registered_reactions[n] = 0
	if PlayersList.am_on(): rpc("check_and_allow_reactions",check_info[2],targets)
	yield(synchronize(),"completed")
	# Reaction priority follows turn order
	var reaction: int = 0
	var reactor_id: int
	for n in range(1,4):
		reactor_id = (my_id+n)%4
		if reaction_handler.registered_reactions[reactor_id]!=reaction:
			reaction = reaction_handler.registered_reactions[reactor_id]
			break
	#
	#################
	# ACTIVATE EFFECT
	# No reaction was made
	if reaction==0:
		if PlayersList.am_on(): rpc("activate_card",id,card_id,targets)
		activate_card(id,card_id,targets)
	# A reaction was made
	else:
		if PlayersList.am_on(): rpc("activate_reaction",my_id,card_id,reactor_id,reaction,targets)
		activate_reaction(my_id,card_id,reactor_id,reaction,targets)

# Check if a player can react and allows them to if so
remote func check_and_allow_reactions(reactability: String, targets: Array):
	# Prep
	var reaction: int
	var targets_just_me: bool
	if targets.size()==1: targets_just_me = targets[0]==my_id
	else: targets_just_me = false
	# Ask for reactions
	var reactions: Array = reaction_handler.verify_reactability(reactability,get_player_cards(my_id),targets_just_me)
	if reactions.empty(): reaction = 0
	else: reaction = yield(reaction_handler.ask_for_reactions(reactions),"completed")
	# Register reactions
	reaction_handler.registered_reactions[my_id] = reaction
	if PlayersList.am_on(): rpc("register_reaction",my_id,reaction)
	yield(synchronize(),"completed")

# Register a player's reaction
remote func register_reaction(reactor_id: int, reaction: int):
	reaction_handler.registered_reactions[reactor_id] = reaction

# The appropriate player activates the appropriate reaction
remote func activate_reaction(instigator_id: int, card_id: int, reactor_id: int, reaction_id: int, targets: Array, color: int = 0): # color = 0:red, 1:black, 2:orange
	###########
	# PLAY CARD
	$"../..".play_reaction()
	if my_id==reactor_id:
		for c in player_hands[my_id]:
			if c.get_id()==reaction_id:
				yield(i_play(c,c.rect_position),"completed")
				break
	else: yield(someone_else_plays(reactor_id,reaction_id),"completed")
	#
	#################
	# ACTIVATE EFFECT
	reaction_handler.activate_reaction(instigator_id,card_id,reactor_id,reaction_id,targets,color)

# Find and execute card effect
remote func activate_card(id: int, card_id: int, targets: Array):
	effects.get_effect(id,card_id,targets)

#############
# Play a card (animation)
#############

# Animation + Logic for "me" playing a Red Card
func i_play(card, position: Vector2):
	UserStats.player_activated(my_id,false) # Update Stats
	######
	# PREP
	# Replicate and set up discarded Card
	var card_info = card.get_info()
	var discarded_card = replace(card)
	discarded_card.set_script(pile_card_script)
	discarded_card.initialize(card_info,info_panel)
	my_hand.discard_card(card)
	# Remaining setup
	add_child(discarded_card)
	discarded_card.rect_pivot_offset = discarded_card.rect_size/2
	discarded_card.rect_position = position+Vector2(140,620)-discarded_card.rect_size/2
	discarded_card.rect_scale = Vector2(.5,.5)
	$"../..".play_red(my_id,tr(card_info[2])) # Log
	# Remove card from
	#
	###########
	# ANIMATION
	# Spin
	AudioController.play_swish_sound() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(discarded_card, "rect_position", Vector2(640,340)-discarded_card.rect_size/2, .4)
	tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(.2,.2), .4)
	tween.parallel().tween_property(discarded_card, "rect_rotation", 360, .4)
	# Biggering
	tween.tween_property(discarded_card, "rect_position", Vector2(640,322)-discarded_card.rect_size/2, .8)
	tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(1,1), .8)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
	tween.tween_callback(self,"remove_player_card",[my_id,card])
	# Bye spin
	tween.tween_property(discarded_card, "rect_position", Vector2(640,340)-discarded_card.rect_size/2, .8)
	tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(0,0), .8)
	tween.parallel().tween_property(discarded_card, "rect_rotation", 0, .8)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_weapon_1") # Sound
	# Await and fixup
	yield(get_tree().create_timer(2),"timeout")
	remove_child(discarded_card)
	#
	#########
	# PROCEED
	# Add card to discard pile
	cards_in_pile.push_front(discarded_card)
	update_pile_number_label()
	pile_UI.add_card(discarded_card)
	# Sync
	yield(synchronize(),"completed")

# Animation + Logic for "someone else" playing a Red Card
remote func someone_else_plays(id: int, effect_id: int):
	UserStats.player_activated(id,false) # Update Stats
	######
	# PREP
	# Get card
	var card
	for c in player_hands[id]:
		if c.get_id()==effect_id:
			card = c
			break
	# Replicate
	var card_info = card.get_info()
	var discarded_card = replace(card)
	$"../..".play_red(id,tr(card_info[2])) # Log
	# Put card near corresponding player dashboard
	discarded_card.rect_pivot_offset = discarded_card.rect_size/2
	discarded_card.rect_scale = Vector2(0,0)
	if id==0 or id==3: discarded_card.rect_position.x = 135-discarded_card.rect_size.x/2
	else: discarded_card.rect_position.x = 1145-discarded_card.rect_size.x/2
	if id<2: discarded_card.rect_position.y = 250-discarded_card.rect_size.y/2
	else: discarded_card.rect_position.y = 530-discarded_card.rect_size.y/2
	discarded_card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
	discarded_card.cover()
	add_child(discarded_card)
	# Setup Drew_A_Card icon
	if id==0 or id==3: player_dashboards[6].position = Vector2(player_dashboards[id].rect_position.x+player_dashboards[id].rect_size.x,player_dashboards[id].rect_position.y+player_dashboards[id].rect_size.y)
	else: player_dashboards[6].position = Vector2(player_dashboards[id].rect_position.x-player_dashboards[id].rect_size.x,player_dashboards[id].rect_position.y+player_dashboards[id].rect_size.y)
	#
	##################
	# APPEAR ANIMATION
	# Make Draw_A_Card_Icon appear
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,1), .3)
	# Remove card from player's hand and update UI
	tween.tween_callback(self,"remove_player_card",[id,card])
	# Move card from dashboard to middle of the screen
	tween.tween_property(discarded_card, "rect_position", Vector2(640,334)-discarded_card.rect_size/2, .5)
	tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(.5,.5), .5)
	tween.parallel().tween_callback(AudioController,"play_swish_sound") # Sound
	# Reveal card
	tween.tween_property(discarded_card.get_node("card_back"), "modulate", Color(1,0,0,1), .5)
	tween.parallel().tween_property(discarded_card, "rect_position", Vector2(640,322)-discarded_card.rect_size/2, .5)
	tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(1,1), .5)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
	tween.tween_property(discarded_card.get_node("card_back"), "modulate", Color(0,0,0,0), .5)
	tween.parallel().tween_property(discarded_card.get_node("Architecture"), "modulate", Color(1,1,1,1), .5) # Revealed
	# Await
	yield(get_tree().create_timer(2),"timeout")
	# Trigger Click_or_Wait
	var click: Vector2 = yield(trigger_click_or_wait(),"completed")
	# Show info if clicked the card
	if Rect2(discarded_card.get_position(),discarded_card.get_size()).has_point(click):
		info_panel.show_info(discarded_card.get_card_name(),"Red",discarded_card.get_id())
	#
	#####################
	# DISAPPEAR ANIMATION
	# Make card disappear
	var retween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	retween.tween_property(discarded_card, "rect_position", Vector2(640,340)-discarded_card.rect_size/2, .8)
	retween.parallel().tween_property(discarded_card, "rect_scale", Vector2(0,0), .8)
	retween.parallel().tween_property(discarded_card, "rect_rotation", 360, .8)
	retween.parallel().tween_callback(AudioController,"play_swing_whoosh_weapon_1") # Sound
	# Make Draw_A_Card_Icon disappear
	retween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,0), .3)
	# Await and fixup
	yield(get_tree().create_timer(1),"timeout")
	remove_child(discarded_card)
	discarded_card.uncover()
	#
	#########
	# PROCEED
	# Set up discarded card
	discarded_card.set_script(pile_card_script)
	discarded_card.initialize(card_info,info_panel)
	# Add card to discard pile
	cards_in_pile.push_front(discarded_card)
	update_pile_number_label()
	pile_UI.add_card(discarded_card)
	# Sync
	yield(synchronize(),"completed")

# Animation + Logic for "me" making a combo
func i_combo(components: Array):
	UserStats.player_activated(my_id,true) # Update Stats
	########################################
	# PREP+ANIMATION LOOP FOR EACH COMPONENT
	var card
	for card_id in components:
		######
		# PREP
		# Get card
		for c in player_hands[my_id]:
			if c.get_id()==card_id:
				card = c
				break
		# Replicate and set up discarded Card
		var card_info = card.get_info()
		var discarded_card = replace(card)
		discarded_card.set_script(pile_card_script)
		discarded_card.initialize(card_info,info_panel)
		my_hand.discard_card(card)
		# Remaining setup
		add_child(discarded_card)
		discarded_card.rect_pivot_offset = discarded_card.rect_size/2
		discarded_card.rect_position = card.rect_position+Vector2(140,620)-discarded_card.rect_size/2
		discarded_card.rect_scale = Vector2(.5,.5)
		$"../..".play_red(my_id,tr(card_info[2])) # Log
		###########
		# ANIMATION
		# Spin
		AudioController.play_swish_sound() # Sound
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(discarded_card, "rect_position", Vector2(640,340)-discarded_card.rect_size/2, .4)
		tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(.2,.2), .4)
		tween.parallel().tween_property(discarded_card, "rect_rotation", 360, .4)
		# Biggering
		tween.tween_property(discarded_card, "rect_position", Vector2(640,322)-discarded_card.rect_size/2, .4)
		tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(1,1), .4)
		tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
		tween.tween_callback(self,"remove_player_card",[my_id,card])
		# Bye spin
		tween.tween_property(discarded_card, "rect_position", Vector2(640,340)-discarded_card.rect_size/2, .4)
		tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(0,0), .4)
		tween.parallel().tween_property(discarded_card, "rect_rotation", 0, .4)
		tween.parallel().tween_callback(AudioController,"play_swing_whoosh_weapon_1") # Sound
		# Await and fixup
		yield(get_tree().create_timer(1.2),"timeout")
		remove_child(discarded_card)
		#
		#########
		# PROCEED
		# Add card to discard pile
		cards_in_pile.push_front(discarded_card)
		update_pile_number_label()
		pile_UI.add_card(discarded_card)
	# Await
	yield(get_tree().create_timer(1),"timeout")

# Animation + Logic for "someone else" making a combo
remote func someone_else_combos(id: int, components: Array):
	UserStats.player_activated(id,true) # Update Stats
	########################################
	# PREP+ANIMATION LOOP FOR EACH COMPONENT
	var card
	for card_id in components:
		######
		# PREP
		# Get card
		for c in player_hands[id]:
			if c.get_id()==card_id:
				card = c
				break
		# Replicate
		var card_info = card.get_info()
		var discarded_card = replace(card)
		$"../..".play_red(id,tr(card_info[2])) # Log
		# Put card near corresponding player dashboard
		discarded_card.rect_pivot_offset = discarded_card.rect_size/2
		discarded_card.rect_scale = Vector2(0,0)
		if id==0 or id==3: discarded_card.rect_position.x = 135-discarded_card.rect_size.x/2
		else: discarded_card.rect_position.x = 1145-discarded_card.rect_size.x/2
		if id<2: discarded_card.rect_position.y = 250-discarded_card.rect_size.y/2
		else: discarded_card.rect_position.y = 530-discarded_card.rect_size.y/2
		discarded_card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
		discarded_card.cover()
		add_child(discarded_card)
		# Setup Drew_A_Card icon
		if id==0 or id==3: player_dashboards[6].position = Vector2(player_dashboards[id].rect_position.x+player_dashboards[id].rect_size.x,player_dashboards[id].rect_position.y+player_dashboards[id].rect_size.y)
		else: player_dashboards[6].position = Vector2(player_dashboards[id].rect_position.x-player_dashboards[id].rect_size.x,player_dashboards[id].rect_position.y+player_dashboards[id].rect_size.y)
		#
		##################
		# APPEAR ANIMATION
		# Make Discarded_A_Card_Icon appear
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,1), .3)
		# Remove card from player's hand and update UI
		tween.tween_callback(self,"remove_player_card",[id,card])
		# Move card from dashboard to middle of the screen
		tween.tween_property(discarded_card, "rect_position", Vector2(640,334)-discarded_card.rect_size/2, .3)
		tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(.5,.5), .3)
		tween.parallel().tween_callback(AudioController,"play_swish_sound") # Sound
		# Reveal card
		tween.tween_property(discarded_card.get_node("card_back"), "modulate", Color(1,0,0,1), .3)
		tween.parallel().tween_property(discarded_card, "rect_position", Vector2(640,322)-discarded_card.rect_size/2, .3)
		tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(1,1), .3)
		tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
		tween.tween_property(discarded_card.get_node("card_back"), "modulate", Color(0,0,0,0), .3)
		tween.parallel().tween_property(discarded_card.get_node("Architecture"), "modulate", Color(1,1,1,1), .3) # Revealed
		# Await
		yield(get_tree().create_timer(1.2),"timeout")
		# Trigger Click_or_Wait
		#yield(trigger_click_or_wait(),"completed")
		#
		#####################
		# DISAPPEAR ANIMATION
		# Make card disappear
		var retween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		retween.tween_property(discarded_card, "rect_position", Vector2(640,340)-discarded_card.rect_size/2, .5)
		retween.parallel().tween_property(discarded_card, "rect_scale", Vector2(0,0), .5)
		retween.parallel().tween_property(discarded_card, "rect_rotation", 360, .5)
		retween.parallel().tween_callback(AudioController,"play_swing_whoosh_weapon_1") # Sound
		# Make Discarded_A_Card_Icon disappear
		retween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,0), .3)
		# Await and fixup
		yield(get_tree().create_timer(.8),"timeout")
		remove_child(discarded_card)
		discarded_card.uncover()
		#
		#########
		# PROCEED
		# Set up discarded card
		discarded_card.set_script(pile_card_script)
		discarded_card.initialize(card_info,info_panel)
		# Add card to discard pile
		cards_in_pile.push_front(discarded_card)
		update_pile_number_label()
		pile_UI.add_card(discarded_card)
	# Await
	yield(get_tree().create_timer(1),"timeout")
	# Sync
	yield(synchronize(),"completed")

################
# Discard a card
################

# Play discard animation and remove card from player's hand...
func discard_card(player_id: int, card_index: int):
	# Check
	if card_index<0: yield(get_tree().create_timer(.1),"timeout")
	# Who discards?
	elif PlayersList.get_player_unique_id(player_id)==PlayersList.get_my_unique_id():
		yield(i_discard(card_index),"completed")
	else:
		yield(someone_else_discards(player_id,card_index),"completed")

# Animation + Logic for "me" discarding a Red Card
func i_discard(card_index):
	UserStats.player_discarded(my_id) # Update Stats
	######
	# PREP
	# Animation setup + discard from my_hand
	var position = my_hand.cards_in_hand[card_index].rect_position
	var card = player_hands[my_id][card_index]
	my_hand.discard_card(my_hand.cards_in_hand[card_index])
	var card_info = card.get_info()
	var discarded_card = replace(card)
	add_child(discarded_card)
	discarded_card.rect_pivot_offset = discarded_card.rect_size/2
	discarded_card.rect_position = position+Vector2(140,620)-discarded_card.rect_size/2
	discarded_card.rect_scale = Vector2(.35,.35)
	#  Remove card from player's hand and update UI
	remove_player_card(my_id,card)
	#
	###########
	# ANIMATION
	# Put card on discard pile
	AudioController.play_swish_sound() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(discarded_card, "rect_position", Vector2(987,291)-discarded_card.rect_size/2, .7)
	tween.parallel().tween_property(discarded_card, "rect_rotation", 90, .7)
	# Spin away
	tween.tween_property(discarded_card, "rect_scale", Vector2(0,0), .8)
	tween.parallel().tween_property(discarded_card, "rect_rotation", 360, .8)
	tween.parallel().tween_callback(AudioController,"play_splash_bathroom") # Sound
	# Await and fixup
	yield(get_tree().create_timer(1.5),"timeout")
	remove_child(discarded_card)
	#
	#########
	# PROCEED
	# Set up discarded card
	discarded_card.set_script(pile_card_script)
	discarded_card.initialize(card_info,info_panel)
	# Add card to discard pile
	cards_in_pile.push_front(discarded_card)
	update_pile_number_label()
	pile_UI.add_card(discarded_card)
	# Sync
	yield(synchronize(),"completed")

# Animation + Logic for "someone else" playing a Red Card
func someone_else_discards(player_id,card_index):
	UserStats.player_discarded(player_id) # Update Stats
	######
	# PREP
	# Animation setup
	var card = player_hands[player_id][card_index]
	var card_info = card.get_info()
	var discarded_card = replace(card)
	discarded_card.rect_pivot_offset = discarded_card.rect_size/2
	discarded_card.rect_scale = Vector2(0,0)
	if player_id==0 or player_id==3: discarded_card.rect_position.x = 135-discarded_card.rect_size.x/2
	else: discarded_card.rect_position.x = 1145-discarded_card.rect_size.x/2
	if player_id<2: discarded_card.rect_position.y = 250-discarded_card.rect_size.y/2
	else: discarded_card.rect_position.y = 530-discarded_card.rect_size.y/2
	discarded_card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
	discarded_card.cover()
	add_child(discarded_card)
	#  Setup Drew_A_Card icon
	if player_id==0 or player_id==3: player_dashboards[6].position = Vector2(player_dashboards[player_id].rect_position.x+player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y)
	else: player_dashboards[6].position = Vector2(player_dashboards[player_id].rect_position.x-player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y)
	#
	###########
	# ANIMATION
	#  Make Draw_A_Card_Icon appear
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,1), .3)
	#  Remove card from player's hand and update UI
	tween.tween_callback(self,"remove_player_card",[player_id,card])
	#  Move card from dashboard to middle of the screen
	tween.tween_property(discarded_card, "rect_position", Vector2(640,334)-discarded_card.rect_size/2, .5)
	tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(.5,.5), .5)
	tween.parallel().tween_callback(AudioController,"play_swish_sound") # Sound
	# Reveal card
	tween.tween_property(discarded_card.get_node("card_back"), "modulate", Color(1,0,0,1), .5)
	tween.parallel().tween_property(discarded_card, "rect_position", Vector2(640,322)-discarded_card.rect_size/2, .5)
	tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(1,1), .5)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
	tween.tween_property(discarded_card.get_node("card_back"), "modulate", Color(0,0,0,0), .5)
	tween.parallel().tween_property(discarded_card.get_node("Architecture"), "modulate", Color(1,1,1,1), .5) # Revealed
	#  Make card disappear
	tween.tween_property(discarded_card, "rect_position", Vector2(987,291)-discarded_card.rect_size/2, .8)
	tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(0,0), .8)
	tween.parallel().tween_property(discarded_card, "rect_rotation", 360, .8)
	tween.parallel().tween_callback(AudioController,"play_splash_bathroom") # Sound
	#  Make Draw_A_Card_Icon disappear
	tween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,0), .3)
	# Await and fixup
	yield(get_tree().create_timer(2.5),"timeout")
	remove_child(discarded_card)
	discarded_card.uncover()
	#
	#########
	# PROCEED
	# Set up discarded card
	discarded_card.set_script(pile_card_script)
	discarded_card.initialize(card_info,info_panel)
	# Add card to discard pile
	cards_in_pile.push_front(discarded_card)
	update_pile_number_label()
	pile_UI.add_card(discarded_card)
	# Sync
	yield(synchronize(),"completed")

##############
# Trade a card
##############

# Play trade animation and apply appropriate logic
func trade_card(giver_id: int, taker_id: int, card_index: int):
	# Check
	if card_index<0 || player_hands[taker_id].size()>6:
		yield(get_tree().create_timer(.1),"timeout")
	# Who trades with who?
	elif PlayersList.get_player_unique_id(giver_id)==PlayersList.get_my_unique_id():
		yield(i_give(taker_id,card_index),"completed")
	elif PlayersList.get_player_unique_id(taker_id)==PlayersList.get_my_unique_id():
		yield(i_take(giver_id,card_index),"completed")
	else:
		yield(two_others_trade(giver_id,taker_id,card_index),"completed")

# I give someone a card
func i_give(taker_id: int, card_index: int):
	######
	# PREP
	# Setup card
	var position = my_hand.cards_in_hand[card_index].rect_position
	var card = player_hands[my_id][card_index]
	my_hand.discard_card(my_hand.cards_in_hand[card_index])
	var discarded_card = replace(card)
	add_child(discarded_card)
	discarded_card.rect_position = position+Vector2(140,620)
	discarded_card.rect_scale = Vector2(.5,.5)
	if taker_id==0 or taker_id==3: player_dashboards[5].position = Vector2(player_dashboards[taker_id].rect_position.x+player_dashboards[taker_id].rect_size.x,player_dashboards[taker_id].rect_position.y+player_dashboards[taker_id].rect_size.y)
	else: player_dashboards[5].position = Vector2(player_dashboards[taker_id].rect_position.x-player_dashboards[taker_id].rect_size.x,player_dashboards[taker_id].rect_position.y+player_dashboards[taker_id].rect_size.y)
	# Remove card from player's hand and update UI
	remove_player_card(my_id,card)
	#
	###########
	# ANIMATION
	# Move card to the middle of the screen
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(discarded_card, "rect_position", Vector2(640,334)-discarded_card.rect_size/4, .5)
	tween.parallel().tween_callback(AudioController,"play_swish_sound") # Sound
	# Add card to player's hand and update UI
	tween.tween_callback(self,"add_player_card",[taker_id,discarded_card])
	# Make Draw_A_Card_Icon appear from taker's dashboard
	tween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,1), .3)
	# Move card from middle of the screen to dashboard
	if taker_id==0 or taker_id==3: tween.tween_property(discarded_card, "rect_position", Vector2(player_dashboards[taker_id].rect_position.x+player_dashboards[taker_id].rect_size.x,player_dashboards[taker_id].rect_position.y+player_dashboards[taker_id].rect_size.y), .5)
	else: tween.tween_property(discarded_card, "rect_position", Vector2(player_dashboards[taker_id].rect_position.x-player_dashboards[taker_id].rect_size.x,player_dashboards[taker_id].rect_position.y+player_dashboards[taker_id].rect_size.y), .5)
	tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(0,0), .5)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
	tween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,0), .3)
	# Await
	yield(get_tree().create_timer(2.2),"timeout")
	#
	#########
	# PROCEED
	# Sync
	yield(synchronize(),"completed")

# Someone gives me a card
func i_take(giver_id: int, card_index: int):
	######
	# PREP
	# Setup card
	var card = player_hands[giver_id][card_index]
	if giver_id==0 or giver_id==3: card.rect_position.x = 135-card.rect_size.x/2
	else: card.rect_position.x = 1145-card.rect_size.x/2
	if giver_id<2: card.rect_position.y = 250
	else: card.rect_position.y = 530
	card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
	card.cover()
	# Make Draw_A_Card_Icon appear from giver's dashboard
	if giver_id==0 or giver_id==3: player_dashboards[6].position = Vector2(player_dashboards[giver_id].rect_position.x+player_dashboards[giver_id].rect_size.x,player_dashboards[giver_id].rect_position.y+player_dashboards[giver_id].rect_size.y)
	else: player_dashboards[6].position = Vector2(player_dashboards[giver_id].rect_position.x-player_dashboards[giver_id].rect_size.x,player_dashboards[giver_id].rect_position.y+player_dashboards[giver_id].rect_size.y)
	#
	###########
	# ANIMATION
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,1), .3)
	# Remove card from player's hand and update UI
	tween.tween_callback(self,"remove_player_card",[giver_id,card])
	# Move card from dashboard to middle of the screen
	tween.tween_property(card, "rect_position", Vector2(640,334)-card.rect_size/4, .5)
	tween.parallel().tween_property(card, "rect_scale", Vector2(.5,.5), .5)
	tween.parallel().tween_callback(AudioController,"play_swish_sound") # Sound
	# Make Draw_A_Card_Icon disappear
	tween.parallel().tween_property(player_dashboards[6], "modulate", Color(1,1,1,0), .3)
	# Reveal card
	tween.tween_property(card.get_node("card_back"), "modulate", Color(1,0,0,1), .5)
	tween.parallel().tween_property(card, "rect_position", Vector2(640,322)-card.rect_size/2, .5)
	tween.parallel().tween_property(card, "rect_scale", Vector2(1,1), .5)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
	tween.tween_property(card.get_node("card_back"), "modulate", Color(0,0,0,0), .5)
	tween.parallel().tween_property(card.get_node("Architecture"), "modulate", Color(1,1,1,1), .5) # Revealed
	tween.parallel().tween_callback(AudioController,"play_interface_1") # Sound
	# Move card to middle of the hand
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/4,my_hand.rect_position.y), .3)
	tween.parallel().tween_property(card, "rect_scale", Vector2(.5,.5), .3)
	# Remove card from player's hand and update UI
	tween.tween_callback(self,"add_player_card",[my_id,card])
	# Await and fixup
	yield(get_tree().create_timer(2.2),"timeout")
	card.get_node("Architecture").modulate = Color(1,1,1,1) # Revealed
	card.uncover()
	#
	#########
	# PROCEED
	# Add card to hand
	remove_child(card)
	yield(my_hand.add_card(card),"completed")
	# Sync
	yield(synchronize(),"completed")

# Two players other than me trade cards
func two_others_trade(giver_id: int, taker_id: int, card_index: int):
	######
	# PREP
	# Setup card
	var card = player_hands[giver_id][card_index]
	if giver_id==0 or giver_id==3: card.rect_position.x = 135-card.rect_size.x/2
	else: card.rect_position.x = 1145-card.rect_size.x/2
	if giver_id<2: card.rect_position.y = 250
	else: card.rect_position.y = 530
	card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
	card.cover()
	# Make Draw_A_Card_Icon appear from giver's dashboard
	if giver_id==0 or giver_id==3: player_dashboards[6].position = Vector2(player_dashboards[giver_id].rect_position.x+player_dashboards[giver_id].rect_size.x,player_dashboards[giver_id].rect_position.y+player_dashboards[giver_id].rect_size.y)
	else: player_dashboards[6].position = Vector2(player_dashboards[giver_id].rect_position.x-player_dashboards[giver_id].rect_size.x,player_dashboards[giver_id].rect_position.y+player_dashboards[giver_id].rect_size.y)
	#
	###########
	# ANIMATION
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,1), .3)
	# Remove card from player's hand and update UI
	tween.tween_callback(self,"remove_player_card",[giver_id,card])
	# Move card from dashboard to middle of the screen
	tween.tween_property(card, "rect_position", Vector2(640,334)-card.rect_size/4, .5)
	tween.parallel().tween_property(card, "rect_scale", Vector2(.5,.5), .5)
	tween.parallel().tween_callback(AudioController,"play_swish_sound") # Sound
	# Make Draw_A_Card_Icon disappear and reappear on taker's dashboard
	tween.parallel().tween_property(player_dashboards[6], "modulate", Color(1,1,1,0), .3)
	if taker_id==0 or taker_id==3: tween.tween_property(player_dashboards[5], "position", Vector2(player_dashboards[taker_id].rect_position.x+player_dashboards[taker_id].rect_size.x,player_dashboards[taker_id].rect_position.y+player_dashboards[taker_id].rect_size.y), 0)
	else: tween.tween_property(player_dashboards[5], "position", Vector2(player_dashboards[taker_id].rect_position.x-player_dashboards[taker_id].rect_size.x,player_dashboards[taker_id].rect_position.y+player_dashboards[taker_id].rect_size.y), 0)
	tween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,1), .3)
	# Add card to player's hand and update UI
	tween.tween_callback(self,"add_player_card",[taker_id,card])
	# Move card from middle of the screen to dashboard
	tween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,1), .3)
	if taker_id==0 or taker_id==3: tween.tween_property(card, "rect_position", Vector2(player_dashboards[taker_id].rect_position.x+player_dashboards[taker_id].rect_size.x,player_dashboards[taker_id].rect_position.y+player_dashboards[taker_id].rect_size.y), .5)
	else: tween.tween_property(card, "rect_position", Vector2(player_dashboards[taker_id].rect_position.x-player_dashboards[taker_id].rect_size.x,player_dashboards[taker_id].rect_position.y+player_dashboards[taker_id].rect_size.y), .5)
	tween.parallel().tween_property(card, "rect_scale", Vector2(0,0), .5)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
	tween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,0), .3)
	# Await and fixup
	yield(get_tree().create_timer(2.2),"timeout")
	card.get_node("Architecture").modulate = Color(1,1,1,1) # Revealed
	card.uncover()
	#
	#########
	# PROCEED
	# Sync
	yield(synchronize(),"completed")

#############
# Trade hands
#############

# Swap two player's hands and play animation
func trade_hands(trader_id_1: int, trader_id_2: int):
	# Who trades with who?
	if PlayersList.get_player_unique_id(trader_id_1)==PlayersList.get_my_unique_id():
		yield(we_trade(trader_id_2),"completed")
	elif PlayersList.get_player_unique_id(trader_id_2)==PlayersList.get_my_unique_id():
		yield(we_trade(trader_id_1),"completed")
	else:
		yield(they_trade(trader_id_1,trader_id_2),"completed")

# I trade hands with another player
func we_trade(trader_id: int):
	########
	# I GIVE
	# Icon setup
	if trader_id==0 or trader_id==3: player_dashboards[5].position = Vector2(player_dashboards[trader_id].rect_position.x+player_dashboards[trader_id].rect_size.x,player_dashboards[trader_id].rect_position.y+player_dashboards[trader_id].rect_size.y)
	else: player_dashboards[5].position = Vector2(player_dashboards[trader_id].rect_position.x-player_dashboards[trader_id].rect_size.x,player_dashboards[trader_id].rect_position.y+player_dashboards[trader_id].rect_size.y)
	# Icon appear
	var icon_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	icon_tween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,1), .3)
	yield(get_tree().create_timer(.3),"timeout")
	# Card pass loop
	var my_card_size: int = player_hands[my_id].size()
	for n in player_hands[my_id].size():
		# Setup card
		var position = my_hand.cards_in_hand[my_card_size-n-1].rect_position
		var card = player_hands[my_id][my_card_size-n-1]
		my_hand.discard_card(my_hand.cards_in_hand[my_card_size-n-1])
		var discarded_card = replace(card)
		player_hands[my_id][my_card_size-n-1] = discarded_card
		discarded_card.rect_position = position+Vector2(140,620)
		discarded_card.rect_scale = Vector2(.5,.5)
		add_child(discarded_card)
		# ANIMATION
		# Move card from dashboard to middle of the screen
		AudioController.play_swish_sound() # Sound
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(discarded_card, "rect_position", Vector2(640,334)-discarded_card.rect_size/4, .5)
		tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(.5,.5), .5)
		# Move it to its new owner's dashboard
		if trader_id==0 or trader_id==3: tween.tween_property(discarded_card, "rect_position", Vector2(player_dashboards[trader_id].rect_position.x+player_dashboards[trader_id].rect_size.x,player_dashboards[trader_id].rect_position.y+player_dashboards[trader_id].rect_size.y), .5)
		else: tween.tween_property(discarded_card, "rect_position", Vector2(player_dashboards[trader_id].rect_position.x-player_dashboards[trader_id].rect_size.x,player_dashboards[trader_id].rect_position.y+player_dashboards[trader_id].rect_size.y), .5)
		tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(0,0), .5)
		tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
		# Await
		yield(get_tree().create_timer(1),"timeout")
	# Icon disappear
	var icon_retween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	icon_retween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,0), .3)
	yield(get_tree().create_timer(.3),"timeout")
	#
	##########
	# YOU GIVE
	# Icon setup
	if trader_id==0 or trader_id==3: player_dashboards[6].position = Vector2(player_dashboards[trader_id].rect_position.x+player_dashboards[trader_id].rect_size.x,player_dashboards[trader_id].rect_position.y+player_dashboards[trader_id].rect_size.y)
	else: player_dashboards[6].position = Vector2(player_dashboards[trader_id].rect_position.x-player_dashboards[trader_id].rect_size.x,player_dashboards[trader_id].rect_position.y+player_dashboards[trader_id].rect_size.y)
	# Icon appear
	var reicon_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	reicon_tween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,1), .3)
	yield(get_tree().create_timer(.3),"timeout")
	# Card pass loop
	for n in player_hands[trader_id].size():
		# Setup card
		var card = player_hands[trader_id][n]
		if trader_id==0 or trader_id==3: card.rect_position = Vector2(player_dashboards[trader_id].rect_position.x+player_dashboards[trader_id].rect_size.x,player_dashboards[trader_id].rect_position.y+player_dashboards[trader_id].rect_size.y)
		else: card.rect_position = Vector2(player_dashboards[trader_id].rect_position.x-player_dashboards[trader_id].rect_size.x,player_dashboards[trader_id].rect_position.y+player_dashboards[trader_id].rect_size.y)
		# ANIMATION
		# Move card from dashboard to middle of the screen
		AudioController.play_swish_sound() # Sound
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "rect_position", Vector2(640,334)-card.rect_size/4, .5)
		tween.parallel().tween_property(card, "rect_scale", Vector2(.5,.5), .5)
		# Move it to the middle of my hand
		tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/4,my_hand.rect_position.y), .5)
		tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
		# Await and fixup
		yield(get_tree().create_timer(1),"timeout")
		remove_child(card)
		my_hand.add_card(card)
	# Icon disappear
	var reicon_retween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	reicon_retween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,0), .3)
	yield(get_tree().create_timer(.3),"timeout")
	#
	#######
	# LOGIC
	var buf: Array = player_hands[my_id].duplicate()
	player_hands[my_id] = player_hands[trader_id]
	player_hands[trader_id] = buf
	player_dashboards[my_id].get_node("Card_Icons/Card_Number").text = str(player_hands[my_id].size())
	player_dashboards[trader_id].get_node("Card_Icons/Card_Number").text = str(player_hands[trader_id].size())
	# Sync
	yield(synchronize(),"completed")

# Two other players trade hands
func they_trade(trader_id_1: int, trader_id_2: int):
	# ANIMATIONS
	yield(they_trade_aux(trader_id_1,trader_id_2),"completed")
	yield(they_trade_aux(trader_id_2,trader_id_1),"completed")
	# LOGIC
	var buf: Array = player_hands[trader_id_1].duplicate()
	player_hands[trader_id_1] = player_hands[trader_id_2]
	player_hands[trader_id_2] = buf
	player_dashboards[trader_id_1].get_node("Card_Icons/Card_Number").text = str(player_hands[trader_id_1].size())
	player_dashboards[trader_id_2].get_node("Card_Icons/Card_Number").text = str(player_hands[trader_id_2].size())
	# Sync
	yield(synchronize(),"completed")
# Animation: trader_1 passes their cards to trade
func they_trade_aux(trader_id_1: int, trader_id_2: int):
	######
	# PREP
	# Icon setup
	if trader_id_1==0 or trader_id_1==3: player_dashboards[5].position = Vector2(player_dashboards[trader_id_1].rect_position.x+player_dashboards[trader_id_1].rect_size.x,player_dashboards[trader_id_1].rect_position.y+player_dashboards[trader_id_1].rect_size.y)
	else: player_dashboards[5].position = Vector2(player_dashboards[trader_id_1].rect_position.x-player_dashboards[trader_id_1].rect_size.x,player_dashboards[trader_id_1].rect_position.y+player_dashboards[trader_id_1].rect_size.y)
	if trader_id_2==0 or trader_id_2==3: player_dashboards[6].position = Vector2(player_dashboards[trader_id_2].rect_position.x+player_dashboards[trader_id_2].rect_size.x,player_dashboards[trader_id_2].rect_position.y+player_dashboards[trader_id_2].rect_size.y)
	else: player_dashboards[6].position = Vector2(player_dashboards[trader_id_2].rect_position.x-player_dashboards[trader_id_2].rect_size.x,player_dashboards[trader_id_2].rect_position.y+player_dashboards[trader_id_2].rect_size.y)
	# Icon appear
	var icon_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	icon_tween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,1), .3)
	icon_tween.parallel().tween_property(player_dashboards[6], "modulate", Color(1,1,1,1), .3)
	yield(get_tree().create_timer(.3),"timeout")
	#
	###########
	# ANIMATION
	# Card pass loop
	for n in player_hands[trader_id_1].size():
		# Setup card
		var card = player_hands[trader_id_1][n]
		if trader_id_1==0 or trader_id_1==3: card.rect_position = Vector2(player_dashboards[trader_id_1].rect_position.x+player_dashboards[trader_id_1].rect_size.x,player_dashboards[trader_id_1].rect_position.y+player_dashboards[trader_id_1].rect_size.y)
		else: card.rect_position = Vector2(player_dashboards[trader_id_1].rect_position.x-player_dashboards[trader_id_1].rect_size.x,player_dashboards[trader_id_1].rect_position.y+player_dashboards[trader_id_1].rect_size.y)
		card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
		card.cover()
		# ANIMATION
		# Move card from dashboard to middle of the screen
		AudioController.play_swish_sound() # Sound
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "rect_position", Vector2(640,334)-card.rect_size/4, .5)
		tween.parallel().tween_property(card, "rect_scale", Vector2(.5,.5), .5)
		# Move it to its new owner's dashboard
		if trader_id_2==0 or trader_id_2==3: tween.tween_property(card, "rect_position", Vector2(player_dashboards[trader_id_2].rect_position.x+player_dashboards[trader_id_2].rect_size.x,player_dashboards[trader_id_2].rect_position.y+player_dashboards[trader_id_2].rect_size.y), .5)
		else: tween.tween_property(card, "rect_position", Vector2(player_dashboards[trader_id_2].rect_position.x-player_dashboards[trader_id_2].rect_size.x,player_dashboards[trader_id_2].rect_position.y+player_dashboards[trader_id_2].rect_size.y), .5)
		tween.parallel().tween_property(card, "rect_scale", Vector2(0,0), .5)
		tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
		# Await and fixup
		yield(get_tree().create_timer(1),"timeout")
		card.get_node("Architecture").modulate = Color(1,1,1,1) # Revealed
		card.uncover()
	# Icon disappear
	var icon_retween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	icon_retween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,0), .3)
	icon_retween.parallel().tween_property(player_dashboards[6], "modulate", Color(1,1,1,0), .3)
	yield(get_tree().create_timer(.3),"timeout")

##############
# Shuffle hand
##############

# Shuffle a player's hand into the deck
func shuffle_hand(player_id: int):
	# Who shuffles
	if PlayersList.get_player_unique_id(player_id)==PlayersList.get_my_unique_id():
		yield(i_shuffle(),"completed")
	else:
		yield(someone_else_shuffles(player_id),"completed")

# I shuffle my hand
func i_shuffle():
	##################
	# PREP + ANIMATION
	# Card pass loop
	var my_card_size: int = player_hands[my_id].size()
	for n in player_hands[my_id].size():
		# Setup card
		var position = my_hand.cards_in_hand[my_card_size-n-1].rect_position
		var card = player_hands[my_id][my_card_size-n-1]
		my_hand.discard_card(my_hand.cards_in_hand[my_card_size-n-1])
		var discarded_card = replace(card)
		player_hands[my_id][my_card_size-n-1] = discarded_card
		discarded_card.rect_position = position+Vector2(140,620)-discarded_card.rect_size/2
		discarded_card.rect_scale = Vector2(.5,.5)
		discarded_card.cover()
		add_child(discarded_card)
		# ANIMATION
		# Move card to the deck
		AudioController.play_swish_sound() # Sound
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(discarded_card, "rect_position", Vector2(1048,159), .7)
		tween.parallel().tween_property(discarded_card.get_node("Architecture"), "modulate", Color(1,1,1,0), .7)
		tween.parallel().tween_property(discarded_card, "rect_scale", Vector2(.35,.35), .7)
		tween.parallel().tween_property(discarded_card, "rect_rotation", 90, .7)
		# Make it disappear
		tween.tween_property(discarded_card, "modulate", Color(1,1,1,0), .3)
		tween.parallel().tween_callback(AudioController,"play_card_shove_1") # Sound
		# Await and fixup
		yield(get_tree().create_timer(1),"timeout")
		discarded_card.get_node("Architecture").modulate = Color(1,1,1,1)
		discarded_card.uncover()
		cards_in_deck.append(discarded_card)
		remove_child(discarded_card)
	#
	#########
	# PROCEED
	# Finish
	cards_in_deck.shuffle()
	update_deck_number_label()
	player_hands[my_id].clear()
	player_dashboards[my_id].get_node("Card_Icons/Card_Number").text = str(player_hands[my_id].size())
	yield(get_tree().create_timer(.01),"timeout")
	# Sync
	yield(synchronize(),"completed")

# Someone else shuffles their hand
func someone_else_shuffles(player_id: int):
	##################
	# PREP + ANIMATION
	# Icon setup
	if player_id==0 or player_id==3: player_dashboards[6].position = Vector2(player_dashboards[player_id].rect_position.x+player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y)
	else: player_dashboards[6].position = Vector2(player_dashboards[player_id].rect_position.x-player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y)
	# Icon appear
	var icon_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	icon_tween.tween_property(player_dashboards[6], "modulate", Color(1,1,1,1), .3)
	yield(get_tree().create_timer(.3),"timeout")
	# Card pass loop
	for n in player_hands[player_id].size():
		# Setup card
		var card = player_hands[player_id][n]
		if player_id==0 or player_id==3: card.rect_position = Vector2(player_dashboards[player_id].rect_position.x+player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y)
		else: card.rect_position = Vector2(player_dashboards[player_id].rect_position.x-player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y)
		card.get_node("Architecture").modulate = Color(1,1,1,0) # Hidden
		card.cover()
		# ANIMATION
		# Move card from dashboard to the deck
		AudioController.play_swish_sound() # Sound
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "rect_position", Vector2(1048,159), .7)
		tween.parallel().tween_property(card, "rect_scale", Vector2(.35,.35), .7)
		tween.parallel().tween_property(card, "rect_rotation", 90, .7)
		# Make it disappear
		tween.tween_property(card, "modulate", Color(1,1,1,0), .3)
		tween.parallel().tween_callback(AudioController,"play_card_shove_1") # Sound
		# Await and fixup
		yield(get_tree().create_timer(1),"timeout")
		card.get_node("Architecture").modulate = Color(1,1,1,1) # Revealed
		card.uncover()
		cards_in_deck.append(card)
		remove_child(card)
	# Icon disappear
	var icon_retween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	icon_retween.parallel().tween_property(player_dashboards[6], "modulate", Color(1,1,1,0), .3)
	yield(get_tree().create_timer(.3),"timeout")
	#
	#########
	# PROCEED
	# Finish
	cards_in_deck.shuffle()
	update_deck_number_label()
	player_hands[player_id].clear()
	player_dashboards[player_id].get_node("Card_Icons/Card_Number").text = str(player_hands[player_id].size())
	yield(get_tree().create_timer(.01),"timeout")
	# Sync
	yield(synchronize(),"completed")

###################################
# Take a card from the discard pile
###################################

# Take a card from the discard pile
func retrieve_card(player_id: int, card_index: int):
	# Check
	if card_index<0 || player_hands[player_id].size()>6:
		yield(get_tree().create_timer(.1),"timeout")
	# Which card?
	else:
		cards_in_pile.remove(card_index)
		var card = replace(pile_UI.retrieve_card(card_index))
		# Who takes?
		if player_id==my_id: yield(i_retrieve(card),"completed")
		else: yield(someone_else_retrieves(player_id,card),"completed")

# I take it
func i_retrieve(card):
	######
	# PREP
	# Place card over red deck space
	card.rect_rotation = 90
	card.rect_scale = Vector2(.35,.35)
	card.rect_position = Vector2(1048,247)
	card.modulate = Color(1,1,1,0)
	add_child(card)
	#
	###########
	# ANIMATION
	# Make Card appear
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "modulate", Color(1,1,1,1), .3)
	# Update UI after it appeared (looks good)
	tween.tween_callback(self,"update_pile_number_label")
	# Move card to middle of the screen
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/5.5,card.rect_position.y), .4)
	tween.parallel().tween_property(card, "rect_rotation", 0, .4)
	tween.parallel().tween_callback(AudioController,"play_cardsoundflick") # Sound
	# "Reveal" card
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/2,card.rect_position.y-100), .7)
	tween.parallel().tween_property(card, "rect_scale", Vector2(1,1), .7)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
	tween.tween_callback(AudioController,"play_interface_1") # Sound
	# Move card to middle of the hand
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/4,my_hand.rect_position.y), .3)
	tween.parallel().tween_property(card, "rect_scale", Vector2(.5,.5), .3)
	# Await and fixup
	yield(get_tree().create_timer(1.5),"timeout")
	#
	#########
	# PROCEED
	# Add card to hand
	add_player_card(my_id,card)
	remove_child(card)
	yield(my_hand.add_card(card),"completed")
	# Sync
	yield(synchronize(),"completed")

# Someone else takes it
func someone_else_retrieves(player_id: int, card):
	######
	# PREP
	# Place card over red deck space
	card.rect_scale = Vector2(.35,.35)
	card.modulate = Color(1,1,1,0)
	card.rect_rotation = 90
	card.rect_position = Vector2(1048,247)
	add_child(card)
	# Setup Drew_A_Card icon
	if player_id==0 or player_id==3: player_dashboards[5].position = Vector2(player_dashboards[player_id].rect_position.x+player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y)
	else: player_dashboards[5].position = Vector2(player_dashboards[player_id].rect_position.x-player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y)
	#
	###########
	# ANIMATION
	# Make Card and icon appear
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "modulate", Color(1,1,1,1), .3)
	tween.parallel().tween_property(player_dashboards[5], "modulate", Color(1,1,1,1), .3)
	# Update UI after it appeared
	tween.tween_callback(self,"update_pile_number_label")
	# Move card to middle of the screen
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/5.5,card.rect_position.y), .4)
	tween.parallel().tween_property(card, "rect_rotation", 0, .4)
	tween.parallel().tween_callback(AudioController,"play_cardsoundflick") # Sound
	# "Reveal" card
	tween.tween_property(card, "rect_position", Vector2(640-card.rect_size.x/2,card.rect_position.y-100), .7)
	tween.parallel().tween_property(card, "rect_scale", Vector2(1,1), .7)
	tween.parallel().tween_callback(AudioController,"play_swing_whoosh_in_room_2") # Sound
	# Await
	yield(get_tree().create_timer(1),"timeout")
	# Trigger Click_or_Wait
	var click: Vector2 = yield(trigger_click_or_wait(),"completed")
	# Show info if clicked the card
	if Rect2(card.get_position(),card.get_size()).has_point(click):
		info_panel.show_info(card.get_card_name(),"Red",card.get_id())
	# Move card to player's dashboard
	var retween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if player_id==0 or player_id==3: retween.tween_property(card, "rect_position", Vector2(player_dashboards[player_id].rect_position.x+player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y), .3)
	else: retween.tween_property(card, "rect_position", Vector2(player_dashboards[player_id].rect_position.x-player_dashboards[player_id].rect_size.x,player_dashboards[player_id].rect_position.y+player_dashboards[player_id].rect_size.y), .3)
	retween.parallel().tween_property(card, "rect_scale", Vector2(0,0), .3)
	retween.parallel().tween_callback(AudioController,"play_cardsoundflick") # Sound
	# Make icon disappear
	retween.tween_property(player_dashboards[5], "modulate", Color(1,1,1,0), .3)
	# Await
	yield(get_tree().create_timer(.5),"timeout")
	#
	#########
	# PROCEED
	# Logic
	add_player_card(player_id,card)
	# Sync
	yield(synchronize(),"completed")

###################
# Other logic funcs
###################

# Add card to hand and update UI
func add_player_card(id: int, card):
	player_hands[id].append(card)
	player_dashboards[id].get_node("Card_Icons/Card_Number").text = str(player_hands[id].size())
# Remove card from hand and update UI
func remove_player_card(id: int, card):
	player_hands[id].erase(card)
	player_dashboards[id].get_node("Card_Icons/Card_Number").text = str(player_hands[id].size())

# Checks if a player has at least a card in hand
func player_has_cards(id: int) -> bool:
	return not player_hands[id].empty()
# Checks if a player has a specific card in hand
func player_has_card(id: int, card_id: int) -> bool:
	for c in player_hands[id]: if c.get_id()==card_id: return true
	return false

# Return number of cards in a player's hand
func get_player_card_number(id: int) -> int:
	return player_hands[id].size()
# Get all cards in a player's hand
func get_player_cards(id: int) -> Array:
	var player_cards: Array = []
	for card in player_hands[id]:
		var player_card = replace(card,false)
		player_cards.append(player_card)
	return player_cards

# Return number of cards in discard pile
func get_cards_in_pile_number() -> int:
	return cards_in_pile.size()
# Get all cards in discard pile
func get_cards_in_pile() -> Array:
	var pile_cards: Array = []
	for card in pile_UI.get_cards():
		var pile_card = replace(card,false)
		pile_cards.append(pile_card)
	return pile_cards

# Gets the name of a card in a player's hand
func get_player_card_name(player_id: int, card_index: int) -> String:
	return tr(player_hands[player_id][card_index].get_card_name())
# Gets the name of a card in the discard pile
func get_pile_card_name(card_index: int) -> String:
	return tr(get_cards_in_pile()[card_index].get_card_name())

# Replace an existing Card with a copy
func replace(card, delete_original: bool = true) -> MarginContainer:
	# Extract card info
	var card_info: Array = []
	card_info.append(card.get_node("Architecture/Name_Container/Panel/Name").get("custom_fonts/font").get("size")) # Name char size
	card_info.append(card.get_node("Architecture/Effect_Container/Panel/Effect").get("custom_fonts/font").get("size")) # Eff char size
	var og_card_info: Array = card.get_info()
	card_info.append(og_card_info[0]) # ID
	card_info.append(og_card_info[2]) # Name
	if delete_original: card.queue_free()
	# Create copy of the card
	var new_card = card_template.instance()
	new_card.initialize("Red",card_info)
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

#

####################
# Bot-Handling Stuff
####################

######################################################################################
# The many steps taken by a bot on the quest to play a dang card cause me code is arse

# Used to choose the card to play
var index_tot: int = 0
# Used communicate the card to play
signal bot_chose

# Bot checks if they can play a card
# If so, sends a message to all other peers along and calls pc_suggests_a_card to suggest and index
# Then gets a number from the total of the suggested indexes and checks if the bot can play the corresponding card
# Finally, return the id of the card if playable
# (returns -1 if hand empty or chosen card not playable)
func bot_tries_to_play_a_card(curr: int):
	# - Avoid deadlocks
	for n in 4: reaction_handler.registered_reactions[n] = 0
	yield(get_tree().create_timer(.2),"timeout")
	# - Checks for cards in hand
	var hand_size: int = get_player_card_number(curr)
	if hand_size<1:
		emit_signal("bot_chose",-1)
		return
	# - Everyone suggests a random number from 0 to twice the bot's hand size
	# warning-ignore:narrowing_conversion
	var suggested_index: int = RNGController.unique_roll(0,hand_size*2) # was hand_size-1
	index_tot+=suggested_index
	if PlayersList.am_on():
		rpc("pc_suggests_a_card", suggested_index)
		yield(synchronize(),"completed")
	# - 50% chance to play no card anyways
	if index_tot<=hand_size*PlayersList.get_apn():
		emit_signal("bot_chose",-1)
		return
	# - Otherwise gets the card corresponding to the index
	var chosen_index: int = index_tot%hand_size
	index_tot = 0
	# - Checks if the card is playable
	var card_id: int = player_hands[curr][chosen_index].get_id()
	if target_checker.can_be_played(curr,card_id,false)[0]==false: emit_signal("bot_chose",-1)
	# - Returns its id
	else: emit_signal("bot_chose",card_id)

# Aux function to add the suggested indexes
remote func pc_suggests_a_card(suggested_index): index_tot+=suggested_index

# A bot actually plays a card
func bot_plays_a_card(curr,card_id):
	###############
	# CHECK TARGETS
	var check_info: Array = target_checker.can_be_played(curr,card_id)
	#
	###########
	# PLAY CARD
	yield(someone_else_plays(curr,card_id),"completed")
	yield(Synchronizer.synchronize_game(),"completed")
	#
	######################
	# GET TARGET(S) IF ANY
	var targets = yield(effects.get_target(curr,card_id,check_info[1]),"completed")
	# Dual Chance's reactability is 'Single Enemy Target' by default, this changes if the first effect is chosen
	if card_id==18 and targets.empty(): check_info[2] = "Unspecified"
	#
	################
	# ALLOW REACTION + Sync
	yield(check_and_allow_reactions(check_info[2],targets),"completed")
	var reaction: int = 0
	var reactor_id: int
	for n in range(1,4):
		reactor_id = (curr+n)%4
		if reaction_handler.registered_reactions[reactor_id]!=reaction:
			reaction = reaction_handler.registered_reactions[reactor_id]
			break
	#
	#################
	# ACTIVATE EFFECT
	# No reaction was made
	if reaction==0: activate_card(curr,card_id,targets)
	# A reaction was made
	else: activate_reaction(curr,card_id,reactor_id,reaction,targets)

# Bot somehow combos (DONER_DELIGHT only)
func bot_combos(curr,card_id):
	match card_id:
		35:
			if player_has_card(curr,36) and player_has_card(curr,37):
				yield(someone_else_combos(curr,[35,36,37]),"completed")
				activate_card(curr,-2,[])
			else: effects.game_manager.chain_number-=1
		36:
			if player_has_card(curr,35) and player_has_card(curr,37):
				yield(someone_else_combos(curr,[35,36,37]),"completed")
				activate_card(curr,-2,[])
			else: effects.game_manager.chain_number-=1
		37:
			if player_has_card(curr,35) and player_has_card(curr,36):
				yield(someone_else_combos(curr,[35,36,37]),"completed")
				activate_card(curr,-2,[])
			else: effects.game_manager.chain_number-=1
		_:
			effects.game_manager.chain_number-=1
