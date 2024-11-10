extends Control
# Manages dashboards containing some player info

var dashboards: Array = []
var turn_indicator: Sprite
var target_sprites: Array = []
var crown: Sprite

# Preparations
func _ready():
	# Place dashboards
	for i in range(4):
		dashboards.append(get_child(i))
		target_sprites.append($Target_Sprites.get_child(i))
	dashboards[0].rect_position = Vector2(-145,190)
	dashboards[1].rect_position = Vector2(1425,190)
	dashboards[2].rect_position = Vector2(1425,420)
	dashboards[3].rect_position = Vector2(-145,420)
	# Place U_panel
	var my_id: int = PlayersList.get_my_id()
	var u_panel: Panel = get_child(10)
	remove_child(u_panel)
	dashboards[my_id].get("custom_styles/panel").border_width_top = 0
	dashboards[my_id].get("custom_styles/panel").border_width_left = 0
	dashboards[my_id].get("custom_styles/panel").border_width_right = 0
	dashboards[my_id].get("custom_styles/panel").border_width_bottom = 0
	dashboards[my_id].add_child(u_panel)
	match my_id:
		0: u_panel.get("custom_styles/panel").bg_color = Color(1,.6,.6,1)
		1: u_panel.get("custom_styles/panel").bg_color = Color(.4,.4,1,1)
		2: u_panel.get("custom_styles/panel").bg_color = Color(.4,.8,.4,1)
		3: u_panel.get("custom_styles/panel").bg_color = Color(.9,.9,.6,1)
	u_panel.show()
	# Init other stuff
	turn_indicator = get_child(4)
	crown = get_child(9)

# Set up vars and trigger match start animation
func initialize(first_player: int):
	# Set up dashboards
	var titles = UnlockablesInfo.TITLES
	var avatars = UnlockablesInfo.AVATARS
	for i in range(4):
		# Username
		var label = dashboards[i].get_child(0).get_child(0)
		var font_size = 16
		label.text = PlayersList.get_player_username(i)
		while label.get_line_count()>1:
			font_size-=1
			label.get("custom_fonts/font").set("size", font_size)
		# Title
		label = dashboards[i].get_child(1).get_child(0)
		font_size = 13
		label.text = titles[PlayersList.get_player_title(i)][0]
		while label.get_line_count()>1:
			font_size-=1
			label.get("custom_fonts/font").set("size", font_size)
		# Avatar
		var sprite = dashboards[i].get_child(2).get_child(0).get_child(0)
		sprite.texture = load(avatars[PlayersList.get_player_avatar(i)][0])
	# Trigger animation
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_callback(AudioController,"play_turnpage") # Sound
	tween.tween_property(dashboards[0], "rect_position", Vector2(0,190), .3)
	tween.tween_callback(AudioController,"play_turnpage") # Sound
	tween.tween_property(dashboards[1], "rect_position", Vector2(1280,190), .3)
	tween.tween_callback(AudioController,"play_turnpage") # Sound
	tween.tween_property(dashboards[2], "rect_position", Vector2(1280,420), .3)
	tween.tween_callback(AudioController,"play_turnpage") # Sound
	tween.tween_property(dashboards[3], "rect_position", Vector2(0,420), .3)
	yield(get_tree().create_timer(1.25),"timeout")
	# Trigger first animation call
	upd_turn(first_player)

# Moves the "Curr_Turn_Icon"
func upd_turn(id: int):
	var next_DB = dashboards[id]
	# Indicator disappears
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(turn_indicator, "modulate", Color(1,1,1,0), .2)
	# Sets up new position
	if next_DB.rect_position.x<640: tween.tween_property(turn_indicator, "position", Vector2(next_DB.rect_position.x+next_DB.rect_size.x,next_DB.rect_position.y+next_DB.rect_size.y), 0)
	else: tween.tween_property(turn_indicator, "position", Vector2(next_DB.rect_position.x-next_DB.rect_size.x,next_DB.rect_position.y+next_DB.rect_size.y), 0)
	# Indicator reappears
	tween.tween_property(turn_indicator, "modulate", Color(1,1,1,1), .2)
	# Indicator rotation
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(turn_indicator, "rotation_degrees", 360, .4)
	yield(get_tree().create_timer(1.2),"timeout")
	turn_indicator.rotation_degrees=0 # Reset rotation

# Shake a dashboard to highlight the player was targeted by an effect
func shake(id: int):
	var x = dashboards[id].rect_position.x
	var y = dashboards[id].rect_position.y
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(dashboards[id],"rect_position",Vector2(x,y+5),.05)
	tween.tween_property(dashboards[id],"rect_position",Vector2(x,y-5),.05)
	tween.tween_property(dashboards[id],"rect_position",Vector2(x,y+5),.05)
	tween.tween_property(dashboards[id],"rect_position",Vector2(x,y-5),.05)
	tween.tween_property(dashboards[id],"rect_position",Vector2(x,y),.05)

# Update the crown sprite to indicate which player is ahead
func upd_crown(player: int):
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(crown, "modulate", Color(1,1,1,0), .2)
	match player:
		0:
			tween.tween_property(crown,"position",Vector2(128,182),0)
			tween.tween_property(crown,"rotation_degrees",9,0)
		1:
			tween.tween_property(crown,"position",Vector2(1152,182),0)
			tween.tween_property(crown,"rotation_degrees",-9,0)
		2:
			tween.tween_property(crown,"position",Vector2(1152,412),0)
			tween.tween_property(crown,"rotation_degrees",-9,0)
		3:
			tween.tween_property(crown,"position",Vector2(128,412),0)
			tween.tween_property(crown,"rotation_degrees",9,0)
	tween.tween_property(crown, "modulate", Color(1,1,1,1), .2)

# Target sprite moving towards player animation
func target(id: int):
	var target_sprite: Sprite = target_sprites[id]
	target_sprite.position = Vector2(640,340)
	target_sprite.scale = Vector2(.75,.75)
	target_sprite.modulate = Color(1,1,1,0)
	var x: int
	var y: int
	if id==0 || id==3: x = 40
	else: x = 1240
	if id==0 || id==1: y = 265
	else: y = 495
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target_sprite,"modulate",Color(1,1,1,.4),.5)
	tween.tween_property(target_sprite,"position",Vector2(x,y),1)
	tween.parallel().tween_property(target_sprite,"scale",Vector2(.15,.15),1)
	tween.tween_property(target_sprite,"modulate",Color(1,1,1,0),3)

#

####################
# Bot-Handling Stuff
####################

# Grey out db and change username
func bot_up_dashboard(id: int):
	# Prep
	var disconnected_sprite: Sprite = $Disconnection_Sprites.get_child(id)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	# Color
	tween.tween_property(dashboards[id],"modulate",Color(.6,.6,.6),.3)
	# Sprite
	tween.tween_property(disconnected_sprite,"modulate",Color(1,1,1,.3),.3)
	# Username
	var uns = [["Botboi","Metalmenace","REDBEAR","Fingerflips","I H8 U >:D"],["Greyguy","Ironhead","Blauchshund","Jailord","Kebabmaker"],["Robobud","Mechahombre","Verdrana","Skipper","Forever Fren"],["Droidude","Automachap","Janne Chat","DOROCARDO!","RNJoseph"]]
	var label = dashboards[id].get_child(0).get_child(0)
	var font_size = 16
	label.text = uns[id][PlayersList.get_bot_un(id)]
	while label.get_line_count()>1:
		font_size-=1
		label.get("custom_fonts/font").set("size", font_size)
	PlayersList.set_username(id,label.text)
	# Title
	dashboards[id].get_child(1).get_child(0).text = "Bot"
