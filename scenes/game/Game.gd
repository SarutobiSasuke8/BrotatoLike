extends Node2D

const PLAYER_SCENE = preload("res://scenes/player/Player.tscn")
const ENEMY_SCENE = preload("res://scenes/enemies/Enemy.tscn")

const WAVE_DURATION := 60.0
const BASE_SPAWN_INTERVAL := 2.0

var player: Node2D
var wave_timer := 0.0
var spawn_timer := 0.0

var hud_health: Label
var hud_wave: Label
var hud_gold: Label
var hud_timer: Label
var hud_level: Label

func _ready() -> void:
	GameState.reset()
	_setup_background()
	_setup_hud()

	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = get_viewport_rect().size / 2

	GameState.health_changed.connect(_on_health_changed)
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.xp_changed.connect(_on_xp_changed)

	_start_wave()

func _process(delta: float) -> void:
	wave_timer -= delta
	spawn_timer -= delta

	hud_timer.text = "⏱ %d" % max(0, ceili(wave_timer))

	if spawn_timer <= 0.0:
		_spawn_enemy()
		spawn_timer = max(0.3, BASE_SPAWN_INTERVAL - GameState.wave * 0.1)

	if wave_timer <= 0.0:
		_end_wave()

func _start_wave() -> void:
	wave_timer = WAVE_DURATION
	spawn_timer = 1.5
	hud_wave.text = "Wave %d" % GameState.wave

func _end_wave() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	GameState.wave += 1
	_start_wave()
	# TODO: open shop between waves

func _spawn_enemy() -> void:
	var enemy = ENEMY_SCENE.instantiate()
	add_child(enemy)
	var vp := get_viewport_rect().size
	var side := randi() % 4
	var positions := [
		Vector2(randf_range(0.0, vp.x), -40.0),
		Vector2(randf_range(0.0, vp.x), vp.y + 40.0),
		Vector2(-40.0, randf_range(0.0, vp.y)),
		Vector2(vp.x + 40.0, randf_range(0.0, vp.y)),
	]
	enemy.global_position = positions[side]
	enemy.health = int(enemy.health * (1.0 + GameState.wave * 0.15))
	enemy.damage = int(enemy.damage * (1.0 + GameState.wave * 0.1))

func _setup_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.10, 0.13)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)

func _setup_hud() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var bar := HBoxContainer.new()
	canvas.add_child(bar)
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.add_theme_constant_override("separation", 30)

	hud_health = _make_label("HP: 100/100")
	hud_wave   = _make_label("Wave 1")
	hud_gold   = _make_label("Gold: 0")
	hud_timer  = _make_label("⏱ 60")
	hud_level  = _make_label("Lv 1")

	for lbl in [hud_health, hud_wave, hud_gold, hud_timer, hud_level]:
		bar.add_child(lbl)

func _make_label(txt: String) -> Label:
	var lbl := Label.new()
	lbl.text = txt
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return lbl

func _on_health_changed(current: int, maximum: int) -> void:
	hud_health.text = "HP: %d/%d" % [current, maximum]

func _on_gold_changed(amount: int) -> void:
	hud_gold.text = "Gold: %d" % amount

func _on_xp_changed(_current: int, _next: int) -> void:
	hud_level.text = "Lv %d" % GameState.player_level
