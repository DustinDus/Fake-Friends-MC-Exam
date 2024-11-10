extends Node
# Handles the user's stats and manages its file
# USER STATS are the user's actual, carved-in-stone stats
# GAME STATS is an object containing the stats gained in the latest game

# Games
var games_played: int # 0
var won_games: int
var lost_games: int
var shortest_game_played: int
var longest_game_played: int
var games_quit: int # 5
# Self movement
var tiles_traveled: int
var times_sent_back_to_the_start: int
var times_jailed: int
# Others movement
var tiles_sent_other_players_back: int
var times_sent_someone_else_to_the_start: int # 10
# Cards
var red_cards_drawn: int
var black_cards_drawn: int
var orange_cards_drawn: int
var red_cards_activated: int
var combos_activated: int # 15
var reactions_activated: int
var red_cards_negated: int
var black_cards_negated: int
var orange_cards_negated: int
var cards_stolen: int # 20
var cards_discarded: int
# Effects
var turns_skipped: int
# Others
var time: int

# For each player's game stats
var game_stats: Array

####################
# Save data handling

# Load user data on bootup
func _ready():
	load_info()
	for n in 4: game_stats.append(Game_Stats.new())

# Save user settings
func save_info():
	# Gather user info
	var save_info_dict: Dictionary = {
		"games_played": games_played, # 0
		"won_games": won_games,
		"lost_games": lost_games,
		"shortest_game_played": shortest_game_played,
		"longest_game_played": longest_game_played,
		"games_quit": games_quit, # 5
		"tiles_traveled": tiles_traveled,
		"times_sent_back_to_the_start": times_sent_back_to_the_start,
		"times_jailed": times_jailed,
		"tiles_sent_other_players_back": tiles_sent_other_players_back,
		"times_sent_someone_else_to_the_start": times_sent_someone_else_to_the_start, # 10
		"red_cards_drawn": red_cards_drawn,
		"black_cards_drawn": black_cards_drawn,
		"orange_cards_drawn": orange_cards_drawn,
		"red_cards_activated": red_cards_activated,
		"combos_activated": combos_activated, # 15
		"reactions_activated": reactions_activated,
		"red_cards_negated": red_cards_negated,
		"black_cards_negated": black_cards_negated,
		"orange_cards_negated": orange_cards_negated,
		"cards_stolen": cards_stolen, # 20
		"cards_discarded": cards_discarded,
		"turns_skipped": turns_skipped,
		"time": time
	}
	# Save the stuff to file
	var save = File.new()
	save.open("user://savegame.stats", File.WRITE)
	save.store_line(to_json(save_info_dict))
	save.close()

# Load user settings
func load_info():
	# Load stuff from file
	var save = File.new()
	if not save.file_exists("user://savegame.stats"): reset_info()
	save.open("user://savegame.stats", File.READ)
	var save_info_dict: Dictionary = parse_json(save.get_line())
	save.close()
	# Gather user info
	games_played = save_info_dict["games_played"] # 0
	won_games = save_info_dict["won_games"]
	lost_games = save_info_dict["lost_games"]
	shortest_game_played = save_info_dict["shortest_game_played"]
	longest_game_played = save_info_dict["longest_game_played"]
	games_quit = save_info_dict["games_quit"] # 5
	tiles_traveled = save_info_dict["tiles_traveled"]
	times_sent_back_to_the_start = save_info_dict["times_sent_back_to_the_start"]
	times_jailed = save_info_dict["times_jailed"]
	tiles_sent_other_players_back = save_info_dict["tiles_sent_other_players_back"]
	times_sent_someone_else_to_the_start = save_info_dict["times_sent_someone_else_to_the_start"] # 10
	red_cards_drawn = save_info_dict["red_cards_drawn"]
	black_cards_drawn = save_info_dict["black_cards_drawn"]
	orange_cards_drawn = save_info_dict["orange_cards_drawn"]
	red_cards_activated = save_info_dict["red_cards_activated"]
	combos_activated = save_info_dict["combos_activated"] # 15
	reactions_activated = save_info_dict["reactions_activated"]
	red_cards_negated = save_info_dict["red_cards_negated"]
	black_cards_negated = save_info_dict["black_cards_negated"]
	orange_cards_negated = save_info_dict["orange_cards_negated"]
	cards_stolen = save_info_dict["cards_stolen"] # 20
	cards_discarded = save_info_dict["cards_discarded"]
	turns_skipped = save_info_dict["turns_skipped"]
	time = save_info_dict["time"]

# Resets all user settings
func reset_info():
	# Reset user info
	var save_info_dict: Dictionary = {
		"games_played": 0, # 0
		"won_games": 0,
		"lost_games": 0,
		"shortest_game_played": 0,
		"longest_game_played": 0,
		"games_quit": 0, # 5
		"tiles_traveled": 0,
		"times_sent_back_to_the_start": 0,
		"times_jailed": 0,
		"tiles_sent_other_players_back": 0,
		"times_sent_someone_else_to_the_start": 0, # 10
		"red_cards_drawn": 0,
		"black_cards_drawn": 0,
		"orange_cards_drawn": 0,
		"red_cards_activated": 0,
		"combos_activated": 0, # 15
		"reactions_activated": 0,
		"red_cards_negated": 0,
		"black_cards_negated": 0,
		"orange_cards_negated": 0,
		"cards_stolen": 0, # 20
		"cards_discarded": 0,
		"turns_skipped": 0,
		"time": 0
	}
	# Save the stuff to file
	var save = File.new()
	save.open("user://savegame.stats", File.WRITE)
	save.store_line(to_json(save_info_dict))
	save.close()

#####################
# Handling User Stats

# Return an array of stats
func get_stats() -> Array:
	var stats: Array = []
	stats.append(games_played) # 0
	stats.append(won_games)
	stats.append(lost_games)
	stats.append(shortest_game_played)
	stats.append(longest_game_played)
	stats.append(games_quit) # 5
	stats.append(tiles_traveled)
	stats.append(times_sent_back_to_the_start)
	stats.append(times_jailed)
	stats.append(tiles_sent_other_players_back)
	stats.append(times_sent_someone_else_to_the_start) # 10
	stats.append(red_cards_drawn)
	stats.append(black_cards_drawn)
	stats.append(orange_cards_drawn)
	stats.append(red_cards_activated)
	stats.append(combos_activated) # 15
	stats.append(reactions_activated)
	stats.append(red_cards_negated)
	stats.append(black_cards_negated)
	stats.append(orange_cards_negated)
	stats.append(cards_stolen) # 20
	stats.append(cards_discarded)
	stats.append(turns_skipped)
	stats.append(time)
	return stats

# Update the stats at the end of a game
func upd_stats(my_id: int, victory: bool):
	# Prep
	var gs = game_stats[my_id]
	# Games
	games_played+=1
	if victory: won_games+=1
	else: lost_games+=1
	if gs.time<shortest_game_played || shortest_game_played==0: shortest_game_played = gs.time
	if gs.time>longest_game_played: longest_game_played = gs.time
	# Self movement
	tiles_traveled += gs.tiles_traveled
	times_sent_back_to_the_start += gs.times_sent_back_to_the_start
	times_jailed += gs.times_jailed
	# Others movement
	tiles_sent_other_players_back += gs.tiles_sent_other_players_back
	times_sent_someone_else_to_the_start += gs.times_sent_someone_else_to_the_start
	# Cards
	red_cards_drawn += gs.red_cards_drawn
	black_cards_drawn += gs.black_cards_drawn
	orange_cards_drawn += gs.orange_cards_drawn
	red_cards_activated += gs.red_cards_activated
	combos_activated += gs.combos_activated
	reactions_activated += gs.reactions_activated
	red_cards_negated += gs.red_cards_negated
	black_cards_negated += gs.black_cards_negated
	orange_cards_negated += gs.orange_cards_negated
	cards_stolen += gs.cards_stolen
	cards_discarded += gs.cards_discarded
	# Effects
	turns_skipped += gs.turns_skipped
	# Others
	time += gs.time
	# Save
	save_info()

#####################
# Handling Game Stats

# Reset each player's game stats
func reset_game_stats(): for gs in game_stats: gs.reset()
# Get each player's game stats
func get_game_stats() -> Array: return game_stats
# Get each player's quantifiable game stats as 4-sized arrays
func get_game_stats_to_compare() -> Array:
	# Prep
	var stats_to_compare: Array = [] # Empty
	for s in 16: stats_to_compare.append([]) # Made up of 15 empty arrays
	var stats: Array = []
	for gs in game_stats: stats.append(gs.git())
	# Fill
	for n in 4:
		for m in 16:
			stats_to_compare[m].append(stats[n][m])
	# Return
	return stats_to_compare

# Modify single stats

# tiles_traveled + times_sent_back_to_the_start
func player_moved(id: int, start: int, end: int):
	if end<1: end = 1
	elif end>64: end = end-(end-64)
	if end==1: game_stats[id].times_sent_back_to_the_start+=1
	game_stats[id].tiles_traveled+=abs(end-start)

# tiles_sent_other_players_back + times_sent_someone_else_to_the_start
func player_moved_another_player(id: int, start: int, end: int):
	if end<1: end = 1
	elif end>64: end = end-(end-64)
	if end==1: game_stats[id].times_sent_someone_else_to_the_start+=1
	if end>start: return # Doesn't count if you move them forward
	game_stats[id].tiles_sent_other_players_back+=start-end

# times_jailed
func player_jailed(id: int): game_stats[id].times_jailed+=1

# red_cards_drawn + black_cards_drawn + orange_cards_drawn
func player_drew(id: int, card_type: int):
	if card_type==0: game_stats[id].red_cards_drawn+=1
	elif card_type==1: game_stats[id].black_cards_drawn+=1
	else: game_stats[id].orange_cards_drawn+=1

# red_cards_activated + combos_activated
func player_activated(id: int, is_combo: bool):
	game_stats[id].red_cards_activated+=1
	if is_combo: game_stats[id].combos_activated+=1

# reactions_activated
func player_reacted(id: int): game_stats[id].reactions_activated+=1

# red_cards_negated + black_cards_negated + orange_cards_negated
func player_negated(id: int, card_type: int):
	if card_type==0: game_stats[id].red_cards_negated+=1
	elif card_type==1: game_stats[id].black_cards_negated+=1
	else: game_stats[id].orange_cards_negated+=1

# cards_stolen
func player_stole(id: int): game_stats[id].cards_stolen+=1

# cards_discarded
func player_discarded(id: int): game_stats[id].cards_discarded+=1

# turns_skipped
func player_skips(id: int): game_stats[id].turns_skipped+=1

# held_seven_cards
func player_held_seven_cards(id: int): game_stats[id].held_seven_cards=true

# reflected_fu
func player_reflected_fu(id: int): game_stats[id].reflected_fu=true
