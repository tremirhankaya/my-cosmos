extends Area2D

# ── Tool Sistemi ─────────────────────────────────────────
# required_tool_type: hangi alet kategorisi gerekli ("axe", "pickaxe", "" = el)
# min_tier: o kategoride minimum tier (1=wooden, 2=stone, 3=iron)
#
# Süre formülü:
#   çarpan = tool_tier - min_tier + 1
#   efektif süre = break_time / çarpan
# ─────────────────────────────────────────────────────────

@export var item_name: String = "Wood Log"

# ItemDB'den okunur (_ready'de)
var min_tier: int = 0
var break_time: float = 4.0
var required_tool_type: String = ""
var hand_allowed: bool = false
var drops: Array = []
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
	min_tier = data.get("min_tier", 0)
	break_time = data.get("break_time", 4.0)
	required_tool_type = data.get("required_tool_type", "")
	hand_allowed = data.get("hand_allowed", true)
	drops = data.get("drops", [])
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_create_progress_bar()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = false

# E tuşu — sadece el ile toplanabilir kaynaklar (required_tool_type yok)
func interact() -> void:
	if player_nearby and required_tool_type == "":
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

const ItemDropScript = preload("res://scripts/systems/item_drop.gd")

func _drop_and_destroy() -> void:
	for entry in drops:
		var chance = entry.get("chance", 1.0)
		if randf() > chance:
			continue
		var amount = randi_range(entry.get("min", 1), entry.get("max", 1))
		_spawn_drop(entry["item"], amount)
	queue_free()

func _spawn_drop(drop_name: String, drop_amount: int) -> void:
	var drop = Area2D.new()
	drop.set_script(ItemDropScript)
	drop.item_name = drop_name
	drop.quantity = drop_amount
	drop.position = global_position
	get_node("/root/World").call_deferred("add_child", drop)
