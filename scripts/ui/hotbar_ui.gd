extends HBoxContainer

const SLOT_COUNT = 9

var slot_panels: Array = []
var selected_slot: int = 0

func _ready() -> void:
	_build_slots()
	Inventory.inventory_changed.connect(_refresh)
	_refresh()
	_update_selection()
	_create_cursor_label()
	_create_split_popup()

func _create_cursor_label() -> void:
	var cursor_node = Control.new()
	cursor_node.set_script(preload("res://scripts/ui/held_item_cursor.gd"))
	get_node("/root/World/HUD").call_deferred("add_child", cursor_node)

func _create_split_popup() -> void:
	var popup = PanelContainer.new()
	popup.name = "SplitPopup"
	popup.set_script(preload("res://scripts/ui/split_popup.gd"))
	get_node("/root/World/HUD").call_deferred("add_child", popup)

func _build_slots() -> void:
	for i in SLOT_COUNT:
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(64, 64)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.gui_input.connect(_on_slot_gui_input.bind(i))

		var icon = TextureRect.new()
		icon.name = "Icon"
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.visible = false
		panel.add_child(icon)

		var label = Label.new()
		label.name = "Label"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.text = ""
		panel.add_child(label)

		var qty_label = Label.new()
		qty_label.name = "Qty"
		qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		qty_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		qty_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		qty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		qty_label.add_theme_font_size_override("font_size", 11)
		qty_label.visible = false
		panel.add_child(qty_label)

		var dur_bg = ColorRect.new()
		dur_bg.name = "DurBg"
		dur_bg.color = Color(0.2, 0.2, 0.2, 0.8)
		dur_bg.size = Vector2(64, 4)
		dur_bg.position = Vector2(0, 60)
		dur_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dur_bg.visible = false
		panel.add_child(dur_bg)

		var dur_fill = ColorRect.new()
		dur_fill.name = "DurFill"
		dur_fill.size = Vector2(64, 4)
		dur_fill.position = Vector2(0, 60)
		dur_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dur_fill.visible = false
		panel.add_child(dur_fill)

		add_child(panel)
		slot_panels.append(panel)

func _refresh() -> void:
	for i in SLOT_COUNT:
		var slot = Inventory.slots[i]
		var panel = slot_panels[i]
		var icon = panel.get_node("Icon") as TextureRect
		var label = panel.get_node("Label") as Label
		var qty = panel.get_node("Qty") as Label
		if slot["item"] != "":
			var icon_path = ItemDB.get_icon(slot["item"])
			if icon_path != "":
				icon.texture = load(icon_path)
				icon.visible = true
				label.text = ""
				qty.text = str(slot["quantity"])
				qty.visible = true
			else:
				icon.visible = false
				qty.visible = false
				label.text = str(slot["item"]) + "\n" + str(slot["quantity"])
		else:
			icon.visible = false
			icon.texture = null
			qty.visible = false
			label.text = ""
	_update_durability_bar()

func _update_selection() -> void:
	for i in SLOT_COUNT:
		var panel = slot_panels[i]
		if i == selected_slot:
			panel.add_theme_stylebox_override("panel", _selected_style())
		else:
			panel.remove_theme_stylebox_override("panel")
	_update_durability_bar()

func _update_durability_bar() -> void:
	for i in SLOT_COUNT:
		var panel = slot_panels[i]
		var dur_bg = panel.get_node("DurBg")
		var dur_fill = panel.get_node("DurFill")
		if i != selected_slot:
			dur_bg.visible = false
			dur_fill.visible = false
			continue
		var slot = Inventory.slots[i]
		var durability = slot.get("durability", -1)
		if durability == -1:
			dur_bg.visible = false
			dur_fill.visible = false
			continue
		var max_dur = ItemDB.get_item(slot["item"]).get("max_durability", 1)
		var ratio = float(durability) / float(max_dur)
		dur_bg.visible = true
		dur_fill.visible = true
		dur_fill.size.x = 64.0 * ratio
		if ratio > 0.5:
			dur_fill.color = Color(0.2, 0.9, 0.2)
		elif ratio > 0.25:
			dur_fill.color = Color(0.9, 0.7, 0.1)
		else:
			dur_fill.color = Color(0.9, 0.2, 0.2)

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

func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.alt_pressed:
				_try_split(slot_index)
			elif Inventory.is_holding():
				Inventory.place_held_in_slot(slot_index)
			else:
				Inventory.pickup_from_slot(slot_index)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if Inventory.is_holding():
				Inventory.cancel_held()
				get_viewport().set_input_as_handled()

func _try_split(slot_index: int) -> void:
	var popup = get_node_or_null("/root/World/HUD/SplitPopup")
	if popup:
		popup.open(slot_index)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			selected_slot = event.keycode - KEY_1
			_update_selection()
