extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/Title
@onready var recipe_list: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/RecipeList
@onready var feedback_label: Label = $PanelContainer/VBoxContainer/FeedbackLabel

var current_station: String = "none"
var _feedback_timer: float = 0.0

func _ready() -> void:
	visible = false
	Inventory.inventory_changed.connect(_refresh)

func _process(delta: float) -> void:
	if _feedback_timer > 0.0:
		_feedback_timer -= delta
		if _feedback_timer <= 0.0:
			feedback_label.text = ""

func open(station: String = "none") -> void:
	current_station = station
	title_label.text = "Crafting" if station == "none" else station.capitalize()
	_refresh()
	visible = true

func close() -> void:
	visible = false

func _refresh() -> void:
	# Mevcut listeyi temizle
	for child in recipe_list.get_children():
		child.queue_free()

	for recipe_name in CraftingDB.RECIPES:
		var recipe = CraftingDB.RECIPES[recipe_name]
		if recipe["station"] != current_station:
			continue
		_add_recipe_entry(recipe_name, recipe)

func _add_recipe_entry(recipe_name: String, recipe: Dictionary) -> void:
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 2)

	# Tarif başlığı (output 1'den fazlaysa "×10" göster)
	var name_label = Label.new()
	var output = recipe.get("output", 1)
	name_label.text = recipe_name if output == 1 else "%s  ×%d" % [recipe_name, output]
	name_label.add_theme_font_size_override("font_size", 14)
	container.add_child(name_label)

	# Malzeme listesi
	var can_craft = true
	for item in recipe["ingredients"]:
		var needed: int = recipe["ingredients"][item]
		var have: int = Inventory.get_quantity(item)

		var ing_label = Label.new()
		ing_label.text = "  %s: %d/%d" % [item, have, needed]
		ing_label.add_theme_font_size_override("font_size", 11)

		if have >= needed:
			ing_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
		else:
			ing_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
			can_craft = false

		container.add_child(ing_label)

	# Craft butonu
	var btn = Button.new()
	btn.text = "Craft"
	btn.disabled = not can_craft
	btn.pressed.connect(_on_craft_pressed.bind(recipe_name))
	container.add_child(btn)

	# Ayraç
	var sep = HSeparator.new()
	container.add_child(sep)

	recipe_list.add_child(container)

func _on_craft_pressed(recipe_name: String) -> void:
	var success = CraftingDB.craft(recipe_name, current_station)
	if success:
		_show_feedback("Yapildi: " + recipe_name, true)
	else:
		_show_feedback("Malzeme yetersiz!", false)

func _show_feedback(message: String, success: bool) -> void:
	feedback_label.text = message
	if success:
		feedback_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	else:
		feedback_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	_feedback_timer = 2.0
