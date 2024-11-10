extends Node
# Singleton containing miscellaneous info, right now only remembers the direction in which some menus appear

#################
# Menu directions

# [0:forward, 1:left_to_right, 2:right_to_left, 3:top_to_bottom, 4:bottom_to_top]
var play_menu_direction: int = 0
# [0:left_to_right, 1:right_to_left]
var room_config_direction: int = 0

#################
# Getters/Setters

# Play Menu
func get_play_menu_direction() -> int: return play_menu_direction
func set_play_menu_direction(direction: int): play_menu_direction = direction
# Room Confin (P2P_Setup)
func get_room_config_direction() -> int: return room_config_direction
func set_room_config_direction(direction: int): room_config_direction = direction
