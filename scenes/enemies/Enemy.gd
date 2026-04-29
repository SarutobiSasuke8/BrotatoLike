extends CharacterBody2D

@export var speed := 80.0
@export var health := 30
@export var damage := 10
@export var xp_value := 5
@export var gold_value := 2

var body_color := Color(0.85, 0.18, 0.18)
var body_radius := 14.0
var player: Node2D = null
var contact_timer := 0.0
const CONTACT_RATE := 0.5

func setup_type(type: String, wave: int) -> void:
	var hp_scale := 1.0 + wave * 0.15
	var dmg_scale := 1.0 + wave * 0.10
	match type:
		"speeder":
			speed = 160.0
			health = int(15 * hp_scale)
			damage = int(8 * dmg_scale)
			xp_value = 3
			gold_value = 1
			body_color = Color(0.95, 0.55, 0.10)
			body_radius = 10.0
		"tank":
			speed = 45.0
			health = int(80 * hp_scale)
			damage = int(20 * dmg_scale)
			xp_value = 15
			gold_value = 5
			body_color = Color(0.45, 0.10, 0.70)
			body_radius = 20.0
		_:
			health = int(health * hp_scale)
			damage = int(damage * dmg_scale)
	var shape_node := get_node_or_null("CollisionShape2D")
	if shape_node and shape_node.shape is CircleShape2D:
		shape_node.shape = shape_node.shape.duplicate()
		(shape_node.shape as CircleShape2D).radius = body_radius
	queue_redraw()

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	velocity = (player.global_position - global_position).normalized() * speed
	move_and_slide()

	contact_timer -= delta
	if contact_timer <= 0.0:
		for i in range(get_slide_collision_count()):
			var col := get_slide_collision(i)
			if col and col.get_collider() and col.get_collider().is_in_group("player"):
				col.get_collider().take_damage(damage)
				contact_timer = CONTACT_RATE
				break

func _draw() -> void:
	draw_circle(Vector2.ZERO, body_radius, body_color)
	draw_arc(Vector2.ZERO, body_radius, 0.0, TAU, 32, body_color.darkened(0.45), 2.5)
	var ex := body_radius * 0.36
	var ey := -body_radius * 0.29
	var er := body_radius * 0.22
	draw_circle(Vector2(-ex, ey), er, Color.WHITE)
	draw_circle(Vector2(ex, ey), er, Color.WHITE)
	draw_circle(Vector2(-ex, ey), er * 0.5, Color.BLACK)
	draw_circle(Vector2(ex, ey), er * 0.5, Color.BLACK)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	GameState.add_xp(xp_value)
	GameState.add_gold(gold_value)
	queue_free()
