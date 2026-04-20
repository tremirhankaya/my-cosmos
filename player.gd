extends CharacterBody2D

const SPEED = 200.0

# 400x400 tile * 32px = 12800x12800
const WORLD_SIZE = Vector2(12800, 12800)

@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	add_to_group("player")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(WORLD_SIZE.x)
	camera.limit_bottom = int(WORLD_SIZE.y)
	crafting_ui = get_node("/root/World/HUD/CraftingUI")

var crafting_ui = null

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			_try_interact()
		if event.keycode == KEY_C:
			print("C basıldı, crafting_ui: ", crafting_ui)
			if crafting_ui == null:
				print("crafting_ui null!")
				return
			if crafting_ui.visible:
				crafting_ui.close()
			else:
				crafting_ui.open("none")

func _try_interact() -> void:
	var nodes = get_tree().get_nodes_in_group("resource_node")
	for node in nodes:
		if node.player_nearby:
			node.interact()
			return

func _physics_process(delta: float) -> void:
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
