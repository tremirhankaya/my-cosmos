# Astro Point — Godot 2D Oyun Projesi

## Oyun Konsepti
Top-down 2D survival/crafting oyunu. Oyuncu kaynak toplar, crafting ile itemler üretir ve sonunda gemi inşa ederek uzaya çıkmayı hedefler (Gemi Govdesi + Gemi Motoru tarifleri var).

## Proje Yapısı
```
astro-point/
├── player.gd              # CharacterBody2D, hareket + E/C tuş kontrolü
├── world.tscn             # Ana sahne
├── node_2d.tscn
├── systems/
│   ├── inventory.gd       # Autoload/Singleton — 54 slotlu envanter
│   ├── item_db.gd         # Autoload/Singleton — tüm item tanımları
│   ├── crafting_db.gd     # Autoload/Singleton — tarifler + craft mantığı
│   └── resource_node.gd   # Area2D — toplanabilir kaynak düğümü
├── ui/
│   ├── inventory_ui.gd    # Escape ile açılır, 54 slot grid
│   ├── crafting_ui.gd     # C tuşu ile açılır, station bazlı tarifler
│   ├── Inventory_ui.tscn
│   ├── CraftingUi.tscn
│   └── crafting_ui.tscn
└── prefabs/
    └── item_node.tscn
```

## Autoload / Singleton'lar
- `Inventory` → systems/inventory.gd
- `ItemDB` → systems/item_db.gd
- `CraftingDB` → systems/crafting_db.gd

## Oyun Mekanikleri

### Hareket
- WASD veya ok tuşları, hız: 200
- Dünya boyutu: 12800x12800 (400×400 tile × 32px)
- Camera2D sınırları buna göre ayarlı

### Envanter (inventory.gd)
- 54 slot
- `add_item(name, amount)`, `remove_item(name, amount)`, `has_item(name, amount)`, `get_quantity(name)`
- `inventory_changed` sinyali UI'ı günceller
- Aynı item varsa üstüne ekler, yoksa boş slot arar

### Item Tipleri (item_db.gd)
- `resource`: Wood Log, Stone, Iron Ore, Coal, Fiber, **Iron**, **Islenmis Iron**, Steel Ingot
- `tool`: Wooden/Stone/Iron Pickaxe
- `weapon`: Wooden/Stone/Iron/Steel Sword, Wooden/Stone/Iron Bow
- `material`: Paper
- `structure`: Stone Forge, Workbench, Iron Workbench, Smelter, Storage Chest, Conveyor Belt, Mining Drill, Kova, Kuyu
- `ship_part`: Gemi Govdesi, Gemi Motoru

### Metal Progression
```
Iron Ore + Coal → [Stone Forge]  → Iron
Iron + Coal     → [Smelter]      → Islenmis Iron
Islenmis Iron + Coal → [Smelter] → Steel Ingot
```

### Crafting Sistemi (crafting_db.gd)
Station türleri: `none` (elle), `stone_forge`, `workbench`, `iron_workbench`, `smelter`

Progression zinciri:
- **Elle**: Wooden Pickaxe/Axe/Sword/Bow, Wooden Arrow×10, Stone Forge
- **Workbench** (NPC'den başlangıçta verilir): Stone Pickaxe/Axe/Sword, Stone Arrow×10, Storage Chest, Iron Workbench
- **Stone Forge**: Iron (Iron Ore×3 + Coal×1)
- **Iron Workbench**: Iron Pickaxe/Axe/Sword/Bow, Iron Arrow×10, Kova, Smelter, Conveyor Belt, Gemi Govdesi
- **Smelter**: Islenmis Iron, Steel Ingot, Steel Sword, Gemi Motoru

**Tool sistemi:** tool_type: axe/pickaxe/hoe/water, tier: 1-3. resource_node'a required_tool eklenecek.
**Output sistemi:** crafting_db'de `output` alanı — oklar 10'lu, torch 3'lü üretilir.
**Tarım loop:** Wooden/Iron Hoe (toprak sürer) → Tohum ek (dünyada bulunur) → Watering Can + Kuyu/Kova → hasat → Campfire'da pişir
**Yemek:** Cooked Meat, Bread, Baked Potato — Campfire'da üretilir
**Zırh:** Leather (Hide×3) → Leather set (workbench) | Iron set (iron_workbench)
**Stations:** none, campfire, stone_forge, workbench, iron_workbench, smelter

### Tuş Kontrolleri
- `E` → yakındaki resource_node ile etkileşim
- `C` → crafting menüsünü aç/kapat
- `Escape` → envanter aç/kapat

### Resource Node (resource_node.gd)
- Area2D tabanlı
- `item_name`, `amount`, `interaction_range` export edilmiş
- Oyuncu yakına girince `player_nearby = true`, E'ye basınca item envantere eklenir ve node silinir

## Geliştirme Notları
- Kullanıcı Godot öğreniyor, detaylı açıklama faydalı
- Temel mekanikler hazır: hareket, envanter, crafting, resource toplama
- Sonraki hedef: oyun mekaniklerini genişletmek (smelter, savaş, gemi, vb.)
