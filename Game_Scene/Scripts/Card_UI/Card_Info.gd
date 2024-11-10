extends Panel
# Shows card info in BIG characters

var name_label: Label
var effect_label: Label

func initialize():
	name_label = $Name
	effect_label = $Effect/ScrollContainer/Label
	show()

# Show a certain card's info
func show_info(card_name: String, color: String, id: int):
	# Set up info
	name_label.text = tr(card_name)
	effect_label.text = tr(card_name+" EFFECT")
	match color:
		"Red": name_label.set("custom_colors/font_color",Color(255,0,0))
		"Black": name_label.set("custom_colors/font_color",Color(0,0,0))
		"Orange": name_label.set("custom_colors/font_color",Color("#ffa000"))
	# Set up sprite
	var artwork_path: String = "res://Card_Factory/Textures/Artworks/"+color+"/"+str(id)+".png"
	if ResourceLoader.exists(artwork_path):
		$Artwork/Panel/Sprite.scale = Vector2(.45,.45)
		$Artwork/Panel/Sprite.texture = load(artwork_path)
	else:
		$Artwork/Panel/Sprite.scale = Vector2(.25,.25)
	# Move panel
	if rect_position.y==-460: # -300
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rect_position", Vector2(rect_position.x,rect_position.y+rect_size.y), .4)

# Closes panel if open and
# a click is made outside its area
func _input(event):
	if Input.is_action_just_pressed("click"):
		var evLocal = make_input_local(event)
		if rect_position.y!=-460: # -300
			if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
				var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "rect_position", Vector2(rect_position.x,-460), .6) # -300
