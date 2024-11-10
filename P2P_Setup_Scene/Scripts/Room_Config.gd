extends Control
# Creates and manages room and Network signals

# Nodes
var room_ip
var user_ip
var lobby
# Player data
var p_ids: Array # Player IDs
var p_uns: Array # Player usernames
var p_tis: Array # Player titles
var p_avs: Array # Player avatars

# Signals
signal appended # Just to avoid anomalies
signal room_is_ready # Proceed to color selection

# Init
func initialize():
	# Vars
	room_ip = $Join_Room_Stuff/LineEdit_Layer/Room_IP
	user_ip = $IP_Layer/User_IP
	lobby = $Lobby_Layer/Lobby
	p_uns = []
	p_tis = []
	p_avs = []
	# Setup signals
	if get_tree().connect("network_peer_connected", self, "_player_connected")!=0:
		print("!!! Multiplayer_Config can't connect a signal !!!")
	if get_tree().connect("network_peer_disconnected", self, "_player_disconnected")!=0:
		print("!!! Multiplayer_Config can't connect a signal !!!")
	if get_tree().connect("connected_to_server", self, "_connected_to_server")!=0:
		print("!!! Multiplayer_Config can't connect a signal !!!")
	if get_tree().connect("server_disconnected", self, "_server_disconnected")!=0:
		print("!!! Network singleton can't connect a signal !!!")
	# Pull up UI
	match MiscInfo.get_room_config_direction():
		0:
			rect_position = Vector2(-1280,100) # -1120
			room_ip.rect_position = Vector2(-490,400) # -310
		1:
			rect_position = Vector2(1280,100) # 1120
			room_ip.rect_position = Vector2(2070,400) # 1910
	MiscInfo.set_room_config_direction(1)
	self.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rect_position",Vector2(0,100),.3)
	tween.parallel().tween_property(room_ip,"rect_position",Vector2(790,400),.3)

#################
# Network signals

# Called on all peers on player connecting
func _player_connected(id: int):
	print("Player " + str(id) + " connected")
	# Host stores new player data and propagates it
	if multiplayer.is_network_server():
		# Get data
		p_ids.append(id)
		rpc_id(id, "send_player", multiplayer.get_network_unique_id())
		yield(self, "appended")
		# Add to lobby
		lobby.add_player(id, p_uns[p_uns.size()-1], p_tis[p_tis.size()-1], p_avs[p_avs.size()-1])
		# Updates clients' lobbies
		for n in p_uns.size(): rpc("setup_p",  p_ids[n], p_uns[n], p_tis[n], p_avs[n])

# Aux funcs to get connected player's username
remote func send_player(id):
	rpc_id(id, "take_player", User.get_username(), User.get_title(), User.get_avatar())
remote func take_player(username,title,avatar):
	p_uns.append(username)
	p_tis.append(title)
	p_avs.append(avatar)
	emit_signal("appended")

# Aux func to add player data to clients
remote func setup_p(id: int, un: String, ti: int, av: int):
	if not p_ids.has(id):
		# Get data
		p_ids.append(id)
		p_uns.append(un)
		p_tis.append(ti)
		p_avs.append(av)
		# Add to lobby
		lobby.add_player(id, un, ti, av)

# Called on all peers on client disconnecting
func _player_disconnected(id: int):
	print("Player " + str(id) + " disconnected")
	# Reset if someone left during color selection
	if $"../Color_Selection".visible==true:
		_exit_room()
		return
	# Remove data
	var n = p_ids.find(id)
	p_ids.erase(id)
	p_uns.remove(n)
	p_tis.remove(n)
	p_avs.remove(n)
	# Remove from lobby
	lobby.remove_player(id)

# Called on new client on connection
func _connected_to_server():
	lobby.someone_here()

# Called on all clients on host disconnecting
func _server_disconnected():
	_exit_room()

###############################################
# Network set up methods / Create or Join lobby

# Called on host on room creation
func _on_create_room():
	AudioController.play_camera_shutter_button() # Sound
	# Prep
	print("Host connected")
	# Animation
	$"../Utility_Buttons".hide_back()
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", Vector2(1280,100), .3) # 1120
	tween.parallel().tween_property(room_ip,"rect_position",Vector2(2070,400),.3) # 1910
	yield(get_tree().create_timer(.3),"timeout")
	# Creates room and inits lobby
	Network.create_server()
	p_ids.append(1)
	p_uns.append(User.get_username())
	p_tis.append(User.get_title())
	p_avs.append(User.get_avatar())
	lobby.someone_here()
	lobby.initialize()
	lobby.add_player(p_ids[p_ids.size()-1], p_uns[p_uns.size()-1], p_tis[p_tis.size()-1], p_avs[p_avs.size()-1])
	# Open IP tab
	$IP_Layer.pull_up()

# Called on client on room entrance
func _on_join_room():
	# Prep
	print("Client connected")
	# Check IP
	if user_ip.text=="" || room_ip.text=="":
		AudioController.play_clackier_button() # Sound
		return
	else: AudioController.play_camera_shutter_button() # Sound
	# Animation
	$"../Utility_Buttons".hide_back()
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", Vector2(1280,100), .3) # 1120
	tween.parallel().tween_property(room_ip,"rect_position",Vector2(2070,400),.3) # 1910
	yield(get_tree().create_timer(.3),"timeout")
	# Connects to room and inits lobby
	Network.ip_address = room_ip.text
	Network.join_server()
	lobby.initialize()
	# Open IP tab
	$IP_Layer.pull_up()

####################
# Lobby menu methods

# When a "Kick" button is pressed
# Can only be used by host on client
func _kick_player(id: int):
	Network.server.disconnect_peer(id)

# When "Cancel_or_Leave" button from the lobby is pressed
func _exit_room():
	AudioController.play_old_camera_shutter_button() # Sound
	# Kill the connection
	Network.kill_connection()
	# Animation
	$"../Utility_Buttons".show_back()
	lobby.deinitialize()
	$IP_Layer.pull_down()
	yield(get_tree().create_timer(.4),"timeout")
	# Reload scene to reset all vars
	var ok = get_tree().reload_current_scene()
	if ok!=0: print("!!! Can't reload P2P_Setup scene !!!")

# When "Start" button from the lobby is pressed
func _start_match():
	if p_ids.size()==4:
		AudioController.play_whoosh_3() # Sound
		to_color_selection()
		rpc("to_color_selection")
# Proceeds to color selection
remote func to_color_selection():
	get_node("IP_Layer").hide()
	get_node("Lobby_Layer").hide()
	emit_signal("room_is_ready", p_ids, p_uns, p_tis, p_avs)
	hide()
