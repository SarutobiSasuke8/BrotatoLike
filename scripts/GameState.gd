extends Node

signal health_changed(current: int, maximum: int)
signal gold_changed(amount: int)
signal xp_changed(current: int, next_level: int)

var wave: int = 1
var gold: int = 0
var xp: int = 0
var xp_to_next: int = 10
var player_level: int = 1

var stats := {
	"max_health": 100,
	"speed": 200.0,
	"damage": 15,
	"fire_rate": 1.0,
	"bullet_speed": 400.0,
	"armor": 0,
	"xp_mult": 1.0,
	"gold_mult": 1.0,
}

const UPGRADES = [
	{"label": "+25 Max HP",       "stat": "max_health",   "value": 25,   "cost": 8},
	{"label": "+5 Damage",        "stat": "damage",       "value": 5,    "cost": 10},
	{"label": "+0.3 Fire Rate",   "stat": "fire_rate",    "value": 0.3,  "cost": 12},
	{"label": "+30 Speed",        "stat": "speed",        "value": 30.0, "cost": 6},
	{"label": "+2 Armor",         "stat": "armor",        "value": 2,    "cost": 8},
	{"label": "+80 Bullet Speed", "stat": "bullet_speed", "value": 80.0, "cost": 7},
	{"label": "+20% XP",          "stat": "xp_mult",      "value": 0.2,  "cost": 5},
	{"label": "+20% Gold",        "stat": "gold_mult",    "value": 0.2,  "cost": 5},
]

func apply_upgrade(upgrade: Dictionary) -> void:
	stats[upgrade.stat] += upgrade.value

func add_xp(amount: int) -> void:
	xp += int(amount * stats.xp_mult)
	while xp >= xp_to_next:
		xp -= xp_to_next
		xp_to_next = int(xp_to_next * 1.4)
		player_level += 1
	emit_signal("xp_changed", xp, xp_to_next)

func add_gold(amount: int) -> void:
	gold += int(amount * stats.gold_mult)
	emit_signal("gold_changed", gold)

func reset() -> void:
	wave = 1
	gold = 0
	xp = 0
	xp_to_next = 10
	player_level = 1
	stats = {
		"max_health": 100,
		"speed": 200.0,
		"damage": 15,
		"fire_rate": 1.0,
		"bullet_speed": 400.0,
		"armor": 0,
		"xp_mult": 1.0,
		"gold_mult": 1.0,
	}
