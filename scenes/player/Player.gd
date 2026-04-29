extends CharacterBody2D

signal died

const WEAPON_SCENE = preload("res://scenes/weapons/Weapon.tscn")

var health: int
var flash_timer := 0.0

func _ready() -> void:
	add_to_group("player")
	health = int(GameState.stats.max_health)
	var weapon := WEAPON_SCENE.instantiate()
	add_child(weapon)

func _physics_process(delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	velocity = dir.normalized() * float(GameState.stats.speed) if dir != Vector2.ZERO else Vector2.ZERO
	move_and_slide()

	var vp := get_viewport_rect().size
	global_position = global_position.clamp(Vector2(18, 18), vp - Vector2(18, 18))

	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			queue_redraw()

func _draw() -> void:
	var col := Color.RED if flash_timer > 0.0 else Color(0.35, 0.75, 0.20)
	draw_circle(Vector2.ZERO, 18.0, col)
	draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 32, col.darkened(0.45), 2.5)
	draw_circle(Vector2(-6, -5), 4.0, Color.WHITE)
	draw_circle(Vector2(6, -5), 4.0, Color.WHITE)
	draw_circle(Vector2(-6, -5), 2.0, Color.BLACK)
	draw_circle(Vector2(6, -5), 2.0, Color.BLACK)

func take_damage(amount: int) -> void:
	var actual: int = max(1, amount - int(GameState.stats.armor))
	health -= actual
	GameState.emit_signal("health_changed", health, int(GameState.stats.max_health))
	flash_timer = 0.15
	queue_redraw()
	if health <= 0:
		die()

func die() -> void:
	emit_signal("died")
