--[[
	PlayerDataManager.lua
	Handles saving/loading player data using Roblox DataStoreService.
	Location: ServerScriptService/Core/PlayerDataManager
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local GameConfig = require(game.ReplicatedStorage.Config.GameConfig)

local PlayerDataManager = {}
PlayerDataManager._cache = {} -- In-memory cache of player data

local DATA_STORE_NAME = "HouseFlipperData_v1"
local dataStore = DataStoreService:GetDataStore(DATA_STORE_NAME)

-- Default data template for new players
local DEFAULT_DATA = {
	-- Economy
	money = GameConfig.STARTING_MONEY,
	totalEarned = 0,
	totalSpent = 0,
	housesFlipped = 0,

	-- Tools
	unlockedTools = {"Broom", "TrashBag"}, -- Starting tools
	equippedTool = "Broom",

	-- Jobs
	completedJobs = {},
	currentJobId = nil,
	currentJobProgress = {},

	-- Houses
	ownedHouses = {}, -- List of house IDs the player owns
	currentHouseId = nil,

	-- Perks (category -> perkId -> level)
	perks = {
		Cleaning = {},
		Painting = {},
		Handyman = {},
		Demolition = {},
		Building = {},
		Negotiation = {},
	},
	perkPoints = 0,

	-- XP per category
	xp = {
		Cleaning = 0,
		Painting = 0,
		Handyman = 0,
		Demolition = 0,
		Building = 0,
		Negotiation = 0,
	},

	-- Inventory (owned paint, tiles, etc.)
	inventory = {
		paint = {}, -- {colorId = count}
		tiles = {}, -- {tileId = count}
	},

	-- Statistics
	stats = {
		wallsPainted = 0,
		wallsDemolished = 0,
		wallsBuilt = 0,
		trashCleaned = 0,
		stainsCleaned = 0,
		furniturePlaced = 0,
		tilesPlaced = 0,
		fixturesInstalled = 0,
	},

	-- Settings
	settings = {
		musicVolume = 0.5,
		sfxVolume = 0.8,
	},
}

-- Deep copy utility for default data
local function deepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

-- Load player data from DataStore
function PlayerDataManager.loadData(player)
	local userId = tostring(player.UserId)
	local success, data = pcall(function()
		return dataStore:GetAsync("Player_" .. userId)
	end)

	if success and data then
		-- Merge with defaults to handle new fields added in updates
		local mergedData = deepCopy(DEFAULT_DATA)
		for key, value in pairs(data) do
			if type(value) == "table" and type(mergedData[key]) == "table" then
				for subKey, subValue in pairs(value) do
					mergedData[key][subKey] = subValue
				end
			else
				mergedData[key] = value
			end
		end
		PlayerDataManager._cache[userId] = mergedData
		print("[PlayerDataManager] Loaded data for " .. player.Name)
	else
		PlayerDataManager._cache[userId] = deepCopy(DEFAULT_DATA)
		print("[PlayerDataManager] Created new data for " .. player.Name)
	end

	return PlayerDataManager._cache[userId]
end

-- Save player data to DataStore
function PlayerDataManager.saveData(player)
	local userId = tostring(player.UserId)
	local data = PlayerDataManager._cache[userId]
	if not data then return false end

	local success, err = pcall(function()
		dataStore:SetAsync("Player_" .. userId, data)
	end)

	if success then
		print("[PlayerDataManager] Saved data for " .. player.Name)
	else
		warn("[PlayerDataManager] Failed to save data for " .. player.Name .. ": " .. tostring(err))
	end

	return success
end

-- Get cached player data (fast, no DataStore call)
function PlayerDataManager.getData(player)
	local userId = tostring(player.UserId)
	return PlayerDataManager._cache[userId]
end

-- Update a specific field in player data
function PlayerDataManager.updateField(player, field, value)
	local data = PlayerDataManager.getData(player)
	if data then
		data[field] = value
		return true
	end
	return false
end

-- Add money to player
function PlayerDataManager.addMoney(player, amount)
	local data = PlayerDataManager.getData(player)
	if data then
		data.money = data.money + amount
		data.totalEarned = data.totalEarned + amount
		return data.money
	end
	return nil
end

-- Subtract money from player (returns false if insufficient funds)
function PlayerDataManager.subtractMoney(player, amount)
	local data = PlayerDataManager.getData(player)
	if data and data.money >= amount then
		data.money = data.money - amount
		data.totalSpent = data.totalSpent + amount
		return true, data.money
	end
	return false, data and data.money or 0
end

-- Unlock a tool for the player
function PlayerDataManager.unlockTool(player, toolType)
	local data = PlayerDataManager.getData(player)
	if data then
		for _, tool in ipairs(data.unlockedTools) do
			if tool == toolType then
				return false -- Already unlocked
			end
		end
		table.insert(data.unlockedTools, toolType)
		return true
	end
	return false
end

-- Check if player has a tool
function PlayerDataManager.hasTool(player, toolType)
	local data = PlayerDataManager.getData(player)
	if data then
		for _, tool in ipairs(data.unlockedTools) do
			if tool == toolType then
				return true
			end
		end
	end
	return false
end

-- Add completed job
function PlayerDataManager.completeJob(player, jobId)
	local data = PlayerDataManager.getData(player)
	if data then
		table.insert(data.completedJobs, jobId)
		data.currentJobId = nil
		data.currentJobProgress = {}
		return true
	end
	return false
end

-- Add a house to owned list
function PlayerDataManager.addHouse(player, houseId)
	local data = PlayerDataManager.getData(player)
	if data then
		table.insert(data.ownedHouses, houseId)
		return true
	end
	return false
end

-- Remove a house from owned list
function PlayerDataManager.removeHouse(player, houseId)
	local data = PlayerDataManager.getData(player)
	if data then
		for i, id in ipairs(data.ownedHouses) do
			if id == houseId then
				table.remove(data.ownedHouses, i)
				return true
			end
		end
	end
	return false
end

-- Increment a stat
function PlayerDataManager.incrementStat(player, statName, amount)
	local data = PlayerDataManager.getData(player)
	if data and data.stats[statName] ~= nil then
		data.stats[statName] = data.stats[statName] + (amount or 1)
		return data.stats[statName]
	end
	return nil
end

-- Add XP to a category
function PlayerDataManager.addXP(player, category, amount)
	local data = PlayerDataManager.getData(player)
	if data and data.xp[category] ~= nil then
		data.xp[category] = data.xp[category] + amount
		return data.xp[category]
	end
	return nil
end

-- Setup autosave and cleanup
function PlayerDataManager.init()
	-- Save on player leave
	Players.PlayerRemoving:Connect(function(player)
		PlayerDataManager.saveData(player)
		PlayerDataManager._cache[tostring(player.UserId)] = nil
	end)

	-- Autosave every interval
	task.spawn(function()
		while true do
			task.wait(GameConfig.AUTOSAVE_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				PlayerDataManager.saveData(player)
			end
		end
	end)

	-- Save all on server shutdown
	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			PlayerDataManager.saveData(player)
		end
	end)

	print("[PlayerDataManager] Initialized with autosave every " .. GameConfig.AUTOSAVE_INTERVAL .. "s")
end

return PlayerDataManager
