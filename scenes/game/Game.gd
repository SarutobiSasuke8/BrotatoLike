extends Node2D

const PLAYER_SCENE = preload("res://scenes/player/Player.tscn")
const ENEMY_SCENE  = preload("res://scenes/enemies/Enemy.tscn")

const WAVE_DURATION      := 60.0
const BASE_SPAWN_INTERVAL := 2.0

var player: Node2D = null
var wave_timer  := 0.0
var spawn_timer := 0.0
var in_shop     := false
var shop_layer: CanvasLayer = null
var _shop_items: Array = []  # [{btn, upgrade}]

var hud_health: Label
var hud_wave:   Label
var hud_gold:   Label
var hud_timer:  Label
var hud_level:  Label
var hud_xp_bar: ProgressBar

func _ready() -> void:
	GameState.reset()
	_setup_background()
	_setup_hud()

	player = PLAYER_SCENE.instantiate()
	player.died.connect(_on_player_died)
	add_child(player)
	player.global_position = get_viewport_rect().size / 2

	GameState.health_changed.connect(_on_health_changed)
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.xp_changed.connect(_on_xp_changed)

	_start_wave()

func _process(delta: float) -> void:
	if in_shop:
		return
	wave_timer  -= delta
	spawn_timer -= delta

	hud_timer.text = "⏱ %d" % max(0, ceili(wave_timer))

	if spawn_timer <= 0.0:
		_spawn_enemy()
		spawn_timer = max(0.3, BASE_SPAWN_INTERVAL - GameState.wave * 0.1)

	if wave_timer <= 0.0:
		_end_wave()

# ── Wave flow ────────────────────────────────────────────────────────────────

func _start_wave() -> void:
	in_shop = false
	wave_timer  = WAVE_DURATION
	spawn_timer = 1.5
	hud_wave.text = "Wave %d" % GameState.wave

func _end_wave() -> void:
	wave_timer = INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	GameState.wave += 1
	_open_shop()

# ── Enemy spawning ───────────────────────────────────────────────────────────

func _spawn_enemy() -> void:
	var enemy = ENEMY_SCENE.instantiate()
	var vp    := get_viewport_rect().size
	var side  := randi() % 4
	var spawn_pos := [
		Vector2(randf_range(0.0, vp.x), -50.0),
		Vector2(randf_range(0.0, vp.x), vp.y + 50.0),
		Vector2(-50.0, randf_range(0.0, vp.y)),
		Vector2(vp.x + 50.0, randf_range(0.0, vp.y)),
	][side]
	enemy.global_position = spawn_pos
	add_child(enemy)

	var roll := randf()
	var type := "normal"
	if roll < 0.25:
		type = "speeder"
	elif roll < 0.40:
		type = "tank"
	enemy.setup_type(type, GameState.wave)

# ── Shop ─────────────────────────────────────────────────────────────────────

func _open_shop() -> void:
	in_shop = true
	_shop_items = []

	shop_layer = CanvasLayer.new()
	add_child(shop_layer)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.80)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_layer.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	panel.add_child(margin)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 14)
	margin.add_child(inner)

	var title := Label.new()
	title.text = "SHOP  —  Wave %d Complete!" % (GameState.wave - 1)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner.add_child(title)

	var gold_label := Label.new()
	gold_label.text = "Gold: %d" % GameState.gold
	gold_label.add_theme_font_size_override("font_size", 19)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.20))
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner.add_child(gold_label)

	inner.add_child(HSeparator.new())

	var pool := GameState.UPGRADES.duplicate()
	pool.shuffle()
	var offers := pool.slice(0, min(3, pool.size()))

	for upgrade in offers:
		var btn := Button.new()
		btn.text = "%s   [%d gold]" % [upgrade.label, upgrade.cost]
		btn.add_theme_font_size_override("font_size", 17)
		btn.disabled = GameState.gold < upgrade.cost
		_shop_items.append({"btn": btn, "upgrade": upgrade})
		inner.add_child(btn)

	# Connect after building the full array so each closure captures correct index
	for item in _shop_items:
		var captured_item = item
		item.btn.pressed.connect(func():
			_purchase_upgrade(captured_item, gold_label)
		)

	inner.add_child(HSeparator.new())

	var skip_btn := Button.new()
	skip_btn.text = "Continue to Wave %d  →" % GameState.wave
	skip_btn.add_theme_font_size_override("font_size", 17)
	skip_btn.pressed.connect(_close_shop)
	inner.add_child(skip_btn)

func _purchase_upgrade(item: Dictionary, gold_label: Label) -> void:
	var upgrade: Dictionary = item.upgrade
	if GameState.gold < upgrade.cost:
		return
	GameState.gold -= upgrade.cost
	GameState.apply_upgrade(upgrade)
	_on_gold_changed(GameState.gold)
	gold_label.text = "Gold: %d" % GameState.gold

	var btn: Button = item.btn
	btn.disabled = true
	btn.text = "✓  " + btn.text

	if upgrade.stat == "max_health" and player and is_instance_valid(player):
		player.health = min(player.health + upgrade.value, GameState.stats.max_health)
		GameState.health_changed.emit(player.health, GameState.stats.max_health)

	for other in _shop_items:
		if not other.btn.disabled:
			other.btn.disabled = GameState.gold < other.upgrade.cost

func _close_shop() -> void:
	if shop_layer:
		shop_layer.queue_free()
		shop_layer = null
	_shop_items = []
	_start_wave()

# ── Death ────────────────────────────────────────────────────────────────────

func _on_player_died() -> void:
	in_shop = true
	_show_game_over()

func _show_game_over() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "YOU DIED"
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color.RED)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var info := Label.new()
	info.text = "Wave %d  |  Level %d  |  %d Gold" % [GameState.wave, GameState.player_level, GameState.gold]
	info.add_theme_font_size_override("font_size", 21)
	info.add_theme_color_override("font_color", Color.WHITE)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(info)

	var btn := Button.new()
	btn.text = "Play Again"
	btn.add_theme_font_size_override("font_size", 22)
	btn.custom_minimum_size = Vector2(180, 0)
	btn.pressed.connect(func(): get_tree().reload_current_scene())
	vbox.add_child(btn)

# ── HUD ──────────────────────────────────────────────────────────────────────

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

	hud_xp_bar = ProgressBar.new()
	hud_xp_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hud_xp_bar.offset_top = -18
	hud_xp_bar.min_value = 0.0
	hud_xp_bar.max_value = 1.0
	hud_xp_bar.value = 0.0
	hud_xp_bar.show_percentage = false
	canvas.add_child(hud_xp_bar)

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
	var pct := float(current) / float(maximum)
	var col := Color.RED if pct < 0.3 else (Color(1.0, 0.65, 0.0) if pct < 0.6 else Color.WHITE)
	hud_health.add_theme_color_override("font_color", col)

func _on_gold_changed(amount: int) -> void:
	hud_gold.text = "Gold: %d" % amount

func _on_xp_changed(current: int, next: int) -> void:
	hud_level.text = "Lv %d" % GameState.player_level
	hud_xp_bar.value = float(current) / float(next)
