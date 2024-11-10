extends Node
# Handles disconnections

#######################
# Handle disconnections

# Prep
func _ready():
	if get_tree().connect("network_peer_disconnected", self, "_player_disconnected")!=0:
		print("!!! Multiplayer_Config can't connect a signal !!!")
	if get_tree().connect("server_disconnected", self, "_server_disconnected")!=0:
		print("!!! Network singleton can't connect a signal !!!")

# Client disconnected
func _player_disconnected(unique_id: int):
	print("Player " + str(unique_id) + " disconnected")
	# End the game if it hasn't even started
	if get_parent().get_node_or_null("Pregame_Manager")!=null:
		$".."._main_menu()
		return
	# Swap player out for a bot
	PlayersList.decrease_apn()
	var id: int = PlayersList.get_player_common_id(unique_id)
	$"../Game_Manager".turn_into_bot(id)
	# Everyone has disconnected: let the host leave early
	if not PlayersList.am_on():
		Network.kill_connection()
		$"../Utility_Buttons".show_back()

# Host disconnected
func _server_disconnected():
	print("Host disconnected")
	# End the game if it hasn't even started
	if get_parent().get_node_or_null("Pregame_Manager")!=null:
		$".."._main_menu()
		return
	# Swap all players for bots
	PlayersList.min_apn()
	for id in 4:
		if PlayersList.get_player_unique_id(id)!=PlayersList.get_my_unique_id():
			$"../Game_Manager".turn_into_bot(id)
	# Connection died: Let the client leave early
	Network.kill_connection()
	$"../Utility_Buttons".show_back()

# Manual disconnection if necessary
func kill_connection_if_online(): if PlayersList.am_on(): Network.kill_connection()
