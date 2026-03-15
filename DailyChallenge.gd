extends Node

const MODIFIERS = [
	{"name": "Fast Ball",         "desc": "Ball moves at lightning speed!",    "key": "fast_ball"},
	{"name": "Small Paddle",      "desc": "Your paddle is half the size.",      "key": "small_paddle"},
	{"name": "Extra Powerups",    "desc": "Powerups drop much more often.",     "key": "extra_powerups"},
	{"name": "Double Explosions", "desc": "Explosive bricks chain react.",      "key": "double_explosions"},
	{"name": "Multiball Start",   "desc": "You start with three balls!",        "key": "multiball_start"},
]

var seed_value: int = 0
var modifier: Dictionary = {}
var is_active: bool = false

func get_daily_seed() -> int:
	var unix = int(Time.get_unix_time_from_system())
	return unix / 86400

func setup() -> void:
	seed_value = get_daily_seed()
	seed(seed_value)
	var idx = seed_value % MODIFIERS.size()
	modifier = MODIFIERS[idx]

func generate_level() -> Array:
	seed(seed_value)
	var rows = 6
	var cols = 9
	var grid = []
	var weights = {"B": 50, "S": 20, "E": 10, "U": 5, ".": 15}
	var pool = []
	for k in weights:
		for i in range(weights[k]):
			pool.append(k)
	
	for r in range(rows):
		var half = []
		var half_size = cols / 2
		for c in range(half_size):
			half.append(pool[randi() % pool.size()])
		
		# Peilaa rivi
		var row = half.duplicate()
		if cols % 2 == 1:
			row.append(pool[randi() % pool.size()])
		var mirrored = half.duplicate()
		mirrored.reverse()
		row.append_array(mirrored)
		grid.append(row)
	
	return grid
