extends "res://tests/TestCase.gd"

const LevelUpRules = preload("res://scripts/logic/LevelUpRules.gd")
const GameStateScript = preload("res://scripts/GameState.gd")

var _levels: Array = []


func test_setting_defaults_on() -> void:
	assert_true(LevelUpRules.DEFAULT_ENABLED)
	assert_true(ProjectSettings.has_setting(LevelUpRules.SETTING_PATH), "setting is declared in project.godot")
	assert_true(LevelUpRules.is_enabled())


func test_setting_can_turn_the_choice_off() -> void:
	var original = ProjectSettings.get_setting(LevelUpRules.SETTING_PATH)
	ProjectSettings.set_setting(LevelUpRules.SETTING_PATH, false)
	assert_false(LevelUpRules.is_enabled())
	ProjectSettings.set_setting(LevelUpRules.SETTING_PATH, original)
	assert_true(LevelUpRules.is_enabled())


func test_choices_are_three_distinct_shop_upgrades() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in range(50):
		var choices := LevelUpRules.roll_choices(GameStateScript.UPGRADES, rng)
		assert_eq(choices.size(), 3)
		var labels := {}
		for choice in choices:
			assert_true(GameStateScript.UPGRADES.has(choice), "choice comes from the shop pool")
			labels[choice.label] = true
		assert_eq(labels.size(), 3)


func test_levels_reached_queues_one_choice_per_level() -> void:
	assert_eq(LevelUpRules.levels_reached(1, 1), [] as Array[int])
	assert_eq(LevelUpRules.levels_reached(1, 2), [2] as Array[int])
	assert_eq(LevelUpRules.levels_reached(1, 4), [2, 3, 4] as Array[int])


func test_game_state_emits_leveled_up_for_each_level() -> void:
	var gs = GameStateScript.new()
	gs.reset()
	_levels = []
	gs.leveled_up.connect(func(level: int): _levels.append(level))
	gs.add_xp(9)
	assert_eq(_levels, [])
	gs.add_xp(1)  # reaches 10: level 2
	assert_eq(_levels, [2])
	gs.add_xp(33)  # 14 + 19 = 33: levels 3 and 4
	assert_eq(_levels, [2, 3, 4])
	gs.free()


func test_choosing_an_upgrade_applies_it_without_spending_gold() -> void:
	var gs = GameStateScript.new()
	gs.reset()
	gs.gold = 3
	var choice: Dictionary = GameStateScript.UPGRADES[1]  # +5 Damage
	gs.apply_upgrade(choice)
	assert_eq(gs.stats.damage, 20)
	assert_eq(gs.gold, 3)
	gs.free()
