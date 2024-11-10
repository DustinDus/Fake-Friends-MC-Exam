extends ParallaxLayer

export(float) var red_f_speed = 15.0

func _process(delta):
	self.motion_offset.x += red_f_speed*delta
