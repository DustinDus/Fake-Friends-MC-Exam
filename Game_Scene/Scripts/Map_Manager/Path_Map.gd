extends TileMap
# Sets up the path tiles correctly

# Mapping the "Path" tile names to their IDs
enum {ONLY_TOP, ONLY_RX, ONLY_BOT, ONLY_LX,
	  STR_VERT, STR_HORI,
	  ANGLE_BOT_LX, ANGLE_TOP_LX, ANGLE_TOP_RX, ANGLE_BOT_RX}

# Sets up the road correctly
func initialize():
	# 1-8
	self.set_cell(12, -16, ONLY_BOT)
	self.set_cell(12, -12, STR_VERT)
	self.set_cell(12, -8, STR_VERT)
	self.set_cell(12, -4, STR_VERT)
	self.set_cell(12, 0, STR_VERT)
	self.set_cell(12, 4, STR_VERT)
	self.set_cell(12, 8, STR_VERT)
	self.set_cell(12, 12, ANGLE_BOT_RX)
	# 9-16
	self.set_cell(8, 12, STR_HORI)
	self.set_cell(4, 12, STR_HORI)
	self.set_cell(0, 12, STR_HORI)
	self.set_cell(-4, 12, STR_HORI)
	self.set_cell(-8, 12, STR_HORI)
	self.set_cell(-12, 12, STR_HORI)
	self.set_cell(-16, 12, ANGLE_BOT_LX)
	self.set_cell(-16, 8, STR_VERT)
	# 17-24
	self.set_cell(-16, 4, STR_VERT)
	self.set_cell(-16, 0, STR_VERT)
	self.set_cell(-16, -4, STR_VERT)
	self.set_cell(-16, -8, STR_VERT)
	self.set_cell(-16, -12, STR_VERT)
	self.set_cell(-16, -16, ANGLE_TOP_LX)
	self.set_cell(-12, -16, STR_HORI)
	self.set_cell(-8, -16, STR_HORI)
	# 25-32
	self.set_cell(-4, -16, STR_HORI)
	self.set_cell(0, -16, STR_HORI)
	self.set_cell(4, -16, STR_HORI)
	self.set_cell(8, -16, ANGLE_TOP_RX)
	self.set_cell(8, -12, STR_VERT)
	self.set_cell(8, -8, STR_VERT)
	self.set_cell(8, -4, STR_VERT)
	self.set_cell(8, 0, STR_VERT)
	# 33-40
	self.set_cell(8, 4, STR_VERT)
	self.set_cell(8, 8, ANGLE_BOT_RX)
	self.set_cell(4, 8, STR_HORI)
	self.set_cell(0, 8, STR_HORI)
	self.set_cell(-4, 8, STR_HORI)
	self.set_cell(-8, 8, STR_HORI)
	self.set_cell(-12, 8, ANGLE_BOT_LX)
	self.set_cell(-12, 4, STR_VERT)
	# 41-48
	self.set_cell(-12, 0, STR_VERT)
	self.set_cell(-12, -4, STR_VERT)
	self.set_cell(-12, -8, STR_VERT)
	self.set_cell(-12, -12, ANGLE_TOP_LX)
	self.set_cell(-8, -12, STR_HORI)
	self.set_cell(-4, -12, STR_HORI)
	self.set_cell(0, -12, STR_HORI)
	self.set_cell(4, -12, ANGLE_TOP_RX)
	# 49-56
	self.set_cell(4, -8, STR_VERT)
	self.set_cell(4, -4, STR_VERT)
	self.set_cell(4, 0, STR_VERT)
	self.set_cell(4, 4, ANGLE_BOT_RX)
	self.set_cell(0, 4, STR_HORI)
	self.set_cell(-4, 4, STR_HORI)
	self.set_cell(-8, 4, ANGLE_BOT_LX)
	self.set_cell(-8, 0, STR_VERT)
	# 57-64
	self.set_cell(-8, -4, STR_VERT)
	self.set_cell(-8, -8, ANGLE_TOP_LX)
	self.set_cell(-4, -8, STR_HORI)
	self.set_cell(0, -8, ANGLE_TOP_RX)
	self.set_cell(0, -4, STR_VERT)
	self.set_cell(0, 0, ANGLE_BOT_RX)
	self.set_cell(-4, 0, ANGLE_BOT_LX)
	self.set_cell(-4, -4, ONLY_BOT)
	# END
	print("Path tiles Set Up succesfully!")
