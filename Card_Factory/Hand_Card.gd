extends MarginContainer
# A card in hand can be dragged around, inspected and played (under certain conditions)

# For inputs
var dragging: bool 
var click_timer: Timer
var stop_inputs: bool

# Original position
var x
var y
# Card Info
var card_id: int
var card_name: String
# To show info
var info_panel

# Signals
signal check_drop

# Init
func initialize(card_info: Array, passed_info_panel):
	# To detect clicks/drags
	dragging = false
	click_timer = Timer.new()
	click_timer.one_shot = true
	add_child(click_timer)
	stop_inputs = false
	# Vars
	x = 640-rect_size.x/4
	y = 620
	card_id = card_info[0]
	card_name = card_info[2]
	info_panel = passed_info_panel
	set_process(true)
	# Signals
	if get_node("Cover").connect("gui_input",self,"_gui_input")!=0:
		print("!!! Player_Hand_Card can't connect a signal !!!")
	if get_node("Cover").connect("mouse_entered",self,"_on_mouse_entered")!=0:
		print("!!! Player_Hand_Card can't connect a signal !!!")
	if get_node("Cover").connect("mouse_exited",self,"_on_mouse_exited")!=0:
		print("!!! Player_Hand_Card can't connect a signal !!!")

# For dragging
func _process(_delta):
	if stop_inputs: return
	if dragging: rect_position = dragged_center()

# Tells apart click and drag
func _gui_input(event):
	if stop_inputs: return
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("click"):
			AudioController.play_card_slide_7() # Sound
			get_parent().layer = 4
			dragging = true
			click_timer.start(.1)
			var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rect_scale", Vector2(.75,.75), .4)
			tween.parallel().tween_property(self, "rect_position", dragged_center(), .4)
		if Input.is_action_just_released("click"):
			AudioController.play_card_slide_8() # Sound
			fix_up_layer()
			dragging = false
			emit_signal("check_drop",self,get_global_mouse_position()-get_parent().get_parent().rect_position)
			if click_timer.get_time_left()>0: info_panel.show_info(card_name,"Red",card_id)
			var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rect_position", Vector2(x,y), .6)
			tween.parallel().tween_property(self, "rect_scale", Vector2(.5,.5), .4)

# Get center of the card relative to mouse position
func dragged_center(): return get_global_mouse_position()-(rect_size/(2.6))

# Pull card up/down
func _on_mouse_entered():
	if stop_inputs: return
	get_parent().layer = 1
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", Vector2(x,y-100), .6)
func _on_mouse_exited():
	if stop_inputs: return
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position", Vector2(x,y), .6)
	fix_up_layer()

# Fixes the card's layer after being released
func fix_up_layer():
	get_parent().layer = 1
	while rect_position!=Vector2(x,y): yield(get_tree().create_timer(.4),"timeout")
	get_parent().layer = 0

# Pass main info in an array: [ID,color,name]
func get_info() -> Array: return [card_id,"Red",card_name]
# Single values
func get_id() -> int: return card_id
func get_card_name() -> String: return card_name
