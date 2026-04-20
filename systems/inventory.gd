extends Node

const SLOT_COUNT = 54

var slots: Array = []

signal inventory_changed

func _ready() -> void:
	slots.resize(SLOT_COUNT)
	for i in SLOT_COUNT:
		slots[i] = {"item": "", "quantity": 0}

func add_item(item_name: String, amount: int = 1) -> bool:
	# Önce aynı item varsa üstüne ekle
	for slot in slots:
		if slot["item"] == item_name:
			slot["quantity"] += amount
			inventory_changed.emit()
			return true
	# Boş slot bul
	for slot in slots:
		if slot["item"] == "":
			slot["item"] = item_name
			slot["quantity"] = amount
			inventory_changed.emit()
			return true
	return false  # Envanter dolu

func remove_item(item_name: String, amount: int = 1) -> bool:
	for slot in slots:
		if slot["item"] == item_name and slot["quantity"] >= amount:
			slot["quantity"] -= amount
			if slot["quantity"] == 0:
				slot["item"] = ""
			inventory_changed.emit()
			return true
	return false  # Yeterli item yok

func has_item(item_name: String, amount: int = 1) -> bool:
	for slot in slots:
		if slot["item"] == item_name and slot["quantity"] >= amount:
			return true
	return false

func get_quantity(item_name: String) -> int:
	for slot in slots:
		if slot["item"] == item_name:
			return slot["quantity"]
	return 0
