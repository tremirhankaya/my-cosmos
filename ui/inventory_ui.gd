extends Control

# Hiyerarşiye göre yolu güncelledim. 
# Eğer script InventoryUi üzerindeyse yol: GridContainer/SlotGrid olmalı
@onready var slot_grid: GridContainer = $GridContainer/SlotGrid

var slot_panels: Array = []

func _ready() -> void:
	# UI'ın ekranın ortasında durmasını kodla garantiye alalım
	set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	
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

	for i in Inventory.SLOT_COUNT:
		var panel = Panel.new()
		# Slot boyutlarını belirle
		panel.custom_minimum_size = Vector2(64, 64) 
		
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		# Label'ın panelin tamamını kaplamasını sağla
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.text = ""
		
		panel.add_child(label)
		slot_grid.add_child(panel)
		slot_panels.append(panel)

func _refresh() -> void:
	# Panel sayısı ile envanter verisi uyumlu mu kontrol et
	if slot_panels.size() < Inventory.slots.size(): return
	
	for i in range(Inventory.slots.size()):
		var slot = Inventory.slots[i]
		var label = slot_panels[i].get_child(0) as Label
		
		if slot["item"] != "":
			label.text = str(slot["item"]) + "\n" + str(slot["quantity"])
		else:
			label.text = ""

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Escape tuşu vb.
		visible = !visible
		if visible:
			_refresh() # Menü açıldığında her zaman tazele
