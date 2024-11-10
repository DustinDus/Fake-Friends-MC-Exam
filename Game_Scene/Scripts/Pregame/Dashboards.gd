extends Control
# Manages pregame dashboards UI

var dashboards: Array
var turn_indicator: Sprite

# Init
func initialize():
	for n in 4: 
		dashboards.append(get_child(n))
		dashboards[n].get_node("Username").text = PlayersList.get_player_username(n)
		dashboards[n].get_node("Result").text = ""
	turn_indicator = get_child(4)
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(AudioController,"play_chips_stack_1") # Sound
	tween.tween_property(dashboards[0],"rect_position",Vector2(0,0),.2)
	tween.tween_callback(AudioController,"play_chips_stack_1") # Sound
	tween.tween_property(dashboards[1],"rect_position",Vector2(300,0),.2)
	tween.tween_callback(AudioController,"play_chips_stack_1") # Sound
	tween.tween_property(dashboards[2],"rect_position",Vector2(300,300),.2)
	tween.tween_callback(AudioController,"play_chips_stack_1") # Sound
	tween.tween_property(dashboards[3],"rect_position",Vector2(0,300),.2)
	yield(get_tree().create_timer(.9),"timeout")
	update_turn(0)

# Update result label of a player
func update_result(p: int, res: int):
	dashboards[p].get_node("Result").text = str(res)

# Check which dashboards to hide and which to reset
func reset_dashboards(has_to_roll_players: Array):
	for n in 4:
		if not has_to_roll_players.has(n):
			AudioController.play_chips_handle_3() # Sound
			if n==0 or n==3:
				var pos = dashboards[n].rect_position
				var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(dashboards[n],"rect_position",Vector2(pos.x-640,pos.y),.2)
			else:
				var pos = dashboards[n].rect_position
				var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(dashboards[n],"rect_position",Vector2(pos.x+640,pos.y),.2)
		else: dashboards[n].get_node("Result").text = ""

# Moves the "Curr_Turn_Icon"
func update_turn(p: int):
	# Indicator disappears
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(turn_indicator, "modulate", Color(1,1,1,0), .3)
	# Sets up new position
	match p:
		0: tween.tween_property(turn_indicator, "position", Vector2(140,140), 0)
		1: tween.tween_property(turn_indicator, "position", Vector2(360,140), 0)
		2: tween.tween_property(turn_indicator, "position", Vector2(360,360), 0)
		3: tween.tween_property(turn_indicator, "position", Vector2(140,360), 0)
	# Indicator reappears
	tween.tween_property(turn_indicator, "modulate", Color(1,1,1,1), .3)
	# Indicator rotation
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_callback(AudioController,"play_twirling_cartoon_sound")
	tween.tween_property(turn_indicator, "rotation_degrees", 360, .4)
	yield(get_tree().create_timer(1.8),"timeout")
	turn_indicator.rotation_degrees=0 # Reset rotation
