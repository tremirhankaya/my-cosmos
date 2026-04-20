extends Node

# station türleri: "workbench", "campfire", "stone_forge", "iron_workbench", "smelter"
# output: kaç adet üretilir (varsayılan 1)
const RECIPES = {

	# ── WORKBENCH ────────────────────────────────────────────────
	"Rope": {
		"ingredients": {"Fiber": 4},
		"station": "workbench",
		"output": 1
	},
	"Bandage": {
		"ingredients": {"Fiber": 3},
		"station": "workbench",
		"output": 1
	},
	"Torch": {
		"ingredients": {"Wood Log": 1, "Coal": 1},
		"station": "workbench",
		"output": 3
	},
	"Campfire": {
		"ingredients": {"Wood Log": 3, "Stone": 2, "Coal": 1},
		"station": "workbench",
		"output": 1
	},
	"Stone Forge": {
		"ingredients": {"Stone": 6, "Wood Log": 2},
		"station": "workbench",
		"output": 1
	},
	"Wooden Pickaxe": {
		"ingredients": {"Wood Log": 2, "Rope": 1},
		"station": "workbench",
		"output": 1
	},
	"Wooden Axe": {
		"ingredients": {"Wood Log": 2, "Rope": 1},
		"station": "workbench",
		"output": 1
	},
	"Wooden Sword": {
		"ingredients": {"Wood Log": 2, "Rope": 1},
		"station": "workbench",
		"output": 1
	},
	"Wooden Bow": {
		"ingredients": {"Wood Log": 2, "Rope": 1},
		"station": "workbench",
		"output": 1
	},
	"Wooden Arrow": {
		"ingredients": {"Wood Log": 1, "Fiber": 1},
		"station": "workbench",
		"output": 10
	},
	"Wooden Hoe": {
		"ingredients": {"Wood Log": 2, "Rope": 1},
		"station": "workbench",
		"output": 1
	},
	"Stone Pickaxe": {
		"ingredients": {"Wood Log": 1, "Stone": 3, "Rope": 1},
		"station": "workbench",
		"output": 1
	},
	"Stone Axe": {
		"ingredients": {"Wood Log": 1, "Stone": 3, "Rope": 1},
		"station": "workbench",
		"output": 1
	},
	"Stone Sword": {
		"ingredients": {"Wood Log": 1, "Stone": 2, "Rope": 1},
		"station": "workbench",
		"output": 1
	},
	"Stone Arrow": {
		"ingredients": {"Wood Log": 1, "Stone": 2},
		"station": "workbench",
		"output": 10
	},
	"Leather": {
		"ingredients": {"Hide": 3},
		"station": "workbench",
		"output": 1
	},
	"Leather Helmet": {
		"ingredients": {"Leather": 2},
		"station": "workbench",
		"output": 1
	},
	"Leather Chest": {
		"ingredients": {"Leather": 4},
		"station": "workbench",
		"output": 1
	},
	"Leather Leggings": {
		"ingredients": {"Leather": 3},
		"station": "workbench",
		"output": 1
	},
	"Paper": {
		"ingredients": {"Wood Log": 2},
		"station": "workbench",
		"output": 1
	},
	"Storage Chest": {
		"ingredients": {"Wood Log": 6, "Stone": 4},
		"station": "workbench",
		"output": 1
	},
	"Bed": {
		"ingredients": {"Wood Log": 5, "Fiber": 4},
		"station": "workbench",
		"output": 1
	},
	# Ham Iron (Stone Forge çıktısı) ile yapılır — Islenmis Iron GEREKMEZ
	"Iron Workbench": {
		"ingredients": {"Ham Iron":6, "Stone": 4},
		"station": "workbench",
		"output": 1
	},

	# ── CAMPFIRE ─────────────────────────────────────────────────
	"Cooked Meat": {
		"ingredients": {"Raw Meat": 1},
		"station": "campfire",
		"output": 1
	},
	# Bread ve Baked Potato tarım sistemi kurulunca eklenecek

	# ── STONE FORGE ──────────────────────────────────────────────
	"Ham Iron":{
		"ingredients": {"Iron Ore": 3, "Coal": 1},
		"station": "stone_forge",
		"output": 1
	},

	# ── IRON WORKBENCH ───────────────────────────────────────────
	"Iron Pickaxe": {
		"ingredients": {"Wood Log": 1, "Ham Iron":3, "Rope": 1},
		"station": "iron_workbench",
		"output": 1
	},
	"Iron Axe": {
		"ingredients": {"Wood Log": 1, "Ham Iron":3, "Rope": 1},
		"station": "iron_workbench",
		"output": 1
	},
	"Iron Sword": {
		"ingredients": {"Wood Log": 1, "Ham Iron":2, "Rope": 1},
		"station": "iron_workbench",
		"output": 1
	},
	"Iron Bow": {
		"ingredients": {"Wood Log": 2, "Ham Iron":2, "Rope": 2},
		"station": "iron_workbench",
		"output": 1
	},
	"Iron Arrow": {
		"ingredients": {"Ham Iron":1, "Wood Log": 1},
		"station": "iron_workbench",
		"output": 10
	},
	"Iron Hoe": {
		"ingredients": {"Wood Log": 1, "Ham Iron":2, "Rope": 1},
		"station": "iron_workbench",
		"output": 1
	},
	"Watering Can": {
		"ingredients": {"Ham Iron":3},
		"station": "iron_workbench",
		"output": 1
	},
	"Iron Helmet": {
		"ingredients": {"Ham Iron":3},
		"station": "iron_workbench",
		"output": 1
	},
	"Iron Chest": {
		"ingredients": {"Ham Iron":5},
		"station": "iron_workbench",
		"output": 1
	},
	"Iron Leggings": {
		"ingredients": {"Ham Iron":4},
		"station": "iron_workbench",
		"output": 1
	},
	"Kova": {
		"ingredients": {"Ham Iron":4},
		"station": "iron_workbench",
		"output": 1
	},
	"Smelter": {
		"ingredients": {"Ham Iron":12, "Stone": 8},
		"station": "iron_workbench",
		"output": 1
	},
	"Conveyor Belt": {
		"ingredients": {"Ham Iron":4, "Stone": 2},
		"station": "iron_workbench",
		"output": 1
	},
	"Mining Drill": {
		"ingredients": {"Islenmis Iron": 8, "Stone": 4, "Rope": 4},
		"station": "iron_workbench",
		"output": 1
	},
	"Kuyu": {
		"ingredients": {"Stone": 8, "Ham Iron":4, "Rope": 2, "Kova": 1},
		"station": "iron_workbench",
		"output": 1
	},
	"Gemi Govdesi": {
		"ingredients": {"Islenmis Iron": 20, "Stone": 10},
		"station": "iron_workbench",
		"output": 1
	},

	# ── SMELTER ──────────────────────────────────────────────────
	"Islenmis Iron": {
		"ingredients": {"Ham Iron":3, "Coal": 1},
		"station": "smelter",
		"output": 1
	},
	"Steel Ingot": {
		"ingredients": {"Islenmis Iron": 3, "Coal": 2},
		"station": "smelter",
		"output": 1
	},
	"Steel Sword": {
		"ingredients": {"Wood Log": 1, "Steel Ingot": 3, "Rope": 1},
		"station": "smelter",
		"output": 1
	},
	"Gemi Motoru": {
		"ingredients": {"Steel Ingot": 15, "Islenmis Iron": 8},
		"station": "smelter",
		"output": 1
	},
}

func can_craft(recipe_name: String, current_station: String = "none") -> bool:
	if not RECIPES.has(recipe_name):
		return false
	var recipe = RECIPES[recipe_name]
	if recipe["station"] != current_station:
		return false
	for item in recipe["ingredients"]:
		if not Inventory.has_item(item, recipe["ingredients"][item]):
			return false
	return true

func craft(recipe_name: String, current_station: String = "none") -> bool:
	if not can_craft(recipe_name, current_station):
		return false
	var recipe = RECIPES[recipe_name]
	for item in recipe["ingredients"]:
		Inventory.remove_item(item, recipe["ingredients"][item])
	var amount = recipe.get("output", 1)
	Inventory.add_item(recipe_name, amount)
	return true
