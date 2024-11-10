extends ParallaxLayer

export(float) var black_f_speed = -15.0

func _process(delta):
	self.motion_offset.x += black_f_speed*delta
