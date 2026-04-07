--[[
	Client Bootstrap
	Initializes all client-side controllers for House Flipper.
	Location: StarterPlayerScripts/init (LocalScript)

	NOTE: In Roblox Studio, this should be a LocalScript.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Wait for remotes to be created by server
ReplicatedStorage:WaitForChild("Remotes")

-- Import controllers
local ToolController = require(script.Controllers.ToolController)
local PlacementController = require(script.Controllers.PlacementController)
local CameraController = require(script.Controllers.CameraController)

-- Wait for player data from server
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local events = remotes:WaitForChild("Events")

local playerData = nil

-- Listen for initial player data
local dataReceivedEvent = events:WaitForChild("PlayerDataReceived")
dataReceivedEvent.OnClientEvent:Connect(function(data)
	playerData = data

	-- Initialize all controllers with player data
	ToolController.init(playerData)
	PlacementController.init()
	CameraController.init()

	print("[Client] All controllers initialized for " .. player.Name)
end)

-- Also try to get data via RemoteFunction (in case event was already fired)
task.spawn(function()
	task.wait(2) -- Give server time to setup
	if not playerData then
		local functions = remotes:WaitForChild("Functions")
		local getDataFunc = functions:WaitForChild("GetPlayerData")
		playerData = getDataFunc:InvokeServer()

		if playerData then
			ToolController.init(playerData)
			PlacementController.init()
			CameraController.init()
			print("[Client] Controllers initialized via fallback for " .. player.Name)
		end
	end
end)

-- Listen for money changes
local moneyEvent = events:WaitForChild("MoneyChanged")
moneyEvent.OnClientEvent:Connect(function(newAmount)
	if playerData then
		playerData.money = newAmount
	end
end)

-- Listen for notifications
local notifyEvent = events:WaitForChild("NotifyPlayer")
notifyEvent.OnClientEvent:Connect(function(message)
	-- Display notification (UI system handles the visual)
	print("[Notification] " .. message)
end)

print("[Client] House Flipper client script loaded. Waiting for player data...")
