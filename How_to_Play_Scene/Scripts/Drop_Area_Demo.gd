extends Control
# Demo to show a card was played correctly

var you_got_it: Sprite

func _ready(): you_got_it = get_child(0)

func check_drop(pos: Vector2):
	if Rect2(Vector2(590,245),rect_size).has_point(pos):
		AudioController.play_generic_button() # Sound
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(you_got_it,"modulate",Color(1,1,1,.5),.7)
		tween.tween_property(you_got_it,"modulate",Color(1,1,1,0),.3)
