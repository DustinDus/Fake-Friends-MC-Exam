extends Control
const visible_cards_icon = "res://Game_Scene/Textures/SeeCards.png"
# Handles the clouds that contain sprites to show each player's "status effects"

# Effects
enum {VISIBLE_CARDS,RED_IMMUNITY,BLACK_IMMUNITY,STOPPED,IMPRISONED
	  CROUPIER,NEGATIVE_MOVEMENT,HALVED_MOVEMENT,CANT_PLAY_RED}

# GUI nodes
var clouds: Array = []
var sprites: Array = []
var number_font: DynamicFont
var card_view_aux: Panel

# Init
func initialize():
	# GUI
	for n in 4:
		clouds.append(get_child(n))
		if clouds[n].connect("show_cards",self,"_show_cards")!=0:
			print("!!! Effect Clouds can't connect a signal !!!")
	card_view_aux = $"../Effects_UI/Card_View_Aux"
	# Sprites
	sprites.append(load("res://Game_Scene/Textures/Effect_Icons/SeeCards.png"))
	sprites.append(load("res://Game_Scene/Textures/Effect_Icons/RedImmunity.png"))
	sprites.append(load("res://Game_Scene/Textures/Effect_Icons/BlackImmunity.png"))
	sprites.append(load("res://Game_Scene/Textures/Effect_Icons/Stopped.png"))
	sprites.append(load("res://Game_Scene/Textures/Effect_Icons/Imprisoned.png"))
	sprites.append(load("res://Game_Scene/Textures/Effect_Icons/Croupier.png"))
	sprites.append(load("res://Game_Scene/Textures/Effect_Icons/NegativeMovement.png"))
	sprites.append(load("res://Game_Scene/Textures/Effect_Icons/HalvedMovement.png"))
	sprites.append(load("res://Game_Scene/Textures/Effect_Icons/CantPlayRed.png"))
	# Font
	number_font = DynamicFont.new()
	number_font.font_data = load("res://nano.ttf")
	number_font.outline_color = Color(0,0,0)
	number_font.outline_size = 5
	number_font.size = 196

# Add an effect to a player and setup cloud
func add_effect(player_id: int, effect_number: int, turn_number: int):
	# Check
	var cloud = clouds[player_id]
	if cloud.has_node(str(effect_number)):
		# Update label
		var sprite = cloud.get_node(str(effect_number))
		var label = sprite.get_child(0)
		label.text = str(int(label.text)+turn_number)
		yield(get_tree(),"idle_frame")
		return
	# Prep sprite
	var effect_sprite = Sprite.new()
	effect_sprite.texture = sprites[effect_number]
	effect_sprite.position = Vector2(0,-20)
	effect_sprite.scale = Vector2(.5,.5)
	effect_sprite.name = str(effect_number)
	effect_sprite.visible = cloud.get_child_count()==0
	# Prep label
	var effect_label = Label.new()
	effect_label.rect_position = Vector2(70,-235)
	effect_label.add_font_override("font",number_font)
	effect_label.add_color_override("font_color",Color(.8,.8,.8))
	effect_label.add_color_override("font_color_shadow",Color(0,0,0))
	effect_label.add_constant_override("shadow_offset_x",10)
	effect_label.add_constant_override("shadow_offset_y",10)
	effect_label.text = str(turn_number)
	# Add
	effect_sprite.add_child(effect_label)
	cloud.add_child(effect_sprite)
	# Process?
	if cloud.get_child_count()>1: cloud.set_process(true)
	if cloud.has_node("0"): cloud.set_process_input(true)
	else: cloud.set_process_input(false)
	# Show ?
	if cloud.modulate==Color(1,1,1,1):
		yield(get_tree(),"idle_frame")
	else:
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(cloud,"modulate",Color(1,1,1,1),.4)
		yield(get_tree().create_timer(.4),"timeout")

# Reduce the number on the effect labels
func reduce_effects(player_id: int):
	for effect_sprite in clouds[player_id].get_children():
		var remaining_turns = int(effect_sprite.get_child(0).text)
		effect_sprite.get_child(0).text = str(remaining_turns-1)
	yield(get_tree(),"idle_frame")

# Remove an effect from a player and fix up cloud
func remove_effect(player_id: int, effect_number: int):
	# Check
	var cloud = clouds[player_id]
	if not cloud.has_node(str(effect_number)):
		yield(get_tree(),"idle_frame")
		return
	# Process?
	var child_number: int = cloud.get_child_count()-1
	if child_number<2: cloud.set_process(false)
	if effect_number==0: cloud.set_process_input(false)
	else: cloud.set_process_input(true)
	# Remove
	cloud.get_node(str(effect_number)).queue_free()
	# Hide ?
	if child_number>1:
		yield(get_tree(),"idle_frame")
	elif child_number==1:
		cloud.get_child(0).show()
		yield(get_tree(),"idle_frame")
	else:
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(cloud,"modulate",Color(1,1,1,0),.4)
		yield(get_tree().create_timer(.4),"timeout")

# Show cards
func _show_cards(player_id: int): card_view_aux.setup_UI(player_id)
