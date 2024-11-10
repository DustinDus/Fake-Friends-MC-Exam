extends Control
# Verifies card reactability and reactions

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

# Registers each player's reaction to something
var registered_reactions: Array
# Aux nodes
var reaction_asker: Panel
var reaction_effects: Control
var click_or_wait_layer: CanvasLayer

func _ready():
	registered_reactions = [0,0,0,0]
	reaction_asker = get_child(0).get_child(0)
	reaction_asker.initialize()
	reaction_effects = get_child(1)
	reaction_effects.initialize()
	click_or_wait_layer = $"../Click_Or_Wait_Layer"
	show()

#####################
# Check for reactions
#####################

# Checks the available reactions based on the kind of effect
func verify_reactability(effect_type: String, cards: Array, targets_just_me: bool) -> Array:
	match effect_type:
		"Single Enemy Target":
			if targets_just_me: return check_reactions([NO_U,ROULETTE,INSTANT_KARMA,OBJECTION],cards)
			else: return check_reactions([OBJECTION],cards)
		"Multiple Enemy Targets":
			return check_reactions([EXEMPTION,OBJECTION],cards)
		"Black Card Single":
			if targets_just_me: return check_reactions([IMMUNITY,IMMUNITY_2,BREAK_IN_BLACK,GIMME_THAT,OBJECTION],cards)
			else: return check_reactions([IMMUNITY,IMMUNITY_2,GIMME_THAT,OBJECTION],cards)
		"Black Card Multiple":
			if targets_just_me: return check_reactions([IMMUNITY,IMMUNITY_2,BREAK_IN_BLACK,GIMME_THAT,EXEMPTION,OBJECTION],cards)
			else: return check_reactions([IMMUNITY,IMMUNITY_2,GIMME_THAT,EXEMPTION,OBJECTION],cards)
		"Unspecified": return check_reactions([OBJECTION],cards)
		"Unaffectable": return []
		_:
			print("!!! effect_type not recognized !!!")
			return []

# Checks wether the cards in the player's hand are adequate reactions
func check_reactions(adequate_reactions: Array, cards: Array) -> Array:
	var possible_reactions: Array = []
	for card in cards:
		var card_id = card.get_id()
		if adequate_reactions.has(card_id): possible_reactions.append(card)
	return possible_reactions

# Ask the player if they want to use a reaction
func ask_for_reactions(reactions: Array, time_limit: float = 2):
	yield(click_or_wait_layer.appear_to_tell_player_time_left(time_limit-.1),"completed")
	reaction_asker.pre_setup_UI(reactions,time_limit)
	return yield(reaction_asker,"communicate_answer")

#####################
# Execute reactions
#####################

# Execute reaction effect
remote func activate_reaction(instigator_id: int, action: int, reactor_id: int, reaction: int, original_targets: Array, color: int):
	match reaction:
		NO_U: reaction_effects.No_U(instigator_id,action)
		ROULETTE: reaction_effects.Roulette(instigator_id,action,reactor_id)
		INSTANT_KARMA: reaction_effects.Instant_Karma(instigator_id,action,reactor_id)
		OBJECTION: reaction_effects.Objection(instigator_id)
		IMMUNITY,IMMUNITY_2: reaction_effects.Immunity()
		BREAK_IN_BLACK: reaction_effects.Break_in_Black(reactor_id)
		GIMME_THAT: reaction_effects.Gimme_That(reactor_id)
		EXEMPTION: reaction_effects.Exemption(instigator_id,action,reactor_id,original_targets,color)
		_:
			print("!!! Reaction not recognized !!!")
			if reaction_effects.game_manager.chain_number>0: reaction_effects.game_manager.chain_number-=1
			else: reaction_effects.end_chain(reaction_effects.game_manager.curr)
	# Update Stats
	UserStats.player_reacted(reactor_id)
	match reaction:
		NO_U: if action==0: UserStats.player_reflected_fu(reactor_id)
		OBJECTION,IMMUNITY,IMMUNITY_2,BREAK_IN_BLACK: UserStats.player_negated(reactor_id,color)

