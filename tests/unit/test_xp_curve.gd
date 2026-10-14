extends "res://tests/TestCase.gd"

const XpCurve = preload("res://scripts/logic/XpCurve.gd")
const GameStateScript = preload("res://scripts/GameState.gd")


func test_threshold_sequence() -> void:
	var thresholds := [10]
	for i in range(4):
		thresholds.append(XpCurve.next_threshold(thresholds[-1]))
	assert_eq(thresholds, [10, 14, 19, 26, 36])


func test_xp_below_threshold_does_not_level() -> void:
	var r := XpCurve.apply_xp(0, 10, 1, 9)
	assert_eq(r.xp, 9)
	assert_eq(r.xp_to_next, 10)
	assert_eq(r.level, 1)
	assert_eq(r.levels_gained, 0)


func test_exact_threshold_levels_once() -> void:
	var r := XpCurve.apply_xp(0, 10, 1, 10)
	assert_eq(r.xp, 0)
	assert_eq(r.xp_to_next, 14)
	assert_eq(r.level, 2)
	assert_eq(r.levels_gained, 1)


func test_large_gain_levels_multiple_times_and_carries_remainder() -> void:
	var r := XpCurve.apply_xp(0, 10, 1, 25)
	assert_eq(r.xp, 1)
	assert_eq(r.xp_to_next, 19)
	assert_eq(r.level, 3)
	assert_eq(r.levels_gained, 2)


func test_scaled_rewards_truncate() -> void:
	assert_eq(XpCurve.scaled_xp(5, 1.0), 5)
	assert_eq(XpCurve.scaled_xp(3, 1.4), 4)
	assert_eq(XpCurve.scaled_xp(15, 1.2), 18)
	assert_eq(XpCurve.scaled_gold(2, 1.0), 2)
	assert_eq(XpCurve.scaled_gold(2, 1.4), 2)
	assert_eq(XpCurve.scaled_gold(5, 1.6), 8)


func test_apply_xp_matches_original_loop() -> void:
	# Replays the pre-refactor GameState.add_xp loop for many gains and compares.
	var xp := 0
	var to_next := 10
	var level := 1
	var state := {"xp": 0, "xp_to_next": 10, "level": 1}
	for gain in [3, 5, 15, 1, 40, 7, 120, 0, 9, 300]:
		xp += gain
		while xp >= to_next:
			xp -= to_next
			to_next = int(to_next * 1.4)
			level += 1
		state = XpCurve.apply_xp(state.xp, state.xp_to_next, state.level, gain)
		assert_eq([state.xp, state.xp_to_next, state.level], [xp, to_next, level], "after gain %d" % gain)


func test_game_state_add_xp_and_gold_use_multipliers() -> void:
	var gs = GameStateScript.new()
	gs.reset()
	gs.stats.xp_mult = 1.2
	gs.stats.gold_mult = 1.6
	gs.add_xp(15)  # 18 XP: level 2 with 8 carried over
	assert_eq(gs.player_level, 2)
	assert_eq(gs.xp, 8)
	assert_eq(gs.xp_to_next, 14)
	gs.add_gold(5)
	assert_eq(gs.gold, 8)
	gs.free()
