extends TileMap
# Sets up the effect sprites on the tiles and remembers their identifiers
# NOTE: the class is questioned for the tile numbers on the board so it goes -1 to map them to their position in the array
# Es: If it's asked to return the tile 27 it'll return the tile in position 26 in the array

# Maps the "Effect" tiles to their IDs
enum {WHITE_SPACE = -1, DRAW_RED, DRAW_BLACK, DRAW_ORANGE, VICTORY
	  PRISON, ROLL_AGAIN, BACK_TO_START, LOSE_A_TURN, EVEN_OR_ODD
	  PLUS_1, PLUS_5_OR_PLUS_6, GIFT_OR_PLUS_1, PLUS_4, PLUS_2
	  PARKING_METER, MINEFIELD}

# It stores the effects in order
var tiles: Array = []
var symbol_effects: Node2D
# For card tile effects
var coordinates: Array = []
var card_tiles: Array = []

# Aux to set up single tile (save some space)
func add_tile(x: int, y: int, id: int):
	tiles.append(id)
	if id!=WHITE_SPACE: self.set_cell(x, y, id)
	coordinates.append(Vector2(x,y))
	card_tiles.append([-1,-1]) # type, activator id

# Sets up tile sprites
func initialize():
	# 1-8
	add_tile(12, -16, DRAW_RED)
	add_tile(12, -12, WHITE_SPACE)
	add_tile(12, -8, WHITE_SPACE)
	add_tile(12, -4, DRAW_BLACK)
	add_tile(12, 0, WHITE_SPACE)
	add_tile(12, 4, WHITE_SPACE)
	add_tile(12, 8, DRAW_RED)
	add_tile(12, 12, ROLL_AGAIN)
	# 9-16
	add_tile(8, 12, WHITE_SPACE)
	add_tile(4, 12, WHITE_SPACE)
	add_tile(0, 12, DRAW_BLACK)
	add_tile(-4, 12, DRAW_RED)
	add_tile(-8, 12, PLUS_4)
	add_tile(-12, 12, DRAW_BLACK)
	add_tile(-16, 12, DRAW_RED)
	add_tile(-16, 8, WHITE_SPACE)
	# 17-24
	add_tile(-16, 4, BACK_TO_START)
	add_tile(-16, 0, DRAW_BLACK)
	add_tile(-16, -4, WHITE_SPACE)
	add_tile(-16, -8, DRAW_RED)
	add_tile(-16, -12, DRAW_RED)
	add_tile(-16, -16, PRISON)
	add_tile(-12, -16, DRAW_BLACK)
	add_tile(-8, -16, WHITE_SPACE)
	# 25-32
	add_tile(-4, -16, GIFT_OR_PLUS_1)
	add_tile(0, -16, DRAW_RED)
	add_tile(4, -16, DRAW_BLACK)
	add_tile(8, -16, PLUS_2)
	add_tile(8, -12, DRAW_BLACK)
	add_tile(8, -8, WHITE_SPACE)
	add_tile(8, -4, DRAW_RED)
	add_tile(8, 0, DRAW_ORANGE)
	# 33-40
	add_tile(8, 4, LOSE_A_TURN)
	add_tile(8, 8, DRAW_BLACK)
	add_tile(4, 8, WHITE_SPACE)
	add_tile(0, 8, WHITE_SPACE)
	add_tile(-4, 8, DRAW_BLACK)
	add_tile(-8, 8, WHITE_SPACE)
	add_tile(-12, 8, DRAW_RED)
	add_tile(-12, 4, DRAW_BLACK)
	# 41-48
	add_tile(-12, 0, WHITE_SPACE)
	add_tile(-12, -4, WHITE_SPACE)
	add_tile(-12, -8, DRAW_BLACK)
	add_tile(-12, -12, PLUS_5_OR_PLUS_6)
	add_tile(-8, -12, DRAW_BLACK)
	add_tile(-4, -12, WHITE_SPACE)
	add_tile(0, -12, WHITE_SPACE)
	add_tile(4, -12, DRAW_RED)
	# 49-56
	add_tile(4, -8, DRAW_BLACK)
	add_tile(4, -4, EVEN_OR_ODD)
	add_tile(4, 0, WHITE_SPACE)
	add_tile(4, 4, DRAW_BLACK)
	add_tile(0, 4, WHITE_SPACE)
	add_tile(-4, 4, WHITE_SPACE)
	add_tile(-8, 4, DRAW_RED)
	add_tile(-8, 0, WHITE_SPACE)
	# 57-64
	add_tile(-8, -4, WHITE_SPACE)
	add_tile(-8, -8, DRAW_RED)
	add_tile(-4, -8, DRAW_BLACK)
	add_tile(0, -8, DRAW_BLACK)
	add_tile(0, -4, DRAW_BLACK)
	add_tile(0, 0, DRAW_BLACK)
	add_tile(-4, 0, DRAW_BLACK)
	add_tile(-4, -4, VICTORY)
	# END
	symbol_effects = self.get_child(0)
	symbol_effects.initialize()
	print("Symbol tiles Set Up succesfully!")

# Returns the effect id of a tile
func get_tile_eff(v: int, activator_id: int) -> int:
	if card_tiles[v-1][0]!=-1:
		if card_tiles[v-1][1]==activator_id: return -1
		else: return card_tiles[v-1][0]
	else: return tiles[v-1]

# Delegates effect identification
# (card tiles have priority over regular tiles)
func exec_tile_eff(type: int, activator_id: int, game_manager):
	symbol_effects.exec_tile_eff(type, activator_id, game_manager)

# Get tile type
func get_tile_type(v: int):
	return tiles[v-1]
# Get card tile owner
func get_card_tile_owner(v: int) -> int:
	return card_tiles[v-1][1]

# Finds the first tile behind v of the specified type (look at the enum)
func find_previous_type_specific_tile(v: int, type: int) -> int:
	v-=2
	while v>=0:
		if v<0: break
		if tiles[v]==type: return v+1
		v-=1
	return 1

# Checks if it's a prison tile
func is_prison(v: int):
	return tiles[v-1]==PRISON

# Puts card tiles on the board
# info: [tileset x, tileset y, tile number, type]
func add_card_tile(activator_id: int, n: int, type: int):
	if type==PARKING_METER: AudioController.play_parking_brake() # Sound
	elif type==MINEFIELD: AudioController.play_old_camera() # Sound
	if n>0 and n<64:
		card_tiles[n-1][0] = type
		card_tiles[n-1][1] = activator_id
		self.set_cell(coordinates[n-1][0], coordinates[n-1][1], type)
# Removes a card tile from array and puts original symbol back
func remove_card_tile(n: int):
	card_tiles[n-1][0] = -1
	card_tiles[n-1][1] = -1
	self.set_cell(coordinates[n-1][0], coordinates[n-1][1], tiles[n-1])
