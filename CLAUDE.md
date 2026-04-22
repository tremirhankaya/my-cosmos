# Astro Point — Godot 2D Oyun Projesi

> **CLAUDE İÇİN:** Bu dosyayı her konuşmanın başında oku. En son nerede kaldığımız ve ne yapılacağı burada yazar.

---

## 🔴 EN SON NEREDE KALDIK

**Tamamlanan:**
- Tüm item ve crafting tarifleri netleşti (item_db + crafting_db)
- station_node.gd — E ile crafting açar, uzaklaşınca kapanır
- Hotbar — ekranın altında 9 slot, 1-9 tuşlarıyla seçim
- Genel envanter 45 slot (slot 10-54), hotbar 9 slot (slot 1-9)
- Placement sistemi — hotbar'da structure seçili iken sol tıkla yerleştir
- Cannot place uyarısı — engel varsa PlaceWarning label gösterir
- world_generator.gd — noise tabanlı ağaç/rock/fiber spawn
- Çayır biome'u temel hali hazır (zemin + resource node'lar)
- Mouse pozisyonu: `get_viewport().get_camera_2d().get_global_mouse_position()`

**TEMEL KURALLAR:**
- Tüm yerleştirilebilir objeler 32x32 grid'e snap olur
- Pozisyon: `(mouse_pos / 32).floor() * 32` — tile'ın sol üst köşesi
- Z Index: zemin=0, resource node sprite=1, station sprite=0 (ağacın altında)
- Prefab path'leri: `res://prefabs/tree_.tscn`, `rock_.tscn`, `fiber_.tscn`, `work_bench.tscn`

**SIRADAKI ADIMLAR:**

### 1. Tool Mekaniği
- Axe ile ağaca vur → Wood Log düşer, ağaç yok olur
- Pickaxe ile rock'a vur → Stone düşer
- Fiber bitkisine E ile topla (zaten çalışıyor, test et)
- Tool tier sistemi

### 2. Biome Sistemi Genişletme
- Orman, Taşlık biome'ları ekle (noise tabanlı)
- Su/gölet tile'ı ekle

### 3. Tarım Sistemi
- Hoe ile toprağa vur → tarla
- Tohum ek, sula, hasat

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
