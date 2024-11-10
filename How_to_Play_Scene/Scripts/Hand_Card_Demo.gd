extends MarginContainer
# Demo to move and play a card in hand

# Data for info panel
var card_id: int
var card_name:  String
var card_color: String
# Other stuff
var dragging: bool
var click_timer: Timer
var og_pos
# To show info
var info_panel: Panel

func initialize(id: int, color: String, passed_info_panel: Panel):
	# Dragging stuff
	og_pos = rect_position
	dragging = false
	click_timer = Timer.new()
	click_timer.one_shot = true
	add_child(click_timer)
	if get_node("Cover").connect("gui_input",self,"_gui_input")!=0:
		print("!!! Player_Hand_Card_Demo can't connect a signal !!!")
	set_process(true)
	info_panel = passed_info_panel
	
	# Get Info
	var card_database = load("res://Card_Factory/Card_Databases/"+color+"_Card_Database.gd")
	var card_info = card_database.DATA[id]
	
	# Set Vars
	card_id = id
	card_name = card_info[3]
	card_color = color
	
	# Set Sprite
	var artwork_path: String = "res://Card_Factory/Textures/Artworks/"+color+"/"+str(id)+".png"
	if ResourceLoader.exists(artwork_path):
		$Architecture/Artwork_Container/Artwork_Frame/Panel/Artwork.scale = Vector2(.375,.375)
		$Architecture/Artwork_Container/Artwork_Frame/Panel/Artwork.texture = load(artwork_path)
	
	# Set Outline
	var card_outline = Sprite.new()
	card_outline.texture = load("res://Card_Factory/Textures/"+card_color+"Outline.png")
	card_outline.position = Vector2(125,175)
	card_outline.scale = Vector2(.2,.2)
	self.add_child(card_outline)
	
	# Set Text and Panel colors
	match color:
		"Red":
			$Architecture/Name_Container/Panel/Name.set("custom_colors/font_color",Color(255,0,0))
			$Architecture/Effect_Container/Panel/Effect.set("custom_colors/font_color",Color(255,0,0))
			$Background.get("custom_styles/panel").bg_color = Color("#ffc8c8")
			$Architecture/Name_Container/Panel.get("custom_styles/panel").bg_color = Color("#ffe1e1")
			$Architecture/Effect_Container/Panel.get("custom_styles/panel").bg_color = Color("#ffe1e1")
		"Black":
			$Architecture/Name_Container/Panel/Name.set("custom_colors/font_color",Color(0,0,0))
			$Architecture/Effect_Container/Panel/Effect.set("custom_colors/font_color",Color(0,0,0))
			$Background.get("custom_styles/panel").bg_color = Color("#787878")
			$Architecture/Name_Container/Panel.get("custom_styles/panel").bg_color = Color("#969696")
			$Architecture/Effect_Container/Panel.get("custom_styles/panel").bg_color = Color("#969696")
		"Orange":
			$Architecture/Name_Container/Panel/Name.set("custom_colors/font_color",Color("#ffa000"))
			$Architecture/Effect_Container/Panel/Effect.set("custom_colors/font_color",Color("#ffa000"))
			$Background.get("custom_styles/panel").bg_color = Color("#ffdcaa")
			$Architecture/Name_Container/Panel.get("custom_styles/panel").bg_color = Color("#fff0c8")
			$Architecture/Effect_Container/Panel.get("custom_styles/panel").bg_color = Color("#fff0c8")
	
	# Set Info
	$Architecture/Name_Container/Panel/Name.get("custom_fonts/font").set("size", card_info[0])
	$Architecture/Effect_Container/Panel/Effect.get("custom_fonts/font").set("size", card_info[1])
	$Architecture/Name_Container/Panel/Name.text = tr(card_name)
	$Architecture/Effect_Container/Panel/Effect.text = tr(card_name+" EFFECT")

# For dragging
func _process(_delta): if dragging: rect_position = dragged_center()

# Tells apart click and drag
func _gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("click"):
			AudioController.play_card_slide_7() # Sound
			get_parent().layer = 2
			dragging = true
			click_timer.start(.1)
			var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rect_scale", Vector2(.75,.75), .4)
			tween.parallel().tween_property(self, "rect_position", dragged_center(), .4)
		if Input.is_action_just_released("click"):
			AudioController.play_card_slide_8() # Sound
			if info_panel!=null and click_timer.get_time_left()>0: info_panel.show_info(card_name,card_color,card_id)
			fix_up_layer()
			#get_parent().layer = 0
			check_drop()
			dragging = false
			var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rect_position", og_pos, .6)
			tween.parallel().tween_property(self, "rect_scale", Vector2(.5,.5), .4)

# Get center of the card relative to mouse position
func dragged_center(): return get_global_mouse_position()-(rect_size/2.6)

# Check if it was dropped in the middle of the board
func check_drop():
	var drop_area = get_node_or_null("../../Drop_Area")
	if drop_area!=null: drop_area.check_drop(get_global_mouse_position())

# Fixes the card's layer after being released
func fix_up_layer():
	get_parent().layer = 1
	while rect_position!=og_pos: yield(get_tree().create_timer(.2),"timeout")
	get_parent().layer = 0
