--[[
	EconomySystem.lua
	Handles all money transactions, purchases, and sales validation.
	Location: ServerScriptService/Systems/EconomySystem
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FurnitureData = require(ReplicatedStorage.Config.FurnitureData)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local RemoteManager = require(script.Parent.Parent.Core.RemoteManager)
local PlayerDataManager = require(script.Parent.Parent.Core.PlayerDataManager)

local EconomySystem = {}

function EconomySystem.init()
	-- Handle purchase requests
	local purchaseEvent = RemoteManager.getEvent("PurchaseItem")
	if purchaseEvent then
		purchaseEvent.OnServerEvent:Connect(function(player, itemType, itemId, quantity)
			EconomySystem.purchaseItem(player, itemType, itemId, quantity or 1)
		end)
	end

	-- Handle sell requests
	local sellEvent = RemoteManager.getEvent("SellItem")
	if sellEvent then
		sellEvent.OnServerEvent:Connect(function(player, itemType, itemId, quantity)
			EconomySystem.sellItem(player, itemType, itemId, quantity or 1)
		end)
	end

	print("[EconomySystem] Initialized")
end

-- Purchase furniture, paint, or tiles
function EconomySystem.purchaseItem(player, itemType, itemId, quantity)
	local data = PlayerDataManager.getData(player)
	if not data then return false end

	local totalCost = 0
	local itemName = ""

	-- Calculate discount from negotiation perks
	local discount = 0
	if data.perks.Negotiation and data.perks.Negotiation.discount then
		local level = data.perks.Negotiation.discount
		if level == 1 then discount = 0.05
		elseif level == 2 then discount = 0.10
		elseif level == 3 then discount = 0.15
		end
	end

	if itemType == "furniture" then
		local item = FurnitureData.getById(itemId)
		if not item then
			EconomySystem._notify(player, "Item not found!")
			return false
		end
		totalCost = math.floor(item.price * quantity * (1 - discount))
		itemName = item.name

	elseif itemType == "paint" then
		for _, paint in ipairs(FurnitureData.PaintColors) do
			if paint.id == itemId then
				totalCost = math.floor(paint.price * quantity * (1 - discount))
				itemName = paint.name .. " Paint"
				break
			end
		end

	elseif itemType == "tile" then
		for _, tile in ipairs(FurnitureData.TileOptions) do
			if tile.id == itemId then
				totalCost = math.floor(tile.price * quantity * (1 - discount))
				itemName = tile.name
				break
			end
		end
	end

	if totalCost <= 0 then
		EconomySystem._notify(player, "Invalid item!")
		return false
	end

	-- Attempt purchase
	local success, newBalance = PlayerDataManager.subtractMoney(player, totalCost)
	if not success then
		EconomySystem._notify(player, "Not enough money! Need $" .. totalCost .. ", have $" .. newBalance)
		return false
	end

	-- Add to inventory
	if itemType == "paint" then
		data.inventory.paint[itemId] = (data.inventory.paint[itemId] or 0) + quantity
	elseif itemType == "tile" then
		data.inventory.tiles[itemId] = (data.inventory.tiles[itemId] or 0) + quantity
	end
	-- Furniture is placed directly, tracked by house system

	-- Update client
	local moneyEvent = RemoteManager.getEvent("MoneyChanged")
	if moneyEvent then
		moneyEvent:FireClient(player, data.money)
	end

	EconomySystem._notify(player, string.format("Purchased %dx %s for $%d", quantity, itemName, totalCost))
	return true
end

-- Sell back furniture or materials
function EconomySystem.sellItem(player, itemType, itemId, quantity)
	local data = PlayerDataManager.getData(player)
	if not data then return false end

	local refundPerUnit = 0
	local itemName = ""

	if itemType == "furniture" then
		local item = FurnitureData.getById(itemId)
		if item then
			refundPerUnit = math.floor(item.price * GameConfig.FURNITURE_RESALE_MULTIPLIER)
			itemName = item.name
		end
	elseif itemType == "paint" then
		if data.inventory.paint[itemId] and data.inventory.paint[itemId] >= quantity then
			for _, paint in ipairs(FurnitureData.PaintColors) do
				if paint.id == itemId then
					refundPerUnit = math.floor(paint.price * GameConfig.FURNITURE_RESALE_MULTIPLIER)
					itemName = paint.name .. " Paint"
					break
				end
			end
			data.inventory.paint[itemId] = data.inventory.paint[itemId] - quantity
		else
			EconomySystem._notify(player, "You don't have enough of that item!")
			return false
		end
	elseif itemType == "tile" then
		if data.inventory.tiles[itemId] and data.inventory.tiles[itemId] >= quantity then
			for _, tile in ipairs(FurnitureData.TileOptions) do
				if tile.id == itemId then
					refundPerUnit = math.floor(tile.price * GameConfig.FURNITURE_RESALE_MULTIPLIER)
					itemName = tile.name
					break
				end
			end
			data.inventory.tiles[itemId] = data.inventory.tiles[itemId] - quantity
		else
			EconomySystem._notify(player, "You don't have enough of that item!")
			return false
		end
	end

	if refundPerUnit <= 0 then return false end

	local totalRefund = refundPerUnit * quantity
	PlayerDataManager.addMoney(player, totalRefund)

	local moneyEvent = RemoteManager.getEvent("MoneyChanged")
	if moneyEvent then
		moneyEvent:FireClient(player, data.money)
	end

	EconomySystem._notify(player, string.format("Sold %dx %s for $%d", quantity, itemName, totalRefund))
	return true
end

-- Internal notify helper
function EconomySystem._notify(player, message)
	local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
	if notifyEvent then
		notifyEvent:FireClient(player, message)
	end
end

return EconomySystem
