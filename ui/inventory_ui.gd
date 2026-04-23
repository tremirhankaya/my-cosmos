extends Control

# Hiyerarşiye göre yolu güncelledim. 
# Eğer script InventoryUi üzerindeyse yol: GridContainer/SlotGrid olmalı
@onready var slot_grid: GridContainer = $GridContainer/SlotGrid

var slot_panels: Array = []

func _ready() -> void:
	# UI'ın ekranın ortasında durmasını kodla garantiye alalım
	set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$GridContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_slots()
	# Sinyal kontrolü (Inventory autoload/singleton olmalı)
	if Inventory.has_signal("inventory_changed"):
		Inventory.inventory_changed.connect(_refresh)
	
	_refresh() # Başlangıçta verileri çek
	visible = false

func _build_slots() -> void:
	# Önce eski slotlar varsa temizleyelim (re-build durumları için)
	for child in slot_grid.get_children():
		child.queue_free()
	slot_panels.clear()

	for i in range(9, Inventory.SLOT_COUNT):
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

		slot_grid.add_child(panel)
		slot_panels.append(panel)

func _refresh() -> void:
	if slot_panels.size() == 0:
		return

	for i in range(slot_panels.size()):
		var slot = Inventory.slots[i + 9]
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
	if event.is_action_pressed("ui_cancel"):
		# Held item varsa once onu iptal et
		if Inventory.is_holding():
			Inventory.cancel_held()
			return
		# Crafting aciksa once onu kapat
		var crafting_ui = get_node_or_null("/root/World/HUD/CraftingUI")
		if crafting_ui and crafting_ui.visible:
			crafting_ui.close()
			return
		visible = !visible
		if visible:
			_refresh()
