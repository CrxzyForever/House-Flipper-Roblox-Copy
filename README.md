# House Flipper - Roblox Edition

A Roblox recreation of the popular Steam game **House Flipper** by Frozen District.

## About

Buy rundown houses, renovate them with tools (painting, tiling, demolition, cleaning), furnish them to match buyer preferences, and sell for profit!

## Project Structure

```
src/
├── ReplicatedStorage/       -- Shared config & data modules
│   ├── Config/              -- Game settings, furniture, houses, jobs, buyers, perks, rooms
│   └── Shared/              -- Enums and utility functions
├── ServerScriptService/     -- Server-side game logic
│   ├── Core/                -- Game manager, player data (DataStore), remote events
│   └── Systems/             -- Job, economy, house, room detection, buyer, furniture, perk systems
├── StarterPlayerScripts/    -- Client-side controllers
│   └── Controllers/         -- Tool usage, furniture placement, camera
└── StarterGui/              -- UI scripts
    ├── HudUI.lua            -- Money, tool display, notifications, job progress
    ├── TabletUI.lua         -- Main menu hub (TAB key)
    ├── ShopUI.lua           -- Furniture/paint/tile shop
    ├── EmailUI.lua          -- Job email system
    ├── PerkUI.lua           -- Skill tree upgrades
    └── BuyerUI.lua          -- Buyer profiles & house listings
```

## Setup in Roblox Studio

1. Use **Rojo** or manually place scripts in the matching Roblox Studio locations
2. `init.lua` files in ServerScriptService and StarterPlayerScripts are the bootstrap scripts
3. Replace `rbxassetid://0` placeholders with your actual asset IDs for models, icons, and textures
4. Build your house models in Roblox Studio and tag parts with CollectionService tags (`Stain`, `Trash`, `Wall`, `Paintable`, `Tileable`, `Destructible`, etc.)

## Key Features

- 10 tools with perk-based upgrades
- 12 jobs with progressive unlocking
- 9 purchasable houses (Small/Medium/Large)
- 40+ furniture items across 9 categories
- 10 buyer profiles with unique preferences
- Room auto-detection system
- Full economy with negotiation perks
- Tablet UI with shop, email, perks, and buyer profiles

## Controls

- **TAB** - Open/close tablet
- **1-6** - Select tools
- **Q** - Cycle tools
- **Click** - Use tool / interact
- **R** - Rotate furniture (placement mode)
- **G** - Toggle grid snap
- **V** - Toggle camera mode
- **ESC** - Cancel placement
