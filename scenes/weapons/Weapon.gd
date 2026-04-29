extends Node2D

const BULLET_SCENE = preload("res://scenes/weapons/Bullet.tscn")

var fire_timer := 0.0

func _process(delta: float) -> void:
	fire_timer -= delta
	if fire_timer <= 0.0:
		_shoot()
		fire_timer = 1.0 / GameState.stats.fire_rate

func _shoot() -> void:
	var target := _nearest_enemy()
	if target == null:
		return
	var bullet := BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(
		(target.global_position - global_position).normalized(),
		GameState.stats.bullet_speed,
		GameState.stats.damage
	)

func _nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist := INF
	for e in enemies:
		var d := global_position.distance_squared_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	return nearest
