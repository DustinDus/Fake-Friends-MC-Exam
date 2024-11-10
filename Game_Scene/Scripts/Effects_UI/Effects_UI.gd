extends Control
# Handles card effects animations+logic

# Possible UI effect a player can use
var target_aux # Target a player(s)
var roll_aux # Roll dice
var choice_aux # Choose something
var card_selection_aux # Choose a card

# Timer
var click_or_wait_layer: CanvasLayer
var done: bool = false # Just so the timer knows when to stop

# To remember the UI effect, the player who can interact with it and the specification (for bots)
var current_eff: Array = ["",-1,null]

# To communicate the player's choice/result
signal answer

# Preparations
func _ready(): show()

# Init
func initialize(red_effects, black_effects, orange_effects):
	# Actions
	target_aux = $Target_Aux
	target_aux.initialize()
	roll_aux = $Roll_Aux
	roll_aux.initialize()
	choice_aux = $Choice_Aux
	choice_aux.initialize()
	card_selection_aux = $Card_Selection_Aux
	card_selection_aux.initialize()
	click_or_wait_layer = $"../Click_Or_Wait_Layer"
	# Signals to request actions
	if red_effects.connect("question",self,"_interpret_question")!=0:
		print("!!! Aux_Effs can't connect a signal !!!")
	if black_effects.connect("question",self,"_interpret_question")!=0:
		print("!!! Aux_Effs can't connect a signal !!!")
	if orange_effects.connect("question",self,"_interpret_question")!=0:
		print("!!! Aux_Effs can't connect a signal !!!")

# Matches a question signal with an action
func _interpret_question(question: String, activator_unique_id: int, specification):
	register_eff(question,activator_unique_id,specification)
	match question:
		# Target player(s)
		"target": target(activator_unique_id,specification)
		# Roll
		"roll_start": roll_start(specification)
		"roll_allow": roll_allow(activator_unique_id,specification)
		"roll_close": roll_close()
		# Choice
		"choice": choice(activator_unique_id,specification)
		# Card Selection
		"card_selection": card_selection(activator_unique_id,specification)

# Returns an answer
func return_answer(answer):
	current_eff[0] = ""
	current_eff[1] = -1
	current_eff[2] = null
	emit_signal("answer",answer)

# Effects that target a player(s)
# "type" is an array containing two values:
# - type[0] points out the number of targets that must be selected (0 or 2 for code's sake)
# - type[1] contains the available targets among players
func target(activator_unique_id: int, type):
	# Bot?
	if PlayersList.is_bot_uid(activator_unique_id): bot_targets(type[0],type[1])
	# User
	elif activator_unique_id==PlayersList.get_my_unique_id():
		start_timer()
		target_aux.pre_setup_UI(type)
	var answer = yield(target_aux,"communicate_answer")
	return_answer(answer)

# Prepares UI for effects that require a dice to roll
# "type" is str(int) from 1 to 4 and indicates how to setup the plate
func roll_start(type: String):
	roll_aux.pre_setup_UI(type)
	yield(roll_aux,"communicate_answer")
	return_answer(0)
# Allows someone to roll
# "color" is str(int) used by the dice to change color 
func roll_allow(activator_unique_id: int, color: String):
	# Bot?
	if PlayersList.is_bot_uid(activator_unique_id): bot_rolls(color)
	# User
	elif activator_unique_id==PlayersList.get_my_unique_id(): start_timer()
	roll_aux.allow_to_roll(activator_unique_id,color)
	var answer = yield(roll_aux,"communicate_answer")
	return_answer(answer)
# Closes the roll UI
# There is no specification
func roll_close():
	roll_aux.close_UI()
	yield(roll_aux,"communicate_answer")
	return_answer(0)

# Sets up a choice for the specified player
# "type" can be a String or an array:
# - if String then it indicates the type of choice
# - if array then it containes the paths to the images needed for the choice
func choice(activator_unique_id: int, type):
	# Bot?
	if PlayersList.is_bot_uid(activator_unique_id): bot_chooses(type)
	# User
	elif activator_unique_id==PlayersList.get_my_unique_id(): start_timer()
	choice_aux.pre_setup_UI(activator_unique_id,type)
	var answer = yield(choice_aux,"communicate_answer")
	return_answer(answer)

# Makes the player choose a card among those specified
# "info_pool" is an array of two arrays:
# - [0] contains specifications [is_stoppable,cover_cards]
# - [1] contains the activator's cards
func card_selection(activator_unique_id: int, info_pool: Array):
	# Bot?
	if PlayersList.is_bot_uid(activator_unique_id): bot_selects_a_card(info_pool[0][0],info_pool[1])
	# User
	elif activator_unique_id==PlayersList.get_my_unique_id():
		start_timer()
		card_selection_aux.pre_setup_UI(info_pool)
	var answer = yield(card_selection_aux,"communicate_answer")
	return_answer(answer)

#

######################
# Timer-handling stuff
######################

# Start timer, give bot answer on timeout
func start_timer():
	# Only if online
	if !PlayersList.am_on(): return
	# Prep
	var t: float = .0
	done = false
	# Wait
	yield(get_tree().create_timer(.3),"timeout") # Necessary or targeting won't trigger the timer
	click_or_wait_layer.appear_to_tell_player_time_left(10.0)
	while true:
		t+=.1
		yield(get_tree().create_timer(.1),"timeout")
		if done:
			PlayersList.reset_disconnect_countdown() # Disconnect Countdown Shenanigans
			click_or_wait_layer.disappear()
			return
		if t>10.0:
			if PlayersList.decrease_disconnect_countdown(): $"../.."._main_menu() # Disconnect Countdown Shenanigans
			else: break
	# Roll
	bot_UI_fixup(true)

#

####################
# Bot-handling stuff
####################

# Remote func to register "private" current eff data
func register_eff(question: String, activator_id: int, type):
	current_eff[0] = question
	current_eff[1] = activator_id
	current_eff[2] = type

# Bot returns a random target
func bot_targets(n: int, targets: Array, to_rpc: bool = false):
	yield(get_tree().create_timer(.8),"timeout")
	targets.shuffle()
	if n==0:
		if to_rpc: target_aux.start_answering(targets[0])
		else: target_aux.answer(targets[0])
	else:
		if to_rpc:
			target_aux.stored_targets[0] = targets[0]
			target_aux.stored_targets[1] = targets[1]
			target_aux.start_answering(targets[1])
		else: target_aux.answer([targets[0],targets[1]])

# Bot rolls manually
func bot_rolls(color: String, to_rpc: bool = false):
	# Prep
	roll_aux.roll_button.disable_color(true,int(color))
	yield(get_tree().create_timer(.8),"timeout")
	# Answer
	if to_rpc: roll_aux._roll()
	else: roll_aux.answer(RNGController.common_roll(1,6))

# Bot returns a random choice
func bot_chooses(type, to_rpc: bool = false):
	# Prep
	yield(get_tree().create_timer(2),"timeout")
	var choices: Array = []
	# one_or_the_other
	if typeof(type)==19: for n in range(1,type.size()+1): choices.append(n)
	# one_to_six
	elif type=="1_to_6": for n in range(1,7): choices.append(n)
	# board_number
	else: for n in range(1,65): choices.append(n)
	# Answer
	choices.shuffle()
	if to_rpc: choice_aux.propagate_answer(choices[0])
	else: choice_aux.start_answering(choices[0])

# Bot stops if it can, returns a random card's index otherwise
func bot_selects_a_card(is_stoppable: int, cards: Array, to_rpc: bool = false):
	yield(get_tree().create_timer(.8),"timeout")
	if is_stoppable || cards.empty():
		if to_rpc: card_selection_aux._confirm_card()
		else: card_selection_aux.answer(-1)
	else:
		var indexes: Array = []
		for index in cards.size(): indexes.append(index)
		indexes.shuffle()
		if to_rpc:
			card_selection_aux.card_index = indexes[0]
			card_selection_aux._confirm_card()
		else: card_selection_aux.answer(indexes[0])

# In case the user disconnected while Effects_UI was triggered
func bot_UI_fixup(to_rpc: bool = false):
	# Target was triggered
	if current_eff[0]=="target": bot_targets(current_eff[2][0],current_eff[2][1],to_rpc)
	# Roll was triggered
	elif current_eff[0]=="roll_allow": bot_rolls(current_eff[2],to_rpc)
	# Choice was triggered
	elif current_eff[0]=="choice": bot_chooses(current_eff[2],to_rpc)
	# Card Selection was triggered
	elif current_eff[0]=="card_selection": bot_selects_a_card(current_eff[2][0][0],current_eff[2][1],to_rpc)
