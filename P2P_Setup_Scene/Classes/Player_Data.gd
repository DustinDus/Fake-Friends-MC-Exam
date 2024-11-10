extends Node
class_name Player_Data
# Class that contains a single player's match-related info

# Player info
var id: int # Unique id
var username: String
var title: int
var avatar: int
var color: String

# Init
func _init(player_id: int, player_username: String, player_title: int, player_avatar: int, player_color: String):
	id = player_id
	username = player_username
	title = player_title
	avatar = player_avatar
	color = player_color

# Getters
func get_id() -> int: return id;
func get_username() -> String: return username
func get_title() -> int: return title
func get_avatar() -> int: return avatar
func get_color() -> String: return color

# Setters
func set_username(un: String): username = un
