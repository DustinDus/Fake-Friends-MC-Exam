extends TileMap
# Sets up the numbers, remembers the order and manages their positions
# NOTE: the class is questioned for the tile numbers on the board so it goes -1 to map them to their position in the array
# Es: If it's asked to return the tile 27 it'll return the tile in position 26 in the array

# It stores the coordinates in order
var tiles: Array = []

# Aux to set up single tile (save some space)
func add_tile(x: int, y: int, id: int):
	tiles.append(Vector2(x,y))
	self.set_cell(x, y, id)

# Sets up all number tiles in order
func initialize():
	# 1-8
	add_tile(12, -16, 1)
	add_tile(12, -12, 2)
	add_tile(12, -8, 3)
	add_tile(12, -4, 4)
	add_tile(12, 0, 5)
	add_tile(12, 4, 6)
	add_tile(12, 8, 7)
	add_tile(12, 12, 8)
	# 9-16
	add_tile(8, 12, 9)
	add_tile(4, 12, 10)
	add_tile(0, 12, 11)
	add_tile(-4, 12, 12)
	add_tile(-8, 12, 13)
	add_tile(-12, 12, 14)
	add_tile(-16, 12, 15)
	add_tile(-16, 8, 16)
	# 17-24
	add_tile(-16, 4, 17)
	add_tile(-16, 0, 18)
	add_tile(-16, -4, 19)
	add_tile(-16, -8, 20)
	add_tile(-16, -12, 21)
	add_tile(-16, -16, 22)
	add_tile(-12, -16, 23)
	add_tile(-8, -16, 24)
	# 25-32
	add_tile(-4, -16, 25)
	add_tile(0, -16, 26)
	add_tile(4, -16, 27)
	add_tile(8, -16, 28)
	add_tile(8, -12, 29)
	add_tile(8, -8, 30)
	add_tile(8, -4, 31)
	add_tile(8, 0, 32)
	# 33-40
	add_tile(8, 4, 33)
	add_tile(8, 8, 34)
	add_tile(4, 8, 35)
	add_tile(0, 8, 36)
	add_tile(-4, 8, 37)
	add_tile(-8, 8, 38)
	add_tile(-12, 8, 39)
	add_tile(-12, 4, 40)
	# 41-48
	add_tile(-12, 0, 41)
	add_tile(-12, -4, 42)
	add_tile(-12, -8, 43)
	add_tile(-12, -12, 44)
	add_tile(-8, -12, 45)
	add_tile(-4, -12, 46)
	add_tile(0, -12, 47)
	add_tile(4, -12, 48)
	# 49-56
	add_tile(4, -8, 49)
	add_tile(4, -4, 50)
	add_tile(4, 0, 51)
	add_tile(4, 4, 52)
	add_tile(0, 4, 53)
	add_tile(-4, 4, 54)
	add_tile(-8, 4, 55)
	add_tile(-8, 0, 56)
	# 57-64
	add_tile(-8, -4, 57)
	add_tile(-8, -8, 58)
	add_tile(-4, -8, 59)
	add_tile(0, -8, 60)
	add_tile(0, -4, 61)
	add_tile(0, 0, 62)
	add_tile(-4, 0, 63)
	add_tile(-4, -4, 64)
	# END
	print("Number tiles set up succesfully!")

# Returns the global position of a tile (according to its number, not index)
func get_tile_pos(num: int) -> Vector2:
	if num>=64: num = 64-(num%64)
	elif num<1: num = 1
	var coords = tiles[num-1]
	var pos = self.map_to_world(coords)
	return to_global(pos)

# Returns an array of the up to 4 adjacent tiles
func get_adjacent_tiles(tile: int) -> Array:
	match tile:
		1: return [2,28]
		2: return [1,3,29]
		3: return [2,4,30]
		4: return [3,5,31]
		5: return [4,6,32]
		6: return [5,7,33]
		7: return [6,8,34]
		8: return [7,9]
		9: return [8,10,34]
		10: return [9,11,35]
		11: return [10,12,36]
		12: return [11,13,37]
		13: return [12,14,38]
		14: return [13,15,39]
		15: return [14,16]
		16: return [15,17,39]
		17: return [16,18,40]
		18: return [17,19,41]
		19: return [18,20,42]
		20: return [19,21,43]
		21: return [20,22,44]
		22: return [21,23]
		23: return [22,24,44]
		24: return [23,25,45]
		25: return [24,26,46]
		26: return [25,27,47]
		27: return [26,28,48]
		28: return [1,27,29]
		29: return [2,28,30,48]
		30: return [3,29,31,49]
		31: return [4,30,32,50]
		32: return [5,31,33,51]
		33: return [6,32,34,52]
		34: return [7,9,33,35]
		35: return [10,34,36,52]
		36: return [11,35,37,53]
		37: return [12,36,38,54]
		38: return [13,37,39,55]
		39: return [14,16,38,40]
		40: return [17,39,41,55]
		41: return [18,40,42,56]
		42: return [19,41,43,57]
		43: return [20,42,44,58]
		44: return [21,23,43,45]
		45: return [24,44,46,58]
		46: return [25,45,47,59]
		47: return [26,46,48,60]
		48: return [27,29,47,49]
		49: return [30,48,50,60]
		50: return [31,49,51,61]
		51: return [32,50,52,62]
		52: return [33,35,51,53]
		53: return [36,52,54,62]
		54: return [37,53,55,63]
		55: return [38,40,54,56]
		56: return [41,55,57,63]
		57: return [42,56,58,64]
		58: return [43,45,57,59]
		59: return [46,58,60,64]
		60: return [47,49,59,61]
		61: return [50,60,61,64]
		62: return [51,53,61,63]
		63: return [54,56,62,64]
		64: return [57,59,61,63]
		_:
			print("!!! Unexpected tile number !!!")
			return []
