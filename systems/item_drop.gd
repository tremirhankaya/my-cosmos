extends Area2D

# ── Yerde duran item ──

var item_name: String = ""
var quantity: int = 1

var _time_alive: float = 0.0
var _bob_phase: float = 0.0
var _spawn_dir: Vector2 = Vector2.ZERO

const PICKUP_DELAY = 0.5
const SPAWN_POP_SPEED = 80.0
const SPAWN_POP_DURATION = 0.25
const DROP_SCALE = Vector2(0.5, 0.5)

func _ready() -> void:
	add_to_group("item_drop")
	_bob_phase = randf() * TAU
	var angle = randf() * TAU
	_spawn_dir = Vector2(cos(angle), sin(angle))
	_create_collision()
	_create_visual()
	# Spawn scale animasyonu
	scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	# Pickup sinyali
	body_entered.connect(_on_body_entered)

func _create_collision() -> void:
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	add_child(shape)

func _create_visual() -> void:
	var icon_path = ItemDB.get_icon(item_name)
	if icon_path != "":
		var sprite = Sprite2D.new()
		sprite.texture = load(icon_path)
		sprite.scale = DROP_SCALE
		sprite.name = "Visual"
		sprite.z_index = 5
		add_child(sprite)
	else:
		var poly = Polygon2D.new()
		poly.polygon = PackedVector2Array([
			Vector2(-6, -6), Vector2(6, -6),
			Vector2(6, 6), Vector2(-6, 6)
		])
		poly.color = Color(1, 0.85, 0.2)
		poly.name = "Visual"
		poly.z_index = 5
		add_child(poly)

func _physics_process(delta: float) -> void:
	_time_alive += delta

	# Spawn pop
	if _time_alive < SPAWN_POP_DURATION:
		var pop_strength = 1.0 - (_time_alive / SPAWN_POP_DURATION)
		position += _spawn_dir * SPAWN_POP_SPEED * pop_strength * delta

	# Yumuşak yüzme efekti
	var visual = get_node_or_null("Visual")
	if visual:
		visual.position.y = sin((_time_alive + _bob_phase) * 1.2) * 1.0
		visual.position.x = cos((_time_alive + _bob_phase) * 0.8) * 0.5

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and _time_alive >= PICKUP_DELAY:
		Inventory.add_item(item_name, quantity)
		queue_free()
