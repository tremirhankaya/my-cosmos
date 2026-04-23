extends Area2D

# ── Break Level Sistemi ──────────────────────────────────
# Level 0 = El ile kırılır (fiber, çalı)
# Level 1 = En az Wooden tool gerekir (ağaç, taş)
# Level 2 = En az Stone tool gerekir (kömür, demir cevheri)
# Level 3 = En az Iron tool gerekir (sert cevherler)
#
# Tool seviyeleri (ItemDB'deki tier):
#   0 = El (hand)
#   1 = Wooden (tahta)
#   2 = Stone (taş)
#   3 = Iron (demir)
#
# Süre formülü:
#   çarpan = tool_level - break_level + 1
#   efektif süre = break_time / çarpan
#   tool_level < break_level → kırılamaz
# ─────────────────────────────────────────────────────────

@export var item_name: String = "Wood Log"
@export var amount: int = 1

# ItemDB'den okunur (_ready'de)
var break_level: int = 0
var break_time: float = 4.0
var player_nearby: bool = false
var _progress_bg: Polygon2D = null
var _progress_fill: Polygon2D = null

const BAR_WIDTH = 32.0
const BAR_HEIGHT = 4.0
const BAR_Y = -28.0  # sprite üzerinde

func _ready() -> void:
	add_to_group("resource_node")
	# ItemDB'den break verilerini oku
	var data = ItemDB.get_item(item_name)
	break_level = data.get("break_level", 0)
	break_time = data.get("break_time", 4.0)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_create_progress_bar()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = false

# E tuşu — sadece el ile toplanabilir kaynaklar (break_level 0)
func interact() -> void:
	if player_nearby and break_level == 0:
		_drop_and_destroy()

# ── Progress bar ──
func _create_progress_bar() -> void:
	var half = BAR_WIDTH / 2.0
	_progress_bg = Polygon2D.new()
	_progress_bg.polygon = PackedVector2Array([
		Vector2(-half, BAR_Y), Vector2(half, BAR_Y),
		Vector2(half, BAR_Y + BAR_HEIGHT), Vector2(-half, BAR_Y + BAR_HEIGHT)
	])
	_progress_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	_progress_bg.z_index = 20
	_progress_bg.visible = false
	add_child(_progress_bg)

	_progress_fill = Polygon2D.new()
	_progress_fill.polygon = PackedVector2Array([
		Vector2(-half, BAR_Y), Vector2(-half, BAR_Y),
		Vector2(-half, BAR_Y + BAR_HEIGHT), Vector2(-half, BAR_Y + BAR_HEIGHT)
	])
	_progress_fill.color = Color(0, 1, 0, 0.9)
	_progress_fill.z_index = 21
	_progress_fill.visible = false
	add_child(_progress_fill)

func show_progress(ratio: float) -> void:
	_progress_bg.visible = true
	_progress_fill.visible = true
	var half = BAR_WIDTH / 2.0
	var w = BAR_WIDTH * clamp(ratio, 0.0, 1.0)
	_progress_fill.polygon = PackedVector2Array([
		Vector2(-half, BAR_Y), Vector2(-half + w, BAR_Y),
		Vector2(-half + w, BAR_Y + BAR_HEIGHT), Vector2(-half, BAR_Y + BAR_HEIGHT)
	])

func hide_progress() -> void:
	_progress_bg.visible = false
	_progress_fill.visible = false

const ItemDropScript = preload("res://systems/item_drop.gd")

func _drop_and_destroy() -> void:
	_spawn_drop(item_name, amount)
	queue_free()

func _spawn_drop(drop_name: String, drop_amount: int) -> void:
	var drop = Area2D.new()
	drop.set_script(ItemDropScript)
	drop.item_name = drop_name
	drop.quantity = drop_amount
	drop.position = global_position
	get_node("/root/World").call_deferred("add_child", drop)
