extends CharacterBody2D

const WEAPON_SCENE = preload("res://scenes/weapons/Weapon.tscn")

var health: int

func _ready() -> void:
	add_to_group("player")
	health = GameState.stats.max_health
	var weapon := WEAPON_SCENE.instantiate()
	add_child(weapon)

func _physics_process(_delta: float) -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	velocity = dir.normalized() * GameState.stats.speed if dir != Vector2.ZERO else Vector2.ZERO
	move_and_slide()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color(0.35, 0.75, 0.20))
	draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 32, Color(0.15, 0.45, 0.05), 2.5)
	# Eyes
	draw_circle(Vector2(-6, -5), 4.0, Color.WHITE)
	draw_circle(Vector2(6, -5), 4.0, Color.WHITE)
	draw_circle(Vector2(-6, -5), 2.0, Color.BLACK)
	draw_circle(Vector2(6, -5), 2.0, Color.BLACK)

func take_damage(amount: int) -> void:
	var actual := max(1, amount - GameState.stats.armor)
	health -= actual
	GameState.emit_signal("health_changed", health, GameState.stats.max_health)
	if health <= 0:
		die()

func die() -> void:
	get_tree().reload_current_scene()
