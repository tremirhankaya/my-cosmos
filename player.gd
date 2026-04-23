extends CharacterBody2D

const SPEED = 200.0
const TILE = 32
const PLACE_RANGE = 2  # Kaç tile uzağa koyabilir (Chebyshev mesafesi)

# 400x400 tile * 32px = 12800x12800
const WORLD_SIZE = Vector2(12800, 12800)

@onready var camera: Camera2D = $Camera2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var hotbar = null
var place_warning = null
var _warning_timer: float = 0.0
var facing_dir: String = "down"

var _prefab_cache: Dictionary = {}

# ── Placement sistemi ──
var _is_placing: bool = false
var _placement_preview: Polygon2D = null
var _placement_valid: bool = false
var _place_target: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(WORLD_SIZE.x)
	camera.limit_bottom = int(WORLD_SIZE.y)
	Inventory.add_item("Workbench", 1)
	Inventory.add_item("Stone", 10)
	Inventory.add_item("Fiber", 10)
	hotbar = get_node("/root/World/HUD/Hotbar")
	place_warning = get_node("/root/World/HUD/PlaceWarning")
	place_warning.visible = false
	_create_placement_preview()

# ── Placement preview ──
func _create_placement_preview() -> void:
	_placement_preview = Polygon2D.new()
	_placement_preview.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(TILE, 0),
		Vector2(TILE, TILE), Vector2(0, TILE)
	])
	_placement_preview.color = Color(0, 1, 0, 0.4)
	_placement_preview.z_index = 10
	_placement_preview.visible = false
	get_node("/root/World").call_deferred("add_child", _placement_preview)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			_try_interact()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_placing()
		else:
			_finish_placing()

# ── Placement: basılı tut → sürükle → bırak ──
func _start_placing() -> void:
	if hotbar == null:
		return
	var item_name = hotbar.get_selected_item()
	if item_name == "":
		return
	if not ItemDB.is_placeable(item_name):
		return
	_is_placing = true
	_placement_preview.visible = true
	_update_placement_preview()

func _finish_placing() -> void:
	if not _is_placing:
		return
	_update_placement_preview()
	_is_placing = false
	_placement_preview.visible = false
	if _placement_valid:
		_do_place()
	elif _place_target != Vector2.ZERO:
		_show_warning("Cannot place here!")

func _update_placement_preview() -> void:
	var mouse_world = get_global_mouse_position()
	var target_tile = Vector2(floor(mouse_world.x / TILE), floor(mouse_world.y / TILE))
	var player_tile = Vector2(floor(global_position.x / TILE), floor(global_position.y / TILE))

	# Chebyshev mesafesi — menzil kontrolü
	var dist = max(abs(target_tile.x - player_tile.x), abs(target_tile.y - player_tile.y))
	var in_range = dist <= PLACE_RANGE and dist > 0

	_place_target = target_tile * TILE
	_placement_preview.position = _place_target

	# Çarpışma kontrolü (sadece menzildeyse hesapla)
	var is_clear = in_range and _check_tile_clear(_place_target)

	_placement_valid = in_range and is_clear
	if _placement_valid:
		_placement_preview.color = Color(0, 1, 0, 0.4)  # yeşil
	else:
		_placement_preview.color = Color(1, 0, 0, 0.4)  # kırmızı

func _check_tile_clear(pos: Vector2) -> bool:
	var center = pos + Vector2(TILE / 2, TILE / 2)
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = center
	query.collision_mask = 1
	query.exclude = [self.get_rid()]
	if space.intersect_point(query).size() > 0:
		return false
	# Station overlap — tile bazlı karşılaştır (eski/yeni pozisyon fark etmez)
	var tile = Vector2i(floor(pos.x / TILE), floor(pos.y / TILE))
	for s in get_tree().get_nodes_in_group("station_node"):
		var s_tile = Vector2i(floor(s.position.x / TILE), floor(s.position.y / TILE))
		if s_tile == tile:
			return false
	return true

func _do_place() -> void:
	var item_name = hotbar.get_selected_item()
	if item_name == "":
		return
	var prefab_path = ItemDB.get_prefab(item_name)
	if prefab_path == "":
		return
	if not _prefab_cache.has(prefab_path):
		_prefab_cache[prefab_path] = load(prefab_path)
	var node = _prefab_cache[prefab_path].instantiate()
	if "station_type" in node:
		node.station_type = item_name.to_lower().replace(" ", "_")
	node.position = _place_target + Vector2(TILE / 2, TILE / 2)
	get_node("/root/World").add_child(node)
	Inventory.remove_item(item_name, 1)

# ── UI ──
func _show_warning(text: String) -> void:
	place_warning.text = text
	place_warning.visible = true
	_warning_timer = 2.0

func _process(delta: float) -> void:
	if _warning_timer > 0.0:
		_warning_timer -= delta
		if _warning_timer <= 0.0:
			place_warning.visible = false

# ── Etkileşim ──
func _try_interact() -> void:
	var stations = get_tree().get_nodes_in_group("station_node")
	for station in stations:
		if station.player_nearby:
			station.interact()
			return
	var nodes = get_tree().get_nodes_in_group("resource_node")
	for node in nodes:
		if node.player_nearby:
			node.interact()
			return

# ── Hareket ──
func _physics_process(_delta: float) -> void:
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		if abs(direction.y) >= abs(direction.x):
			facing_dir = "down" if direction.y > 0 else "up"
		else:
			facing_dir = "right" if direction.x > 0 else "left"
		_play_anim("run_" + facing_dir)
	else:
		_play_anim("idle_" + facing_dir)

	# Placement preview her frame güncelle
	if _is_placing:
		_update_placement_preview()

	velocity = direction * SPEED
	move_and_slide()

func _play_anim(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)
