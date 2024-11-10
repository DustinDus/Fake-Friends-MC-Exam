extends MarginContainer
# Scene used to create a card from its data

# Useful vars
var card_id: int
var card_color: String
var card_name: String

# Proper initialization function
# Sets up card of specified color using passed info
# card_info: [Name_Font_Size, Text_Font_Size, ID, NAME]
func initialize(color: String, card_info: Array):
	# Set Vars
	card_id = card_info[2]
	card_color = color
	card_name = card_info[3]
	
	# Set Sprite
	var artwork_path: String = "res://Card_Factory/Textures/Artworks/"+card_color+"/"+str(card_id)+".png"
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
	match card_color:
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

# Cover/Uncover
func cover():
	var card_back = Sprite.new()
	card_back.name = "card_back"
	card_back.texture = load("res://Card_Factory/Textures/"+card_color+"Back.png")
	card_back.position = Vector2(125,175)
	card_back.scale = Vector2(.2,.2)
	self.add_child(card_back)
func uncover():
	if has_node("card_back"): get_node("card_back").queue_free()

# Pass main info in an array: [ID,color,name]
func get_info() -> Array: return [card_id,card_color,card_name]
# Single values
func get_id() -> int: return card_id
func get_card_color() -> String: return card_color
func get_card_name() -> String: return card_name




# Test Function (_ready <-> test)
# Sets up a card according to some vars
func test():
	# Language to check the card in
	TranslationServer.set_locale("en")
	# Which card to get
	var id = 11
	# From Where
	var color = "Orange"
	# Get Info
	var card_database = load("res://Card_Factory/Card_Databases/"+color+"_Card_Database.gd")
	var card_info = card_database.DATA[id]
	
	# Set Vars
	card_id = card_info[2]
	card_color = color
	card_name = card_info[3]
	
	# Set Sprite
	var artwork_path: String = "res://Card_Factory/Textures/Artworks/"+card_color+"/"+str(card_id)+".png"
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
