extends RefCounted
## Pure enemy stat scaling per type and wave.

const HP_SCALE_PER_WAVE := 0.15
const DAMAGE_SCALE_PER_WAVE := 0.10


static func hp_scale(wave: int) -> float:
	return 1.0 + wave * HP_SCALE_PER_WAVE


static func damage_scale(wave: int) -> float:
	return 1.0 + wave * DAMAGE_SCALE_PER_WAVE


## Gameplay stats for an enemy of `type` on `wave`. `base` holds the normal enemy's
## exported defaults ({"speed", "health", "damage", "xp_value", "gold_value"}), which
## the normal type scales and the other types replace.
static func stats_for(type: String, wave: int, base: Dictionary) -> Dictionary:
	var hp := hp_scale(wave)
	var dmg := damage_scale(wave)
	match type:
		"speeder":
			return {"speed": 160.0, "health": int(15 * hp), "damage": int(8 * dmg), "xp_value": 3, "gold_value": 1}
		"tank":
			return {"speed": 45.0, "health": int(80 * hp), "damage": int(20 * dmg), "xp_value": 15, "gold_value": 5}
		_:
			return {
				"speed": base.speed,
				"health": int(base.health * hp),
				"damage": int(base.damage * dmg),
				"xp_value": base.xp_value,
				"gold_value": base.gold_value,
			}
