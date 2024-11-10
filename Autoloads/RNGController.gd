extends Node
# Singleton used to generate random numbers

var _unique_rng: RandomNumberGenerator # Unique, unpredictable RNG created when the app boots up
var _common_rng: RandomNumberGenerator # RNG common to each player during a game

func _ready():
	_unique_rng = RandomNumberGenerator.new()
	_unique_rng.randomize()

func initialize(raw_seed: String):
	var refined_seed: int = hash(raw_seed)
	seed(refined_seed)
	_common_rng = RandomNumberGenerator.new()
	_common_rng.set_seed(refined_seed)

func unique_roll(low: int, high: int) -> int: return _unique_rng.randi_range(low,high)

func common_roll(low: int, high: int) -> int: return _common_rng.randi_range(low,high)
