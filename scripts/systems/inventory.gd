extends Node

const SLOT_COUNT = 54

var slots: Array = []

signal inventory_changed
signal held_item_changed

# ── Held item (cursor'da tasinan item) ──
var held_item: String = ""
var held_quantity: int = 0
var held_source_slot: int = -1

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

# ── Held item methodlari ──

func is_holding() -> bool:
	return held_item != ""

func pickup_from_slot(slot_index: int) -> void:
	var slot = slots[slot_index]
	if slot["item"] == "":
		return
	held_item = slot["item"]
	held_quantity = slot["quantity"]
	held_source_slot = slot_index
	slot["item"] = ""
	slot["quantity"] = 0
	inventory_changed.emit()
	held_item_changed.emit()

func pickup_partial(slot_index: int, amount: int) -> void:
	var slot = slots[slot_index]
	if slot["item"] == "" or amount <= 0 or amount > slot["quantity"]:
		return
	held_item = slot["item"]
	held_quantity = amount
	held_source_slot = slot_index
	slot["quantity"] -= amount
	if slot["quantity"] == 0:
		slot["item"] = ""
	inventory_changed.emit()
	held_item_changed.emit()

func place_held_in_slot(slot_index: int) -> void:
	if not is_holding():
		return
	var target = slots[slot_index]

	if target["item"] == "":
		target["item"] = held_item
		target["quantity"] = held_quantity
		_clear_held()
	elif target["item"] == held_item:
		var max_stack = ItemDB.get_item(held_item).get("max_stack", 99)
		var space = max_stack - target["quantity"]
		var to_add = min(held_quantity, space)
		target["quantity"] += to_add
		held_quantity -= to_add
		if held_quantity <= 0:
			_clear_held()
		else:
			held_item_changed.emit()
	else:
		var temp_item = target["item"]
		var temp_qty = target["quantity"]
		target["item"] = held_item
		target["quantity"] = held_quantity
		held_item = temp_item
		held_quantity = temp_qty
		held_source_slot = slot_index
		held_item_changed.emit()

	inventory_changed.emit()

func cancel_held() -> void:
	if not is_holding():
		return
	if held_source_slot >= 0 and slots[held_source_slot]["item"] == "":
		slots[held_source_slot]["item"] = held_item
		slots[held_source_slot]["quantity"] = held_quantity
	elif held_source_slot >= 0 and slots[held_source_slot]["item"] == held_item:
		slots[held_source_slot]["quantity"] += held_quantity
	else:
		add_item(held_item, held_quantity)
	_clear_held()
	inventory_changed.emit()

func _clear_held() -> void:
	held_item = ""
	held_quantity = 0
	held_source_slot = -1
	held_item_changed.emit()
