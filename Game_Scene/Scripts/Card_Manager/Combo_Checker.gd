extends Node2D
# Checks if the player can/wants to make a combo

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

# Ask player if they want to execute a combo
var combo_asker: Control

# To communicate data to Red_Deck
# : Is meant to return [String,Array]
# - "String" is the card/combo name
# - "Array" contains the combo pieces (or the card name if no combo is made)
signal answer

# Init
func initialize():
	combo_asker = get_child(0)
	combo_asker.initialize()

##################################
# TO VERIFY IF A COMBO CAN BE MADE
##################################

# Checks if a player can execute a combo
# If so: asks if they want to
func can_combo(activator_id: int, card_id: int) -> bool:
	match card_id:
		YING: return can_Ying_and_Yang(activator_id)
		YANG: return can_Ying_and_Yang(activator_id)
		KEBAB: return can_Doner_Delight(activator_id)
		SAUCE: return can_Doner_Delight(activator_id)
		BREAD: return can_Doner_Delight(activator_id)
		_: return false

# Ying+Yang:
func can_Ying_and_Yang(activator_id: int) -> bool:
	if PlayersList.get_player_unique_id(activator_id)==PlayersList.get_my_unique_id() and get_parent().player_has_card(activator_id,YING) and get_parent().player_has_card(activator_id,YANG): return true
	else: return false

# Kebab+Sauce+Bread
func can_Doner_Delight(activator_id: int) -> bool:
	if PlayersList.get_player_unique_id(activator_id)==PlayersList.get_my_unique_id() and get_parent().player_has_card(activator_id,KEBAB) and get_parent().player_has_card(activator_id,SAUCE) and get_parent().player_has_card(activator_id,BREAD): return true
	else: return false

###########################################
# TO ASK IF THE PLAYER WANTS TO USE A COMBO
###########################################

# Checks if a player can execute a combo
# If so: asks if they want to
func ask_to_combo(activator_id: int, card_id: int):
	match card_id:
		YING: ask_to_Ying_and_Yang(activator_id,card_id)
		YANG: ask_to_Ying_and_Yang(activator_id,card_id)
		KEBAB: ask_to_Doner_Delight(activator_id,card_id)
		SAUCE: ask_to_Doner_Delight(activator_id,card_id)
		BREAD: ask_to_Doner_Delight(activator_id,card_id)
		_: emit_signal("answer",[card_id,[]])

# Ying+Yang:
func ask_to_Ying_and_Yang(activator_id: int, card_id: int):
	if PlayersList.get_player_unique_id(activator_id)==PlayersList.get_my_unique_id() and get_parent().player_has_card(activator_id,7) and get_parent().player_has_card(activator_id,8):
			combo_asker.appear(tr("USE YING AND YANG TOGETHER?"))
			var answer = yield(combo_asker,"answer")
			if answer: emit_signal("answer", [YING_AND_YANG,[YING,YANG]])
			else: emit_signal("answer",[card_id,[card_id]])
	else: emit_signal("answer",[card_id,[card_id]])

# Kebab+Sauce+Bread
func ask_to_Doner_Delight(activator_id: int, card_id: int):
	if PlayersList.get_player_unique_id(activator_id)==PlayersList.get_my_unique_id() and get_parent().player_has_card(activator_id,35) and get_parent().player_has_card(activator_id,36) and get_parent().player_has_card(activator_id,37):
			combo_asker.appear(tr("USE KEBAB, BREAD AND SAUCE TOGETHER?"))
			var answer = yield(combo_asker,"answer")
			if answer: emit_signal("answer", [DONER_DELIGHT,[KEBAB,BREAD,SAUCE]])
			else: emit_signal("answer",[card_id,[card_id]])
	else: emit_signal("answer",[card_id,[card_id]])
