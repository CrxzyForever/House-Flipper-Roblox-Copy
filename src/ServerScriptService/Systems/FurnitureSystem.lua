--[[
	FurnitureSystem.lua
	Server-side validation for furniture placement, movement, and removal.
	Location: ServerScriptService/Systems/FurnitureSystem
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FurnitureData = require(ReplicatedStorage.Config.FurnitureData)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local RemoteManager = require(script.Parent.Parent.Core.RemoteManager)
local PlayerDataManager = require(script.Parent.Parent.Core.PlayerDataManager)

local FurnitureSystem = {}

function FurnitureSystem.init()
	-- Handle furniture placement
	local placeEvent = RemoteManager.getEvent("PlaceFurniture")
	if placeEvent then
		placeEvent.OnServerEvent:Connect(function(player, houseId, furnitureId, position, rotation)
			FurnitureSystem.placeFurniture(player, houseId, furnitureId, position, rotation)
		end)
	end

	-- Handle furniture movement
	local moveEvent = RemoteManager.getEvent("MoveFurniture")
	if moveEvent then
		moveEvent.OnServerEvent:Connect(function(player, houseId, placementIndex, newPosition, newRotation)
			FurnitureSystem.moveFurniture(player, houseId, placementIndex, newPosition, newRotation)
		end)
	end

	-- Handle furniture removal
	local removeEvent = RemoteManager.getEvent("RemoveFurniture")
	if removeEvent then
		removeEvent.OnServerEvent:Connect(function(player, houseId, placementIndex)
			FurnitureSystem.removeFurniture(player, houseId, placementIndex)
		end)
	end

	print("[FurnitureSystem] Initialized")
end

function FurnitureSystem.placeFurniture(player, houseId, furnitureId, position, rotation)
	local data = PlayerDataManager.getData(player)
	if not data then return end

	-- Verify player owns the house
	local HouseSystem = require(script.Parent.HouseSystem)
	local houseState = HouseSystem.getHouseState(houseId)
	if not houseState or houseState.ownerId ~= tostring(player.UserId) then
		FurnitureSystem._notify(player, "You don't own this house!")
		return
	end

	-- Verify furniture exists in catalog
	local furnitureInfo = FurnitureData.getById(furnitureId)
	if not furnitureInfo then
		FurnitureSystem._notify(player, "Invalid furniture item!")
		return
	end

	-- Check if the item requires installation (needs installation tool)
	if furnitureInfo.requiresInstallation then
		if not PlayerDataManager.hasTool(player, "InstallationTool") then
			FurnitureSystem._notify(player, "You need the Installation Tool to place this item!")
			return
		end
	end

	-- Validate position is within house bounds
	-- (Simplified: in full implementation, use house boundary checking)
	if not position or typeof(position) ~= "Vector3" then
		FurnitureSystem._notify(player, "Invalid placement position!")
		return
	end

	-- Add furniture to house state
	local placement = {
		furnitureId = furnitureId,
		position = position,
		rotation = rotation or CFrame.new(),
		placedBy = tostring(player.UserId),
		timestamp = os.time(),
	}

	table.insert(houseState.furniture, placement)

	-- Update stats
	PlayerDataManager.incrementStat(player, "furniturePlaced")

	-- Trigger room re-detection
	local furniturePlacedEvent = RemoteManager.getEvent("FurniturePlaced")
	if furniturePlacedEvent then
		furniturePlacedEvent:FireClient(player, houseId)
	end

	-- Notify about installation requirement
	if furnitureInfo.requiresInstallation then
		PlayerDataManager.incrementStat(player, "fixturesInstalled")
		FurnitureSystem._notify(player, furnitureInfo.name .. " installed!")
	else
		FurnitureSystem._notify(player, furnitureInfo.name .. " placed!")
	end
end

function FurnitureSystem.moveFurniture(player, houseId, placementIndex, newPosition, newRotation)
	local HouseSystem = require(script.Parent.HouseSystem)
	local houseState = HouseSystem.getHouseState(houseId)
	if not houseState or houseState.ownerId ~= tostring(player.UserId) then
		FurnitureSystem._notify(player, "You don't own this house!")
		return
	end

	local placement = houseState.furniture[placementIndex]
	if not placement then
		FurnitureSystem._notify(player, "Furniture not found!")
		return
	end

	placement.position = newPosition
	placement.rotation = newRotation or placement.rotation

	-- Trigger room re-detection
	local furniturePlacedEvent = RemoteManager.getEvent("FurniturePlaced")
	if furniturePlacedEvent then
		furniturePlacedEvent:FireClient(player, houseId)
	end
end

function FurnitureSystem.removeFurniture(player, houseId, placementIndex)
	local data = PlayerDataManager.getData(player)
	if not data then return end

	local HouseSystem = require(script.Parent.HouseSystem)
	local houseState = HouseSystem.getHouseState(houseId)
	if not houseState or houseState.ownerId ~= tostring(player.UserId) then
		FurnitureSystem._notify(player, "You don't own this house!")
		return
	end

	local placement = houseState.furniture[placementIndex]
	if not placement then return end

	-- Refund half the furniture cost
	local furnitureInfo = FurnitureData.getById(placement.furnitureId)
	if furnitureInfo then
		local refund = math.floor(furnitureInfo.price * GameConfig.FURNITURE_RESALE_MULTIPLIER)
		PlayerDataManager.addMoney(player, refund)

		local moneyEvent = RemoteManager.getEvent("MoneyChanged")
		if moneyEvent then
			moneyEvent:FireClient(player, data.money)
		end

		FurnitureSystem._notify(player, furnitureInfo.name .. " removed! Refunded $" .. refund)
	end

	table.remove(houseState.furniture, placementIndex)

	-- Trigger room re-detection
	local furniturePlacedEvent = RemoteManager.getEvent("FurniturePlaced")
	if furniturePlacedEvent then
		furniturePlacedEvent:FireClient(player, houseId)
	end
end

function FurnitureSystem._notify(player, message)
	local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
	if notifyEvent then
		notifyEvent:FireClient(player, message)
	end
end

return FurnitureSystem
