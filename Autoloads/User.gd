extends Node
# Singleton that contains info relative to the user's data and unlockables

# Main info
var username: String
var current_title: int
var current_avatar: int
# Unlockables
var titles: Array
var avatars: Array
# Language
var language: int = 0
# Audio
var master_volume: float = 1.0
var music_volume: float = 1.0
var sound_volume: float = 1.0

####################
# Save data handling

# Load user settings on bootup
func _ready(): load_info()

# Save user settings
func save_info():
	# Gather user info
	var save_info_dict: Dictionary = {
		"username": username,
		"title": current_title,
		"avatar": current_avatar,
		"unlocked_titles": titles,
		"unlocked_avatars": avatars,
		"language": language,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sound_volume": sound_volume
	}
	# Save the stuff to file
	var save = File.new()
	save.open("user://savegame.save", File.WRITE)
	save.store_line(to_json(save_info_dict))
	save.close()

# Load user settings
func load_info():
	# Load stuff from file
	var save = File.new()
	if not save.file_exists("user://savegame.save"):
		print("File doesn't exist: creating a new one")
		reset_info()
	if save.open("user://savegame.save", File.READ)!=OK:
		print("File can't be opened: creating a new one")
		reset_info()
	var save_info_dict: Dictionary = parse_json(save.get_line())
	save.close()
	# Gather user info
	if save_info_dict.has("username"): username = save_info_dict["username"]
	else: username = "User"
	if save_info_dict.has("title"): current_title = save_info_dict["title"]
	else: current_title = 0
	if save_info_dict.has("avatar"): current_avatar = save_info_dict["avatar"]
	else: current_avatar = 0
	if save_info_dict.has("unlocked_titles"): titles = save_info_dict["unlocked_titles"]
	else: titles = [true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
	if save_info_dict.has("unlocked_avatars"): avatars = save_info_dict["unlocked_avatars"]
	else: avatars = [true,true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
	if save_info_dict.has("language"): language = save_info_dict["language"]
	else: language = 0
	if save_info_dict.has("master_volume"): master_volume = save_info_dict["master_volume"]
	else: master_volume = .0
	if save_info_dict.has("music_volume"): music_volume = save_info_dict["music_volume"]
	else: music_volume = .0
	if save_info_dict.has("sound_volume"): sound_volume = save_info_dict["sound_volume"]
	else: sound_volume = .0

# Resets all user settings
func reset_info():
	# Reset user info
	var save_info_dict: Dictionary = {
		"username": "User",
		"title": 0,
		"avatar": 0,
		"unlocked_titles": [true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],
		"unlocked_avatars": [true,true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false],
		# Unlock All: [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
		# Fresh Title Unlocks: [true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
		# Fresh Avatar Unlocks: [true,true,true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
		"language": language,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sound_volume": sound_volume
	}
	# Save the stuff to file
	var save = File.new()
	save.open("user://savegame.save", File.WRITE)
	save.store_line(to_json(save_info_dict))
	save.close()

#################
# Getters/Setters

# Username
func get_username() -> String: return username
func set_username(newUsername: String):
	username = newUsername
	save_info()
# Title
func get_title() -> int: return current_title
func set_title(new_title: int):
	current_title = new_title 
	save_info()
# Avatar
func get_avatar() -> int: return current_avatar
func set_avatar(new_avatar: int):
	current_avatar = new_avatar
	save_info()
# Unlocked titles/avatars
func get_titles() -> Array: return titles
func get_avatars() -> Array: return avatars

# Language
func get_language() -> int: return language
func set_language(new_language: int):
	language = new_language
	save_info()

# Audio
func get_master_volume() -> float: return master_volume
func set_master_volume(new_master_volume: float):
	master_volume = new_master_volume
	save_info()
func get_music_volume() -> float: return music_volume
func set_music_volume(new_music_volume: float):
	music_volume = new_music_volume
	save_info()
func get_sound_volume() -> float: return sound_volume
func set_sound_volume(new_sound_volume: float):
	sound_volume = new_sound_volume
	save_info()
