extends "res://tests/TestCase.gd"

const ShopRules = preload("res://scripts/logic/ShopRules.gd")
const GameStateScript = preload("res://scripts/GameState.gd")


func _pool() -> Array:
	return GameStateScript.UPGRADES


func test_roll_offers_returns_three_distinct_pool_items() -> void:
	for i in range(50):
		var offers := ShopRules.roll_offers(_pool())
		assert_eq(offers.size(), 3)
		var labels := {}
		for offer in offers:
			assert_true(_pool().has(offer), "offer comes from the pool")
			labels[offer.label] = true
		assert_eq(labels.size(), 3, "offers are distinct")


func test_roll_offers_does_not_modify_pool() -> void:
	var pool := _pool().duplicate(true)
	var before := pool.duplicate(true)
	ShopRules.roll_offers(pool)
	assert_eq(pool, before)


func test_roll_offers_caps_at_pool_size() -> void:
	var small := [{"label": "A", "stat": "speed", "value": 1.0, "cost": 1}, {"label": "B", "stat": "armor", "value": 1, "cost": 1}]
	assert_eq(ShopRules.roll_offers(small).size(), 2)
	assert_eq(ShopRules.roll_offers([]).size(), 0)


func test_seeded_rolls_are_deterministic() -> void:
	var a := RandomNumberGenerator.new()
	a.seed = 1234
	var b := RandomNumberGenerator.new()
	b.seed = 1234
	assert_eq(ShopRules.roll_offers(_pool(), 3, a), ShopRules.roll_offers(_pool(), 3, b))


func test_seeded_rolls_reach_every_upgrade() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var seen := {}
	for i in range(200):
		for offer in ShopRules.roll_offers(_pool(), 3, rng):
			seen[offer.label] = true
	assert_eq(seen.size(), _pool().size())


func test_affordability_and_purchase() -> void:
	var upgrade := {"label": "+5 Damage", "stat": "damage", "value": 5, "cost": 10}
	assert_false(ShopRules.can_afford(9, upgrade))
	assert_true(ShopRules.can_afford(10, upgrade))
	assert_eq(ShopRules.gold_after_purchase(9, upgrade), -1)
	assert_eq(ShopRules.gold_after_purchase(10, upgrade), 0)
	assert_eq(ShopRules.gold_after_purchase(25, upgrade), 15)


func test_apply_upgrade_adds_value_to_stat() -> void:
	var gs = GameStateScript.new()
	gs.reset()
	for upgrade in _pool():
		var before = gs.stats[upgrade.stat]
		gs.apply_upgrade(upgrade)
		assert_almost_eq(float(gs.stats[upgrade.stat]), float(before + upgrade.value), 0.0001, upgrade.label)
	gs.free()


func test_upgrade_pool_is_well_formed() -> void:
	var gs = GameStateScript.new()
	gs.reset()
	assert_eq(_pool().size(), 8)
	for upgrade in _pool():
		assert_true(gs.stats.has(upgrade.stat), "%s targets a real stat" % upgrade.label)
		assert_true(int(upgrade.cost) > 0, "%s has a positive cost" % upgrade.label)
	gs.free()
