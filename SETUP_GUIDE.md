# House Flipper Roblox - Setup Guide

## Method 1: Rojo (Recommended for Developers)

### Prerequisites
- [Roblox Studio](https://www.roblox.com/create) installed
- [Rojo](https://rojo.space) installed (VS Code extension OR CLI)
- This repository cloned to your computer

### Step 1: Install the Rojo Roblox Studio Plugin
1. Open **Roblox Studio**
2. Go to **Plugins** tab → **Manage Plugins**
3. Search for **"Rojo"** and install it
4. You should see a **Rojo** button appear in your Plugins toolbar

### Step 2: Start Rojo Server
Open a terminal in your project folder and run:
```bash
rojo serve
```
You should see:
```
Rojo server listening on port 34872
```

### Step 3: Connect Roblox Studio
1. Open Roblox Studio → Create a new **Baseplate** place
2. Click the **Rojo** plugin button in the toolbar
3. Click **"Connect"** — it will auto-sync all scripts

### Step 4: Verify the Structure
In the Explorer panel, you should now see:
```
game
├── ReplicatedStorage
│   ├── Config (Folder)
│   │   ├── GameConfig (ModuleScript)
│   │   ├── ToolConfig (ModuleScript)
│   │   ├── FurnitureData (ModuleScript)
│   │   ├── HouseData (ModuleScript)
│   │   ├── JobData (ModuleScript)
│   │   ├── BuyerData (ModuleScript)
│   │   ├── PerkData (ModuleScript)
│   │   └── RoomData (ModuleScript)
│   └── Shared (Folder)
│       ├── Enums (ModuleScript)
│       └── Utils (ModuleScript)
├── ServerScriptService
│   └── HouseFlipperServer (Script)
│       ├── Core (Folder)
│       │   ├── GameManager (ModuleScript)
│       │   ├── PlayerDataManager (ModuleScript)
│       │   └── RemoteManager (ModuleScript)
│       └── Systems (Folder)
│           ├── JobSystem (ModuleScript)
│           ├── EconomySystem (ModuleScript)
│           ├── HouseSystem (ModuleScript)
│           ├── RoomDetector (ModuleScript)
│           ├── BuyerSystem (ModuleScript)
│           ├── FurnitureSystem (ModuleScript)
│           └── PerkSystem (ModuleScript)
├── StarterPlayer
│   └── StarterPlayerScripts
│       └── HouseFlipperClient (LocalScript)
│           └── Controllers (Folder)
│               ├── ToolController (ModuleScript)
│               ├── PlacementController (ModuleScript)
│               └── CameraController (ModuleScript)
└── StarterGui
    └── HouseFlipperUI (ScreenGui)
        ├── HudUI (LocalScript)
        ├── TabletUI (LocalScript)
        ├── ShopUI (LocalScript)
        ├── EmailUI (LocalScript)
        ├── PerkUI (LocalScript)
        └── BuyerUI (LocalScript)
```

---

## Method 2: Manual Copy-Paste (No Tools Needed)

If you don't want to use Rojo, follow these steps to manually create everything in Roblox Studio.

### Step 1: Create the Folder Structure

In Roblox Studio Explorer:

1. **ReplicatedStorage** → Right-click → Insert Object → **Folder** → Name it `Config`
2. **ReplicatedStorage** → Right-click → Insert Object → **Folder** → Name it `Shared`
3. **ServerScriptService** → Right-click → Insert Object → **Script** → Name it `HouseFlipperServer`
4. Inside `HouseFlipperServer` → Insert **Folder** → `Core`
5. Inside `HouseFlipperServer` → Insert **Folder** → `Systems`
6. **StarterPlayer** → **StarterPlayerScripts** → Insert **LocalScript** → `HouseFlipperClient`
7. Inside `HouseFlipperClient` → Insert **Folder** → `Controllers`
8. **StarterGui** → Insert **ScreenGui** → Name it `HouseFlipperUI`
   - Set `ResetOnSpawn` = false

### Step 2: Create ModuleScripts in Config Folder

For each file below, Right-click the **Config** folder → Insert Object → **ModuleScript**, rename it, and paste the code:

| File in Repo | Script Name | Script Type |
|---|---|---|
| `src/ReplicatedStorage/Config/GameConfig.lua` | GameConfig | ModuleScript |
| `src/ReplicatedStorage/Config/ToolConfig.lua` | ToolConfig | ModuleScript |
| `src/ReplicatedStorage/Config/FurnitureData.lua` | FurnitureData | ModuleScript |
| `src/ReplicatedStorage/Config/HouseData.lua` | HouseData | ModuleScript |
| `src/ReplicatedStorage/Config/JobData.lua` | JobData | ModuleScript |
| `src/ReplicatedStorage/Config/BuyerData.lua` | BuyerData | ModuleScript |
| `src/ReplicatedStorage/Config/PerkData.lua` | PerkData | ModuleScript |
| `src/ReplicatedStorage/Config/RoomData.lua` | RoomData | ModuleScript |

### Step 3: Create ModuleScripts in Shared Folder

| File in Repo | Script Name | Script Type |
|---|---|---|
| `src/ReplicatedStorage/Shared/Enums.lua` | Enums | ModuleScript |
| `src/ReplicatedStorage/Shared/Utils.lua` | Utils | ModuleScript |

### Step 4: Create Server Scripts

The `HouseFlipperServer` **Script** should contain the code from `src/ServerScriptService/init.server.lua`.

Inside the **Core** folder, create **ModuleScripts**:

| File in Repo | Script Name |
|---|---|
| `src/ServerScriptService/Core/GameManager.lua` | GameManager |
| `src/ServerScriptService/Core/PlayerDataManager.lua` | PlayerDataManager |
| `src/ServerScriptService/Core/RemoteManager.lua` | RemoteManager |

Inside the **Systems** folder, create **ModuleScripts**:

| File in Repo | Script Name |
|---|---|
| `src/ServerScriptService/Systems/JobSystem.lua` | JobSystem |
| `src/ServerScriptService/Systems/EconomySystem.lua` | EconomySystem |
| `src/ServerScriptService/Systems/HouseSystem.lua` | HouseSystem |
| `src/ServerScriptService/Systems/RoomDetector.lua` | RoomDetector |
| `src/ServerScriptService/Systems/BuyerSystem.lua` | BuyerSystem |
| `src/ServerScriptService/Systems/FurnitureSystem.lua` | FurnitureSystem |
| `src/ServerScriptService/Systems/PerkSystem.lua` | PerkSystem |

### Step 5: Create Client Scripts

The `HouseFlipperClient` **LocalScript** should contain the code from `src/StarterPlayerScripts/init.client.lua`.

Inside the **Controllers** folder, create **ModuleScripts**:

| File in Repo | Script Name |
|---|---|
| `src/StarterPlayerScripts/Controllers/ToolController.lua` | ToolController |
| `src/StarterPlayerScripts/Controllers/PlacementController.lua` | PlacementController |
| `src/StarterPlayerScripts/Controllers/CameraController.lua` | CameraController |

### Step 6: Create UI Scripts

Inside the **HouseFlipperUI** ScreenGui, create **LocalScripts**:

| File in Repo | Script Name |
|---|---|
| `src/StarterGui/HudUI.client.lua` | HudUI |
| `src/StarterGui/TabletUI.client.lua` | TabletUI |
| `src/StarterGui/ShopUI.client.lua` | ShopUI |
| `src/StarterGui/EmailUI.client.lua` | EmailUI |
| `src/StarterGui/PerkUI.client.lua` | PerkUI |
| `src/StarterGui/BuyerUI.client.lua` | BuyerUI |

---

## Step 7: Fix Require Paths (IMPORTANT - Both Methods)

The `require()` calls use Rojo-style paths with `script.Parent`. If you used **manual copy-paste**, verify these require paths match your Explorer hierarchy.

Example: In `ToolConfig.lua`, the line:
```lua
local Enums = require(script.Parent.Parent.Shared.Enums)
```
This means: ToolConfig → Parent (Config) → Parent (ReplicatedStorage) → Shared → Enums

Make sure your folder structure matches exactly.

---

## Step 8: Enable Required Services

In Roblox Studio:

1. Go to **Home** → **Game Settings** → **Security**
2. Enable **"Allow HTTP Requests"** (if you plan to use any web APIs)
3. Enable **"Enable Studio Access to API Services"** — this is needed for **DataStoreService** to work in testing

---

## Step 9: Tag Your Game Objects

The tool system uses **CollectionService tags** to identify interactable objects. When you build your house models, tag parts:

### How to Add Tags in Studio:
1. Select a Part in the workspace
2. Open **View** → **Tag Editor** (or press the Tags button)
3. Add the appropriate tag

### Required Tags:

| Tag | Used On | Purpose |
|---|---|---|
| `Stain` | Part (decal on floor/wall) | Broom can clean it |
| `Dirt` | Part | Broom can clean it |
| `Trash` | Model/Part | Trash bag picks it up |
| `Debris` | Part | Trash bag picks it up |
| `Wall` | Part | Can be painted, tiled, demolished |
| `Paintable` | Part | Paint roller works on it |
| `Tileable` | Part | Tiling tool works on it |
| `Floor` | Part | Floor surface for tiling/furniture |
| `Destructible` | Part | Sledgehammer can destroy it |
| `BuildSurface` | Part | Wall builder can place walls on it |
| `DirtyWindow` | Part | Window cleaner works on it |
| `DamagedWall` | Part | Plaster tool works on it |
| `NeedsPlaster` | Part | Plaster tool works on it |
| `BrokenGlass` | Part | Vacuum cleans it up |
| `Pest` | Model | Vacuum cleans it up |
| `Installable` | Model | Installation tool works on it |

---

## Step 10: Build a Test House

1. In **Workspace**, create a **Folder** called `Houses`
2. Build a simple house:
   - Floor: A large Part (tag: `Floor`, `BuildSurface`)
   - Walls: Parts arranged as walls (tag: `Wall`, `Paintable`, `Tileable`)
   - Add some trash: Small Parts scattered around (tag: `Trash`)
   - Add stains: Flat Parts on the floor (tag: `Stain`, `Dirt`)
   - Add a dirty window: Part with glass material (tag: `DirtyWindow`)

3. Press **Play** to test!

You should see:
- The HUD appear (money, tool name)
- Press **TAB** to open the tablet
- Tool switching with **1-6** or **Q**
- Click on tagged objects to use tools

---

## Step 11: Create 3D Furniture Models (Future Work)

For each furniture item in `FurnitureData.lua`, you'll need a 3D model:

1. Build or import models in Roblox Studio
2. Upload them via **Asset Manager** → get the `rbxassetid://` ID
3. Replace the `modelId = "rbxassetid://0"` placeholders in `FurnitureData.lua`
4. Also replace icon asset IDs in `ToolConfig.lua`

**Tip**: Use the Roblox **Toolbox** to find free models, or build simple ones with Parts.

---

## Troubleshooting

### "Attempt to index nil" errors
- Most likely a require path issue. Double-check your Explorer hierarchy matches the expected structure.

### DataStore errors in Studio
- Make sure you enabled **"Enable Studio Access to API Services"** in Game Settings → Security.

### Scripts not running
- **Server scripts** must be `Script` type (not ModuleScript or LocalScript)
- **Client scripts** must be `LocalScript` type
- **Shared modules** must be `ModuleScript` type
- Make sure the parent container is correct (ServerScriptService for server, StarterPlayerScripts for client)

### UI not appearing
- Check that `HouseFlipperUI` is a **ScreenGui** inside **StarterGui**
- Check that `ResetOnSpawn` is set to `false`
- Make sure the LocalScripts inside it are running (check Output for errors)
