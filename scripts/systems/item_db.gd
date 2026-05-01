extends Node

const ITEMS = {
	# ── Ham maddeler ─────────────────────────────────────────────
	# break_level: 0=el, 1=wooden, 2=stone, 3=iron
	# break_time: baz kırılma süresi (saniye), tool çarpanıyla bölünür
	"Tree":      {"required_tool_type": "axe",     "min_tier": 0, "hand_allowed": true,  "break_time": 4.0, "drops": [{"item": "Wood Log", "min": 3, "max": 5}]},
	"Wood Log":  {"type": "resource", "max_stack": 99, "icon": "res://assets/items/wood_.png"},
	"Stone":     {"type": "resource", "max_stack": 99, "required_tool_type": "pickaxe", "min_tier": 0, "hand_allowed": true,  "break_time": 4.0, "icon": "res://assets/items/rock.png", "placeable": true, "prefab": "res://prefabs/rock_.tscn", "drops": [{"item": "Stone",    "min": 2, "max": 4}]},
	"Iron Ore":  {"type": "resource", "max_stack": 99, "required_tool_type": "pickaxe", "min_tier": 2, "hand_allowed": false, "break_time": 6.0, "drops": [{"item": "Iron Ore", "min": 1, "max": 2}]},
	"Coal":      {"type": "resource", "max_stack": 99, "required_tool_type": "pickaxe", "min_tier": 1, "hand_allowed": false, "break_time": 3.0, "drops": [{"item": "Coal",     "min": 1, "max": 3}]},
	"Fiber":     {"type": "resource", "max_stack": 99, "required_tool_type": "",        "min_tier": 0, "hand_allowed": true,  "break_time": 0.3, "icon": "res://assets/items/fiber.png", "placeable": false, "prefab": "res://prefabs/fiber_.tscn", "drops": [{"item": "Fiber", "min": 1, "max": 2}]},
	
	# ── İşlenmiş metaller ────────────────────────────────────────
	"Ham Iron":          {"type": "resource", "max_stack": 99},  # Iron Ore → Stone Forge
	"Islenmis Iron":     {"type": "resource", "max_stack": 99},  # Ham Iron → Smelter
	"Steel Ingot":       {"type": "resource", "max_stack": 99},  # Islenmis Iron → Smelter

	# ── Organik / hayvan dropu ───────────────────────────────────
	"Hide":              {"type": "resource", "max_stack": 99},
	"Raw Meat":          {"type": "resource", "max_stack": 30},

	# ── İşlenmiş malzeme ─────────────────────────────────────────
	"Rope":              {"type": "material", "max_stack": 99},
	"Leather":           {"type": "material", "max_stack": 99},
	"Paper":             {"type": "material", "max_stack": 99},

	# ── Tohumlar (dünyada bulunur) ───────────────────────────────
	"Wheat Seed":        {"type": "seed", "max_stack": 99},
	"Carrot Seed":       {"type": "seed", "max_stack": 99},
	"Potato Seed":       {"type": "seed", "max_stack": 99},

	# ── Hasat ────────────────────────────────────────────────────
	"Wheat":             {"type": "food_raw", "max_stack": 99},
	"Carrot":            {"type": "food_raw", "max_stack": 99},
	"Potato":            {"type": "food_raw", "max_stack": 99},

	# ── Pişmiş yemek ─────────────────────────────────────────────
	"Cooked Meat":       {"type": "food", "max_stack": 10},
	"Bread":             {"type": "food", "max_stack": 10},
	"Baked Potato":      {"type": "food", "max_stack": 10},

	# ── Sarf malzeme ─────────────────────────────────────────────
	"Bandage":           {"type": "consumable", "max_stack": 10},
	"Torch":             {"type": "consumable", "max_stack": 10},

	# ── Aletler ──────────────────────────────────────────────────
	# Kazma: Stone/Coal (tier1+), Iron Ore (tier2+ verimsiz, tier3 verimli)
	"Wooden Pickaxe":    {"type": "tool", "tool_type": "pickaxe", "tier": 1, "max_stack": 1, "max_durability": 50},
	"Stone Pickaxe":     {"type": "tool", "tool_type": "pickaxe", "tier": 2, "max_stack": 1, "max_durability": 150},
	"Iron Pickaxe":      {"type": "tool", "tool_type": "pickaxe", "tier": 3, "max_stack": 1, "max_durability": 400},
	# Balta: Wood Log keser
	"Wooden Axe":        {"type": "tool", "tool_type": "axe",     "tier": 1, "max_stack": 1, "max_durability": 50},
	"Stone Axe":         {"type": "tool", "tool_type": "axe",     "tier": 2, "max_stack": 1, "max_durability": 150},
	"Iron Axe":          {"type": "tool", "tool_type": "axe",     "tier": 3, "max_stack": 1, "max_durability": 400},
	# Çapa: toprağı sürer
	"Wooden Hoe":        {"type": "tool", "tool_type": "hoe",     "tier": 1, "max_stack": 1, "max_durability": 50},
	"Iron Hoe":          {"type": "tool", "tool_type": "hoe",     "tier": 2, "max_stack": 1, "max_durability": 200},
	# Sulama
	"Watering Can":      {"type": "tool", "tool_type": "water",   "tier": 1, "max_stack": 1, "max_durability": 100},

	# ── Silahlar ─────────────────────────────────────────────────
	"Wooden Sword":      {"type": "weapon", "max_stack": 1},
	"Stone Sword":       {"type": "weapon", "max_stack": 1},
	"Iron Sword":        {"type": "weapon", "max_stack": 1},
	"Steel Sword":       {"type": "weapon", "max_stack": 1},
	"Wooden Bow":        {"type": "weapon", "max_stack": 1},
	"Iron Bow":          {"type": "weapon", "max_stack": 1},

	# ── Oklar ────────────────────────────────────────────────────
	"Wooden Arrow":      {"type": "ammo", "max_stack": 99},
	"Stone Arrow":       {"type": "ammo", "max_stack": 99},
	"Iron Arrow":        {"type": "ammo", "max_stack": 99},

	# ── Zırh ─────────────────────────────────────────────────────
	"Leather Helmet":    {"type": "armor", "slot": "head",  "max_stack": 1},
	"Leather Chest":     {"type": "armor", "slot": "chest", "max_stack": 1},
	"Leather Leggings":  {"type": "armor", "slot": "legs",  "max_stack": 1},
	"Iron Helmet":       {"type": "armor", "slot": "head",  "max_stack": 1},
	"Iron Chest":        {"type": "armor", "slot": "chest", "max_stack": 1},
	"Iron Leggings":     {"type": "armor", "slot": "legs",  "max_stack": 1},

	# ── Yapılar / Yerleştirilebilir ──────────────────────────────
	"Campfire":          {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "",        "min_tier": 0, "break_time": 2.0, "drops": [{"item": "Campfire",       "min": 1, "max": 1}]},
	"Bed":               {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "axe",     "min_tier": 1, "break_time": 3.0, "drops": [{"item": "Bed",            "min": 1, "max": 1}]},
	"Stone Forge":       {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "pickaxe", "min_tier": 1, "break_time": 5.0, "drops": [{"item": "Stone Forge",    "min": 1, "max": 1}]},
	"Workbench":         {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "axe",     "min_tier": 1, "break_time": 4.0, "drops": [{"item": "Workbench",      "min": 1, "max": 1}]},
	"Iron Workbench":    {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "pickaxe", "min_tier": 2, "break_time": 6.0, "drops": [{"item": "Iron Workbench", "min": 1, "max": 1}]},
	"Smelter":           {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "pickaxe", "min_tier": 2, "break_time": 6.0, "drops": [{"item": "Smelter",        "min": 1, "max": 1}]},
	"Storage Chest":     {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "axe",     "min_tier": 1, "break_time": 3.0, "drops": [{"item": "Storage Chest",  "min": 1, "max": 1}]},
	"Conveyor Belt":     {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "axe",     "min_tier": 1, "break_time": 2.0, "drops": [{"item": "Conveyor Belt",  "min": 1, "max": 1}]},
	"Mining Drill":      {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "pickaxe", "min_tier": 2, "break_time": 6.0, "drops": [{"item": "Mining Drill",   "min": 1, "max": 1}]},
	"Kova":              {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "",        "min_tier": 0, "break_time": 2.0, "drops": [{"item": "Kova",           "min": 1, "max": 1}]},
	"Kuyu":              {"type": "structure", "max_stack": 1, "placeable": true, "prefab": "res://prefabs/work_bench.tscn", "breakable": true, "required_tool_type": "pickaxe", "min_tier": 1, "break_time": 4.0, "drops": [{"item": "Kuyu",           "min": 1, "max": 1}]},

	# ── Gemi parçaları (oyun sonu) ───────────────────────────────
	"Gemi Govdesi":      {"type": "ship_part", "max_stack": 1},
	"Gemi Motoru":       {"type": "ship_part", "max_stack": 1},
}

func get_item(item_name: String) -> Dictionary:
	if ITEMS.has(item_name):
		return ITEMS[item_name]
	return {}

func get_type(item_name: String) -> String:
	return get_item(item_name).get("type", "")

func is_placeable(item_name: String) -> bool:
	return get_item(item_name).get("placeable", false)

func get_prefab(item_name: String) -> String:
	return get_item(item_name).get("prefab", "")

func get_icon(item_name: String) -> String:
	return get_item(item_name).get("icon", "")
