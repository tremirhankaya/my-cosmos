extends Area2D

@export var item_name: String = "Wood Log"
@export var amount: int = 1
@export var interaction_range: float = 64.0

var player_nearby: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = false

func interact() -> void:
	if player_nearby:
		Inventory.add_item(item_name, amount)
		queue_free()
