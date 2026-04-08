--[[
	GameManager.lua
	Main game loop, player setup, and system orchestration.
	Location: ServerScriptService/Core/GameManager
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameManager = {}

-- These get set during init
local RemoteManager = nil
local PlayerDataManager = nil

function GameManager.init()
	-- Initialize core systems with individual error handling
	local Core = script.Parent
	local Systems = Core.Parent.Systems

	local ok1, err1 = pcall(function()
		RemoteManager = require(Core.RemoteManager)
		RemoteManager.init()
		print("[GameManager] RemoteManager initialized")
	end)
	if not ok1 then warn("[GameManager] RemoteManager FAILED: " .. tostring(err1)) end

	local ok2, err2 = pcall(function()
		PlayerDataManager = require(Core.PlayerDataManager)
		PlayerDataManager.init()
		print("[GameManager] PlayerDataManager initialized")
	end)
	if not ok2 then warn("[GameManager] PlayerDataManager FAILED: " .. tostring(err2)) end

	-- Game systems (each wrapped so one failure doesn't stop the rest)
	local systemNames = {"JobSystem", "EconomySystem", "HouseSystem", "RoomDetector", "BuyerSystem", "FurnitureSystem", "PerkSystem"}
	for _, name in ipairs(systemNames) do
		local ok, err = pcall(function()
			local sys = require(Systems[name])
			sys.init()
			print("[GameManager] " .. name .. " initialized")
		end)
		if not ok then
			warn("[GameManager] " .. name .. " FAILED: " .. tostring(err))
		end
	end

	-- Setup remote function handlers (only if both loaded)
	if RemoteManager and PlayerDataManager then
		local getPlayerData = RemoteManager.getFunction("GetPlayerData")
		if getPlayerData then
			getPlayerData.OnServerInvoke = function(player)
				return PlayerDataManager.getData(player)
			end
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
	if not PlayerDataManager or not RemoteManager then
		warn("[GameManager] Cannot setup player - core systems not loaded")
		return
	end

	-- Load player data
	local ok, data = pcall(function()
		return PlayerDataManager.loadData(player)
	end)

	if not ok or not data then
		warn("[GameManager] Failed to load data for " .. player.Name .. ": " .. tostring(data))
		return
	end

	-- Send initial data to client
	local moneyEvent = RemoteManager.getEvent("MoneyChanged")
	if moneyEvent then
		moneyEvent:FireClient(player, data.money)
	end

	-- Send available jobs
	local jobListEvent = RemoteManager.getEvent("JobListUpdated")
	if jobListEvent then
		local jobOk, _ = pcall(function()
			local JobData = require(ReplicatedStorage.Config.JobData)
			local availableJobs = JobData.getAvailableJobs(data.completedJobs)
			jobListEvent:FireClient(player, availableJobs)
		end)
		if not jobOk then
			warn("[GameManager] Failed to send job list to " .. player.Name)
		end
	end

	-- Notify client that data is ready
	local dataEvent = RemoteManager.getEvent("PlayerDataReceived")
	if dataEvent then
		dataEvent:FireClient(player, data)
	end

	print("[GameManager] Player " .. player.Name .. " setup complete. Money: $" .. data.money)
end

return GameManager
