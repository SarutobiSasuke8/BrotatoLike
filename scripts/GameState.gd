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

func add_xp(amount: int) -> void:
	xp += int(amount * stats.xp_mult)
	emit_signal("xp_changed", xp, xp_to_next)
	while xp >= xp_to_next:
		xp -= xp_to_next
		xp_to_next = int(xp_to_next * 1.4)
		player_level += 1

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
