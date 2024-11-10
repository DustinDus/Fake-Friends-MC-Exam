extends Node
class_name Game_Stats
# Class used to simply keep track of a player's stats in a game

# ints
var tiles_traveled: int # 0
var times_sent_back_to_the_start: int
var times_jailed: int
var tiles_sent_other_players_back: int
var times_sent_someone_else_to_the_start: int
var red_cards_drawn: int # 5
var black_cards_drawn: int
var orange_cards_drawn: int
var red_cards_activated: int
var combos_activated: int
var reactions_activated: int # 10
var red_cards_negated: int
var black_cards_negated: int
var orange_cards_negated: int
var cards_stolen: int
var cards_discarded: int # 15
var turns_skipped: int
var time: int

# bools
var held_seven_cards: bool
var reflected_fu: bool

func _init(): reset()

func reset():
	tiles_traveled = 0 # 0
	times_sent_back_to_the_start = 0
	times_jailed = 0
	tiles_sent_other_players_back = 0
	times_sent_someone_else_to_the_start = 0
	red_cards_drawn = 0 # 5
	black_cards_drawn = 0
	orange_cards_drawn = 0
	red_cards_activated = 0
	combos_activated = 0
	reactions_activated = 0 # 10
	red_cards_negated = 0
	black_cards_negated = 0
	orange_cards_negated = 0
	cards_stolen = 0
	cards_discarded = 0 # 15
	turns_skipped = 0
	time = 0
	held_seven_cards = false
	reflected_fu = false

func git() -> Array:
	var game_stats: Array = []
	game_stats.append(tiles_traveled) # 0
	game_stats.append(times_sent_back_to_the_start)
	game_stats.append(times_jailed)
	game_stats.append(tiles_sent_other_players_back)
	game_stats.append(times_sent_someone_else_to_the_start)
	game_stats.append(red_cards_drawn) # 5
	game_stats.append(black_cards_drawn)
	game_stats.append(orange_cards_drawn)
	game_stats.append(red_cards_activated)
	game_stats.append(combos_activated)
	game_stats.append(reactions_activated) # 10
	game_stats.append(red_cards_negated)
	game_stats.append(black_cards_negated)
	game_stats.append(orange_cards_negated)
	game_stats.append(cards_stolen)
	game_stats.append(cards_discarded) # 15
	game_stats.append(turns_skipped)
	game_stats.append(time)
	game_stats.append(held_seven_cards)
	game_stats.append(reflected_fu)
	return game_stats
