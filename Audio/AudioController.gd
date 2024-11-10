extends Node
# Autoload that activates sounds

# Sounds 0: Buttons #
var generic_button: AudioStreamPlayer = AudioStreamPlayer.new()
var heavier_button: AudioStreamPlayer = AudioStreamPlayer.new()
var clackier_button: AudioStreamPlayer = AudioStreamPlayer.new()
var camera_shutter_button: AudioStreamPlayer = AudioStreamPlayer.new()
var old_camera_shutter_button: AudioStreamPlayer = AudioStreamPlayer.new()
var hard_typewriter_button: AudioStreamPlayer = AudioStreamPlayer.new()
var mouse_close_button: AudioStreamPlayer = AudioStreamPlayer.new()
var opening_software_interface_button: AudioStreamPlayer = AudioStreamPlayer.new()
var button_9: AudioStreamPlayer = AudioStreamPlayer.new()
var menu_button: AudioStreamPlayer = AudioStreamPlayer.new()

# Sounds 1: Dice #
var dice_roll: AudioStreamPlayer = AudioStreamPlayer.new()
var cornflakes: AudioStreamPlayer = AudioStreamPlayer.new()
var chips_handle_6: AudioStreamPlayer = AudioStreamPlayer.new()
var chip_lay_2: AudioStreamPlayer = AudioStreamPlayer.new()
var chips_handle_4: AudioStreamPlayer = AudioStreamPlayer.new()
var chip_lay_1: AudioStreamPlayer = AudioStreamPlayer.new()

# Sounds 2: Cards #
var card_slide_7: AudioStreamPlayer = AudioStreamPlayer.new()
var card_slide_8: AudioStreamPlayer = AudioStreamPlayer.new()
var cardsoundflick: AudioStreamPlayer = AudioStreamPlayer.new()
var heartbeat_v2: AudioStreamPlayer = AudioStreamPlayer.new()
var jobro_heartbeat: AudioStreamPlayer = AudioStreamPlayer.new()
var interface_1: AudioStreamPlayer = AudioStreamPlayer.new()
var a_sudden_appearance: AudioStreamPlayer = AudioStreamPlayer.new()
var swing_whoosh_weapon_1: AudioStreamPlayer = AudioStreamPlayer.new()
var swish_sound: AudioStreamPlayer = AudioStreamPlayer.new()
var swing_whoosh_in_room_2: AudioStreamPlayer = AudioStreamPlayer.new()
var splash_bathroom: AudioStreamPlayer = AudioStreamPlayer.new()
var card_shove_1: AudioStreamPlayer = AudioStreamPlayer.new()
var card_place_1: AudioStreamPlayer = AudioStreamPlayer.new()
#var card_place_3: AudioStreamPlayer = AudioStreamPlayer.new()
#var card_place_4: AudioStreamPlayer = AudioStreamPlayer.new()
var shuffle: AudioStreamPlayer = AudioStreamPlayer.new()

# Sounds 3: Movement #
var regularfootstep001: AudioStreamPlayer = AudioStreamPlayer.new()
var teleport: AudioStreamPlayer = AudioStreamPlayer.new()
var teleport_reversed: AudioStreamPlayer = AudioStreamPlayer.new()

# Sounds ?: Others #
var whoosh_3: AudioStreamPlayer = AudioStreamPlayer.new()
var back_tick: AudioStreamPlayer = AudioStreamPlayer.new()
var turnpage: AudioStreamPlayer = AudioStreamPlayer.new()
var bloop_1: AudioStreamPlayer = AudioStreamPlayer.new()
var transition_coat: AudioStreamPlayer = AudioStreamPlayer.new()
var whoosh_click01: AudioStreamPlayer = AudioStreamPlayer.new()
var cowbell_os_1: AudioStreamPlayer = AudioStreamPlayer.new()
var parking_brake: AudioStreamPlayer = AudioStreamPlayer.new()
var old_camera: AudioStreamPlayer = AudioStreamPlayer.new()
var appear_2: AudioStreamPlayer = AudioStreamPlayer.new()
var chips_stack_1: AudioStreamPlayer = AudioStreamPlayer.new()
var chips_handle_3: AudioStreamPlayer = AudioStreamPlayer.new()
var complex_movements_whoosh_6: AudioStreamPlayer = AudioStreamPlayer.new()
var twirling_cartoon_sound: AudioStreamPlayer = AudioStreamPlayer.new()
var tadaa: AudioStreamPlayer = AudioStreamPlayer.new()

# Music
var curr: int = -1
var tracks: Array = []
var fun_game: AudioStreamPlayer = AudioStreamPlayer.new() # Lighter menu theme
var upbeat_background: AudioStreamPlayer = AudioStreamPlayer.new() # Darker menu theme
var upbeat_mission: AudioStreamPlayer = AudioStreamPlayer.new() # Early game theme
var sneaky_spy: AudioStreamPlayer = AudioStreamPlayer.new() # Mid game theme
var creepy_suspense: AudioStreamPlayer = AudioStreamPlayer.new() # End game theme
var adventure_game: AudioStreamPlayer = AudioStreamPlayer.new() # Victory theme

# Get sounds
func _ready():
	#########
	# Buttons
	generic_button.set_stream(load("res://Audio/Buttons/generic_button-tr.wav"))
	generic_button.set_bus("Sound")
	add_child(generic_button)
	heavier_button.set_stream(load("res://Audio/Buttons/heavier_button-tr.wav"))
	heavier_button.set_bus("Sound")
	add_child(heavier_button)
	clackier_button.set_stream(load("res://Audio/Buttons/clackier_button-tr.wav"))
	clackier_button.set_bus("Sound")
	add_child(clackier_button)
	camera_shutter_button.set_stream(load("res://Audio/Buttons/camera-shutter-click-tr.wav"))
	camera_shutter_button.set_bus("Sound")
	add_child(camera_shutter_button)
	old_camera_shutter_button.set_stream(load("res://Audio/Buttons/old-camera-shutter-click-tr.wav"))
	old_camera_shutter_button.set_bus("Sound")
	add_child(old_camera_shutter_button)
	hard_typewriter_button.set_stream(load("res://Audio/Buttons/hard-typewriter-click-tr.wav"))
	hard_typewriter_button.set_bus("Sound")
	add_child(hard_typewriter_button)
	mouse_close_button.set_stream(load("res://Audio/Buttons/mouse-click-close-tr.wav"))
	mouse_close_button.set_bus("Sound")
	add_child(mouse_close_button)
	opening_software_interface_button.set_stream(load("res://Audio/Buttons/opening-software-interface-button-tr.wav"))
	opening_software_interface_button.set_bus("Sound")
	add_child(opening_software_interface_button)
	button_9.set_stream(load("res://Audio/Buttons/button-9.mp3"))
	button_9.set_bus("Sound")
	add_child(button_9)
	menu_button.set_stream(load("res://Audio/Buttons/menu-button.mp3"))
	menu_button.set_bus("Sound")
	add_child(menu_button)
	######
	# Dice
	dice_roll.set_stream(load("res://Audio/Dice/dice-roll-tr.mp3"))
	dice_roll.set_bus("Sound")
	add_child(dice_roll)
	cornflakes.set_stream(load("res://Audio/Dice/cornflakes.mp3"))
	cornflakes.set_bus("Sound")
	add_child(cornflakes)
	chips_handle_6.set_stream(load("res://Audio/Dice/chips-handle-6.ogg"))
	chips_handle_6.set_bus("Sound")
	add_child(chips_handle_6)
	chip_lay_2.set_stream(load("res://Audio/Dice/chip-lay-2.ogg"))
	chip_lay_2.set_bus("Sound")
	add_child(chip_lay_2)
	chips_handle_4.set_stream(load("res://Audio/Dice/chips-handle-4.ogg"))
	chips_handle_4.set_bus("Sound")
	add_child(chips_handle_4)
	chip_lay_1.set_stream(load("res://Audio/Dice/chip-lay-1.ogg"))
	chip_lay_1.set_bus("Sound")
	add_child(chip_lay_1)
	#######
	# Cards
	card_slide_7.set_stream(load("res://Audio/Cards/card-slide-7-tr.mp3"))
	card_slide_7.set_bus("Sound")
	add_child(card_slide_7)
	card_slide_8.set_stream(load("res://Audio/Cards/card-slide-8-tr.mp3"))
	card_slide_8.set_bus("Sound")
	add_child(card_slide_8)
	cardsoundflick.set_stream(load("res://Audio/Cards/cardsoundflick.mp3"))
	cardsoundflick.set_bus("Sound")
	add_child(cardsoundflick)
	heartbeat_v2.set_stream(load("res://Audio/Cards/heartbeat-v2.mp3"))
	heartbeat_v2.set_bus("Sound")
	add_child(heartbeat_v2)
	jobro_heartbeat.set_stream(load("res://Audio/Others/jobro_heartbeat.mp3"))
	jobro_heartbeat.set_bus("Sound")
	add_child(jobro_heartbeat)
	interface_1.set_stream(load("res://Audio/Cards/interface-1-red.mp3"))
	interface_1.set_bus("Sound")
	add_child(interface_1)
	a_sudden_appearance.set_stream(load("res://Audio/Cards/a-sudden-appearance-tr.mp3"))
	a_sudden_appearance.set_bus("Sound")
	add_child(a_sudden_appearance)
	swing_whoosh_weapon_1.set_stream(load("res://Audio/Cards/swing-whoosh-weapon-1.mp3"))
	swing_whoosh_weapon_1.set_bus("Sound")
	add_child(swing_whoosh_weapon_1)
	swish_sound.set_stream(load("res://Audio/Cards/swish-sound.mp3"))
	swish_sound.set_bus("Sound")
	add_child(swish_sound)
	swing_whoosh_in_room_2.set_stream(load("res://Audio/Cards/swing-whoosh-in-room-2.mp3"))
	swing_whoosh_in_room_2.set_bus("Sound")
	add_child(swing_whoosh_in_room_2)
	splash_bathroom.set_stream(load("res://Audio/Cards/splash-bathroom.mp3"))
	splash_bathroom.set_bus("Sound")
	add_child(splash_bathroom)
	card_shove_1.set_stream(load("res://Audio/Cards/card-shove-1.ogg"))
	card_shove_1.set_bus("Sound")
	add_child(card_shove_1)
	card_place_1.set_stream(load("res://Audio/Cards/card-place-1.ogg"))
	card_place_1.set_bus("Sound")
	add_child(card_place_1)
	#card_place_3.set_stream(load("res://Audio/Cards/card-place-3.ogg"))
	#card_place_3.set_bus("Sound")
	#add_child(card_place_3)
	#card_place_4.set_stream(load("res://Audio/Cards/card-place-4-tr.mp3"))
	#card_place_4.set_bus("Sound")
	#add_child(card_place_4)
	shuffle.set_stream(load("res://Audio/Cards/shuffle.mp3"))
	shuffle.set_bus("Sound")
	add_child(shuffle)
	##########
	# Movement
	regularfootstep001.set_stream(load("res://Audio/Movement/regularfootstep001-low-tr.mp3"))
	regularfootstep001.set_bus("Sound")
	add_child(regularfootstep001)
	teleport.set_stream(load("res://Audio/Movement/teleport.mp3"))
	teleport.set_bus("Sound")
	add_child(teleport)
	teleport_reversed.set_stream(load("res://Audio/Movement/teleport_reversed.mp3"))
	teleport_reversed.set_bus("Sound")
	add_child(teleport_reversed)
	########
	# Others
	whoosh_3.set_stream(load("res://Audio/Others/whoosh-3.mp3"))
	whoosh_3.set_bus("Sound")
	add_child(whoosh_3)
	back_tick.set_stream(load("res://Audio/Others/back-tick.mp3"))
	back_tick.set_bus("Sound")
	add_child(back_tick)
	turnpage.set_stream(load("res://Audio/Others/turnpage.mp3"))
	turnpage.set_bus("Sound")
	add_child(turnpage)
	bloop_1.set_stream(load("res://Audio/Others/bloop-1.mp3"))
	bloop_1.set_bus("Sound")
	add_child(bloop_1)
	transition_coat.set_stream(load("res://Audio/Others/transition-coat.mp3"))
	transition_coat.set_bus("Sound")
	add_child(transition_coat)
	whoosh_click01.set_stream(load("res://Audio/Others/whoosh-click01-slo.mp3"))
	whoosh_click01.set_bus("Sound")
	add_child(whoosh_click01)
	cowbell_os_1.set_stream(load("res://Audio/Others/cowbell_os_1.mp3"))
	cowbell_os_1.set_bus("Sound")
	add_child(cowbell_os_1)
	parking_brake.set_stream(load("res://Audio/Others/parking-brake.mp3"))
	parking_brake.set_bus("Sound")
	add_child(parking_brake)
	old_camera.set_stream(load("res://Audio/Others/old-camera.mp3"))
	old_camera.set_bus("Sound")
	add_child(old_camera)
	appear_2.set_stream(load("res://Audio/Others/appear-2-tr.mp3"))
	appear_2.set_bus("Sound")
	add_child(appear_2)
	chips_stack_1.set_stream(load("res://Audio/Others/chips-stack-1.ogg"))
	chips_stack_1.set_bus("Sound")
	add_child(chips_stack_1)
	chips_handle_3.set_stream(load("res://Audio/Others/chips-handle-3.ogg"))
	chips_handle_3.set_bus("Sound")
	add_child(chips_handle_3)
	complex_movements_whoosh_6.set_stream(load("res://Audio/Others/complex-movements-whoosh-6.mp3"))
	complex_movements_whoosh_6.set_bus("Sound")
	add_child(complex_movements_whoosh_6)
	twirling_cartoon_sound.set_stream(load("res://Audio/Others/twirling-cartoon-sound-tr-red.mp3"))
	twirling_cartoon_sound.set_bus("Sound")
	add_child(twirling_cartoon_sound)
	tadaa.set_stream(load("res://Audio/Others/tadaa.mp3"))
	tadaa.set_bus("Sound")
	add_child(tadaa)
	#######
	# Music
	fun_game.set_stream(load("res://Audio/Music/fun-game-upbeat-happy-video-game-music.mp3"))
	fun_game.set_bus("Music")
	tracks.append(fun_game)
	add_child(fun_game)
	upbeat_background.set_stream(load("res://Audio/Music/upbeat-background-loop-casual-video-game-music.mp3"))
	upbeat_background.set_bus("Music")
	tracks.append(upbeat_background)
	add_child(upbeat_background)
	upbeat_mission.set_stream(load("res://Audio/Music/upbeat-mission-fun-and-quirky-adventure.mp3"))
	upbeat_mission.set_bus("Music")
	tracks.append(upbeat_mission)
	add_child(upbeat_mission)
	sneaky_spy.set_stream(load("res://Audio/Music/sneaky-spy-quirky-and-fun-music.mp3"))
	sneaky_spy.set_bus("Music")
	tracks.append(sneaky_spy)
	add_child(sneaky_spy)
	creepy_suspense.set_stream(load("res://Audio/Music/creepy-suspense-horror-background-music.mp3"))
	creepy_suspense.set_bus("Music")
	tracks.append(creepy_suspense)
	add_child(creepy_suspense)
	adventure_game.set_stream(load("res://Audio/Music/adventure-game-fun-background-music.mp3"))
	adventure_game.set_bus("Music")
	tracks.append(adventure_game)
	add_child(adventure_game)

########
# Sounds

# Play button sounds
func play_generic_button(): generic_button.play()
func play_heavier_button(): heavier_button.play()
func play_clackier_button(): clackier_button.play()
func play_camera_shutter_button(): camera_shutter_button.play()
func play_old_camera_shutter_button(): old_camera_shutter_button.play()
func play_hard_typewriter_button(): hard_typewriter_button.play()
func play_mouse_close_button(): mouse_close_button.play()
func play_opening_software_interface_button(): opening_software_interface_button.play()
func play_button_9(): button_9.play()
func play_menu_button(): menu_button.play()

# Play dice sounds
func play_dice_roll(): dice_roll.play()
func play_cornflakes(): cornflakes.play()
func play_chips_handle_6(): chips_handle_6.play()
func play_chip_lay_2(): chip_lay_2.play()
func play_chips_handle_4(): chips_handle_4.play()
func play_chip_lay_1(): chip_lay_1.play()

# Play card sounds
func play_card_slide_7(): card_slide_7.play()
func play_card_slide_8(): card_slide_8.play()
func play_cardsoundflick(): cardsoundflick.play()
func play_heartbeat_v2(): heartbeat_v2.play()
func play_jobro_heartbeat(): jobro_heartbeat.play()
func play_interface_1(): interface_1.play()
func play_a_sudden_appearance(): a_sudden_appearance.play()
func play_swing_whoosh_weapon_1(): swing_whoosh_weapon_1.play()
func play_swish_sound(): swish_sound.play()
func play_swing_whoosh_in_room_2(): swing_whoosh_in_room_2.play()
func play_splash_bathroom(): splash_bathroom.play()
func play_card_shove_1(): card_shove_1.play()
func play_card_place_1(): card_place_1.play()
#func play_card_place_3(): card_place_3.play()
#func play_card_place_4(): card_place_4.play()
func play_shuffle(): shuffle.play()

# Play movement sounds
func play_regularfootstep001(): regularfootstep001.play()
func play_teleport(): teleport.play()
func play_teleport_reversed(): teleport_reversed.play()

# Play other sounds
func play_whoosh_3(): whoosh_3.play()
func play_back_tick(): back_tick.play()
func play_turnpage(): turnpage.play()
func play_bloop_1(): bloop_1.play()
func play_transition_coat(): transition_coat.play(.4)
func play_whoosh_click01(): whoosh_click01.play()
func play_cowbell_os_1(): cowbell_os_1.play()
func play_parking_brake(): parking_brake.play()
func play_old_camera(): old_camera.play()
func play_appear_2(): appear_2.play()
func play_chips_stack_1(): chips_stack_1.play()
func play_chips_handle_3(): chips_handle_3.play()
func play_complex_movements_whoosh_6(): complex_movements_whoosh_6.play()
func play_twirling_cartoon_sound(): twirling_cartoon_sound.play()
func play_tadaa(): tadaa.play()

# Play specified track
func play_music(track: int):
	if track==curr:
		return
	else:
		tracks[curr].stop()
		tracks[track].play()
		curr = track

# Stop whatever track was playing
func stop_music():
	tracks[curr].stop()
	curr = -1
