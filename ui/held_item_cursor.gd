extends Control

var icon: TextureRect
var label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100
	visible = false
	custom_minimum_size = Vector2(48, 48)

	icon = TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(40, 40)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.visible = false
	add_child(icon)

	label = Label.new()
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1, 1, 0.8))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = Vector2(0, 42)
	add_child(label)

	Inventory.held_item_changed.connect(_on_held_changed)

func _on_held_changed() -> void:
	if Inventory.is_holding():
		var icon_path = ItemDB.get_icon(Inventory.held_item)
		if icon_path != "":
			icon.texture = load(icon_path)
			icon.visible = true
			label.text = "x" + str(Inventory.held_quantity)
		else:
			icon.visible = false
			icon.texture = null
			label.text = Inventory.held_item + "\nx" + str(Inventory.held_quantity)
		visible = true
	else:
		visible = false
		icon.visible = false
		icon.texture = null

func _process(_delta: float) -> void:
	if visible:
		position = get_viewport().get_mouse_position() + Vector2(12, 12)
