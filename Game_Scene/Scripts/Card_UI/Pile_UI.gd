extends Panel
# Manages a list of discarded cards

var card_list

func initialize():
	card_list = get_node("ScrollContainer/VBoxContainer")

# Return all cards in pile
func get_cards() -> Array: return card_list.get_children()

# Push card in front of container
func add_card(card):
	card.rect_size = Vector2(1,1)
	card.rect_position = Vector2(0,0)
	card_list.add_child(card)
	card_list.move_child(card,0)

# Remove a card corresponding to an index and return it
func retrieve_card(index: int) -> MarginContainer:
	var card = card_list.get_children()[index]
	card_list.remove_child(card)
	return card

###########################
# Make GUI appear/disappear
###########################

# Opens panel
func _show_pile(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("click"):
		if rect_position.x==1280:
			AudioController.play_camera_shutter_button() # Sound
			var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rect_position", Vector2(rect_position.x-rect_size.x,rect_position.y), .4)
		elif rect_position.x==-175:
			AudioController.play_camera_shutter_button() # Sound
			var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rect_position", Vector2(rect_position.x+rect_size.x,rect_position.y), .4)

# Closes panel if open and
# a click is made outside its area
func _input(event):
	if Input.is_action_just_pressed("click"):
		var evLocal = make_input_local(event)
		if rect_position.x!=1280 and rect_position.x!=-175:
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
				AudioController.play_old_camera_shutter_button() # Sound
				if rect_position.x>640:
					var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
					tween.tween_property(self, "rect_position", Vector2(1280,rect_position.y), .6)
				else:
					var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
					tween.tween_property(self, "rect_position", Vector2(-175,rect_position.y), .6)
