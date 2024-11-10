extends Control
# Shows the player's stats and profile
#warning-ignore-all:integer_division

var back_button: TextureButton
var reset_button: TextureButton

func turn_minutes_to_proper_time(time_in_minutes: int) -> String:
	var hours: int = int(time_in_minutes/60)
	var minutes: int = int(time_in_minutes%60)
	if minutes>9: return str(hours)+":"+str(minutes)
	else: return str(hours)+":0"+str(minutes)

func _ready():
	# Setup Stats
	var stats: Array = UserStats.get_stats()
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel1/Games_Played.text = tr("GAMES PLAYED")+": "+str(stats[0])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel2/Games_Won.text = tr("GAMES WON")+": "+str(stats[1])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel3/Games_Lost.text = tr("GAMES LOST")+": "+str(stats[2])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel4/Shortest_Game_Played.text = tr("SHORTEST GAME")+": "+turn_minutes_to_proper_time(stats[3])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel5/Longest_Game_Played.text = tr("LONGEST GAME")+": "+turn_minutes_to_proper_time(stats[4])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel6/Games_Quit.text = tr("GAMES QUIT")+": "+str(stats[5])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel7/Tiles_Traveled.text = tr("TILES TRAVELED")+": "+str(stats[6])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel8/Times_Sent_to_Start.text = tr("TIMES SENT BACK TO THE START")+": "+str(stats[7])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel9/Times_Jailed.text = tr("TIMES JAILED")+": "+str(stats[8])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel10/Opponent_Back.text = tr("TILES MADE OTHER PLAYERS GO BACK")+": "+str(stats[9])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel11/Opponent_Start.text = tr("TIMES SENT ANOTHER PLAYER BACK TO THE START")+": "+str(stats[10])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel12/Red_Draws.text = tr("RED CARDS DRAWN")+": "+str(stats[11])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel13/Black_Draws.text = tr("BLACK CARDS DRAWN")+": "+str(stats[12])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel14/Orange_Draws.text = tr("ORANGE CARDS DRAWN")+": "+str(stats[13])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel15/Red_Activated.text = tr("RED CARDS ACTIVATED")+": "+str(stats[14])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel16/Combos_Activated.text = tr("COMBOS ACTIVATED")+": "+str(stats[15])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel17/Reactions_Activated.text = tr("REACTIONS ACTIVATED")+": "+str(stats[16])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel18/Red_Negated.text = tr("RED CARDS NEGATED")+": "+str(stats[17])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel19/Black_Negated.text = tr("BLACK CARDS NEGATED")+": "+str(stats[18])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel20/Orange_Negated.text = tr("ORANGE CARDS NEGATED")+": "+str(stats[19])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel21/Cards_Stolen.text = tr("CARDS STOLEN FROM OTHER PLAYERS")+": "+str(stats[20])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel22/Cards_Discarded.text = tr("CARDS DISCARDED")+": "+str(stats[21])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel23/Turns_Skipped.text = tr("TURNS SKIPPED")+": "+str(stats[22])
	$Stats_List/Panel/MarginContainer/Panel/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer/Panel24/Time.text = tr("TIME WASTED HERE")+": "+turn_minutes_to_proper_time(stats[23])
	# Setup Main_Info
	var font_size = 16
	var username = $Main_Info/Panel/MarginContainer/Panel/MarginContainer/Panel/Username
	username.text = User.get_username()
	while username.get_line_count()>1:
		font_size-=1
		username.get("custom_fonts/font").set("size", font_size)
	$Main_Info/Panel/MarginContainer/Panel/MarginContainer/Panel/Label.text = tr(UnlockablesInfo.TITLES[User.get_title()][0])
	$Main_Info/Panel/MarginContainer/Panel/MarginContainer/Panel/Avatar_Border_1/Avatar_Border_2/Sprite.texture = load(UnlockablesInfo.AVATARS[User.get_avatar()][0])
	var unlocks: int
	unlocks = User.get_titles().count(true)
	$Main_Info/Panel/MarginContainer/Panel/MarginContainer/Panel/Titles.text = str(unlocks)+"/20 "+tr("TITLES UNLOCKED")
	unlocks = User.get_avatars().count(true)
	$Main_Info/Panel/MarginContainer/Panel/MarginContainer/Panel/Avatars.text = str(unlocks)+"/20 "+tr("AVATARS UNLOCKED")
	# Setup Reset_Options
	$Utility_Buttons/Reset_Options/Label1.text = tr("WOULD YOU LIKE TO RESET YOUR STATS?")
	$Utility_Buttons/Reset_Options/Label2.text = tr("THIS WILL ALSO RESET ANY TITLES AND AVATARS YOU PREVIOUSLY UNLOCKED")
	# Prep
	back_button = $Utility_Buttons/Back_Button
	reset_button = $Utility_Buttons/Reset_Button
	var button_panel = $Utility_Buttons/Panel_Right
	var stats_list = $Stats_List
	var main_info = $Main_Info
	var fix_panel = $Fix_Panel
	back_button.rect_position = Vector2(1285,-115)
	button_panel.rect_position = Vector2(1229,-100)
	stats_list.modulate = Color(1,1,1,0)
	main_info.modulate = Color(1,1,1,0)
	fix_panel.modulate = Color(1,1,1,0)
	reset_button.modulate = Color(1,1,1,0)
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(back_button,"rect_position",Vector2(1185,15),.4)
	tween.parallel().tween_property(button_panel,"rect_position",Vector2(929,0),.4)
	tween.parallel().tween_property(stats_list,"modulate",Color(1,1,1,1),.4)
	tween.parallel().tween_property(main_info,"modulate",Color(1,1,1,1),.4)
	tween.parallel().tween_property(fix_panel,"modulate",Color(1,1,1,1),.4)
	tween.tween_property(reset_button,"modulate",Color(1,1,1,1),.4)

func _back():
	AudioController.play_mouse_close_button() # Sound
	# Prep
	back_button.disabled = true
	reset_button.disabled = true
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Utility_Buttons/Reset_Button,"modulate",Color(1,1,1,0),.4)
	tween.tween_property(back_button, "rect_position", Vector2(1285,-115),.4)
	tween.parallel().tween_property($Utility_Buttons/Panel_Right, "rect_position", Vector2(1280,-100),.4)
	tween.parallel().tween_property($Stats_List,"modulate",Color(1,1,1,0),.4)
	tween.parallel().tween_property($Main_Info,"modulate",Color(1,1,1,0),.4)
	tween.parallel().tween_property($Fix_Panel,"modulate",Color(1,1,1,0),.4)
	tween.tween_property($Background/Solid_Color.get("custom_styles/panel"), "bg_color", Color("#dcdcdc"), .4)
	yield(get_tree().create_timer(1.2),"timeout")
	# Change Scene
	if get_tree().change_scene("res://Main_Scene/Main.tscn")!=0:
		print("!!! P2P_Setup can't change scene to Main !!!")

func reset():
	# Prep
	back_button.disabled = true
	reset_button.disabled = true
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Utility_Buttons/Reset_Options,"modulate",Color(1,1,1,0),1)
	tween.parallel().tween_property($Utility_Buttons/Scene_Cover,"modulate",Color(1,1,1,1),2)
	tween.tween_property(reset_button,"modulate",Color(1,1,1,0),0)
	tween.parallel().tween_property(back_button, "rect_position", Vector2(1285,-115),0)
	tween.parallel().tween_property($Utility_Buttons/Panel_Right, "rect_position", Vector2(1280,-100),0)
	tween.parallel().tween_property($Stats_List,"modulate",Color(1,1,1,0),0)
	tween.parallel().tween_property($Main_Info,"modulate",Color(1,1,1,0),0)
	tween.parallel().tween_property($Fix_Panel,"modulate",Color(1,1,1,0),0)
	tween.tween_property($Utility_Buttons/Scene_Cover,"modulate",Color(1,1,1,0),2)
	tween.parallel().tween_property($Background/Solid_Color.get("custom_styles/panel"),"bg_color",Color("#dcdcdc"),1)
	yield(get_tree().create_timer(4),"timeout")
	# Change Scene
	if get_tree().change_scene("res://Main_Scene/Main.tscn")!=0:
		print("!!! P2P_Setup can't change scene to Main !!!")
