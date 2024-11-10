extends Sprite
# Script to handle player game mechanics-related data

# Current player tile
var tile: int = 1
# Keeps track of data for the sake of effects
var previous_tile: int = 1
var movement_roll_this_turn: int = 0

# Effects
enum {VISIBLE_CARDS,RED_IMMUNITY,BLACK_IMMUNITY,STOPPED,IMPRISONED
	  CROUPIER,NEGATIVE_MOVEMENT,HALVED_MOVEMENT,CANT_PLAY_RED}
# Miscellaneous variables to keep track of different effects
var diceMultiplier: float = 1.0
var turnsShowingHand: int
var turnsWithRedImmunity: int
var turnsWithBlackImmunity: int
var turnsToSkip: int = 0
var turnsToServe: int = 0
var hasCroupier: bool = false
var turnsWithNegativeMovement: int = 0
var turnsWithHalvedMovement: int = 0
var attemptToEscape: int = 0
var turnsCantPlayRed: int = 0

# Loads the specified texture in the specified coordinates
func initialize(x: float, y: float, texture: String) -> Sprite:
	self.position = Vector2(x,y)
	self.scale = Vector2(0.35,0.35)
	self.texture = load(texture)
	return self

# Updates current player tile and returns result
func upd_tile(v: int) -> int:
	previous_tile = tile
	tile += v
	if tile>64: tile = 64-(tile%64) # Can't go past tile 64
	if tile<1: tile = 1 # Can't go below tile 1
	return tile
# Sets current player tile
func set_tile(v: int):
	previous_tile = tile
	tile = v
	if tile>64: tile = 64-(tile%64) # Can't go past tile 64
	if tile<1: tile = 1 # Can't go below tile 1

##############
# Effect stuff
##############

# Does a player have to skip/serve turns?
func has_to_skip_turns() -> bool: return turnsToSkip>0
func has_to_serve_turns() -> bool: return turnsToServe>0

# Is a player immune to red/black cards?
func has_red_immunity() -> bool: return turnsWithRedImmunity>0
func has_black_immunity() -> bool: return turnsWithBlackImmunity>0

# Can a player play red cards
func can_play_red_cards() -> bool: return turnsCantPlayRed==0

# Reset this turn's movement roll
func reset_movement_roll(): movement_roll_this_turn = 0

# Multiply dice multiplier
func multiply_multiplier(multiplier: int): diceMultiplier*=multiplier

# Setup the player's dice multiplier in accordance to their effects
func setup_multiplier():
	diceMultiplier = 1.0
	if turnsWithNegativeMovement>0: diceMultiplier*=-1.0
	if turnsWithHalvedMovement>0: diceMultiplier*=0.5

# Add appropriate effect to player for tot turns
func add_effect(effect_number: int, turn_number: int):
	match effect_number:
		VISIBLE_CARDS: turnsShowingHand+=turn_number
		RED_IMMUNITY: turnsWithRedImmunity+=turn_number
		BLACK_IMMUNITY: turnsWithBlackImmunity+=turn_number
		STOPPED: turnsToSkip+=turn_number
		IMPRISONED: turnsToServe+=turn_number
		CROUPIER: hasCroupier=true
		NEGATIVE_MOVEMENT: turnsWithNegativeMovement+=turn_number
		HALVED_MOVEMENT: turnsWithHalvedMovement+=turn_number
		CANT_PLAY_RED: turnsCantPlayRed+=turn_number

# Remove appropriate effect from player
func remove_effect(effect_number: int):
	match effect_number:
		VISIBLE_CARDS: turnsShowingHand=0
		RED_IMMUNITY: turnsWithRedImmunity=0
		BLACK_IMMUNITY: turnsWithBlackImmunity=0
		STOPPED: turnsToSkip=0
		IMPRISONED: turnsToServe=0
		CROUPIER: hasCroupier=false
		NEGATIVE_MOVEMENT: turnsWithNegativeMovement=0
		HALVED_MOVEMENT: turnsWithHalvedMovement=0
		CANT_PLAY_RED: turnsCantPlayRed=0

# Reduce each effect by one turn (and make croupier false)
func reduce_effects():
	if turnsShowingHand>0: turnsShowingHand-=1
	if turnsWithRedImmunity>0: turnsWithRedImmunity-=1
	if turnsWithBlackImmunity>0: turnsWithBlackImmunity-=1
	if turnsToSkip>0: turnsToSkip-=1
	if turnsToServe>0: turnsToServe-=1
	hasCroupier=false
	if turnsWithNegativeMovement>0: turnsWithNegativeMovement-=1
	if turnsWithHalvedMovement>0: turnsWithHalvedMovement-=1
	if turnsCantPlayRed>0: turnsCantPlayRed-=1

# Returns an array of ints corresponding to the effects with 0 turns left
func get_over_effects() -> Array:
	var over_effects = []
	if turnsShowingHand==0: over_effects.append(VISIBLE_CARDS)
	if turnsWithRedImmunity==0: over_effects.append(RED_IMMUNITY)
	if turnsWithBlackImmunity==0: over_effects.append(BLACK_IMMUNITY)
	if turnsToSkip==0: over_effects.append(STOPPED)
	if turnsToServe==0: over_effects.append(IMPRISONED)
	over_effects.append(CROUPIER)
	if turnsWithNegativeMovement==0: over_effects.append(NEGATIVE_MOVEMENT)
	if turnsWithHalvedMovement==0: over_effects.append(HALVED_MOVEMENT)
	if turnsCantPlayRed==0: over_effects.append(CANT_PLAY_RED)
	return over_effects
