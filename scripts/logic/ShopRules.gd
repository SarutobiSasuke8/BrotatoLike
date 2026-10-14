extends RefCounted
## Pure shop rules: rolling offers from the upgrade pool, affordability and purchase.

const OFFER_COUNT := 3


## Returns up to `count` distinct upgrades from `pool`, in random order. The pool is
## not modified. Pass an `rng` for deterministic rolls (tests); with no rng the global
## RNG is used through Array.shuffle(), exactly as the original shop did.
static func roll_offers(pool: Array, count: int = OFFER_COUNT, rng: RandomNumberGenerator = null) -> Array:
	var shuffled := pool.duplicate()
	if rng == null:
		shuffled.shuffle()
	else:
		for i in range(shuffled.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var tmp = shuffled[i]
			shuffled[i] = shuffled[j]
			shuffled[j] = tmp
	return shuffled.slice(0, min(count, shuffled.size()))


static func can_afford(gold: int, upgrade: Dictionary) -> bool:
	return gold >= int(upgrade.cost)


## Gold left after buying `upgrade`, or -1 if it cannot be afforded.
static func gold_after_purchase(gold: int, upgrade: Dictionary) -> int:
	if not can_afford(gold, upgrade):
		return -1
	return gold - int(upgrade.cost)


## Adds the upgrade's value to its stat in `stats` (mutates and returns `stats`).
static func apply_upgrade(stats: Dictionary, upgrade: Dictionary) -> Dictionary:
	stats[upgrade.stat] += upgrade.value
	return stats
