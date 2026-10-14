extends "res://tests/TestCase.gd"

const EnemyScaling = preload("res://scripts/logic/EnemyScaling.gd")

const NORMAL_BASE := {"speed": 80.0, "health": 30, "damage": 10, "xp_value": 5, "gold_value": 2}


func test_scale_factors() -> void:
	assert_almost_eq(EnemyScaling.hp_scale(0), 1.0)
	assert_almost_eq(EnemyScaling.hp_scale(4), 1.6)
	assert_almost_eq(EnemyScaling.damage_scale(0), 1.0)
	assert_almost_eq(EnemyScaling.damage_scale(5), 1.5)


func test_wave_one_values() -> void:
	var normal := EnemyScaling.stats_for("normal", 1, NORMAL_BASE)
	assert_eq(normal.health, 34)
	assert_eq(normal.damage, 11)
	assert_eq(normal.speed, 80.0)
	assert_eq(normal.xp_value, 5)
	assert_eq(normal.gold_value, 2)

	var speeder := EnemyScaling.stats_for("speeder", 1, NORMAL_BASE)
	assert_eq(speeder.speed, 160.0)
	assert_eq(speeder.health, 17)
	assert_eq(speeder.damage, 8)
	assert_eq([speeder.xp_value, speeder.gold_value], [3, 1])

	var tank := EnemyScaling.stats_for("tank", 1, NORMAL_BASE)
	assert_eq(tank.speed, 45.0)
	assert_eq(tank.damage, 22)
	assert_eq([tank.xp_value, tank.gold_value], [15, 5])


func test_unknown_type_falls_back_to_normal() -> void:
	assert_eq(EnemyScaling.stats_for("mystery", 3, NORMAL_BASE), EnemyScaling.stats_for("normal", 3, NORMAL_BASE))


func test_stats_match_original_formulas_for_many_waves() -> void:
	# Mirrors the pre-refactor Enemy.setup_type arithmetic exactly.
	for wave in range(0, 40):
		var hp_scale := 1.0 + wave * 0.15
		var dmg_scale := 1.0 + wave * 0.10
		assert_eq(EnemyScaling.stats_for("speeder", wave, NORMAL_BASE).health, int(15 * hp_scale), "speeder hp wave %d" % wave)
		assert_eq(EnemyScaling.stats_for("speeder", wave, NORMAL_BASE).damage, int(8 * dmg_scale), "speeder dmg wave %d" % wave)
		assert_eq(EnemyScaling.stats_for("tank", wave, NORMAL_BASE).health, int(80 * hp_scale), "tank hp wave %d" % wave)
		assert_eq(EnemyScaling.stats_for("tank", wave, NORMAL_BASE).damage, int(20 * dmg_scale), "tank dmg wave %d" % wave)
		assert_eq(EnemyScaling.stats_for("normal", wave, NORMAL_BASE).health, int(30 * hp_scale), "normal hp wave %d" % wave)
		assert_eq(EnemyScaling.stats_for("normal", wave, NORMAL_BASE).damage, int(10 * dmg_scale), "normal dmg wave %d" % wave)


func test_enemies_get_tougher_every_wave() -> void:
	for type in ["normal", "speeder", "tank"]:
		var previous := EnemyScaling.stats_for(type, 0, NORMAL_BASE)
		for wave in range(1, 20):
			var current := EnemyScaling.stats_for(type, wave, NORMAL_BASE)
			assert_true(current.health >= previous.health, "%s hp wave %d" % [type, wave])
			assert_true(current.damage >= previous.damage, "%s dmg wave %d" % [type, wave])
			previous = current
