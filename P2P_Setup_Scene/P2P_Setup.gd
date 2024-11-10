extends Control
# Coordinates actions to begin a game with P2P connection

# Nodes
onready var room_config = $Room_Config
onready var color_selection = $Color_Selection
# Player data
var player_IDs: Array
var player_usernames: Array
var player_titles: Array
var player_avatars: Array
var player_colors: Array

# Init
func _ready():
	# Signals
	if room_config.connect("room_is_ready", self, "_room_is_ready")!=0:
		print("!!! P2P_Setup can't connect a signal !!!")
	if color_selection.connect("colors_are_ready", self, "_colors_are_ready")!=0:
		print("!!! P2P_Setup can't connect a signal !!!")
	# Translation
	$Room_Config/Create_Room_Stuff/Create_Room.text = tr("CREATE ROOM")
	$Room_Config/Join_Room_Stuff/Join_Room.text = tr("JOIN ROOM")
	$Room_Config/Join_Room_Stuff/LineEdit_Layer/Room_IP.placeholder_text = tr("HOST'S IP")
	# Prep
	get_child(0).initialize()
	$Utility_Buttons.initialize(1)
	# Pull up Room Config
	room_config.initialize()

# When the host clicks "Start"
func _room_is_ready(p_ids: Array, p_uns: Array, p_tis: Array, p_avs: Array):
	# Copy passed user data
	player_IDs = p_ids.duplicate(true)
	player_usernames = p_uns.duplicate(true)
	player_titles = p_tis.duplicate(true)
	player_avatars = p_avs.duplicate(true)
	# Pull up color selection
	color_selection.initialize(p_ids)

# When all players have selected a color
func _colors_are_ready(p_cols: Array):
	# Copy passed user data
	player_colors = p_cols.duplicate(true)
	# Pull up game
	prepare_game()

# When all preparations are done
# Compress player data
func prepare_game():
	var player_data: Array = []
	var pos
	pos = player_colors.find("RED")
	player_data.append(Player_Data.new(player_IDs[pos], player_usernames[pos], player_titles[pos], player_avatars[pos], "RED"))
	pos = player_colors.find("BLUE")
	player_data.append(Player_Data.new(player_IDs[pos], player_usernames[pos], player_titles[pos], player_avatars[pos], "BLUE"))
	pos = player_colors.find("GREEN")
	player_data.append(Player_Data.new(player_IDs[pos], player_usernames[pos], player_titles[pos], player_avatars[pos], "GREEN"))
	pos = player_colors.find("YELLOW")
	player_data.append(Player_Data.new(player_IDs[pos], player_usernames[pos], player_titles[pos], player_avatars[pos], "YELLOW"))
	PlayersList.set_data(player_data)
	PlayersList.prepare_my_ids()
	PlayersList.prepare_bot_array()
	start_game()
# Pull up game scene
func start_game():
	if get_tree().change_scene("res://Game_Scene/Game.tscn")!=0:
		print("!!! P2P_Setup can't change scene !!!")

# Go back to Play
func _back():
	AudioController.play_old_camera_shutter_button() # Sound
	# Prep
	$Utility_Buttons.disable_buttons()
	MiscInfo.set_room_config_direction(0)
	# Animation
	for n in range(1,5): get_child(0).get_child(n).queue_free()
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(room_config, "rect_position", Vector2(-1120,100), .3)
	tween.parallel().tween_property($Room_Config/Join_Room_Stuff/LineEdit_Layer/Room_IP,"rect_position",Vector2(-310,400),.3)
	yield(get_tree().create_timer(.3),"timeout")
	# Change Scene
	if get_tree().change_scene("res://Play_Scene/Play.tscn")!=0:
		print("!!! P2P_Setup can't change scene to Play !!!")
