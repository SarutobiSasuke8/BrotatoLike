extends RefCounted
## Pure wave timing and spawn rules. No scene tree access, so it can be unit tested.

const WAVE_DURATION := 60.0
const BASE_SPAWN_INTERVAL := 2.0
const MIN_SPAWN_INTERVAL := 0.3
const SPAWN_INTERVAL_STEP := 0.1
const FIRST_SPAWN_DELAY := 1.5

## Probability thresholds for enemy types, checked against a roll in [0, 1).
const SPEEDER_CHANCE := 0.25
const TANK_CHANCE_CUMULATIVE := 0.40


## Seconds between spawns for a wave. Shrinks by 0.1 s per wave, floored at 0.3 s.
static func spawn_interval(wave: int) -> float:
	return max(MIN_SPAWN_INTERVAL, BASE_SPAWN_INTERVAL - wave * SPAWN_INTERVAL_STEP)


## Enemy type for a random roll in [0, 1): 25% speeder, 15% tank, 60% normal.
static func enemy_type_for_roll(roll: float) -> String:
	if roll < SPEEDER_CHANCE:
		return "speeder"
	if roll < TANK_CHANCE_CUMULATIVE:
		return "tank"
	return "normal"


## Seconds left to show on the HUD timer (never negative, rounded up).
static func display_seconds(wave_timer: float) -> int:
	return max(0, ceili(wave_timer))


## True once the wave timer has run out.
static func is_wave_over(wave_timer: float) -> bool:
	return wave_timer <= 0.0
