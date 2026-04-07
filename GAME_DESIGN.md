# House Flipper - Roblox Edition: Game Design Document

## Original Game Research (Steam - House Flipper by Frozen District)

### Overview
House Flipper is a first-person simulation game where players act as a one-man renovation crew.
The core loop: **Buy rundown houses → Renovate them → Sell for profit.**
Players can also take on **renovation jobs** from clients via email to earn starting capital.

---

## CORE GAMEPLAY SYSTEMS

### 1. Tools (Unlocked Progressively via Jobs)

| Tool | Function | Unlock Method |
|------|----------|---------------|
| **Broom/Mop** | Clean dirt, stains from floors/walls | Starting tool |
| **Trash Bag** | Pick up and dispose of garbage/debris | Starting tool |
| **Paint Roller** | Paint interior/exterior walls (requires paint cans) | "Amaranth Walls" job |
| **Tiling & Paneling Tool** | Apply tiles/wood panels to walls/floors | "Necessary Extra Bathroom" job |
| **Sledgehammer** | Demolish walls | "Additional Walls" job (Thomas Johnson) |
| **Wall Builder** | Construct new walls and lintels | Same as sledgehammer |
| **Window Cleaning Tool** | Clean dirty windows (context-sensitive) | Any job requiring window cleaning |
| **Plaster Tool** | Plaster damaged walls (context-sensitive) | Any job requiring plastering |
| **Vacuum** | Clean cockroaches/broken glass | Any job requiring pest cleanup |
| **Installation Tool** | Install radiators, sinks, toilets, showers | Various jobs |

### 2. Perks / Skill Tree (7 Categories, 3 perks each, 3 levels each)

**Cleaning**
- Good Mop → Ultra Hyper Mop: Increases cleaning range
- Multiple Trash Disposal: Pick up multiple trash items at once
- Penetrating Vision: Filth shown on radar/minimap

**Painting**
- No Double Paint: Prevents applying paint to already-painted surfaces
- Paint Efficiency: Reduces paint usage by 20%/40%
- Instant Painting: Move roller faster, increases speed
- Paint More: Paint 2/3/4 stripes at once (wider roller)

**Handyman**
- Faster installations
- Pick up more tiles at once (1 → 3 → 5 → 10)
- Better plastering

**Demolition**
- Passionate Hammer Master: Swing faster
- Triceps of Steel: Stronger strikes
- Efficiency improvements

**Building**
- Mason: New walls come pre-painted in room color
- One Man Crew: Build multiple walls simultaneously
- Structural improvements

**Negotiation**
- Increase money earned from jobs
- Increase house sale value
- Reduce job requirements

**Gardener** (DLC-inspired, optional)
- Faster gardening speed
- Find weeds/molehills on radar
- Tool upgrades

### 3. Job / Mission System
- Jobs arrive via **email on the player's laptop**
- Each job has specific tasks (clean, paint, install, demolish, etc.)
- Players can complete **70% for partial pay** or **100% for full pay**
- Jobs unlock new tools progressively
- Jobs can be replayed for additional money
- Approximately 20+ jobs in the base game

### 4. House Buying & Selling
- Players browse available houses on a **tablet/laptop interface**
- Houses have fixed purchase prices
- House sizes: Small (<100m²), Medium (100-200m²), Large (>200m²)
- After renovation, houses are listed for sale
- **Buyers** make offers based on how well the house matches their preferences
- Profit = Sale Price - Purchase Price - Renovation Costs

### 5. Buyer System (13 Buyers in Original)
Each buyer has unique preferences:

| Buyer Type | Preferences |
|-----------|-------------|
| Minimalist (Chang Choi) | Cheap furniture, minimal items, expensive study furniture |
| Retired Couple (Jantarts) | Classic furniture, bigger homes |
| Bachelor (Jimmy Traitor) | Expensive furniture, no TV in bedroom, max space |
| Family | Multiple bedrooms, kid-friendly items |
| Artist | Creative/unique decorations |
| Professional | Home office, modern furniture |
| And more... | Each with unique likes/dislikes |

**Buyer satisfaction** is based on:
- Room types present
- Room sizes
- Specific furniture items
- Cleanliness
- Overall house condition
- Style matching (modern, classic, etc.)

### 6. Room Detection System
Rooms are auto-classified based on furniture placed:

| Room Type | Required Furniture (Minimum) |
|-----------|----------------------------|
| **Kitchen** | Kitchen Sink + Oven/Stove/Refrigerator (3 items) |
| **Bathroom** | Toilet + Sink + Shower/Bathtub |
| **Bedroom** | Bed + Wardrobe/Dresser |
| **Living Room** | Sofa + Coffee Table (min 11m²) |
| **Office** | Desk + Office Chair + Cabinet + Bookcase + Picture/Carpet (5 items) |
| **Dining Room** | Dining Table + Chairs |
| **Garage** | Workbench + Tool storage |
| **Laundry Room** | Washing Machine + Dryer/Ironing Board |

Room size affects classification (e.g., "Small Kitchen" <10m², "Large Kitchen" >20m²).

### 7. Furniture Catalog
Categories:
- **Kitchen**: Sinks, ovens, refrigerators, counters, cabinets, tables
- **Bathroom**: Toilets, sinks, showers, bathtubs, mirrors, towel racks
- **Bedroom**: Beds, wardrobes, dressers, nightstands, lamps
- **Living Room**: Sofas, coffee tables, TV stands, TVs, bookshelves
- **Office**: Desks, office chairs, filing cabinets, bookshelves
- **Dining**: Tables, chairs, buffets
- **Decorative**: Paintings, plants, rugs, curtains, clocks
- **Appliances**: Washing machines, dryers, radiators, AC units
- **Outdoor/Garden**: Fences, benches, planters, grills

Furniture has **style tags**: Modern, Classic, Rustic, Luxury, Industrial, Minimalist

### 8. UI / Interface
- **Tablet** (TAB key): Main menu hub with 5 tabs
  - Store: Buy building pieces, furniture, garden items
  - Perks: Upgrade skills
  - Photos: Take property photos
  - Buyer Profiles: View buyer preferences
  - Map: Navigate to properties
- **Laptop**: Shows account balance, current date, job emails
- **HUD**: Minimap, current tool, money display, task checklist
- **Email System**: Receive job offers, buyer inquiries, tips

### 9. Economy
- Starting money: ~$2,000 (from tutorial)
- Job payouts: $500 - $5,000+ depending on complexity
- House prices: $15,000 - $200,000+
- Furniture prices: $10 - $5,000+ per item
- Paint/tiles: $5 - $50 per unit
- Sale multipliers based on renovation quality and buyer match

---

## ROBLOX ADAPTATION NOTES

### Key Differences from Steam Version
1. **Third-person** instead of first-person (Roblox standard)
2. **Multiplayer** support (co-op renovation)
3. **Robux monetization** for cosmetic items, extra tool skins
4. Simplified controls for younger audience
5. **Proximity prompts** for interactions instead of mouse-click mechanics

### Roblox-Specific Features to Add
- **Leaderboards** (most money earned, houses flipped)
- **Daily challenges** for bonus rewards
- **Trading** furniture between players
- **Visit friends' houses** feature
- **Gamepass** options (2x money, exclusive furniture, extra tool slots)

---

## DLC Content (For Future Updates)

| DLC Theme | Key Features |
|-----------|-------------|
| Garden | Outdoor renovation, plants, landscaping |
| Luxury | Swimming pools, high-end furniture, penthouses |
| HGTV | Celebrity-inspired designs, special properties |
| Pets | Companion animals that follow you |
| Farm | Animals, crops, farmhouses |
| Apocalypse | Post-apocalyptic themed houses, bunkers |
| Cyberpunk | Futuristic apartments, neon furniture |
| Dine Out | Restaurant renovation, commercial kitchens |

---

## PROJECT FILE STRUCTURE (Roblox Studio)

```
src/
├── ReplicatedStorage/          -- Shared modules (client + server)
│   ├── Config/
│   │   ├── GameConfig.lua      -- Global game settings
│   │   ├── ToolConfig.lua      -- Tool definitions & upgrade paths
│   │   ├── FurnitureData.lua   -- Furniture catalog data
│   │   ├── HouseData.lua       -- House definitions & prices
│   │   ├── JobData.lua         -- Job/mission definitions
│   │   ├── BuyerData.lua       -- Buyer profiles & preferences
│   │   ├── PerkData.lua        -- Skill tree definitions
│   │   └── RoomData.lua        -- Room type requirements
│   └── Shared/
│       ├── Enums.lua           -- Game enumerations
│       └── Utils.lua           -- Shared utility functions
│
├── ServerScriptService/        -- Server-side logic
│   ├── Core/
│   │   ├── GameManager.lua     -- Main game loop & state
│   │   ├── PlayerDataManager.lua -- Save/load player data (DataStore)
│   │   └── RemoteManager.lua   -- Remote event/function setup
│   ├── Systems/
│   │   ├── JobSystem.lua       -- Job assignment & completion
│   │   ├── EconomySystem.lua   -- Money transactions & validation
│   │   ├── HouseSystem.lua     -- House buying/selling/ownership
│   │   ├── RoomDetector.lua    -- Auto-detect room types
│   │   ├── BuyerSystem.lua     -- Buyer matching & offers
│   │   ├── FurnitureSystem.lua -- Furniture placement validation
│   │   └── PerkSystem.lua      -- Perk unlocking & effects
│   └── init.lua                -- Server bootstrap
│
├── StarterPlayerScripts/       -- Client-side logic
│   ├── Controllers/
│   │   ├── ToolController.lua  -- Tool selection & usage
│   │   ├── PlacementController.lua -- Furniture placement (client)
│   │   └── CameraController.lua -- Camera management
│   └── init.lua                -- Client bootstrap
│
└── StarterGui/                 -- UI Scripts
    ├── TabletUI.lua            -- Main tablet interface
    ├── ShopUI.lua              -- Furniture/paint store
    ├── EmailUI.lua             -- Job email system
    ├── HudUI.lua               -- HUD (money, minimap, tools)
    ├── PerkUI.lua              -- Skill tree interface
    └── BuyerUI.lua             -- Buyer profiles viewer
```
