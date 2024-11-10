extends Control
# Handles its scene

# To start the game
var start: Button
# Background effects
var background: ParallaxBackground
# Remember the user's color
var color: int
# To enable/disable on click
var colors: Array

func _ready():
	# Prep
	start = $Start
	start.disabled = true
	start.text = tr("CHOOSE A COLOR")
	background = $Background
	$Utility_Buttons.initialize(1)
	color = -1
	colors = $Color_Wheel/Colors.get_children()
	# Animation
	rect_position = Vector2(1280,0) # 840
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2(0,0),.3)

# Prepare and start the match
func _start_game():
	disable_buttons()
	AudioController.play_heavier_button()
	# Prepare each player's data
	var player_data: Array = []
	var uns: Array = [["Botboi","Metalmenace","REDBEAR","Fingerflips","I H8 U >:D"],["Greyguy","Ironhead","Blauchshund","Jailord","Kebabmaker"],["Robobud","Mechahombre","Verdrana","Skipper","Forever Fren"],["Droidude","Automachap","Janne Chat","DOROCARDO!","RNJoseph"]]
	for n in 4:
		if n!=color: player_data.append(Player_Data.new(RNGController.unique_roll(2,999999999),uns[n][RNGController.unique_roll(0,4)],-1,-1,match_color(n)))
		else:
			player_data.append(Player_Data.new(1,User.get_username(),User.get_title(),User.get_avatar(),match_color(n)))
			PlayersList.my_unique_id = 1
			PlayersList.my_id = n
	PlayersList.set_data(player_data)
	PlayersList.prepare_bot_array(true)
	PlayersList.min_apn()
	# Animation
	background.pull_up_quarters(color)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(start,"modulate",Color(1,1,1,0),.5)
	tween.tween_property($Color_Wheel,"modulate",Color(1,1,1,0),.5)
	yield(get_tree().create_timer(1.6),"timeout")
	# Start the game
	if get_tree().change_scene("res://Game_Scene/Game.tscn")!=0:
		print("!!! Bot_Game_Setup can't change scene !!!")

# To select a color
func _select_color(c: int):
	AudioController.play_opening_software_interface_button() # Sound
	background.pull_up_quarter(c,color)
	colors[color].disabled = false
	colors[c].disabled = true
	color = c
	_enable_start()

# Aux stuff to keep things clean
func _enable_start():
	start.disabled = false
	start.text = tr("CLICK TO START")
func match_color(v: int) -> String:
	match v:
		0: return "RED"
		1: return "BLUE"
		2: return "GREEN"
		3: return "YELLOW"
		_: return "BLACK"
func disable_buttons():
	for button in get_node("Color_Wheel/Colors").get_children():
		if button.get_index()==color: button.add_stylebox_override("disabled",button.get_stylebox("focus"))
		else: button.add_stylebox_override("disabled",button.get_stylebox("normal"))
		button.disabled = true
	$Utility_Buttons.disable_buttons()
	start.disabled = true

# Go back to Play
func _back():
	AudioController.play_old_camera_shutter_button() # Sound
	# Prep
	disable_buttons()
	background.pull_up_quarter(-1,color)
	MiscInfo.set_room_config_direction(0)
	# Animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2(1280,0),.3) # 840
	yield(get_tree().create_timer(.3),"timeout")
	# Change Scene
	if get_tree().change_scene("res://Play_Scene/Play.tscn")!=0:
		print("!!! P2P_Setup can't change scene to Play !!!")
