extends ParallaxBackground
# P2P_Setup's background

func initialize():
	var color_selection: Control
	color_selection = get_parent().get_node("Color_Selection")
	var ok
	ok = color_selection.connect("color_selected",self,"pull_up_quarter")
	if ok!=0: print("!!! Background can't connect a signal !!!")

func pull_up_quarter(color: String):
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	match color:
		"RED": tween.tween_property(get_child(1),"rect_position",Vector2(0,0),.5)
		"BLUE": tween.tween_property(get_child(2),"rect_position",Vector2(0,0),.5)
		"GREEN": tween.tween_property(get_child(3),"rect_position",Vector2(0,0),.5)
		"YELLOW": tween.tween_property(get_child(4),"rect_position",Vector2(0,0),.5)

func reset_quarters():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(get_child(1),"rect_position",Vector2(-640,-360),.4)
	tween.parallel().tween_property(get_child(2),"rect_position",Vector2(640,-360),.4)
	tween.parallel().tween_property(get_child(3),"rect_position",Vector2(640,360),.4)
	tween.parallel().tween_property(get_child(4),"rect_position",Vector2(-640,360),.4)
	yield(get_tree().create_timer(.4),"timeout")
