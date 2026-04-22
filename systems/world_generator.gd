extends Node

const TILE_SIZE = 32
const WORLD_TILES = 400

var tree_scene = preload("res://prefabs/tree_.tscn")
var rock_scene = preload("res://prefabs/rock_.tscn")
var fiber_scene = preload("res://prefabs/fiber_.tscn")

var noise = FastNoiseLite.new()

@onready var tilemap: TileMapLayer = get_node("/root/World/Ground")

func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.05
	_paint_ground()
	_generate_world()

func _paint_ground() -> void:
	for x in range(WORLD_TILES):
		for y in range(WORLD_TILES):
			tilemap.set_cell(Vector2i(x, y), 5, Vector2i(0, 0))

func _generate_world() -> void:
	var world = get_parent()
	var tree_count = 0
	var rock_count = 0
	var fiber_count = 0

	for i in range(150):
		var pos = _random_grid_pos()
		var val = noise.get_noise_2d(pos.x, pos.y)

		if val > 0.1:
			_spawn(tree_scene, pos, world)
			tree_count += 1
		elif val > 0.0:
			_spawn(rock_scene, pos, world)
			rock_count += 1
		else:
			_spawn(fiber_scene, pos, world)
			fiber_count += 1

	print("Agac: ", tree_count, " | Rock: ", rock_count, " | Fiber: ", fiber_count)

func _random_grid_pos() -> Vector2:
	var x = randi_range(0, WORLD_TILES - 1) * TILE_SIZE
	var y = randi_range(0, WORLD_TILES - 1) * TILE_SIZE
	return Vector2(x, y)

func _spawn(scene: PackedScene, pos: Vector2, parent: Node) -> void:
	var node = scene.instantiate()
	node.position = pos
	parent.add_child.call_deferred(node)
