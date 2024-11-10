extends Node2D
# Checks activation requirements, targets and possible reactions for red cards

# IDs mapped to Card Names
enum {FU,GRAVEDIGGER,GRAVEROBBER,TORNADO,BONK
	  CARDMAGEDDON,RNGALLOWS,YING,YANG,JUDGE
	  HEART_OF_THE_CARDS,KOBE,DOUBLE_UP,TRIPLE_IT,QUICK_MATHS
	  THE_MAGICIAN,DICE_TAX,JAILBREAK,DUAL_CHANCE,MALUS
	  BACKPOCKET_PAIN,YEET,RULES_OF_NATURE,ITS_TIME_TO_STOP,CROUPIER
	  PARKING_METER,MINEFIELD,MAKE_IT_RAIN,MOMS_CREDIT_CARD,X_FACTOR
	  SWITCH,TOPSY_TURVY,UNAWARENESS,TABULA_RASA,MIRROR_CARD
	  KEBAB,SAUCE,BREAD,NO_U,ROULETTE
	  INSTANT_KARMA,OBJECTION,IMMUNITY,IMMUNITY_2,BREAK_IN_BLACK
	  GIMME_THAT,EXEMPTION,ROCK_SOLID,INDECLINABLE_OFFER,CONTROLLED_BURN}
# + Combo IDs
enum {YING_AND_YANG = -1, DONER_DELIGHT = -2}

# To extrapolate data
var game_manager: Node2D
# Show a player they can't play
var cant_play: Sprite

# Init
func initialize():
	game_manager = $"../../.."
	cant_play = get_child(0)
	#last_card_used = "None"

# Checks if a card can be played
# : Returns [bool1,Array,String]
# - "bool" tells if the card can be activated
# - "Array" contains the available targets (if any)
# - "String" indicates the card's reactability
func can_be_played(activator_id: int, card_id: int, show_cant_play_it: bool = true) -> Array:
	var data: Array = [true,[],"Unspecified"]
	# Check if can be played and get targets
	if not game_manager.playerManager.can_play_red_cards(activator_id): data[0] = false
	elif game_manager.playerManager.has_to_serve_turns(activator_id) and card_id!=JAILBREAK: data[0] = false
	else: match card_id:
		# 0-9
		FU: check_generic_enemy_targets(activator_id,data)
		GRAVEDIGGER:check_cards_in_red_pile(1,data)
		GRAVEROBBER: check_cards_in_black_pile_and_get_enemy_targets(1,activator_id,data)
		TORNADO: check_generic_enemy_targets(activator_id,data)
		BONK: check_generic_enemy_targets(activator_id,data)
		CARDMAGEDDON: check_enemy_targets_with_cards(activator_id,data)
		RNGALLOWS: check_enemy_targets_with_cards(activator_id,data)
		YING: check_enemy_targets_with_cards(activator_id,data)
		YANG: check_enemy_targets_with_cards(activator_id,data)
		JUDGE: check_for_at_least_two_targets_with_cards(activator_id,data)
		# 10-19
		HEART_OF_THE_CARDS: data[1].append(activator_id) # Self effect
		KOBE: data[1].append(activator_id) # Self effect
		DOUBLE_UP: data[1].append(activator_id) # Self effect
		TRIPLE_IT: data[1].append(activator_id) # Self effect
		QUICK_MATHS: data[1].append(activator_id) # Self effect
		THE_MAGICIAN: check_generic_enemy_targets(activator_id,data)
		DICE_TAX: check_generic_enemy_targets(activator_id,data)
		JAILBREAK: Jailbreak(data)
		DUAL_CHANCE: check_generic_enemy_targets_always_true(activator_id,data)
		MALUS: check_generic_enemy_targets(activator_id,data)
		# 20-29
		BACKPOCKET_PAIN: check_generic_enemy_targets(activator_id,data)
		YEET: check_generic_enemy_targets(activator_id,data)
		RULES_OF_NATURE: check_generic_enemy_targets(activator_id,data)
		ITS_TIME_TO_STOP: check_for_at_least_two_generic_enemy_targets(activator_id,data)
		CROUPIER: data[1].append(activator_id) # Self effect
		PARKING_METER: data[1].append(activator_id) # Tile change
		MINEFIELD: data[1].append(activator_id) # Tile change
		MAKE_IT_RAIN: data[1].append(activator_id) # Self effect
		MOMS_CREDIT_CARD: check_activator_is_at_least_on_tile_x(activator_id,5,data)
		X_FACTOR: check_generic_enemy_targets(activator_id,data)
		# 30-39
		SWITCH: check_generic_enemy_targets(activator_id,data)
		TOPSY_TURVY: check_enemy_targets_on_reversible_tiles(activator_id,data)
		UNAWARENESS: data[1].append(activator_id) # Self effect
		TABULA_RASA: check_generic_enemy_targets(activator_id,data)
		MIRROR_CARD: return Mirror_Card(activator_id)
		KEBAB: check_generic_enemy_targets(activator_id,data)
		SAUCE: check_generic_enemy_targets(activator_id,data)
		BREAD: check_generic_enemy_targets(activator_id,data)
		NO_U,ROULETTE: data[0]=false # Reactions can't be played just like that
		# 40-49
		INSTANT_KARMA,OBJECTION,IMMUNITY,IMMUNITY_2,BREAK_IN_BLACK,GIMME_THAT,EXEMPTION: data[0]=false
		ROCK_SOLID: data[1].append(activator_id) # Self effect
		INDECLINABLE_OFFER: check_generic_enemy_targets(activator_id,data)
		CONTROLLED_BURN: check_generic_targets(activator_id,data)
		# Combos 
		YING_AND_YANG: check_enemy_targets_with_cards(activator_id,data)
		DONER_DELIGHT: data[1].append(activator_id) # Self effect
		# Error
		_:
			print("!!! Red Card Check not recognized !!!")
			data[0] = false
	# If it's playable get its reactability
	if data[0]: match card_id:
		FU,BONK,RNGALLOWS,YING,YANG,DUAL_CHANCE,BACKPOCKET_PAIN,YEET,X_FACTOR,SWITCH,TOPSY_TURVY,KEBAB,SAUCE,BREAD,INDECLINABLE_OFFER: data[2] = "Single Enemy Target"
		TORNADO,CARDMAGEDDON,JUDGE,THE_MAGICIAN,DICE_TAX,MALUS,RULES_OF_NATURE,ITS_TIME_TO_STOP,TABULA_RASA,CONTROLLED_BURN,JAILBREAK: data[2] = "Multiple Enemy Targets"
		UNAWARENESS,ROCK_SOLID,YING_AND_YANG,DONER_DELIGHT: data[2] = "Unaffectable"
		_: pass
	# Result
	if data[0]==false and show_cant_play_it: cant_play_it()
	return data

# Blink sprite to show the card can't be played
func cant_play_it():
	AudioController.play_clackier_button() # Sound
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(cant_play,"modulate",Color(1,1,1,.2),.3)
	tween.tween_property(cant_play,"modulate",Color(1,1,1,0),.3)

###################
# Check/Get targets
###################

# Gets targets among non-immune enemy players
func check_generic_enemy_targets(activator_id: int, data: Array):
	for n in range(1,4):
		var id = (n+activator_id)%4
		if not game_manager.playerManager.has_red_immunity(id): data[1].append(id)
	if data[1].empty(): data[0] = false

# Gets targets among non-immune enemy players but returns true even if no targets are found
func check_generic_enemy_targets_always_true(activator_id: int, data: Array):
	for n in range(1,4):
		var id = (n+activator_id)%4
		if not game_manager.playerManager.has_red_immunity(id): data[1].append(id)

# Gets at least two targets among non-immune enemy players
func check_for_at_least_two_generic_enemy_targets(activator_id: int, data: Array):
	for n in range(1,4):
		var id = (n+activator_id)%4
		if not game_manager.playerManager.has_red_immunity(id): data[1].append(id)
	if data[1].size()<2: data[0] = false

# Makes sure the activator is at least on a certain tile
func check_activator_is_at_least_on_tile_x(activator_id: int, tile: int, data: Array):
	if game_manager.playerManager.get_player_tile(activator_id)<tile: data[0] = false

# Gets targets among non-immune enemy players with cards in hand
func check_enemy_targets_with_cards(activator_id: int, data: Array):
	for n in range(1,4):
		var id = (n+activator_id)%4
		if (not game_manager.playerManager.has_red_immunity(id)) and game_manager.cardManager.player_has_cards(id): data[1].append(id)
	if data[1].empty(): data[0] = false

# Gets at least two targets among any non-immune players with cards in hand
# (activator must have at least two)
func check_for_at_least_two_targets_with_cards(activator_id: int, data: Array):
	for id in 4:
		if id==activator_id:
			if (game_manager.cardManager.get_player_card_number(id)>1):
				data[1].append(id)
		else:
			if (not game_manager.playerManager.has_red_immunity(id)) and game_manager.cardManager.player_has_cards(id):
				data[1].append(id)
	if data[1].size()<2: data[0] = false

# Check there are more than n red cards in discard pile
func check_cards_in_red_pile(min_cards: int, data: Array):
	if game_manager.cardManager.get_cards_in_red_pile_number()<min_cards: data[0] = false

# Check there are more than n black cards in discard pile
# Then check for targets among non-immune (to black cards) enemy players
func check_cards_in_black_pile_and_get_enemy_targets(min_cards: int, activator_id: int, data: Array):
	if game_manager.cardManager.get_cards_in_black_pile_number()>=min_cards:
		for n in range(1,4):
			var id = (n+activator_id)%4
			if not game_manager.playerManager.has_black_immunity(id): data[1].append(id)
	if data[1].size()<2: data[0] = false

# Check players on tiles that can be reversed
func check_enemy_targets_on_reversible_tiles(activator_id: int, data: Array):
	for n in range(1,4):
		var id = (n+activator_id)%4
		var tile = game_manager.playerManager.get_player_tile(id)
		if tile<10: data[1].append(id)
		else:
			var units: int = tile%10
			var tens: int = (tile-units)/10
			if (tens==6 and units<5) || (tens<6 and units<7): data[1].append(id)
	if data[1].empty(): data[0] = false

func check_generic_targets(activator_id: int, data: Array):
	for n in range(1,5):
		var id = (n+activator_id)%4
		if not game_manager.playerManager.has_red_immunity(id): data[1].append(id)
	if data[1].empty(): data[0] = false

# Special check made specifically for Jailbreak
# Check players in jail
func Jailbreak(data: Array):
	for id in 4:
		if game_manager.playerManager.has_to_serve_turns(id):
			data[1].append(id)
	if data[1].empty(): data[0] = false

# Special check made specifically for Mirror Card
# It returns the same data as the card it mirrors
func Mirror_Card(activator_id: int) -> Array:
	var data: Array = can_be_played(activator_id,get_parent().effects.last_card_used)
	return data
