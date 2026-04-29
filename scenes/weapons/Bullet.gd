extends Area2D

var direction := Vector2.RIGHT
var speed := 400.0
var damage := 15
var lifetime := 3.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(dir: Vector2, spd: float, dmg: int) -> void:
	direction = dir
	speed = spd
	damage = dmg

func _process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.9, 0.1))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
