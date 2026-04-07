--[[
	ToolController.lua
	Client-side tool management: equipping, using, and animating tools.
	Handles all renovation tool interactions (cleaning, painting, tiling, etc.)
	Location: StarterPlayerScripts/Controllers/ToolController
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ToolConfig = require(ReplicatedStorage.Config.ToolConfig)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local Enums = require(ReplicatedStorage.Shared.Enums)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local ToolController = {}

ToolController._currentTool = nil
ToolController._isUsing = false
ToolController._toolModels = {}
ToolController._debounce = false
ToolController._playerData = nil
ToolController._perkEffects = {}

function ToolController.init(playerData)
	ToolController._playerData = playerData

	-- Setup input handling
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		ToolController._onInputBegan(input)
	end)

	UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		ToolController._onInputEnded(input)
	end)

	-- Setup tool hotkeys (1-9 for tool slots)
	-- Listen for mouse click (primary tool action)
	mouse.Button1Down:Connect(function()
		ToolController._startUsingTool()
	end)

	mouse.Button1Up:Connect(function()
		ToolController._stopUsingTool()
	end)

	-- Setup remote event listeners
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local events = remotes:WaitForChild("Events")

	-- Listen for perk updates to adjust tool behavior
	local perkEvent = events:WaitForChild("PerkUnlocked")
	perkEvent.OnClientEvent:Connect(function(category, perkId, level)
		ToolController._updatePerkEffects()
	end)

	-- Equip starting tool
	ToolController.equipTool(Enums.ToolType.Broom)

	print("[ToolController] Initialized")
end

function ToolController._onInputBegan(input)
	-- Number keys 1-6 for tool switching
	local keyMap = {
		[Enum.KeyCode.One] = 1,
		[Enum.KeyCode.Two] = 2,
		[Enum.KeyCode.Three] = 3,
		[Enum.KeyCode.Four] = 4,
		[Enum.KeyCode.Five] = 5,
		[Enum.KeyCode.Six] = 6,
	}

	local slot = keyMap[input.KeyCode]
	if slot and ToolController._playerData then
		local tools = ToolController._playerData.unlockedTools
		if tools[slot] then
			ToolController.equipTool(tools[slot])
		end
	end

	-- Q key to cycle tools
	if input.KeyCode == Enum.KeyCode.Q then
		ToolController.cycleTool()
	end
end

function ToolController._onInputEnded(input)
	-- Nothing needed currently
end

-- Equip a tool by type
function ToolController.equipTool(toolType)
	if ToolController._currentTool == toolType then return end

	-- Verify player has this tool
	if ToolController._playerData then
		local hasTool = false
		for _, t in ipairs(ToolController._playerData.unlockedTools) do
			if t == toolType then
				hasTool = true
				break
			end
		end
		if not hasTool then return end
	end

	local toolDef = ToolConfig.Tools[toolType]
	if not toolDef then return end

	ToolController._currentTool = toolType

	-- Fire equip event to server
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local events = remotes:FindFirstChild("Events")
		if events then
			local equipEvent = events:FindFirstChild("ToolEquipped")
			if equipEvent then
				equipEvent:FireServer(toolType)
			end
		end
	end

	print("[ToolController] Equipped: " .. toolDef.displayName)
end

-- Cycle to next available tool
function ToolController.cycleTool()
	if not ToolController._playerData then return end

	local tools = ToolController._playerData.unlockedTools
	if #tools <= 1 then return end

	local currentIndex = 1
	for i, t in ipairs(tools) do
		if t == ToolController._currentTool then
			currentIndex = i
			break
		end
	end

	local nextIndex = (currentIndex % #tools) + 1
	ToolController.equipTool(tools[nextIndex])
end

-- Start using the current tool
function ToolController._startUsingTool()
	if ToolController._isUsing or ToolController._debounce then return end
	if not ToolController._currentTool then return end

	ToolController._isUsing = true

	local toolType = ToolController._currentTool

	-- Raycast from mouse to find target
	local target = mouse.Target
	if not target then
		ToolController._isUsing = false
		return
	end

	-- Check interaction range
	local character = player.Character
	if not character then
		ToolController._isUsing = false
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		ToolController._isUsing = false
		return
	end

	local distance = (humanoidRootPart.Position - mouse.Hit.Position).Magnitude
	if distance > GameConfig.INTERACTION_RANGE then
		ToolController._isUsing = false
		return
	end

	-- Perform tool action based on type
	if toolType == Enums.ToolType.Broom then
		ToolController._useBroom(target)
	elseif toolType == Enums.ToolType.TrashBag then
		ToolController._useTrashBag(target)
	elseif toolType == Enums.ToolType.PaintRoller then
		ToolController._usePaintRoller(target)
	elseif toolType == Enums.ToolType.TilingTool then
		ToolController._useTilingTool(target)
	elseif toolType == Enums.ToolType.Sledgehammer then
		ToolController._useSledgehammer(target)
	elseif toolType == Enums.ToolType.WallBuilder then
		ToolController._useWallBuilder(target)
	elseif toolType == Enums.ToolType.WindowCleaner then
		ToolController._useWindowCleaner(target)
	elseif toolType == Enums.ToolType.PlasterTool then
		ToolController._usePlasterTool(target)
	elseif toolType == Enums.ToolType.Vacuum then
		ToolController._useVacuum(target)
	elseif toolType == Enums.ToolType.InstallationTool then
		ToolController._useInstallationTool(target)
	end
end

function ToolController._stopUsingTool()
	ToolController._isUsing = false
end

-- === TOOL IMPLEMENTATIONS ===

function ToolController._useBroom(target)
	-- Check if target is a stain/dirt object
	if target:HasTag("Stain") or target:HasTag("Dirt") then
		ToolController._debounce = true

		-- Get cleaning range from perks
		local cleanRange = GameConfig.BROOM_BASE_RANGE
		if ToolController._perkEffects.cleaningRange then
			cleanRange = ToolController._perkEffects.cleaningRange
		end

		-- Fire cleaning event to server
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local cleanEvent = events:FindFirstChild("CleanStain")
				if cleanEvent then
					cleanEvent:FireServer(target:GetFullName(), mouse.Hit.Position, cleanRange)
				end
			end
		end

		-- Visual feedback: play cleaning animation
		task.wait(GameConfig.CLEAN_TIME)
		ToolController._debounce = false
	end
end

function ToolController._useTrashBag(target)
	if target:HasTag("Trash") or target:HasTag("Debris") then
		ToolController._debounce = true

		-- Get trash pickup count from perks
		local pickupCount = 1
		if ToolController._perkEffects.trashPickup then
			pickupCount = ToolController._perkEffects.trashPickup
		end

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local trashEvent = events:FindFirstChild("CleanTrash")
				if trashEvent then
					trashEvent:FireServer(target:GetFullName(), pickupCount)
				end
			end
		end

		task.wait(0.5)
		ToolController._debounce = false
	end
end

function ToolController._usePaintRoller(target)
	if target:HasTag("Paintable") or target:HasTag("Wall") then
		ToolController._debounce = true

		-- Get paint width from perks
		local paintWidth = GameConfig.PAINT_ROLLER_BASE_WIDTH
		if ToolController._perkEffects.paintWidth then
			paintWidth = ToolController._perkEffects.paintWidth
		end

		-- Get paint speed from perks
		local paintTime = GameConfig.PAINT_SPEED_BASE
		if ToolController._perkEffects.paintSpeed then
			paintTime = paintTime / ToolController._perkEffects.paintSpeed
		end

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local paintEvent = events:FindFirstChild("PaintWall")
				if paintEvent then
					-- Send: target wall, hit position, selected color, width
					paintEvent:FireServer(
						target:GetFullName(),
						mouse.Hit.Position,
						ToolController._selectedPaintColor or "white",
						paintWidth
					)
				end
			end
		end

		task.wait(paintTime)
		ToolController._debounce = false
	end
end

function ToolController._useTilingTool(target)
	if target:HasTag("Tileable") or target:HasTag("Wall") or target:HasTag("Floor") then
		ToolController._debounce = true

		local tilesPerPlace = 1
		if ToolController._perkEffects.tilesPerPlace then
			tilesPerPlace = ToolController._perkEffects.tilesPerPlace
		end

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local tileEvent = events:FindFirstChild("TileSurface")
				if tileEvent then
					tileEvent:FireServer(
						target:GetFullName(),
						mouse.Hit.Position,
						ToolController._selectedTile or "white_tile",
						tilesPerPlace
					)
				end
			end
		end

		task.wait(GameConfig.TILE_PLACE_TIME)
		ToolController._debounce = false
	end
end

function ToolController._useSledgehammer(target)
	if target:HasTag("Destructible") or target:HasTag("Wall") then
		ToolController._debounce = true

		local demoSpeed = 1.0
		local demoPower = 1.0
		if ToolController._perkEffects.demoSpeed then
			demoSpeed = ToolController._perkEffects.demoSpeed
		end
		if ToolController._perkEffects.demoPower then
			demoPower = ToolController._perkEffects.demoPower
		end

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local demoEvent = events:FindFirstChild("DemolishWall")
				if demoEvent then
					demoEvent:FireServer(target:GetFullName(), demoPower)
				end
			end
		end

		-- Swing animation timing adjusted by perk
		task.wait(0.8 / demoSpeed)
		ToolController._debounce = false
	end
end

function ToolController._useWallBuilder(target)
	if target:HasTag("BuildSurface") or target:HasTag("Floor") then
		ToolController._debounce = true

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local buildEvent = events:FindFirstChild("BuildWall")
				if buildEvent then
					buildEvent:FireServer(mouse.Hit.Position, mouse.Hit.LookVector)
				end
			end
		end

		local buildTime = GameConfig.WALL_BUILD_TIME
		if ToolController._perkEffects.buildSpeed then
			buildTime = buildTime / ToolController._perkEffects.buildSpeed
		end

		task.wait(buildTime)
		ToolController._debounce = false
	end
end

function ToolController._useWindowCleaner(target)
	if target:HasTag("DirtyWindow") then
		ToolController._debounce = true

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local windowEvent = events:FindFirstChild("CleanWindow")
				if windowEvent then
					windowEvent:FireServer(target:GetFullName())
				end
			end
		end

		task.wait(2.0)
		ToolController._debounce = false
	end
end

function ToolController._usePlasterTool(target)
	if target:HasTag("DamagedWall") or target:HasTag("NeedsPlaster") then
		ToolController._debounce = true

		local plasterTime = 2.0
		if ToolController._perkEffects.plasterSpeed then
			plasterTime = plasterTime / ToolController._perkEffects.plasterSpeed
		end

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local plasterEvent = events:FindFirstChild("PlasterWall")
				if plasterEvent then
					plasterEvent:FireServer(target:GetFullName())
				end
			end
		end

		task.wait(plasterTime)
		ToolController._debounce = false
	end
end

function ToolController._useVacuum(target)
	if target:HasTag("BrokenGlass") or target:HasTag("Pest") then
		ToolController._debounce = true

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local cleanEvent = events:FindFirstChild("CleanStain")
				if cleanEvent then
					cleanEvent:FireServer(target:GetFullName(), mouse.Hit.Position, 5)
				end
			end
		end

		task.wait(1.0)
		ToolController._debounce = false
	end
end

function ToolController._useInstallationTool(target)
	if target:HasTag("Installable") then
		ToolController._debounce = true

		local installTime = 3.0
		if ToolController._perkEffects.installSpeed then
			installTime = installTime / ToolController._perkEffects.installSpeed
		end

		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes then
			local events = remotes:FindFirstChild("Events")
			if events then
				local installEvent = events:FindFirstChild("InstallFixture")
				if installEvent then
					installEvent:FireServer(target:GetFullName())
				end
			end
		end

		task.wait(installTime)
		ToolController._debounce = false
	end
end

-- Update perk effects cache
function ToolController._updatePerkEffects()
	-- Request perk effects from server
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local functions = remotes:FindFirstChild("Functions")
		if functions then
			local getDataFunc = functions:FindFirstChild("GetPlayerData")
			if getDataFunc then
				local data = getDataFunc:InvokeServer()
				if data then
					ToolController._playerData = data
				end
			end
		end
	end
end

-- Set selected paint color (called by UI)
function ToolController.setSelectedPaintColor(colorId)
	ToolController._selectedPaintColor = colorId
end

-- Set selected tile (called by UI)
function ToolController.setSelectedTile(tileId)
	ToolController._selectedTile = tileId
end

-- Get current tool info
function ToolController.getCurrentTool()
	if ToolController._currentTool then
		return ToolConfig.Tools[ToolController._currentTool]
	end
	return nil
end

return ToolController
