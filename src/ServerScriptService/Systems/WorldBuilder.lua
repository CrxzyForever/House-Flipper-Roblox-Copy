--[[
	WorldBuilder.lua
	Generates the entire 3D game world: hub area, houses, furniture, trash, stains.
	All objects are tagged with CollectionService for tool interactions.
	Location: ServerScriptService/Systems/WorldBuilder
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HouseData = require(ReplicatedStorage.Config.HouseData)
local FurnitureData = require(ReplicatedStorage.Config.FurnitureData)

local WorldBuilder = {}

-- Color palette
local COLORS = {
	Grass = Color3.fromRGB(76, 153, 0),
	Road = Color3.fromRGB(80, 80, 80),
	Sidewalk = Color3.fromRGB(180, 180, 170),
	WallDefault = Color3.fromRGB(230, 220, 210),
	WallDirty = Color3.fromRGB(190, 180, 160),
	WallDamaged = Color3.fromRGB(170, 155, 135),
	Floor = Color3.fromRGB(160, 120, 80),
	FloorTile = Color3.fromRGB(220, 220, 220),
	Ceiling = Color3.fromRGB(240, 240, 240),
	Roof = Color3.fromRGB(139, 69, 19),
	Window = Color3.fromRGB(180, 220, 255),
	Door = Color3.fromRGB(120, 80, 40),
	Trash = Color3.fromRGB(100, 90, 70),
	Stain = Color3.fromRGB(80, 60, 40),
	HubFloor = Color3.fromRGB(200, 190, 170),
	Sign = Color3.fromRGB(60, 60, 60),
	SignText = Color3.fromRGB(255, 255, 255),
	Water = Color3.fromRGB(60, 140, 200),
}

-- Materials
local MATS = {
	Grass = Enum.Material.Grass,
	Road = Enum.Material.Asphalt,
	Sidewalk = Enum.Material.Concrete,
	Wall = Enum.Material.SmoothPlastic,
	Floor = Enum.Material.Wood,
	FloorTile = Enum.Material.SmoothPlastic,
	Ceiling = Enum.Material.SmoothPlastic,
	Roof = Enum.Material.Slate,
	Window = Enum.Material.Glass,
	Door = Enum.Material.Wood,
}

-- Constants
local WALL_HEIGHT = 10
local WALL_THICKNESS = 1
local FLOOR_THICKNESS = 0.5
local CEILING_HEIGHT = 10.5
local ROOM_SIZE = 20 -- Base room size in studs
local HOUSE_SPACING = 60 -- Space between houses
local HOUSES_PER_ROW = 3

-- World container
local worldFolder = nil

function WorldBuilder.init()
	-- Create world container
	worldFolder = Instance.new("Folder")
	worldFolder.Name = "GameWorld"
	worldFolder.Parent = workspace

	-- Build the world
	WorldBuilder._buildTerrain()
	WorldBuilder._buildHub()
	WorldBuilder._buildAllHouses()

	print("[WorldBuilder] World generation complete!")
end

-- ============================================================
-- TERRAIN
-- ============================================================
function WorldBuilder._buildTerrain()
	local terrainFolder = Instance.new("Folder")
	terrainFolder.Name = "Terrain"
	terrainFolder.Parent = worldFolder

	-- Large ground plane
	local ground = WorldBuilder._createPart({
		name = "Ground",
		size = Vector3.new(800, 1, 800),
		position = Vector3.new(0, -0.5, 0),
		color = COLORS.Grass,
		material = MATS.Grass,
		anchored = true,
		parent = terrainFolder,
	})

	-- Main road
	WorldBuilder._createPart({
		name = "MainRoad",
		size = Vector3.new(20, 0.2, 600),
		position = Vector3.new(0, 0.1, 0),
		color = COLORS.Road,
		material = MATS.Road,
		anchored = true,
		parent = terrainFolder,
	})

	-- Road center line
	for i = -280, 280, 20 do
		WorldBuilder._createPart({
			name = "RoadLine",
			size = Vector3.new(1, 0.05, 8),
			position = Vector3.new(0, 0.25, i),
			color = Color3.fromRGB(255, 255, 100),
			material = Enum.Material.Neon,
			anchored = true,
			parent = terrainFolder,
		})
	end

	-- Sidewalks on both sides
	for _, xOff in ipairs({-13, 13}) do
		WorldBuilder._createPart({
			name = "Sidewalk",
			size = Vector3.new(6, 0.15, 600),
			position = Vector3.new(xOff, 0.1, 0),
			color = COLORS.Sidewalk,
			material = MATS.Sidewalk,
			anchored = true,
			parent = terrainFolder,
		})
	end
end

-- ============================================================
-- HUB AREA (spawn, info boards)
-- ============================================================
function WorldBuilder._buildHub()
	local hubFolder = Instance.new("Folder")
	hubFolder.Name = "Hub"
	hubFolder.Parent = worldFolder

	-- Hub platform
	WorldBuilder._createPart({
		name = "HubPlatform",
		size = Vector3.new(40, 0.5, 40),
		position = Vector3.new(0, 0.25, -200),
		color = COLORS.HubFloor,
		material = MATS.Sidewalk,
		anchored = true,
		parent = hubFolder,
	})

	-- Spawn location
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "MainSpawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(0, 0.75, -200)
	spawn.Anchored = true
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(100, 200, 255)
	spawn.CanCollide = false
	spawn.Transparency = 0.5
	spawn.Parent = hubFolder

	-- Welcome sign
	WorldBuilder._createSign({
		text = "HOUSE FLIPPER\nRoblox Edition",
		position = Vector3.new(0, 8, -215),
		size = Vector3.new(20, 6, 1),
		parent = hubFolder,
	})

	-- Info sign
	WorldBuilder._createSign({
		text = "Press TAB to open Tablet\nAccept jobs from Emails\nBuy & renovate houses!",
		position = Vector3.new(-12, 5, -195),
		size = Vector3.new(14, 5, 1),
		parent = hubFolder,
		textSize = 18,
	})

	-- Controls sign
	WorldBuilder._createSign({
		text = "Controls:\n1-6: Switch Tools\nQ: Cycle Tools\nClick: Use Tool\nTAB: Tablet Menu\nV: Camera Mode",
		position = Vector3.new(12, 5, -195),
		size = Vector3.new(14, 5, 1),
		parent = hubFolder,
		textSize = 16,
	})
end

-- ============================================================
-- HOUSES
-- ============================================================
function WorldBuilder._buildAllHouses()
	local housesFolder = Instance.new("Folder")
	housesFolder.Name = "Houses"
	housesFolder.Parent = worldFolder

	for i, houseData in ipairs(HouseData.Houses) do
		local row = math.floor((i - 1) / HOUSES_PER_ROW)
		local col = (i - 1) % HOUSES_PER_ROW

		-- Place houses on alternating sides of the road
		local side = (col % 2 == 0) and 1 or -1
		local xPos = side * (30 + math.floor(col / 2) * HOUSE_SPACING)
		local zPos = -100 + row * (HOUSE_SPACING + 20)

		local houseModel = WorldBuilder._buildHouse(houseData, Vector3.new(xPos, 0, zPos))
		houseModel.Parent = housesFolder

		-- Driveway connecting to road
		WorldBuilder._createPart({
			name = "Driveway_" .. houseData.id,
			size = Vector3.new(math.abs(xPos) - 10, 0.15, 6),
			position = Vector3.new(xPos / 2, 0.1, zPos + 5),
			color = COLORS.Sidewalk,
			material = MATS.Sidewalk,
			anchored = true,
			parent = housesFolder,
		})
	end
end

function WorldBuilder._buildHouse(houseData, origin)
	local houseModel = Instance.new("Model")
	houseModel.Name = "House_" .. houseData.id

	-- Store house ID as attribute
	houseModel:SetAttribute("HouseId", houseData.id)
	houseModel:SetAttribute("HouseName", houseData.name)
	houseModel:SetAttribute("PurchasePrice", houseData.purchasePrice)

	CollectionService:AddTag(houseModel, "House")

	-- Calculate room layout
	local rooms = WorldBuilder._generateRoomLayout(houseData)

	-- Build each room
	for roomIndex, room in ipairs(rooms) do
		WorldBuilder._buildRoom(houseModel, houseData, room, origin, roomIndex)
	end

	-- Exterior sign with house info
	WorldBuilder._createSign({
		text = houseData.name .. "\n$" .. houseData.purchasePrice,
		position = origin + Vector3.new(0, 6, -rooms[1].size.Z / 2 - 3),
		size = Vector3.new(12, 4, 0.5),
		parent = houseModel,
		textSize = 20,
	})

	-- For Sale sign
	local forSaleSign = WorldBuilder._createPart({
		name = "ForSaleSign",
		size = Vector3.new(4, 5, 0.5),
		position = origin + Vector3.new(-rooms[1].size.X / 2 - 5, 2.5, -rooms[1].size.Z / 2),
		color = Color3.fromRGB(255, 50, 50),
		material = Enum.Material.SmoothPlastic,
		anchored = true,
		parent = houseModel,
	})
	CollectionService:AddTag(forSaleSign, "ForSaleSign")
	forSaleSign:SetAttribute("HouseId", houseData.id)

	local saleGui = Instance.new("BillboardGui")
	saleGui.Size = UDim2.new(4, 0, 3, 0)
	saleGui.StudsOffset = Vector3.new(0, 0, 0)
	saleGui.AlwaysOnTop = false
	saleGui.Parent = forSaleSign

	local saleLabel = Instance.new("TextLabel")
	saleLabel.Size = UDim2.new(1, 0, 1, 0)
	saleLabel.BackgroundTransparency = 1
	saleLabel.Text = "FOR SALE\n$" .. houseData.purchasePrice
	saleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	saleLabel.Font = Enum.Font.GothamBold
	saleLabel.TextScaled = true
	saleLabel.Parent = saleGui

	-- Sign post
	WorldBuilder._createPart({
		name = "SignPost",
		size = Vector3.new(0.3, 5, 0.3),
		position = origin + Vector3.new(-rooms[1].size.X / 2 - 5, 2.5, -rooms[1].size.Z / 2),
		color = Color3.fromRGB(80, 80, 80),
		material = Enum.Material.Metal,
		anchored = true,
		parent = houseModel,
	})

	return houseModel
end

-- Generate room positions based on house data
function WorldBuilder._generateRoomLayout(houseData)
	local rooms = {}
	local numRooms = houseData.rooms
	local baseSize = math.sqrt(houseData.sizeStuds / numRooms)

	-- Simple grid layout
	local cols = math.min(numRooms, 3)
	local rows = math.ceil(numRooms / cols)

	local roomTypes = {"Kitchen", "LivingRoom", "Bathroom", "Bedroom", "Office", "DiningRoom", "Garage", "LaundryRoom"}

	for i = 1, numRooms do
		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)

		local roomWidth = baseSize + math.random(-2, 2)
		local roomDepth = baseSize + math.random(-2, 2)

		table.insert(rooms, {
			index = i,
			type = roomTypes[math.min(i, #roomTypes)] or "Bedroom",
			offset = Vector3.new(col * (baseSize + WALL_THICKNESS), 0, row * (baseSize + WALL_THICKNESS)),
			size = Vector3.new(math.max(roomWidth, 12), WALL_HEIGHT, math.max(roomDepth, 12)),
			floor = (row == 0) and 1 or (houseData.floors > 1 and 2 or 1),
		})
	end

	return rooms
end

-- Build a single room
function WorldBuilder._buildRoom(houseModel, houseData, room, houseOrigin, roomIndex)
	local roomFolder = Instance.new("Folder")
	roomFolder.Name = "Room_" .. roomIndex .. "_" .. room.type
	roomFolder.Parent = houseModel

	local pos = houseOrigin + room.offset
	local w = room.size.X
	local d = room.size.Z
	local h = room.size.Y

	local condition = houseData.condition
	local wallColor = condition.wallCondition > 0.5 and COLORS.WallDefault or
		(condition.hasDamage and COLORS.WallDamaged or COLORS.WallDirty)

	-- Floor
	local floor = WorldBuilder._createPart({
		name = "Floor",
		size = Vector3.new(w, FLOOR_THICKNESS, d),
		position = pos + Vector3.new(w / 2, FLOOR_THICKNESS / 2, d / 2),
		color = COLORS.Floor,
		material = MATS.Floor,
		anchored = true,
		parent = roomFolder,
	})
	CollectionService:AddTag(floor, "Floor")
	CollectionService:AddTag(floor, "Tileable")
	CollectionService:AddTag(floor, "BuildSurface")
	floor:SetAttribute("HouseId", houseData.id)
	floor:SetAttribute("RoomIndex", roomIndex)

	-- Ceiling
	WorldBuilder._createPart({
		name = "Ceiling",
		size = Vector3.new(w, FLOOR_THICKNESS, d),
		position = pos + Vector3.new(w / 2, h + FLOOR_THICKNESS / 2, d / 2),
		color = COLORS.Ceiling,
		material = MATS.Ceiling,
		anchored = true,
		parent = roomFolder,
	})

	-- Walls (4 walls per room, with door gaps on some)
	-- Front wall (with door on first room)
	local hasDoor = (roomIndex == 1)
	WorldBuilder._buildWall(roomFolder, houseData, {
		position = pos + Vector3.new(w / 2, h / 2 + FLOOR_THICKNESS, 0),
		size = Vector3.new(w, h, WALL_THICKNESS),
		color = wallColor,
		hasDoor = hasDoor,
		hasWindow = not hasDoor,
		roomIndex = roomIndex,
		wallSide = "front",
		isDamaged = condition.hasDamage and math.random() > 0.6,
	})

	-- Back wall
	WorldBuilder._buildWall(roomFolder, houseData, {
		position = pos + Vector3.new(w / 2, h / 2 + FLOOR_THICKNESS, d),
		size = Vector3.new(w, h, WALL_THICKNESS),
		color = wallColor,
		hasDoor = false,
		hasWindow = math.random() > 0.3,
		roomIndex = roomIndex,
		wallSide = "back",
		isDamaged = condition.hasDamage and math.random() > 0.7,
	})

	-- Left wall (with doorway to adjacent room if exists)
	local hasInteriorDoor = (roomIndex > 1) and ((roomIndex - 1) % 3 ~= 0)
	WorldBuilder._buildWall(roomFolder, houseData, {
		position = pos + Vector3.new(0, h / 2 + FLOOR_THICKNESS, d / 2),
		size = Vector3.new(WALL_THICKNESS, h, d),
		color = wallColor,
		hasDoor = hasInteriorDoor,
		hasWindow = false,
		roomIndex = roomIndex,
		wallSide = "left",
		isDamaged = condition.hasDamage and math.random() > 0.7,
	})

	-- Right wall
	WorldBuilder._buildWall(roomFolder, houseData, {
		position = pos + Vector3.new(w, h / 2 + FLOOR_THICKNESS, d / 2),
		size = Vector3.new(WALL_THICKNESS, h, d),
		color = wallColor,
		hasDoor = false,
		hasWindow = math.random() > 0.5,
		roomIndex = roomIndex,
		wallSide = "right",
		isDamaged = condition.hasDamage and math.random() > 0.8,
	})

	-- Place trash objects
	local trashPerRoom = math.ceil(condition.trashCount / houseData.rooms)
	for t = 1, trashPerRoom do
		local trashPos = pos + Vector3.new(
			math.random(2, math.floor(w) - 2),
			FLOOR_THICKNESS + 0.5,
			math.random(2, math.floor(d) - 2)
		)
		WorldBuilder._createTrash(roomFolder, houseData.id, trashPos)
	end

	-- Place stain objects
	local stainsPerRoom = math.ceil(condition.stainCount / houseData.rooms)
	for s = 1, stainsPerRoom do
		local stainPos = pos + Vector3.new(
			math.random(2, math.floor(w) - 2),
			FLOOR_THICKNESS + 0.05,
			math.random(2, math.floor(d) - 2)
		)
		WorldBuilder._createStain(roomFolder, houseData.id, stainPos)
	end

	-- Place pre-installed furniture in appropriate rooms
	if roomIndex <= #houseData.preInstalledFurniture then
		local furnitureId = houseData.preInstalledFurniture[roomIndex]
		if furnitureId then
			local furnitureInfo = FurnitureData.getById(furnitureId)
			if furnitureInfo then
				local fPos = pos + Vector3.new(w / 2, FLOOR_THICKNESS, d / 2)
				WorldBuilder._createFurniture(roomFolder, furnitureInfo, fPos, houseData.id)
			end
		end
	end

	-- Add a ceiling light
	local light = Instance.new("PointLight")
	light.Brightness = 1
	light.Range = 30
	light.Color = Color3.fromRGB(255, 240, 220)

	local lightPart = WorldBuilder._createPart({
		name = "CeilingLight",
		size = Vector3.new(2, 0.3, 2),
		position = pos + Vector3.new(w / 2, h, d / 2),
		color = Color3.fromRGB(255, 255, 240),
		material = Enum.Material.Neon,
		anchored = true,
		parent = roomFolder,
		transparency = 0.3,
	})
	light.Parent = lightPart
end

-- Build a wall segment (may include door/window openings)
function WorldBuilder._buildWall(parent, houseData, config)
	local pos = config.position
	local size = config.size
	local isXWall = size.X > size.Z -- Wall runs along X axis

	if config.hasDoor then
		-- Wall with door opening (split into 3 parts: left, top, right)
		local doorWidth = 5
		local doorHeight = 7

		if isXWall then
			local sideWidth = (size.X - doorWidth) / 2

			-- Left section
			if sideWidth > 0 then
				local leftWall = WorldBuilder._createWallPart(parent, houseData, config, {
					size = Vector3.new(sideWidth, size.Y, size.Z),
					position = pos + Vector3.new(-(doorWidth + sideWidth) / 2, 0, 0),
				})
			end

			-- Right section
			if sideWidth > 0 then
				local rightWall = WorldBuilder._createWallPart(parent, houseData, config, {
					size = Vector3.new(sideWidth, size.Y, size.Z),
					position = pos + Vector3.new((doorWidth + sideWidth) / 2, 0, 0),
				})
			end

			-- Top section (above door)
			local topWall = WorldBuilder._createWallPart(parent, houseData, config, {
				size = Vector3.new(doorWidth, size.Y - doorHeight, size.Z),
				position = pos + Vector3.new(0, (doorHeight) / 2, 0),
			})
		else
			local sideDepth = (size.Z - doorWidth) / 2

			if sideDepth > 0 then
				WorldBuilder._createWallPart(parent, houseData, config, {
					size = Vector3.new(size.X, size.Y, sideDepth),
					position = pos + Vector3.new(0, 0, -(doorWidth + sideDepth) / 2),
				})
			end

			if sideDepth > 0 then
				WorldBuilder._createWallPart(parent, houseData, config, {
					size = Vector3.new(size.X, size.Y, sideDepth),
					position = pos + Vector3.new(0, 0, (doorWidth + sideDepth) / 2),
				})
			end

			WorldBuilder._createWallPart(parent, houseData, config, {
				size = Vector3.new(size.X, size.Y - doorHeight, doorWidth),
				position = pos + Vector3.new(0, (doorHeight) / 2, 0),
			})
		end
	elseif config.hasWindow then
		-- Wall with window
		local windowWidth = 4
		local windowHeight = 4
		local windowBottom = 3

		if isXWall then
			local sideWidth = (size.X - windowWidth) / 2

			-- Left
			if sideWidth > 0 then
				WorldBuilder._createWallPart(parent, houseData, config, {
					size = Vector3.new(sideWidth, size.Y, size.Z),
					position = pos + Vector3.new(-(windowWidth + sideWidth) / 2, 0, 0),
				})
			end
			-- Right
			if sideWidth > 0 then
				WorldBuilder._createWallPart(parent, houseData, config, {
					size = Vector3.new(sideWidth, size.Y, size.Z),
					position = pos + Vector3.new((windowWidth + sideWidth) / 2, 0, 0),
				})
			end
			-- Below window
			WorldBuilder._createWallPart(parent, houseData, config, {
				size = Vector3.new(windowWidth, windowBottom, size.Z),
				position = pos + Vector3.new(0, -(size.Y - windowBottom) / 2, 0),
			})
			-- Above window
			local aboveHeight = size.Y - windowBottom - windowHeight
			if aboveHeight > 0 then
				WorldBuilder._createWallPart(parent, houseData, config, {
					size = Vector3.new(windowWidth, aboveHeight, size.Z),
					position = pos + Vector3.new(0, (size.Y - aboveHeight) / 2, 0),
				})
			end
			-- Window glass
			local windowPart = WorldBuilder._createPart({
				name = "Window",
				size = Vector3.new(windowWidth, windowHeight, size.Z * 0.5),
				position = pos + Vector3.new(0, windowBottom - size.Y / 2 + windowHeight / 2, 0),
				color = COLORS.Window,
				material = MATS.Window,
				anchored = true,
				parent = parent,
				transparency = 0.5,
			})
			CollectionService:AddTag(windowPart, "DirtyWindow")
			windowPart:SetAttribute("HouseId", houseData.id)
		else
			-- Simplified: full wall for Z-axis walls with windows
			WorldBuilder._createWallPart(parent, houseData, config, {
				size = size,
				position = pos,
			})
		end
	else
		-- Solid wall
		WorldBuilder._createWallPart(parent, houseData, config, {
			size = size,
			position = pos,
		})
	end
end

function WorldBuilder._createWallPart(parent, houseData, config, override)
	local wall = WorldBuilder._createPart({
		name = "Wall_" .. config.wallSide .. "_" .. config.roomIndex,
		size = override.size,
		position = override.position,
		color = config.color,
		material = MATS.Wall,
		anchored = true,
		parent = parent,
	})

	CollectionService:AddTag(wall, "Wall")
	CollectionService:AddTag(wall, "Paintable")
	CollectionService:AddTag(wall, "Tileable")
	wall:SetAttribute("HouseId", houseData.id)
	wall:SetAttribute("RoomIndex", config.roomIndex)

	if config.isDamaged then
		CollectionService:AddTag(wall, "DamagedWall")
		CollectionService:AddTag(wall, "NeedsPlaster")
		wall.Color = COLORS.WallDamaged
		-- Add visual damage (dark patches)
		local damage = Instance.new("Decal")
		damage.Color3 = Color3.fromRGB(100, 80, 60)
		damage.Transparency = 0.5
		damage.Parent = wall
	end

	-- Some walls are destructible
	if config.wallSide == "left" or config.wallSide == "right" then
		CollectionService:AddTag(wall, "Destructible")
		wall:SetAttribute("Health", 5)
	end

	return wall
end

-- ============================================================
-- INTERACTABLE OBJECTS
-- ============================================================
function WorldBuilder._createTrash(parent, houseId, position)
	local trashTypes = {
		{name = "CrumpledPaper", size = Vector3.new(0.8, 0.6, 0.8), color = Color3.fromRGB(200, 190, 170)},
		{name = "OldBox", size = Vector3.new(1.5, 1, 1.2), color = Color3.fromRGB(160, 130, 80)},
		{name = "PlasticBag", size = Vector3.new(1, 0.5, 1), color = Color3.fromRGB(220, 220, 220)},
		{name = "BrokenBottle", size = Vector3.new(0.4, 0.8, 0.4), color = Color3.fromRGB(50, 120, 50)},
		{name = "OldNewspaper", size = Vector3.new(1.2, 0.1, 0.8), color = Color3.fromRGB(230, 220, 190)},
		{name = "FoodWrapper", size = Vector3.new(0.6, 0.3, 0.6), color = Color3.fromRGB(200, 50, 50)},
		{name = "DustPile", size = Vector3.new(1, 0.2, 1), color = Color3.fromRGB(150, 140, 120)},
	}

	local trashType = trashTypes[math.random(1, #trashTypes)]

	local trash = WorldBuilder._createPart({
		name = trashType.name,
		size = trashType.size,
		position = position,
		color = trashType.color,
		material = Enum.Material.SmoothPlastic,
		anchored = true,
		parent = parent,
	})

	CollectionService:AddTag(trash, "Trash")
	CollectionService:AddTag(trash, "Debris")
	trash:SetAttribute("HouseId", houseId)

	return trash
end

function WorldBuilder._createStain(parent, houseId, position)
	local stainTypes = {
		{name = "CoffeeStain", color = Color3.fromRGB(100, 60, 30), size = Vector3.new(1.5, 0.05, 1.5)},
		{name = "DirtPatch", color = Color3.fromRGB(80, 70, 50), size = Vector3.new(2, 0.05, 2)},
		{name = "GrimeMark", color = Color3.fromRGB(60, 60, 50), size = Vector3.new(1, 0.05, 1.2)},
		{name = "WaterStain", color = Color3.fromRGB(150, 140, 120), size = Vector3.new(1.8, 0.05, 1.8)},
		{name = "OilSpill", color = Color3.fromRGB(40, 40, 30), size = Vector3.new(1.2, 0.05, 1.2)},
	}

	local stainType = stainTypes[math.random(1, #stainTypes)]

	local stain = WorldBuilder._createPart({
		name = stainType.name,
		size = stainType.size,
		position = position,
		color = stainType.color,
		material = Enum.Material.SmoothPlastic,
		anchored = true,
		parent = parent,
		shape = "Cylinder",
	})
	-- Rotate cylinder to lay flat
	stain.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	stain.Size = Vector3.new(0.05, stainType.size.X, stainType.size.Z)

	CollectionService:AddTag(stain, "Stain")
	CollectionService:AddTag(stain, "Dirt")
	stain:SetAttribute("HouseId", houseId)

	return stain
end

-- ============================================================
-- FURNITURE
-- ============================================================
function WorldBuilder._createFurniture(parent, furnitureInfo, position, houseId)
	local model = Instance.new("Model")
	model.Name = "Furniture_" .. furnitureInfo.id

	local furnitureColors = {
		Kitchen = Color3.fromRGB(200, 200, 200),
		Bathroom = Color3.fromRGB(240, 240, 250),
		Bedroom = Color3.fromRGB(139, 90, 43),
		LivingRoom = Color3.fromRGB(100, 100, 120),
		Office = Color3.fromRGB(60, 60, 60),
		Dining = Color3.fromRGB(120, 80, 40),
		Decorative = Color3.fromRGB(200, 180, 100),
		Appliances = Color3.fromRGB(220, 220, 220),
		Outdoor = Color3.fromRGB(76, 153, 0),
	}

	local baseColor = furnitureColors[furnitureInfo.category] or Color3.fromRGB(180, 180, 180)

	-- Main body
	local body = WorldBuilder._createPart({
		name = "Body",
		size = Vector3.new(furnitureInfo.size[1], furnitureInfo.size[2], furnitureInfo.size[3]),
		position = position + Vector3.new(0, furnitureInfo.size[2] / 2, 0),
		color = baseColor,
		material = Enum.Material.SmoothPlastic,
		anchored = true,
		parent = model,
	})

	model.PrimaryPart = body

	-- Add label
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 150, 0, 30)
	billboard.StudsOffset = Vector3.new(0, furnitureInfo.size[2] / 2 + 1, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = body

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 0.3
	label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = furnitureInfo.name
	label.Parent = billboard

	local labelCorner = Instance.new("UICorner")
	labelCorner.CornerRadius = UDim.new(0, 4)
	labelCorner.Parent = label

	-- Tags
	CollectionService:AddTag(model, "Furniture")
	if furnitureInfo.roomTag then
		CollectionService:AddTag(model, furnitureInfo.roomTag)
	end
	if furnitureInfo.requiresInstallation then
		CollectionService:AddTag(model, "Installable")
	end

	model:SetAttribute("FurnitureId", furnitureInfo.id)
	model:SetAttribute("HouseId", houseId)
	model.Parent = parent

	return model
end

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
function WorldBuilder._createPart(config)
	local part
	if config.shape == "Cylinder" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Cylinder
	elseif config.shape == "Ball" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
	else
		part = Instance.new("Part")
	end

	part.Name = config.name or "Part"
	part.Size = config.size or Vector3.new(1, 1, 1)
	part.Position = config.position or Vector3.new(0, 0, 0)
	part.Color = config.color or Color3.fromRGB(200, 200, 200)
	part.Material = config.material or Enum.Material.SmoothPlastic
	part.Anchored = config.anchored ~= false
	part.CanCollide = config.canCollide ~= false
	part.Transparency = config.transparency or 0
	part.Parent = config.parent

	return part
end

function WorldBuilder._createSign(config)
	local signPart = WorldBuilder._createPart({
		name = "Sign",
		size = config.size or Vector3.new(10, 4, 0.5),
		position = config.position,
		color = COLORS.Sign,
		material = Enum.Material.SmoothPlastic,
		anchored = true,
		parent = config.parent,
	})

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = signPart

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -10, 1, -10)
	textLabel.Position = UDim2.new(0, 5, 0, 5)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = config.text or ""
	textLabel.TextColor3 = COLORS.SignText
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = config.textSize or 24
	textLabel.TextWrapped = true
	textLabel.TextScaled = false
	textLabel.Parent = gui

	-- Also add to back face
	local gui2 = gui:Clone()
	gui2.Face = Enum.NormalId.Back
	gui2.Parent = signPart

	return signPart
end

return WorldBuilder
