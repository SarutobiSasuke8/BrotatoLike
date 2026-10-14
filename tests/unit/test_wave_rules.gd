extends "res://tests/TestCase.gd"

const WaveRules = preload("res://scripts/logic/WaveRules.gd")


func test_wave_constants_match_original_timing() -> void:
	assert_eq(WaveRules.WAVE_DURATION, 60.0)
	assert_eq(WaveRules.FIRST_SPAWN_DELAY, 1.5)


func test_spawn_interval_shrinks_per_wave() -> void:
	assert_almost_eq(WaveRules.spawn_interval(0), 2.0)
	assert_almost_eq(WaveRules.spawn_interval(1), 1.9)
	assert_almost_eq(WaveRules.spawn_interval(5), 1.5)
	assert_almost_eq(WaveRules.spawn_interval(10), 1.0)


func test_spawn_interval_is_floored() -> void:
	assert_almost_eq(WaveRules.spawn_interval(17), 0.3)
	assert_almost_eq(WaveRules.spawn_interval(25), 0.3)
	assert_almost_eq(WaveRules.spawn_interval(1000), 0.3)


func test_spawn_interval_matches_original_formula() -> void:
	for wave in range(0, 40):
		var original: float = max(0.3, 2.0 - wave * 0.1)
		assert_eq(WaveRules.spawn_interval(wave), original, "wave %d" % wave)


func test_enemy_type_thresholds() -> void:
	assert_eq(WaveRules.enemy_type_for_roll(0.0), "speeder")
	assert_eq(WaveRules.enemy_type_for_roll(0.2499), "speeder")
	assert_eq(WaveRules.enemy_type_for_roll(0.25), "tank")
	assert_eq(WaveRules.enemy_type_for_roll(0.3999), "tank")
	assert_eq(WaveRules.enemy_type_for_roll(0.40), "normal")
	assert_eq(WaveRules.enemy_type_for_roll(0.9999), "normal")


func test_enemy_type_distribution_over_uniform_rolls() -> void:
	var counts := {"speeder": 0, "tank": 0, "normal": 0}
	for i in range(1000):
		counts[WaveRules.enemy_type_for_roll(i / 1000.0)] += 1
	assert_eq(counts.speeder, 250)
	assert_eq(counts.tank, 150)
	assert_eq(counts.normal, 600)


func test_display_seconds_rounds_up_and_never_goes_negative() -> void:
	assert_eq(WaveRules.display_seconds(60.0), 60)
	assert_eq(WaveRules.display_seconds(59.2), 60)
	assert_eq(WaveRules.display_seconds(0.01), 1)
	assert_eq(WaveRules.display_seconds(0.0), 0)
	assert_eq(WaveRules.display_seconds(-1.5), 0)


func test_wave_over() -> void:
	assert_false(WaveRules.is_wave_over(0.01))
	assert_true(WaveRules.is_wave_over(0.0))
	assert_true(WaveRules.is_wave_over(-0.5))
