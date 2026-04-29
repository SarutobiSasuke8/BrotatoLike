extends CharacterBody2D

@export var speed := 80.0
@export var health := 30
@export var damage := 10
@export var xp_value := 5
@export var gold_value := 2

var player: Node2D = null
var contact_timer := 0.0
const CONTACT_RATE := 0.5

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
	draw_circle(Vector2.ZERO, 14.0, Color(0.85, 0.18, 0.18))
	draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 32, Color(0.5, 0.05, 0.05), 2.5)
	# Angry eyes
	draw_circle(Vector2(-5, -4), 3.0, Color.WHITE)
	draw_circle(Vector2(5, -4), 3.0, Color.WHITE)
	draw_circle(Vector2(-5, -4), 1.5, Color.BLACK)
	draw_circle(Vector2(5, -4), 1.5, Color.BLACK)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	GameState.add_xp(xp_value)
	GameState.add_gold(gold_value)
	queue_free()
