extends Node
class_name Tweener_Creator
# Class that makes the pawn movement tweeners to save time

# Move player to pos
func move_pawn(player: Sprite, pos: Vector2):
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "position", pos, .2)
	yield(get_tree().create_timer(.2), "timeout")

# Fade player out
func tp_pawn_out(player: Sprite):
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "modulate", Color(1,1,1,0), 1)
	yield(get_tree().create_timer(1), "timeout")

# Fade player in
func tp_pawn_in(player: Sprite):
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "modulate", Color(1,1,1,1), 1)
	yield(get_tree().create_timer(1), "timeout")
