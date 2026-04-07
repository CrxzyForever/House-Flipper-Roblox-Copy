--[[
	RemoteManager.lua
	Creates and manages all RemoteEvents and RemoteFunctions for client-server communication.
	Location: ServerScriptService/Core/RemoteManager
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = {}

-- All remote event/function names organized by system
RemoteManager.Events = {
	-- Economy
	"MoneyChanged",
	"PurchaseItem",
	"SellItem",

	-- Jobs
	"JobListUpdated",
	"AcceptJob",
	"CompleteJob",
	"JobTaskProgress",

	-- House
	"BuyHouse",
	"SellHouse",
	"ListHouse",
	"EnterHouse",
	"ExitHouse",
	"HouseUpdated",

	-- Tools
	"ToolAction",
	"ToolEquipped",
	"CleanStain",
	"CleanTrash",
	"PaintWall",
	"TileSurface",
	"DemolishWall",
	"BuildWall",
	"PlasterWall",
	"CleanWindow",
	"InstallFixture",

	-- Furniture
	"PlaceFurniture",
	"MoveFurniture",
	"RemoveFurniture",
	"RotateFurniture",
	"FurniturePlaced",

	-- Perks
	"UnlockPerk",
	"PerkUnlocked",
	"XPGained",

	-- Buyers
	"RequestBuyerOffers",
	"BuyerOffersReceived",
	"AcceptBuyerOffer",

	-- Room Detection
	"RoomDetected",
	"RoomsUpdated",

	-- UI / General
	"NotifyPlayer",
	"RequestPlayerData",
	"PlayerDataReceived",
}

RemoteManager.Functions = {
	"GetPlayerData",
	"GetAvailableJobs",
	"GetHouseInfo",
	"GetBuyerOffers",
	"GetFurnitureInRoom",
	"CalculateHouseValue",
}

function RemoteManager.init()
	-- Create remotes folder
	local remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage

	local eventsFolder = Instance.new("Folder")
	eventsFolder.Name = "Events"
	eventsFolder.Parent = remotesFolder

	local functionsFolder = Instance.new("Folder")
	functionsFolder.Name = "Functions"
	functionsFolder.Parent = remotesFolder

	-- Create all RemoteEvents
	for _, eventName in ipairs(RemoteManager.Events) do
		local remote = Instance.new("RemoteEvent")
		remote.Name = eventName
		remote.Parent = eventsFolder
	end

	-- Create all RemoteFunctions
	for _, funcName in ipairs(RemoteManager.Functions) do
		local remote = Instance.new("RemoteFunction")
		remote.Name = funcName
		remote.Parent = functionsFolder
	end

	print("[RemoteManager] Initialized " .. #RemoteManager.Events .. " events and " .. #RemoteManager.Functions .. " functions.")
end

-- Helper: get a RemoteEvent by name
function RemoteManager.getEvent(name)
	local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if remotesFolder then
		local eventsFolder = remotesFolder:FindFirstChild("Events")
		if eventsFolder then
			return eventsFolder:FindFirstChild(name)
		end
	end
	warn("[RemoteManager] Event not found: " .. name)
	return nil
end

-- Helper: get a RemoteFunction by name
function RemoteManager.getFunction(name)
	local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if remotesFolder then
		local functionsFolder = remotesFolder:FindFirstChild("Functions")
		if functionsFolder then
			return functionsFolder:FindFirstChild(name)
		end
	end
	warn("[RemoteManager] Function not found: " .. name)
	return nil
end

return RemoteManager
