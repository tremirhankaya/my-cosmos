# Astro Point — Godot 2D Oyun Projesi

> **CLAUDE İÇİN:** Bu dosyayı her konuşmanın başında oku. En son nerede kaldığımız ve ne yapılacağı burada yazar.

---

## 🔴 EN SON NEREDE KALDIK

**Tamamlanan:** Tüm item ve crafting tarifleri netleşti, item_db + crafting_db güncellendi.

**Sıradaki adım: Workbench placement mekaniği**
1. `station_node.gd` oluştur — dünyaya yerleştirilen station (E ile crafting açar)
2. Inventory UI'a "Yerleştir" butonu ekle — structure itemlere özel
3. `player.gd`'ye placement modu ekle — ghost preview + tıklayarak yerleştir
4. Oyun başlangıcında envantere Workbench ekle (NPC şimdilik kod ile)

**Sonraki büyük adımlar (sırasıyla):**
- Tool mekaniği (Axe→ağaç, Pickaxe→taş/cevher, tier sistemi)
- Dünya oluşumu (placeholder tile'lar + resource node spawn)
- Tarım sistemi
- Combat + hayvan sistemi

---

## Git
- **Repo:** https://github.com/tremirhankaya/my-cosmos
- **Aktif branch:** `dev` — geliştirme buraya, stabil → `main`

---

## Oyun Konsepti
Top-down 2D survival/crafting oyunu. Oyuncu kaynak toplar, crafting ile itemler üretir, base kurar ve sonunda gemi inşa ederek uzaya çıkar.

---

## Proje Yapısı
```
astro-point/
├── player.gd              # CharacterBody2D, hareket + E tuş kontrolü
├── world.tscn             # Ana sahne
├── systems/
│   ├── inventory.gd       # Autoload — 54 slotlu envanter
│   ├── item_db.gd         # Autoload — tüm item tanımları
│   ├── crafting_db.gd     # Autoload — tarifler + craft mantığı
│   └── resource_node.gd   # Area2D — toplanabilir kaynak düğümü
├── ui/
│   ├── inventory_ui.gd    # Escape ile açılır, 54 slot grid
│   ├── crafting_ui.gd     # Station bazlı crafting menüsü
│   ├── Inventory_ui.tscn
│   └── crafting_ui.tscn
└── prefabs/
    └── item_node.tscn
```

## Autoload / Singleton'lar
- `Inventory` → systems/inventory.gd
- `ItemDB` → systems/item_db.gd
- `CraftingDB` → systems/crafting_db.gd

---

## Oyun Mekanikleri

### Hareket
- WASD veya ok tuşları, hız: 200
- Dünya: 12800×12800 (400×400 tile × 32px)

### Envanter
- 54 slot, `inventory_changed` sinyali UI'ı günceller
- `add_item`, `remove_item`, `has_item`, `get_quantity`

### Item Tipleri
| Tip | İtemler |
|-----|---------|
| `resource` | Wood Log, Stone, Iron Ore, Coal, Fiber, Ham Iron, Islenmis Iron, Steel Ingot, Hide, Raw Meat |
| `material` | Rope, Leather, Paper |
| `seed` | Wheat Seed, Carrot Seed, Potato Seed |
| `food_raw` | Wheat, Carrot, Potato |
| `food` | Cooked Meat, Bread*, Baked Potato* |
| `consumable` | Bandage, Torch |
| `tool` | Pickaxe/Axe/Hoe (Wooden/Stone/Iron), Watering Can |
| `weapon` | Sword (Wooden/Stone/Iron/Steel), Bow (Wooden/Iron) |
| `ammo` | Wooden Arrow, Stone Arrow, Iron Arrow |
| `armor` | Leather/Iron — Helmet/Chest/Leggings |
| `structure` | Campfire, Bed, Stone Forge, Workbench, Iron Workbench, Smelter, Storage Chest, Conveyor Belt, Mining Drill, Kova, Kuyu |
| `ship_part` | Gemi Govdesi, Gemi Motoru |

*Tarım sistemi kurulunca eklenecek

### Metal Progression
```
Iron Ore + Coal  → [Stone Forge] → Ham Iron
Ham Iron + Coal  → [Smelter]     → Islenmis Iron
Islenmis Iron + Coal → [Smelter] → Steel Ingot
```

### Crafting Sistemi
Elle craft YOK — her şey station'da yapılır. Station türleri:

| Station | Nasıl edinilir | Ne üretir |
|---------|---------------|-----------|
| Workbench | NPC'den başlangıçta | Rope, Bandage, Torch, tüm ahşap/taş aletler, deri zırh, Campfire, Stone Forge, Iron Workbench |
| Campfire | Workbench'te craft | Cooked Meat |
| Stone Forge | Workbench'te craft | Ham Iron |
| Iron Workbench | Workbench'te (Ham Iron×6+Stone×4) | Iron aletler/zırh, Kova, Smelter, Kuyu, Gemi Govdesi |
| Smelter | Iron Workbench'te | Islenmis Iron, Steel Ingot, Steel Sword, Gemi Motoru |

**Tool tier sistemi:** tier 1 (Wooden), tier 2 (Stone), tier 3 (Iron)
- Axe → ağaç keser
- Pickaxe → taş/kömür (tier1+), Iron Ore (tier2 verimsiz / tier3 verimli)
- Hoe → tarla sürer
- Watering Can → sulama

**Output sistemi:** `output` alanı — Torch×3, Arrow×10 üretilir

### Tuş Kontrolleri
- `E` → yakındaki resource_node veya station ile etkileşim
- `Escape` → envanter aç/kapat

### Dünya Kaynakları (henüz implement edilmedi)
| Kaynak | Node tipi | Araç |
|--------|-----------|------|
| Wood Log | Ağaç | Axe (tier1+) |
| Stone | Taş kayalık | Pickaxe (tier1+) |
| Coal | Kömür yatağı | Pickaxe (tier1+) |
| Iron Ore | Cevher yatağı | Pickaxe (tier2+ verimsiz, tier3 verimli) |
| Fiber | Bitki | El |
| Hide + Raw Meat | Hayvan (enemy) | Combat |

---

## Geliştirici Notları
- Kullanıcı Godot öğreniyor — Godot konseptlerini açıkla
- Değişiklik yapmadan önce kullanıcıyla netleştir, sonra kodla
- Her oturum sonunda bu dosyayı güncelle
