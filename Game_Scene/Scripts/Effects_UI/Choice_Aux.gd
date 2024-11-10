extends Control
# Aux for choice effects UI

# Possible kinds of choice UI
var one_or_the_other: Control
var one_to_six: Control
var board_number: Control
# To remember the type
var choice_type: String
# Signal for Eff classes
signal communicate_answer

# Init
func initialize():
	one_or_the_other = $One_or_the_Other
	one_to_six = $"1_to_6"
	board_number = $Board_Number
	board_number.initialize()

# Identifies choice and prepares UI
func pre_setup_UI(activator_unique_id: int, type):
	# Choices that require specific images
	if typeof(type)==19:
		choice_type = "one_or_the_other"
		one_or_the_other.prepare_choice(type, type.size())
	# Other choices
	else: choice_type = type
	# Next
	setup_UI(activator_unique_id)

# Pulls up UI
func setup_UI(activator_unique_id: int):
	if choice_type=="one_or_the_other": yield(one_or_the_other.pull_up(activator_unique_id),"completed")
	elif choice_type=="1_to_6": yield(one_to_six.pull_up(activator_unique_id),"completed")
	elif choice_type=="board_number": yield(board_number.pull_up(activator_unique_id),"completed")

# Each button's answer
func _answer_1(): propagate_answer(1)
func _answer_2(): propagate_answer(2)
func _answer_3(): propagate_answer(3)
func _answer_4(): propagate_answer(4)
func _answer_5(): propagate_answer(5)
func _answer_6(): propagate_answer(6)
func _answer_x(x: int): propagate_answer(x)
# Activator propagates their answer
func propagate_answer(answer: int):
	get_parent().done = true # Stop timer
	if PlayersList.am_on(): rpc("start_answering",answer)
	start_answering(answer)
# Pull down UI and answer
remote func start_answering(answer: int):
	if choice_type=="one_or_the_other": yield(one_or_the_other.pull_down(answer),"completed")
	elif choice_type=="1_to_6": yield(one_to_six.pull_down(answer),"completed")
	elif choice_type=="board_number": yield(board_number.pull_down(),"completed")
	answer(answer)
# Everyone returns the answer
func answer(answer): emit_signal("communicate_answer",answer)
