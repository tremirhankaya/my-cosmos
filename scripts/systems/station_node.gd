extends Area2D

@export var station_type: String = "workbench"

var player_nearby: bool = false

func _ready() -> void:
	add_to_group("station_node")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		var crafting_ui = get_node("/root/World/HUD/CraftingUI")
		if crafting_ui and crafting_ui.visible and crafting_ui.current_station == station_type:
			crafting_ui.close()

func interact() -> void:
	if not player_nearby:
		return
	var crafting_ui = get_node("/root/World/HUD/CraftingUI")
	if crafting_ui == null:
		return
	if crafting_ui.visible and crafting_ui.current_station == station_type:
		crafting_ui.close()
	else:
		crafting_ui.open(station_type)
