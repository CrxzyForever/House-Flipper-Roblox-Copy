--[[
	GameManager.lua
	Main game loop, player setup, and system orchestration.
	Location: ServerScriptService/Core/GameManager
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(script.Parent.RemoteManager)
local PlayerDataManager = require(script.Parent.PlayerDataManager)

local GameManager = {}

function GameManager.init()
	-- Initialize core systems first
	RemoteManager.init()
	PlayerDataManager.init()

	-- Initialize game systems
	local Systems = script.Parent.Parent.Systems
	local JobSystem = require(Systems.JobSystem)
	local EconomySystem = require(Systems.EconomySystem)
	local HouseSystem = require(Systems.HouseSystem)
	local RoomDetector = require(Systems.RoomDetector)
	local BuyerSystem = require(Systems.BuyerSystem)
	local FurnitureSystem = require(Systems.FurnitureSystem)
	local PerkSystem = require(Systems.PerkSystem)

	JobSystem.init()
	EconomySystem.init()
	HouseSystem.init()
	RoomDetector.init()
	BuyerSystem.init()
	FurnitureSystem.init()
	PerkSystem.init()

	-- Build the 3D world (houses, terrain, objects)
	local WorldBuilder = require(Systems.WorldBuilder)
	WorldBuilder.init()

	-- Setup remote function handlers
	local getPlayerData = RemoteManager.getFunction("GetPlayerData")
	if getPlayerData then
		getPlayerData.OnServerInvoke = function(player)
			return PlayerDataManager.getData(player)
		end
	end

	-- Handle new players joining
	Players.PlayerAdded:Connect(function(player)
		GameManager.onPlayerJoin(player)
	end)

	-- Handle players already in game (for Studio testing)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			GameManager.onPlayerJoin(player)
		end)
	end

	print("[GameManager] All systems initialized. House Flipper is ready!")
end

function GameManager.onPlayerJoin(player)
	-- Load player data
	local data = PlayerDataManager.loadData(player)

	-- Send initial data to client
	local moneyEvent = RemoteManager.getEvent("MoneyChanged")
	if moneyEvent then
		moneyEvent:FireClient(player, data.money)
	end

	-- Send available jobs
	local jobListEvent = RemoteManager.getEvent("JobListUpdated")
	if jobListEvent then
		local JobData = require(ReplicatedStorage.Config.JobData)
		local availableJobs = JobData.getAvailableJobs(data.completedJobs)
		jobListEvent:FireClient(player, availableJobs)
	end

	-- Notify client that data is ready
	local dataEvent = RemoteManager.getEvent("PlayerDataReceived")
	if dataEvent then
		dataEvent:FireClient(player, data)
	end

	print("[GameManager] Player " .. player.Name .. " setup complete. Money: $" .. data.money)
end

return GameManager
