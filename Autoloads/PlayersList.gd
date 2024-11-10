extends Node
# Singleton to remember 'player_data's relative to the 4 players of a single game
# NOTE the order is always RED->BLUE->GREEN->YELLOW

# User's ids
var my_id: int
var my_unique_id: int
# Array of 4 Player_Data
var players_data_list: Array

# How many bots aren't bots?
var is_bot_array: Array
var active_player_number: int = 4
# Indexes to point the bot's usernames
var bot_uns: Array

# How many times in a row the user let a timer run its course (disconnect on third in a row)
var disconnect_countdown: int = 3

######
# DATA

# Prepare and get my own ids
func prepare_my_ids():
	for id in 4:
		if get_player_unique_id(id)==multiplayer.get_network_unique_id():
			my_id = id
			my_unique_id = get_player_unique_id(id)
func get_my_id() -> int: return my_id
func get_my_unique_id() -> int: return my_unique_id

# Get/Set all data
func get_data() -> Array: return players_data_list
func set_data(players_data: Array): players_data_list = players_data

# Get a single player's data
func get_player(id: int) -> Player_Data: return players_data_list[id]
func get_player_unique_id(id: int) -> int: return players_data_list[id].get_id()
func get_player_username(id: int) -> String: return players_data_list[id].get_username()
func get_player_title(id: int) -> int: return players_data_list[id].get_title()
func get_player_avatar(id: int) -> int: return players_data_list[id].get_avatar()

# Get a player's common id from their unique one
func get_player_common_id(unique_id: int) -> int:
	for id in 4: if PlayersList.get_player_unique_id(id)==unique_id: return id
	return -1

# Set a single player's data
func set_username(id: int, un: String): players_data_list[id].set_username(un)

######
# SEED

# Create and store a seed based on each player's unique_id and username
func create_seed() -> String:
	var raw_id_seed = 0
	var raw_username_seed = ""
	for n in 4:
		raw_id_seed+=PlayersList.get_player_unique_id(n)
		raw_username_seed+=PlayersList.get_player_username(n)
	var raw_seed = str(raw_id_seed)+raw_username_seed
	return raw_seed

######
# BOTS

# Am I online?
func am_on() -> bool: return active_player_number!=1
# How many non-bot players are there?
func get_apn() -> int: return active_player_number
# It's a bot game / The host left
func min_apn(): active_player_number=1
# A player left
func decrease_apn(): active_player_number-=1

# To tell apart bots from users
func prepare_bot_array(is_bot_game: bool = false):
	if is_bot_game:
		for n in 4:
			if n==my_id: is_bot_array.append(false)
			else: is_bot_array.append(true)
	else:
		for n in 4: is_bot_array.append(false)
# Is this user a bot?
func is_bot(id: int) -> bool: return is_bot_array[id]
func is_bot_uid(unique_id: int) -> bool:
	for id in 4: if unique_id==players_data_list[id].get_id(): return is_bot_array[id]
	return true
# Make this user a bot
func make_bot(id: int): is_bot_array[id] = true

# Bot names are constant between players
func prepare_bot_uns(): for n in 4: bot_uns.append(RNGController.common_roll(0,4))
# Get a bot's name
func get_bot_un(id: int) -> int: return bot_uns[id]

#######
# TIMER

# Reset countdown back to 3
func reset_disconnect_countdown(): disconnect_countdown = 3

# Decrease the countdown and return true on it reaching 0
func decrease_disconnect_countdown() -> bool:
	disconnect_countdown-=1
	if disconnect_countdown==0: return true
	else: return false
