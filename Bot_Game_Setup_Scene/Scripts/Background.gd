extends ParallaxBackground
# Handles the bot_game_setup background

func pull_up_quarter(new_color: int, current_color: int):
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(get_child(new_color+1),"rect_position",Vector2(0,0),.5)
	if current_color!=-1: match current_color:
		0: tween.parallel().tween_property(get_child(current_color+1),"rect_position",Vector2(-640,-360),.5)
		1: tween.parallel().tween_property(get_child(current_color+1),"rect_position",Vector2(640,-360),.5)
		2: tween.parallel().tween_property(get_child(current_color+1),"rect_position",Vector2(640,360),.5)
		3: tween.parallel().tween_property(get_child(current_color+1),"rect_position",Vector2(-640,360),.5)
	current_color = new_color

func pull_up_quarters(color: int):
	var children: Array = []
	for n in 4: children.append(get_child(n+1))
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	for n in range(1,4): tween.tween_property(children[(color+n)%4],"rect_position",Vector2(0,0),.3)
