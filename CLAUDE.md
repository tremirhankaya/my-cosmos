# Astro Point — Godot 2D Oyun Projesi

> **CLAUDE İÇİN:** Bu dosyayı her konuşmanın başında oku. En son nerede kaldığımız ve ne yapılacağı burada yazar.

---

## 🔴 EN SON NEREDE KALDIK

**Tamamlanan:**
- Tüm item ve crafting tarifleri netleşti (item_db + crafting_db)
- station_node.gd — E ile crafting açar, uzaklaşınca kapanır
- Hotbar — ekranın altında 9 slot, 1-9 tuşlarıyla seçim
- Genel envanter 45 slot (slot 10-54), hotbar 9 slot (slot 1-9)
- Placement sistemi — mouse hold-drag-release ile yapı yerleştirme
- Cannot place uyarısı — engel varsa PlaceWarning label gösterir
- world_generator.gd — noise tabanlı ağaç/rock/fiber spawn
- Çayır biome'u temel hali hazır (zemin + resource node'lar)
- Break level sistemi — numeric level (0=el, 1=wood, 2=stone, 3=iron), zaman bazlı kırma
- Item drop sistemi — kırılan/atılan itemler yerde gözükür, üstünden geçince toplanır
- Q ile item atma (Q=1 adet, Alt+Q=tüm stack), baktığın yöne atılır
- **Drag-drop envanter** — slot tıkla → item cursor'a gelir → başka slot'a tıkla (taşı/merge/swap)
- **Alt+click split** — stack'i böl, slider ile miktar seç
- **Slot dışına tıklama** — held item yere düşer
- **Sağ tık iptal** — taşınan item geri döner
- **Item ikonları** — icon alanı olan itemler slotlarda texture ile gösteriliyor
- **Menu mutual exclusion** — envanter + crafting aynı anda açılamaz
- **Craft overflow** — envanter doluysa üretilen item yere düşer
- player.gd `_unhandled_input` kullanıyor (UI tıkları dünyaya geçmiyor)

**TEMEL KURALLAR:**
- Tüm yerleştirilebilir objeler 32x32 grid'e snap olur
- Pozisyon: `(mouse_pos / 32).floor() * 32` — tile'ın sol üst köşesi
- Z Index: zemin=0, resource node sprite=1, station sprite=0 (ağacın altında)
- Prefab path'leri: `res://prefabs/tree_.tscn`, `rock_.tscn`, `fiber_.tscn`, `work_bench.tscn`
- Prefab sprite'ları şu an `centered = true` — placement +16 offset ile düzeltiliyor (ileride centered=false yapılacak)

**SIRADAKI ADIMLAR:**

### 1. Biome Sistemi Genişletme
- Orman, Taşlık biome'ları ekle (noise tabanlı)
- Su/gölet tile'ı ekle

### 2. Tarım Sistemi
- Hoe ile toprağa vur → tarla
- Tohum ek, sula, hasat

### 3. Diğer
- Her structure için ayrı prefab (şu an hepsi work_bench.tscn kullanıyor)
- Daha fazla item'a icon ekle
- Combat sistemi (düşmanlar, vuruş, HP)

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
my-cosmos/
├── world.tscn                 # Ana sahne
├── scripts/                   # TÜM kod dosyaları (.gd) burada
│   ├── player.gd              # CharacterBody2D, hareket + placement + breaking
│   ├── systems/               # Oyun mantığı & autoload'lar
│   │   ├── inventory.gd       # Autoload — 54 slot + held item (drag-drop)
│   │   ├── item_db.gd         # Autoload — tüm item tanımları
│   │   ├── crafting_db.gd     # Autoload — tarifler + craft mantığı
│   │   ├── resource_node.gd   # Area2D — toplanabilir kaynak düğümü
│   │   ├── item_drop.gd       # Area2D — yerde duran item (pickup)
│   │   ├── station_node.gd    # Area2D — crafting station etkileşimi
│   │   └── world_generator.gd # Noise tabanlı dünya oluşturma
│   └── ui/                    # UI bileşen kodları
│       ├── inventory_ui.gd    # Escape ile açılır, 45 slot grid + drag-drop
│       ├── crafting_ui.gd     # Station bazlı crafting menüsü
│       ├── hotbar_ui.gd       # 9 slot hotbar + drag-drop
│       ├── held_item_cursor.gd # Mouse'u takip eden taşınan item görseli
│       └── split_popup.gd     # Alt+click stack bölme popup'ı
├── ui/                        # UI sahne dosyaları (.tscn)
│   ├── inventory_ui.tscn
│   └── crafting_ui.tscn
├── prefabs/                   # Prefab sahne dosyaları
│   ├── tree_.tscn, rock_.tscn, fiber_.tscn, grass_.tscn
│   ├── item_node.tscn
│   └── work_bench.tscn
└── assets/
    ├── items/                 # Item ikonları (wood_.png, rock.png, fiber.png, work_bench.png)
    ├── environment/           # Çevre sprite'ları (tree.png, grass.png)
    ├── tiles/                 # Zemin tile'ları (water.png)
    └── player/                # Oyuncu sprite sheet'leri
        └── Sprites/           # IDLE, RUN, ATTACK 1, ATTACK 2
```

## Autoload / Singleton'lar
- `Inventory` → scripts/systems/inventory.gd
- `ItemDB` → scripts/systems/item_db.gd
- `CraftingDB` → scripts/systems/crafting_db.gd

---

## Oyun Mekanikleri

### Hareket
- WASD veya ok tuşları, hız: 200
- Dünya: 12800×12800 (400×400 tile × 32px)

### Envanter
- 54 slot (0-8 hotbar, 9-53 ana envanter), `inventory_changed` sinyali UI'ı günceller
- `add_item`, `remove_item`, `has_item`, `get_quantity`
- Drag-drop: `pickup_from_slot`, `place_held_in_slot`, `cancel_held`, `pickup_partial`
- `held_item_changed` sinyali cursor label'ı günceller

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
- `Escape` → held item iptal → crafting kapat → envanter aç/kapat (sırasıyla)
- `Q` → seçili item'dan 1 adet yere at, `Alt+Q` → tüm stack'i at
- `1-9` → hotbar slot seçimi
- `Sol tık` → placement (structure) / breaking (tool/hand) / held item'ı yere at
- `Sağ tık` (slot üzerinde) → taşınan item'ı iptal et
- `Alt+Sol tık` (slot üzerinde) → stack bölme popup'ı

### Dünya Kaynakları
| Kaynak | break_level | break_time | Araç | Durum |
|--------|-------------|------------|------|-------|
| Fiber | 0 | 0.3s | El / E tuşu | Çalışıyor |
| Stone | 0 | 4.0s | El | Çalışıyor |
| Wood Log | 1 | 4.0s | Axe (tier1+) | Çalışıyor |
| Coal | 1 | 3.0s | Pickaxe (tier1+) | Prefab lazım |
| Iron Ore | 2 | 6.0s | Pickaxe (tier2+) | Prefab lazım |
| Hide + Raw Meat | — | — | Combat | Henüz yok |

---

## Asset Tasarım Notları

### Karakter & Ekipman — Katmanlı Sprite Sistemi
Zırh/ekipman giyilince karakter görünümü **katmanlı sprite** ile değişir:
```
Player
  ├── BaseBody (AnimatedSprite2D)   ← çıplak karakter
  ├── Helmet   (AnimatedSprite2D)   ← kask katmanı
  ├── Chest    (AnimatedSprite2D)   ← göğüs zırhı
  ├── Legs     (AnimatedSprite2D)   ← bacak zırhı
  ├── ArmSprite (Sprite2D)          ← kol (omuzdan döner)
  └── ToolSprite (Sprite2D)         ← ArmSprite child'ı, kolla döner
```
- Tüm AnimatedSprite2D'ler **aynı anda aynı animasyonu** oynar (idle_down, run_right vs.)
- Ekipman giyilince o katmanın texture'ı değişir ve görünür olur
- **KRİTİK:** Tüm ekipman sprite sheet'leri aynı frame boyutunda ve aynı pozisyonda çizilmeli — yoksa katmanlar kayar
- Referans format: LPC (Liberated Pixel Cup) — tüm ekipmanlar aynı grid'e göre

### Alet Animasyonu — Terraria Mantığı
- Karakter idle/run oynarken `ArmSprite` + `ToolSprite` Tween ile rotate eder
- Kırma/vurma başlayınca kol sallanır, duruncaa sıfırlanır
- `facing_dir`'e göre başlangıç açısı değişir
- Yeni alet seçilince sadece `ToolSprite.texture` güncellenir

---

## Geliştirici Notları
- Kullanıcı Godot öğreniyor — Godot konseptlerini açıkla
- Değişiklik yapmadan önce kullanıcıyla netleştir, sonra kodla
- Her oturum sonunda bu dosyayı güncelle
