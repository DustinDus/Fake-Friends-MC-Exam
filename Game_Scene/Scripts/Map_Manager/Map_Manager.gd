extends Node2D
# Initializes map and delegates functions to the relative node

# Map is split between tilesets
var path_map: TileMap
var number_map: TileMap
var symbol_map: TileMap

# Preparations
func _ready():
	position = Vector2(640,-340)
	$Right_Deck_Holder/Panel.rect_position = Vector2(44,-201)
	$Left_Deck_Holder/Panel.rect_position = Vector2(-244,-201)
	$Dice_Holder/Panel.rect_position = Vector2(-234,70)

# Init
func initialize():
	path_map = $Path_Map
	path_map.initialize()
	number_map = $Number_Map
	number_map.initialize()
	symbol_map = $Symbol_Map
	symbol_map.initialize()
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(AudioController,"play_appear_2") # Sound
	tween.tween_property(self,"position",Vector2(640,340),.5)
	tween.tween_callback(AudioController,"play_card_place_1") # Sound
	tween.tween_property(get_node("Right_Deck_Holder/Panel"),"rect_position",Vector2(244,-201),.2)
	tween.tween_property(get_node("Left_Deck_Holder/Panel"),"rect_position",Vector2(-444,-201),.2)
	tween.tween_callback(AudioController,"play_chip_lay_1") # Sound
	tween.tween_property(get_node("Dice_Holder/Panel"),"rect_position",Vector2(-434,70),.2)
	yield(get_tree().create_timer(1.2),"timeout")

# Returns the global position of a tile identified by its number
func get_tile_pos(v: int) -> Vector2:
	return number_map.get_tile_pos(v)

# Returns the effect id of a tile
func get_tile_eff(v: int, id: int) -> int:
	return symbol_map.get_tile_eff(v,id)

# Delegates the execution of a tile effect
func exec_tile_eff(type: int, activator_id: int, game_manager: Node2D):
	symbol_map.exec_tile_eff(type, activator_id, game_manager)

# Delegates search for first tile behind v of the specified type
func find_previous_type_specific_tile(v: int, type: int) -> int:
	return symbol_map.find_previous_type_specific_tile(v, type)

# Checks if it's a prison tile
func is_prison(v: int):
	return symbol_map.is_prison(v)

# Puts a card tile on the board
func add_card_tile(activator_id: int, n: int, type: int):
	symbol_map.add_card_tile(activator_id,n,type)

# Returns an array of the up to 4 adjacent tiles
func get_adjacent_tiles(tile: int) -> Array:
	return number_map.get_adjacent_tiles(tile)
