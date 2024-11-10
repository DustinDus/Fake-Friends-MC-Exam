extends Node2D
# Manages the rolls to decide who starts and delegates UI changes

# Nodes
var roll_button: TextureButton
var dashboards: Control

# Who's next to roll
var curr: int
# Highest roll value
var max_roll: int
# Indexes of players who need to roll
var has_to_roll_players: Array
# Indexes of players who rolled equal to max_roll
var max_roll_players: Array

# Timer stuff
var t: float = 0.0
var timebar: TextureProgress

# Preparations
func _ready(): show()

# Init
func initialize():
	# Timer prep
	set_process(false)
	timebar = get_child(0)
	# Roll prep
	roll_button = get_child(2)
	yield(roll_button.initialize(0),"completed") # Has animation
	dashboards = get_child(1)
	yield(dashboards.initialize(),"completed") # Has animation
	curr = 0 # Red -> Blue -> Green -> Yellow
	max_roll = 0
	has_to_roll_players = [0,1,2,3]
	max_roll_players = []
	who_is_next()

#########################
# Roll-handling functions

# Check who's next to roll
func who_is_next():
	dashboards.update_turn(curr)
	yield(get_tree().create_timer(1.1),"timeout") # Wait here to avoid problems with update_turns' tween.stop()
	var id = PlayersList.get_player_unique_id(curr)
	if id==PlayersList.get_my_unique_id():
		roll_button.disabled = false
		roll_button.disable_color(false)
		start_timer()
	else:
		roll_button.disabled = true
		roll_button.disable_color(true)

# A player rolls for their value
func _roll_to_start():
	# Timer fix
	stop_timer()
	# Roll + Animation
	roll_button.disabled = true
	var res = RNGController.unique_roll(1,6)
	if PlayersList.am_on(): roll_button.rpc("roll", res)
	yield(roll_button.roll(res),"completed")
	# Everyone checks the roll
	check_roll(res)
	if PlayersList.am_on(): rpc("check_roll", res)

# Checks the roll
remote func check_roll(res: int):
	# If its the highest so far they become the sole max_roll_players
	if res>max_roll:
		max_roll = res
		max_roll_players.clear()
		max_roll_players.append(curr)
	# If its equal to max_roll they are added to other max_roll_players
	elif res==max_roll:
		max_roll_players.append(curr)
	dashboards.update_result(curr,res)
	# Looks for next player to have roll
	while 1:
		curr+=1
		if curr>3 || has_to_roll_players.has(curr): break
	# Checks results if everyone has rolled
	if curr>3: control_results()
	# Seeks next otherwise
	else: who_is_next()

# Checks the rolls
func control_results():
	# Holup
	yield(get_tree().create_timer(1),"timeout")
	# There is only one max_roll_player
	if max_roll_players.size()==1:
		# Disappear
		roll_button.move_out()
		AudioController.play_bloop_1() # Sound
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(dashboards, "modulate", Color(1,1,1,0), 1)
		yield(get_tree().create_timer(1.5),"timeout")
		# Set up the Game Manager
		var game_manager: Node2D = get_parent().get_child(4)
		game_manager.visible = true
		game_manager.initialize(max_roll_players[0])
		#game_manager.initialize(0)
		# Free Pregame Manager
		self.queue_free()
	# There are multiples: redo the rolls among max_roll_players
	else:
		# Stores the players who rolled max
		has_to_roll_players = max_roll_players.duplicate(true)
		max_roll_players.clear()
		curr = has_to_roll_players[0]
		max_roll = 0
		dashboards.reset_dashboards(has_to_roll_players)
		# Checks who rolls next
		who_is_next()

#########################
# Timer-related functions

# Animation and check
func _process(delta):
	t+=delta
	timebar.value = (t/10)*100
	if t>10:
		if PlayersList.decrease_disconnect_countdown(): $".."._main_menu() # Disconnect Countdown Shenanigans
		_roll_to_start()

# Start
func start_timer():
	AudioController.play_back_tick() # Sound
	t = .0
	timebar.value = .0
	set_process(true)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(timebar,"modulate",Color(1,1,1,.2),.5)
	yield(get_tree().create_timer(.5),"timeout")

# Stop
func stop_timer():
	set_process(false)
	print("STOPPED")
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(timebar,"modulate",Color(1,1,1,0),.5)
	yield(get_tree().create_timer(.5),"timeout")
