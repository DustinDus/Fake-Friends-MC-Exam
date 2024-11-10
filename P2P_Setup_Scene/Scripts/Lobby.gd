extends Control
# Stores and shows info of players in the room (Lobby UI)

# UI to show info
var players: Array
# IDs to keep track of each player
var p_ids: Array

# To map unlockables
var titles
var avatars

# Init
func initialize():
	# Vars
	titles = UnlockablesInfo.TITLES
	avatars = UnlockablesInfo.AVATARS 
	# Clients have only "Leave" button
	if not multiplayer.is_network_server():
		$No_One_Here/Label.text = tr("...NO HOST FOUND...")
		$Players/Placeholder/Info/Control.hide()
		$Buttons/Cancel_or_Leave.text = tr("LEAVE")
		$Buttons/Start.visible = false
	# Host also has "Start" and "Kick" buttons
	else:
		$Players/Placeholder/Info/Control.show()
		$Buttons/Cancel_or_Leave.text = tr("CANCEL")
		$Buttons/Start.visible = true
		$Buttons/Start.disabled = true
	# Pulls up UI
	rect_position = Vector2(-1280,60) # -1120
	self.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", Vector2(440,60), .4)

# Just for movement
func deinitialize():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", Vector2(-1280,60), .4) # -1120

# Add player to the the room
func add_player(id: int, username: String, title: int, avatar: int):
	# Duplicates the placeholder "Player_1" from scene tree
	var new_player = $Players.get_child(0).duplicate()
	# Uses the duplicate to store player info
	var username_label = new_player.get_child(0).get_node("VBoxContainer/Name")
	username_label.text = username
	new_player.get_child(0).get_node("VBoxContainer/Title").text = tr(titles[title][0])
	new_player.get_child(0).get_node("Avatar_Border_1/Avatar_Border_2/Sprite").texture = load(avatars[avatar][0])
	# Username fixup
	var font_size = 30
	while username_label.get_line_count()>1:
		font_size-=1
		username_label.get("custom_fonts/font").set("size", font_size)
	# Connects "Kick" button to player (if not host)
	if id!=1: new_player.get_child(0).get_node("Control/Kick").initialize(id, get_parent().get_parent())
	else: new_player.get_child(0).get_node("Control").hide()
	# Adds duplicate to tree and array and makes it visible
	$Players.add_child(new_player)
	players.append(new_player)
	new_player.visible = true
	# Adds ID
	p_ids.append(id)
	# Enables start button once 4 players are in the lobby
	if p_ids.size()>3: $Buttons/Start.disabled = false

# Remove player from the room
func remove_player(id: int):
	# Finds "players" index relative to ID
	var n = p_ids.find(id)
	# Removes player info from the tree and array
	$Players.get_child(n+1).queue_free()
	players.remove(n)
	# Removes ID
	p_ids.erase(id)
	# Disables start button if less than 4 players are in the lobby
	if p_ids.size()<4: $Buttons/Start.disabled = true

# Hide No_One_Here
func someone_here():
	var no_one_here = $No_One_Here
	if no_one_here.visible:
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(no_one_here,"modulate",Color(1,1,1,0),.2)
		yield(get_tree().create_timer(.2),"timeout")
		no_one_here.hide()
