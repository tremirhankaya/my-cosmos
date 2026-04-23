extends PanelContainer

var target_slot_index: int = -1

var info_label: Label
var slider: HSlider
var amount_label: Label

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(200, 130)
	z_index = 101

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

	info_label = Label.new()
	info_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(info_label)

	slider = HSlider.new()
	slider.custom_minimum_size = Vector2(180, 20)
	slider.step = 1
	slider.value_changed.connect(_on_slider_changed)
	vbox.add_child(slider)

	amount_label = Label.new()
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	amount_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(amount_label)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var confirm_btn = Button.new()
	confirm_btn.text = "OK"
	confirm_btn.custom_minimum_size = Vector2(60, 28)
	confirm_btn.pressed.connect(_on_confirm)
	hbox.add_child(confirm_btn)
	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(60, 28)
	cancel_btn.pressed.connect(_on_cancel)
	hbox.add_child(cancel_btn)
	vbox.add_child(hbox)

	add_child(vbox)

func open(slot_index: int) -> void:
	var slot = Inventory.slots[slot_index]
	if slot["item"] == "" or slot["quantity"] <= 1:
		return
	if Inventory.is_holding():
		return
	target_slot_index = slot_index

	info_label.text = slot["item"] + " (" + str(slot["quantity"]) + ")"
	slider.min_value = 1
	slider.max_value = slot["quantity"] - 1
	slider.value = int(slot["quantity"] / 2)
	amount_label.text = str(int(slider.value))

	position = get_viewport().get_mouse_position() - Vector2(100, 70)
	visible = true

func _on_slider_changed(value: float) -> void:
	amount_label.text = str(int(value))

func _on_confirm() -> void:
	Inventory.pickup_partial(target_slot_index, int(slider.value))
	visible = false

func _on_cancel() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_cancel()
		get_viewport().set_input_as_handled()
