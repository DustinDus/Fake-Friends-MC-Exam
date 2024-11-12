extends CanvasLayer
# Plays victory animation AND delegates the endgame menu actions

# Nodes
var victory_panel: Panel
var victory_label: Label
var play_again: Button
var main_menu: Button

var player_stats: Control
var indicator_label: Label
var buttons: Array
var stat_labels: Array

# How many want to play
var want_to_play: int

enum {RED, BLUE, GREEN, YELLOW}

signal play_again
signal main_menu

# Make panel and label disappear
func initialize():
	# Signal
	if get_tree().connect("network_peer_disconnected", self, "_client_goodbye")!=0:
		print("!!! Multiplayer_Config can't connect a signal !!!")
	if get_tree().connect("server_disconnected", self, "_host_goodbye")!=0:
		print("!!! Network singleton can't connect a signal !!!")
	# Vars
	victory_panel = get_child(0)
	victory_panel.modulate = Color(1,1,1,0)
	victory_label = get_child(1)
	victory_label.modulate = Color(1,1,1,0)
	play_again = get_child(2)
	play_again.modulate = Color(1,1,1,0)
	play_again.text = tr("PLAY AGAIN")
	main_menu = get_child(3)
	main_menu.modulate = Color(1,1,1,0)
	main_menu.text = tr("MAIN MENU")
	player_stats = get_child(4)
	player_stats.modulate = Color(1,1,1,0)
	indicator_label = $Player_Stats/Player_Indicator/Label
	buttons = []
	for n in 4: buttons.append($Player_Stats/Button_Panel/MarginContainer/HBoxContainer.get_child(n))
	want_to_play = 0

# Animation
func play(id: int, username: String):
	# Pre-Prep
	for n in 17: stat_labels.append($Player_Stats/Stats_Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer.get_child(n).get_child(0))
	# Prep
	victory_panel.show()
	victory_label.show()
	victory_label.text = username+" "+tr("WINS!")
	victory_label.add_color_override("font_color", get_color(id))
	play_again.show()
	main_menu.show()
	player_stats.show()
	_show_stats(id)
	# Animation
	AudioController.stop_music() # Stop Music
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(victory_panel, "modulate", Color(1,1,1,.8), 2)
	tween.tween_property(victory_label, "modulate", Color(1,1,1,1), .8)
	tween.tween_property(player_stats, "modulate", Color(1,1,1,1), .8)
	if PlayersList.get_apn()==4: tween.tween_property(play_again, "modulate", Color(1,1,1,1), .8)
	else: tween.tween_property(main_menu, "rect_position", Vector2(520,610), 0)
	tween.parallel().tween_property(main_menu, "modulate", Color(1,1,1,1), .8)
	yield(get_tree().create_timer(4.4),"timeout")
	AudioController.play_music(5) # Music

# Show a player's stats
func _show_stats(p: int):
	# Correct name
	indicator_label.text =  tr("'S STATS")%[PlayersList.get_player_username(p)]
	indicator_label.add_color_override("font_color", get_color(p))
	# Fix up stats
	var stats: Array = UserStats.get_game_stats()[p].git()
	stat_labels[0].text = tr("TILES TRAVELED")+": "+str(stats[0])
	stat_labels[1].text = tr("TIMES SENT BACK TO THE START")+": "+str(stats[1])
	stat_labels[2].text = tr("TIMES JAILED")+": "+str(stats[2])
	stat_labels[3].text = tr("TILES MADE OTHER PLAYERS GO BACK")+": "+str(stats[3])
	stat_labels[4].text = tr("TIMES SENT ANOTHER PLAYER BACK TO THE START")+": "+str(stats[4])
	stat_labels[5].text = tr("RED CARDS DRAWN")+": "+str(stats[5])
	stat_labels[6].text = tr("BLACK CARDS DRAWN")+": "+str(stats[6])
	stat_labels[7].text = tr("ORANGE CARDS DRAWN")+": "+str(stats[7])
	stat_labels[8].text = tr("RED CARDS ACTIVATED")+": "+str(stats[8])
	stat_labels[9].text = tr("COMBOS ACTIVATED")+": "+str(stats[9])
	stat_labels[10].text = tr("REACTIONS ACTIVATED")+": "+str(stats[10])
	stat_labels[11].text = tr("RED CARDS NEGATED")+": "+str(stats[11])
	stat_labels[12].text = tr("BLACK CARDS NEGATED")+": "+str(stats[12])
	stat_labels[13].text = tr("ORANGE CARDS NEGATED")+": "+str(stats[13])
	stat_labels[14].text = tr("CARDS STOLEN FROM OTHER PLAYERS")+": "+str(stats[14])
	stat_labels[15].text = tr("CARDS DISCARDED")+": "+str(stats[15])
	stat_labels[16].text = tr("TURNS SKIPPED")+": "+str(stats[16])
	# "Permafocus" only the pressed button
	for n in 4: buttons[n].add_stylebox_override("normal",buttons[n].get_stylebox("disabled"))
	buttons[p].add_stylebox_override("normal",buttons[p].get_stylebox("hover"))

# Get color based on player id
func get_color(id: int) -> Color:
	match id:
		RED: return Color.red
		BLUE: return Color.dodgerblue
		GREEN: return Color.green
		YELLOW: return Color.yellow
		_:
			print("!!! Unexpected color for Victory animation !!!")
			return Color.black

# Play again
func _play_again():
	play_again.disabled = true
	say_play_again(PlayersList.get_my_unique_id())
	if PlayersList.am_on(): rpc("say_play_again",PlayersList.get_my_unique_id())
# Tell other players you want to play again
remote func say_play_again(unique_id: int):
	for n in 4:
		if PlayersList.get_player_unique_id(n)==unique_id:
			play_again.get_child(0).get_child(n).modulate = Color(1,1,1,1)
	want_to_play+=1
	actually_play_again()
# Actually have the game restart if everyone wants to play again
func actually_play_again():
	if want_to_play>3:
		emit_signal("play_again")
		leave()

# Return to main menu
func _main_menu():
	emit_signal("main_menu")
	leave()
# Communicate client is leaving
func _client_goodbye(unique_id: int):
	for n in 4: if PlayersList.get_player_unique_id(n)==unique_id:
		play_again.get_child(0).get_child(n).modulate = Color(1,1,1,1)
		_sprite_goodbye(n)
# Communicate host is leaving
func _host_goodbye():
	for n in 4: if PlayersList.get_player_unique_id(n)!=PlayersList.get_my_unique_id():
		play_again.get_child(0).get_child(n).modulate = Color(1,1,1,1)
		_sprite_goodbye(n)
# Change a sprite to signal a player left
func _sprite_goodbye(n: int):
	var color
	match n:
		0: color = load("res://Game_Scene/Textures/Ready_Icons/RedLeft.png")
		1: color = load("res://Game_Scene/Textures/Ready_Icons/BlueLeft.png")
		2: color = load("res://Game_Scene/Textures/Ready_Icons/GreenLeft.png")
		3: color = load("res://Game_Scene/Textures/Ready_Icons/YellowLeft.png")
	play_again.get_child(0).get_child(n).texture = color
# Animation to darken and remove the canvas
func leave():
	$End_Game_Cover.show()
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($End_Game_Cover.get("custom_styles/panel"), "bg_color", Color("#1c1c1c"), 1)
	yield(get_tree().create_timer(1),"timeout")
	queue_free()
