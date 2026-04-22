extends HBoxContainer

const SLOT_COUNT = 9

var slot_panels: Array = []
var selected_slot: int = 0

func _ready() -> void:
	_build_slots()
	Inventory.inventory_changed.connect(_refresh)
	_refresh()
	_update_selection()

func _build_slots() -> void:
	for i in SLOT_COUNT:
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(64, 64)

		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.text = ""

		panel.add_child(label)
		add_child(panel)
		slot_panels.append(panel)

func _refresh() -> void:
	for i in SLOT_COUNT:
		var slot = Inventory.slots[i]
		var label = slot_panels[i].get_child(0) as Label
		if slot["item"] != "":
			label.text = str(slot["item"]) + "\n" + str(slot["quantity"])
		else:
			label.text = ""

func _update_selection() -> void:
	for i in SLOT_COUNT:
		var panel = slot_panels[i]
		if i == selected_slot:
			panel.add_theme_stylebox_override("panel", _selected_style())
		else:
			panel.remove_theme_stylebox_override("panel")

func _selected_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 0, 0.3)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 0, 1)
	return style

func get_selected_item() -> String:
	return Inventory.slots[selected_slot]["item"]

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			selected_slot = event.keycode - KEY_1
			_update_selection()
