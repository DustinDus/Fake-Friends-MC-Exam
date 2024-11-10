extends Node2D
# Makes the game start/restart/stop
#warning-ignore-all:integer_division

var starting_time: int # To time the match
var game_is_over: bool # Stops the bots from playing after the game is over

# Init
func _ready():
	# Prep
	Synchronizer.set_peripheral_tool($Game_Manager/Click_Or_Wait_Layer)
	UserStats.reset_game_stats()
	$Utility_Buttons.initialize(1)
	RNGController.initialize(PlayersList.create_seed())
	starting_time = OS.get_unix_time()
	game_is_over = false
	PlayersList.prepare_bot_uns()
	# Signals
	if $Game_Manager/Animation_Manager/Victory.connect("play_again",self,"_play_again")!=0: print("!!! Game can't connect a signal !!!")
	if $Game_Manager/Animation_Manager/Victory.connect("main_menu",self,"_main_menu")!=0: print("!!! Game can't connect a signal !!!")
	# Hide back button + Start the game
	if PlayersList.am_on():
		$Utility_Buttons/Back/Back_Button.disabled = true
		$Utility_Buttons/Back/Back_Button.rect_position = Vector2(15,-80)
		get_child(3).initialize()
	else:
		get_child(3).queue_free()
		get_child(4).show()
		get_child(4).initialize(PlayersList.get_my_id())

# Restart the game
func _play_again():
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Game_Manager, "modulate", Color(1,1,1,0), 1)
	tween.parallel().tween_property($Background/Solid_Color_Cover.get("custom_styles/panel"), "bg_color", Color("#1c1c1c"), 1)
	tween.tween_property($Game_Manager/Info_Layer, "offset", Vector2(0,-100), 0) # CanvasLayer
	tween.tween_property($Background/Solid_Color_Cover.get("custom_styles/panel"), "bg_color", Color("#00000000"), 1)
	yield(get_tree().create_timer(2),"timeout")
	# Change Scene
	if get_tree().reload_current_scene()!=0:
		print("!!! Game can't reload scene !!!")

# Back to main menu
func _main_menu():
	AudioController.play_mouse_close_button() # Sound
	# Prep
	$Lobby_Manager.kill_connection_if_online()
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Game_Manager, "modulate", Color(1,1,1,0), 1)
	tween.parallel().tween_property($Utility_Buttons, "offset", Vector2(0,-100), 1) # CanvasLayer
	tween.parallel().tween_property($Utility_Buttons/Panel_Center_Layer, "offset", Vector2(0,-100), 1) # CanvasLayer
	tween.parallel().tween_property($Game_Manager/Info_Layer, "offset", Vector2(0,-100), 1) # CanvasLayer
	for card_layer in $Game_Manager/Card_UI/My_Hand.get_children(): tween.parallel().tween_property(card_layer, "offset", Vector2(card_layer.offset.x,100), 1) # CanvasLayers
	tween.parallel().tween_property($Background/Solid_Color_Cover.get("custom_styles/panel"), "bg_color", Color("#1c1c1c"), 1)
	if has_node("Pregame_Manager"): tween.parallel().tween_property($Pregame_Manager, "modulate", Color(1,1,1,0), 1)
	tween.tween_callback($Game_Manager,"queue_free") # Free Game_Manager when the screen is dark to avoid seeing weird stuff
	tween.tween_property($Background/Solid_Color_Cover.get("custom_styles/panel"), "bg_color", Color("#dcdcdc"), 1)
	yield(get_tree().create_timer(2),"timeout")
	
	# Change Scene
	if get_tree().change_scene("res://Main_Scene/Main.tscn")!=0:
		print("!!! P2P_Setup can't change scene to Main !!!")

# Check for unlocks at the end of the game
func check_for_unlocks(victory: bool, game_manager):
	# Prep
	game_is_over = true
	var my_id: int = PlayersList.get_my_id() # My id
	var game_stats: Array = UserStats.get_game_stats() # Every player's stats this game [0,1,2,3]
	var minutes: int = int((OS.get_unix_time()-starting_time)/60.0) # How long was the match (in minutes)
	var date: Dictionary = Time.get_date_dict_from_system() # What day is today?
	for id in 4: game_stats[id].time+=minutes # Update every player's time stat
	var my_game_stats: Array = game_stats[my_id].git() # My own game stats
	UserStats.upd_stats(my_id,victory) # Update my stats
	var updated_user_stats: Array = UserStats.get_stats() # My own user stats
	# TITLES
	# 3-4
	if !victory: User.titles[3] = true # Lose a game
	if victory: User.titles[4] = true # Win a game
	# 5-9
	if updated_user_stats[2]>=5: User.titles[5] = true # Lose 5 games
	if updated_user_stats[1]>=5: User.titles[6] = true # Win 5 games
	if updated_user_stats[0]>=20: User.titles[7] = true # Play 20 games
	if my_game_stats[0]>=150: User.titles[8] = true # Travel 150 tiles
	if my_game_stats[1]>=3: User.titles[9] = true # Sent back to start 3 times
	# 10-14
	if my_game_stats[5]>=10: User.titles[10] = true # Draw 10 Red Cards
	if my_game_stats[6]>=20: User.titles[11] = true # Draw 20 Black Cards
	if my_game_stats[7]>=2: User.titles[12] = true # Draw 2 Orange Cards
	if my_game_stats[15]>=3: User.titles[13] = true # Discard 3 cards
	if my_game_stats[17]<=1200: User.titles[14] = true # Win in less than 20 minutes
	# 15-19
	if my_game_stats[17]>=3000: User.titles[15] = true # Win in more than 45 minutes
	if date["month"]==12 and date["day"]==25: User.titles[16] = true # Play during Christmas
	if my_game_stats[4]>=5: User.titles[17] = true # Send someone to the start 5 times
	if my_game_stats[9]>0: User.titles[18] = true # Activate a combo
	if victory:
		var unlock: bool = true
		var my_red_cards: int = my_game_stats[5]
		for gs in game_stats:
			if my_red_cards>=gs.red_cards_drawn:
				unlock = false
				break
		if unlock: User.titles[19] = true # Draw fewer Red Cards and still win
	# AVATARS
	# 5-9
	if updated_user_stats[2]: User.avatars[5] = true # Lose 3 games
	if updated_user_stats[1]: User.avatars[6] = true # Win 3 games
	if updated_user_stats[0]: User.avatars[7] = true # Play 10 games
	if my_game_stats[16]>=5: User.avatars[8] = true # Skip 5 turns
	if my_game_stats[2]>=3: User.avatars[9] = true # Jailed 3 times
	# 10-14
	if my_game_stats[17]: User.avatars[10] = true # Hold a hand of 7 cards
	if my_game_stats[3]>=100: User.avatars[11] = true # Make others go back 100 tiles
	if updated_user_stats[17]>=10: User.avatars[12] = true # Negate 10 Black Cards
	if my_game_stats[10]>=3: User.avatars[13] = true # Activate 3 reactions
	if updated_user_stats[11]+updated_user_stats[12]+updated_user_stats[13]>=100: User.avatars[14] = true # Draw 100 cards
	# 15-19
	if updated_user_stats[23]>=86400: User.avatars[15] = true # Play for 24 hours
	if date["month"]==10 and date["day"]==31: User.avatars[16] = true # Play during Halloween
	if !victory and game_manager.playerManager.get_player_tile(my_id)==1: User.avatars[17] = true # Lose while at the start
	if victory:
		var unlock: bool = true
		for n in range(1,4):
			var id = (my_id+n)%4
			if game_manager.playerManager.get_player_tile(id)>17:
				unlock = false
				break
		if unlock: User.avatars[18] = true # Win with everyone else in the dead zone
	if my_game_stats[19]: User.avatars[19] = true # Reflect FU
	# Save unlocks
	User.save_info()

func _exit_tree():
	if !game_is_over:
		UserStats.games_quit+=1
		UserStats.save_info()

# Get a bunch of labels that comment the game stats
#func get_comments(victor: bool) -> Array:
#	var comments: Array = [] # The comments are contained in this
#	var game_stats: Array = UserStats.get_game_stats_to_compare() # Every player's stats this game [0,1,2,3]
#	# Time Comment
#	var minutes: int = int((OS.get_unix_time()-starting_time)/60.0) # How long was the match (in minutes)
#	if minutes<20: comments.append("The match only lasted "+str(minutes)+" minutes!")
#	elif minutes<45: comments.append("The match lasted "+str(minutes)+" minutes")
#	else: comments.append("The match lasted a whopping "+str(minutes)+" minutes...")
#	# Whom was best/worst at what
#	var bests: Array = []
#	for arr in game_stats: bests.append(arr.bsearch(arr.max()))
#	var worsts: Array = []
#	for arr in game_stats: worsts.append(arr.bsearch(arr.min()))
#	# 
#	# Return
#	return comments
