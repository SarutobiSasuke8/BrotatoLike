extends RefCounted
## Pure XP, levelling and reward scaling rules.

const STARTING_XP_TO_NEXT := 10
const GROWTH := 1.4


## XP needed for the level after one that needed `current_to_next`.
static func next_threshold(current_to_next: int) -> int:
	return int(current_to_next * GROWTH)


## XP actually granted after the XP multiplier (truncated, as in the original game).
static func scaled_xp(amount: int, xp_mult: float) -> int:
	return int(amount * xp_mult)


## Gold actually granted after the gold multiplier (truncated).
static func scaled_gold(amount: int, gold_mult: float) -> int:
	return int(amount * gold_mult)


## Applies `gained` XP (already scaled) and returns the new progression state:
## {"xp", "xp_to_next", "level", "levels_gained"}.
static func apply_xp(xp: int, xp_to_next: int, level: int, gained: int) -> Dictionary:
	var new_xp := xp + gained
	var to_next := xp_to_next
	var new_level := level
	while new_xp >= to_next:
		new_xp -= to_next
		to_next = next_threshold(to_next)
		new_level += 1
	return {
		"xp": new_xp,
		"xp_to_next": to_next,
		"level": new_level,
		"levels_gained": new_level - level,
	}
