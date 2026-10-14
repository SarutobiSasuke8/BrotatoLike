extends RefCounted
## Pure rules for the level-up upgrade choice (pick 1 of 3 from the shop pool).

const ShopRules = preload("res://scripts/logic/ShopRules.gd")

## Project setting that turns the level-up choice on or off. Defaults on.
const SETTING_PATH := "brotatolike/gameplay/level_up_choice"
const DEFAULT_ENABLED := true
const CHOICE_COUNT := 3


static func is_enabled() -> bool:
	return bool(ProjectSettings.get_setting(SETTING_PATH, DEFAULT_ENABLED))


## Three distinct upgrades from the same pool the shop uses. Level-up picks are free.
static func roll_choices(pool: Array, rng: RandomNumberGenerator = null) -> Array:
	return ShopRules.roll_offers(pool, CHOICE_COUNT, rng)


## Levels reached when going from `old_level` to `new_level`, one entry per level-up,
## so a big XP gain that crosses two thresholds queues two separate choices.
static func levels_reached(old_level: int, new_level: int) -> Array[int]:
	var levels: Array[int] = []
	for level in range(old_level + 1, new_level + 1):
		levels.append(level)
	return levels
