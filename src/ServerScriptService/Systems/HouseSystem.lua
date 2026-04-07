--[[
	HouseSystem.lua
	Manages house buying, selling, ownership, and state tracking.
	Location: ServerScriptService/Systems/HouseSystem
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HouseData = require(ReplicatedStorage.Config.HouseData)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local RemoteManager = require(script.Parent.Parent.Core.RemoteManager)
local PlayerDataManager = require(script.Parent.Parent.Core.PlayerDataManager)

local HouseSystem = {}

-- Track house states: {[houseId] = {ownerId, furniture, cleanliness, paintedWalls, etc.}}
HouseSystem._houseStates = {}

function HouseSystem.init()
	-- Initialize all houses as available
	for _, house in ipairs(HouseData.Houses) do
		HouseSystem._houseStates[house.id] = {
			ownerId = nil,
			furniture = {}, -- {furnitureId, position, rotation}
			paintedWalls = {}, -- {wallId = colorId}
			tiledSurfaces = {}, -- {surfaceId = tileId}
			cleanliness = house.condition.cleanliness,
			trashRemaining = house.condition.trashCount,
			stainsRemaining = house.condition.stainCount,
			wallCondition = house.condition.wallCondition,
			isListed = false,
		}
	end

	-- Handle buy house
	local buyEvent = RemoteManager.getEvent("BuyHouse")
	if buyEvent then
		buyEvent.OnServerEvent:Connect(function(player, houseId)
			HouseSystem.buyHouse(player, houseId)
		end)
	end

	-- Handle sell/list house
	local listEvent = RemoteManager.getEvent("ListHouse")
	if listEvent then
		listEvent.OnServerEvent:Connect(function(player, houseId)
			HouseSystem.listHouse(player, houseId)
		end)
	end

	-- Handle sell house to buyer
	local sellEvent = RemoteManager.getEvent("SellHouse")
	if sellEvent then
		sellEvent.OnServerEvent:Connect(function(player, houseId, buyerId)
			HouseSystem.sellHouse(player, houseId, buyerId)
		end)
	end

	-- Get house info function
	local getHouseFunc = RemoteManager.getFunction("GetHouseInfo")
	if getHouseFunc then
		getHouseFunc.OnServerInvoke = function(player, houseId)
			return HouseSystem.getHouseInfo(houseId)
		end
	end

	-- Calculate house value function
	local calcValueFunc = RemoteManager.getFunction("CalculateHouseValue")
	if calcValueFunc then
		calcValueFunc.OnServerInvoke = function(player, houseId)
			return HouseSystem.calculateHouseValue(houseId)
		end
	end

	print("[HouseSystem] Initialized with " .. #HouseData.Houses .. " houses")
end

function HouseSystem.buyHouse(player, houseId)
	local data = PlayerDataManager.getData(player)
	if not data then return end

	-- Check max houses
	if #data.ownedHouses >= GameConfig.MAX_HOUSES_OWNED then
		HouseSystem._notify(player, "You already own the maximum number of houses (" .. GameConfig.MAX_HOUSES_OWNED .. ")!")
		return
	end

	-- Get house data
	local house = HouseData.getById(houseId)
	if not house then
		HouseSystem._notify(player, "House not found!")
		return
	end

	-- Check if already owned
	local state = HouseSystem._houseStates[houseId]
	if state and state.ownerId then
		HouseSystem._notify(player, "This house is already owned!")
		return
	end

	-- Try to purchase
	local success, balance = PlayerDataManager.subtractMoney(player, house.purchasePrice)
	if not success then
		HouseSystem._notify(player, string.format(
			"Not enough money! Need $%d, have $%d",
			house.purchasePrice, balance
		))
		return
	end

	-- Transfer ownership
	state.ownerId = tostring(player.UserId)
	PlayerDataManager.addHouse(player, houseId)

	-- Update client
	local moneyEvent = RemoteManager.getEvent("MoneyChanged")
	if moneyEvent then
		moneyEvent:FireClient(player, data.money)
	end

	local houseEvent = RemoteManager.getEvent("HouseUpdated")
	if houseEvent then
		houseEvent:FireClient(player, houseId, "purchased")
	end

	HouseSystem._notify(player, "Purchased " .. house.name .. " for $" .. house.purchasePrice .. "!")
	print("[HouseSystem] " .. player.Name .. " bought " .. house.name)
end

function HouseSystem.listHouse(player, houseId)
	local data = PlayerDataManager.getData(player)
	if not data then return end

	local state = HouseSystem._houseStates[houseId]
	if not state or state.ownerId ~= tostring(player.UserId) then
		HouseSystem._notify(player, "You don't own this house!")
		return
	end

	state.isListed = true

	local houseEvent = RemoteManager.getEvent("HouseUpdated")
	if houseEvent then
		houseEvent:FireClient(player, houseId, "listed")
	end

	HouseSystem._notify(player, "House listed for sale! Check buyer offers.")
end

function HouseSystem.sellHouse(player, houseId, buyerId)
	local data = PlayerDataManager.getData(player)
	if not data then return end

	local state = HouseSystem._houseStates[houseId]
	if not state or state.ownerId ~= tostring(player.UserId) then
		HouseSystem._notify(player, "You don't own this house!")
		return
	end

	-- Calculate sale value using buyer system
	local BuyerSystem = require(script.Parent.BuyerSystem)
	local offer = BuyerSystem.calculateOffer(houseId, buyerId)
	if not offer then
		HouseSystem._notify(player, "This buyer isn't interested in your house.")
		return
	end

	-- Apply negotiation bonus
	local saleBonus = 0
	if data.perks.Negotiation and data.perks.Negotiation.sale_bonus then
		local level = data.perks.Negotiation.sale_bonus
		if level == 1 then saleBonus = 0.05
		elseif level == 2 then saleBonus = 0.10
		elseif level == 3 then saleBonus = 0.15
		end
	end

	local salePrice = math.floor(offer.price * (1 + saleBonus))

	-- Apply sale tax
	local tax = math.floor(salePrice * GameConfig.HOUSE_SALE_TAX)
	local netProfit = salePrice - tax

	-- Complete sale
	PlayerDataManager.addMoney(player, netProfit)
	PlayerDataManager.removeHouse(player, houseId)
	data.housesFlipped = data.housesFlipped + 1

	-- Reset house state
	local house = HouseData.getById(houseId)
	HouseSystem._houseStates[houseId] = {
		ownerId = nil,
		furniture = {},
		paintedWalls = {},
		tiledSurfaces = {},
		cleanliness = house.condition.cleanliness,
		trashRemaining = house.condition.trashCount,
		stainsRemaining = house.condition.stainCount,
		wallCondition = house.condition.wallCondition,
		isListed = false,
	}

	-- Update client
	local moneyEvent = RemoteManager.getEvent("MoneyChanged")
	if moneyEvent then
		moneyEvent:FireClient(player, data.money)
	end

	HouseSystem._notify(player, string.format(
		"House sold to %s for $%d! (Tax: $%d, Net: $%d)",
		offer.buyerName, salePrice, tax, netProfit
	))

	print("[HouseSystem] " .. player.Name .. " sold house " .. houseId .. " for $" .. netProfit)
end

function HouseSystem.calculateHouseValue(houseId)
	local house = HouseData.getById(houseId)
	if not house then return 0 end

	local state = HouseSystem._houseStates[houseId]
	if not state then return house.baseValue end

	local value = house.baseValue

	-- Cleanliness bonus
	local cleanPercent = 1 - (state.trashRemaining + state.stainsRemaining) /
		(house.condition.trashCount + house.condition.stainCount + 1)
	value = value * (1 + cleanPercent * GameConfig.CLEANLINESS_BONUS)

	-- Furniture value (adds to house value)
	local furnitureValue = 0
	local FurnitureData = require(ReplicatedStorage.Config.FurnitureData)
	for _, placed in ipairs(state.furniture) do
		local item = FurnitureData.getById(placed.furnitureId)
		if item then
			furnitureValue = furnitureValue + item.price * 0.7 -- Furniture adds 70% of its cost to value
		end
	end
	value = value + furnitureValue

	-- Painted walls bonus
	local paintedCount = 0
	for _ in pairs(state.paintedWalls) do
		paintedCount = paintedCount + 1
	end
	if paintedCount > 0 then
		value = value * (1 + math.min(paintedCount / 20, 1) * 0.1) -- Up to 10% bonus
	end

	-- Tiled surfaces bonus
	local tiledCount = 0
	for _ in pairs(state.tiledSurfaces) do
		tiledCount = tiledCount + 1
	end
	if tiledCount > 0 then
		value = value * (1 + math.min(tiledCount / 15, 1) * 0.08) -- Up to 8% bonus
	end

	return math.floor(value)
end

function HouseSystem.getHouseInfo(houseId)
	local house = HouseData.getById(houseId)
	if not house then return nil end

	local state = HouseSystem._houseStates[houseId]
	return {
		staticData = house,
		state = state,
		currentValue = HouseSystem.calculateHouseValue(houseId),
	}
end

-- Get house state (used by other systems)
function HouseSystem.getHouseState(houseId)
	return HouseSystem._houseStates[houseId]
end

-- Update house state (used by tool actions)
function HouseSystem.updateHouseState(houseId, field, value)
	local state = HouseSystem._houseStates[houseId]
	if state then
		state[field] = value
	end
end

function HouseSystem._notify(player, message)
	local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
	if notifyEvent then
		notifyEvent:FireClient(player, message)
	end
end

return HouseSystem
