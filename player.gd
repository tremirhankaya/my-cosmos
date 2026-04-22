extends CharacterBody2D

const SPEED = 200.0

# 400x400 tile * 32px = 12800x12800
const WORLD_SIZE = Vector2(12800, 12800)

@onready var camera: Camera2D = $Camera2D
var hotbar = null
var place_warning = null
var _warning_timer: float = 0.0

var station_scene: PackedScene = preload("res://prefabs/work_bench.tscn")

func _ready() -> void:
	add_to_group("player")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(WORLD_SIZE.x)
	camera.limit_bottom = int(WORLD_SIZE.y)
	Inventory.add_item("Workbench", 1)
	hotbar = get_node("/root/World/HUD/Hotbar")
	place_warning = get_node("/root/World/HUD/PlaceWarning")
	place_warning.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			_try_interact()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place()

func _try_place() -> void:
	var item_name = hotbar.get_selected_item()
	if item_name == "":
		return
	if ItemDB.get_type(item_name) != "structure":
		return
	var mouse_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	var place_pos = (mouse_pos / 32).floor() * 32
	if global_position.distance_to(mouse_pos) > 128:
		_show_warning("Too far away!")
		return
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = place_pos + Vector2(16, 16)
	query.collision_mask = 1
	query.exclude = [self.get_rid()]
	var results = space.intersect_point(query)
	if results.size() > 0:
		_show_warning("Cannot place here!")
		return
	var stations = get_tree().get_nodes_in_group("station_node")
	for s in stations:
		if s.position == place_pos:
			_show_warning("Cannot place here!")
			return
	var world = get_node("/root/World")
	var station = station_scene.instantiate()
	station.station_type = item_name.to_lower().replace(" ", "_")
	station.position = place_pos
	world.add_child(station)
	Inventory.remove_item(item_name, 1)

func _show_warning(text: String) -> void:
	place_warning.text = text
	place_warning.visible = true
	_warning_timer = 2.0

func _process(delta: float) -> void:
	if _warning_timer > 0.0:
		_warning_timer -= delta
		if _warning_timer <= 0.0:
			place_warning.visible = false

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

	velocity = direction * SPEED
	move_and_slide()
