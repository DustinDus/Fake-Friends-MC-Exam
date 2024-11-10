extends Node2D
# Checks targets for black cards

# IDs mapped to Card Names
enum {PLUS_1A,PLUS_1B,MINUS_1A,MINUS_1B,PLUS_2A
	  PLUS_2B,MINUS_2A,MINUS_2B,PLUS_3A,PLUS_3B
	  MINUS_3A,MINUS_3B,PLUS_4A,PLUS_4B,MINUS_4A
	  MINUS_4B,PLUS_5A,PLUS_5B,MINUS_5A,MINUS_5B
	  PLUS_6,MINUS_6,ILL_FATE,REVERSAL,REVERSAL_2
	  SWAPAIN,SWAPLEASURE,PRANKZ,PRANKZ_2,MISFORTUNE
	  BACK_TO_THE_STORE,RECONCILIATION,DOUBLE_OR_NOTHING,ALL_OR_NOTHING,A_BAD_DAY
	  WHAT_A_TERRIBLE_DAY,A_GOOD_DAY,LAG,SIKE,SCRIPTED_MATCH
	  SHOTS_FIRED,GIRL_ON_FIRE,RESET,THIS_IS_A_FINE,MEMZ,
	  GO_TO_JAIL,ITS_ALL_OVER,PAINFUL_SACRIFICE,ON_THE_LOOSE,GONNA_GET_YA}

# To extrapolate data
var game_manager: Node2D

# Init
func initialize(): game_manager = $"../../.."

# Checks a card's available targets
func get_targets(activator_id: int, card_id: int) -> Array:
	# Check
	var targets = []
	match card_id:
		# 0-9
		PLUS_1A: check_activator(activator_id,targets)
		PLUS_1B: check_activator(activator_id,targets)
		MINUS_1A: check_activator(activator_id,targets)
		MINUS_1B: check_activator(activator_id,targets)
		PLUS_2A: check_activator(activator_id,targets)
		PLUS_2B: check_activator(activator_id,targets)
		MINUS_2A: check_activator(activator_id,targets)
		MINUS_2B: check_activator(activator_id,targets)
		PLUS_3A: check_activator(activator_id,targets)
		PLUS_3B: check_activator(activator_id,targets)
		# 10-19
		MINUS_3A: check_activator(activator_id,targets)
		MINUS_3B: check_activator(activator_id,targets)
		PLUS_4A: check_activator(activator_id,targets)
		PLUS_4B: check_activator(activator_id,targets)
		MINUS_4A: check_activator(activator_id,targets)
		MINUS_4B: check_activator(activator_id,targets)
		PLUS_5A: check_activator(activator_id,targets)
		PLUS_5B: check_activator(activator_id,targets)
		MINUS_5A: check_activator(activator_id,targets)
		MINUS_5B: check_activator(activator_id,targets)
		# 20-29
		PLUS_6: check_activator(activator_id,targets)
		MINUS_6: check_activator(activator_id,targets)
		ILL_FATE: check_activator(activator_id,targets)
		REVERSAL: targets.append(-1) # No targets
		REVERSAL_2: targets.append(-1) # No targets
		SWAPAIN: verify_activator_and_check_other_players(activator_id,targets)
		SWAPLEASURE: verify_activator_and_check_other_players(activator_id,targets)
		PRANKZ: check_activator(activator_id,targets)
		PRANKZ_2: check_activator(activator_id,targets)
		MISFORTUNE: check_activator(activator_id,targets)
		# 30-39
		BACK_TO_THE_STORE: check_activator(activator_id,targets)
		RECONCILIATION: check_activator(activator_id,targets)
		DOUBLE_OR_NOTHING: check_activator(activator_id,targets)
		ALL_OR_NOTHING: check_activator(activator_id,targets)
		A_BAD_DAY: check_activator(activator_id,targets)
		WHAT_A_TERRIBLE_DAY: check_activator(activator_id,targets)
		A_GOOD_DAY: check_activator(activator_id,targets)
		LAG: check_activator(activator_id,targets)
		SIKE: check_activator(activator_id,targets)
		SCRIPTED_MATCH: check_activator(activator_id,targets)
		# 40-49
		SHOTS_FIRED: verify_activator_and_check_other_players(activator_id,targets)
		GIRL_ON_FIRE: check_activator(activator_id,targets)
		RESET: check_everyone_with_cards(targets)
		THIS_IS_A_FINE: check_activator(activator_id,targets)
		MEMZ: check_activator(activator_id,targets)
		GO_TO_JAIL: check_activator(activator_id,targets)
		ITS_ALL_OVER: check_activator(activator_id,targets)
		PAINFUL_SACRIFICE: verify_activator_and_check_other_players(activator_id,targets)
		ON_THE_LOOSE: targets.append(-1) # No targets
		GONNA_GET_YA: targets.append(-1) # No targets
		# Error
		_: print("!!! Red Card Check not recognized !!!")
	# Result
	return targets

###################
# Check/Get targets
###################

# Only check the activator
func check_activator(activator_id: int, targets: Array):
	if not game_manager.playerManager.has_black_immunity(activator_id):
		targets.append(activator_id)

# Needs to verify the activator is available but only includes other players as targets
func verify_activator_and_check_other_players(activator_id: int, targets: Array):
	if game_manager.playerManager.has_black_immunity(activator_id): return
	for n in range(1,4):
		var id = (n+activator_id)%4
		if not game_manager.playerManager.has_black_immunity(id): targets.append(id)

# Gets targets among everyone
func check_everyone_with_cards(targets: Array):
	for id in 4:
		if not game_manager.playerManager.has_black_immunity(id) and game_manager.cardManager.player_has_cards(id):
			targets.append(id)
