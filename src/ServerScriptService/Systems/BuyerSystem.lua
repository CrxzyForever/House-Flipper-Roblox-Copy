--[[
	BuyerSystem.lua
	Manages buyer matching, offer generation, and house sale negotiations.
	Location: ServerScriptService/Systems/BuyerSystem
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuyerData = require(ReplicatedStorage.Config.BuyerData)
local HouseData = require(ReplicatedStorage.Config.HouseData)
local FurnitureData = require(ReplicatedStorage.Config.FurnitureData)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local RemoteManager = require(script.Parent.Parent.Core.RemoteManager)

local BuyerSystem = {}

function BuyerSystem.init()
	-- Handle buyer offer requests
	local requestOffersEvent = RemoteManager.getEvent("RequestBuyerOffers")
	if requestOffersEvent then
		requestOffersEvent.OnServerEvent:Connect(function(player, houseId)
			local offers = BuyerSystem.generateOffers(houseId)
			local offersEvent = RemoteManager.getEvent("BuyerOffersReceived")
			if offersEvent then
				offersEvent:FireClient(player, houseId, offers)
			end
		end)
	end

	-- Get buyer offers function
	local getOffersFunc = RemoteManager.getFunction("GetBuyerOffers")
	if getOffersFunc then
		getOffersFunc.OnServerInvoke = function(player, houseId)
			return BuyerSystem.generateOffers(houseId)
		end
	end

	print("[BuyerSystem] Initialized with " .. #BuyerData.Buyers .. " buyers")
end

-- Generate offers from all interested buyers for a house
function BuyerSystem.generateOffers(houseId)
	local HouseSystem = require(script.Parent.HouseSystem)
	local houseInfo = HouseSystem.getHouseInfo(houseId)
	if not houseInfo then return {} end

	local offers = {}

	for _, buyer in ipairs(BuyerData.Buyers) do
		local offer = BuyerSystem.calculateOffer(houseId, buyer.id)
		if offer and offer.satisfaction > 0.3 then -- Minimum 30% satisfaction to make an offer
			table.insert(offers, offer)
		end
	end

	-- Sort by price (highest first)
	table.sort(offers, function(a, b) return a.price > b.price end)

	return offers
end

-- Calculate a specific buyer's offer for a house
function BuyerSystem.calculateOffer(houseId, buyerId)
	local HouseSystem = require(script.Parent.HouseSystem)
	local RoomDetector = require(script.Parent.RoomDetector)

	local houseInfo = HouseSystem.getHouseInfo(houseId)
	if not houseInfo then return nil end

	local buyer = BuyerData.getById(buyerId)
	if not buyer then return nil end

	local house = houseInfo.staticData
	local state = houseInfo.state
	local baseValue = houseInfo.currentValue

	-- === Calculate satisfaction score (0.0 to 1.0) ===
	local satisfactionFactors = {}
	local totalWeight = 0
	local totalScore = 0

	-- 1. House size check
	local sizeOk = true
	if buyer.minHouseSize == "Medium" and house.sizeCategory == "Small" then
		sizeOk = false
	elseif buyer.minHouseSize == "Large" and house.sizeCategory ~= "Large" then
		sizeOk = false
	end

	if not sizeOk then
		return {
			buyerId = buyerId,
			buyerName = buyer.name,
			price = 0,
			satisfaction = 0,
			reason = "House is too small for this buyer.",
		}
	end

	-- 2. Required rooms check
	local detectedRooms = RoomDetector.getDetectedRooms(houseId)
	local roomsPresent = {}
	for _, room in pairs(detectedRooms) do
		roomsPresent[room.type] = true
	end

	local requiredRoomScore = 0
	local requiredRoomCount = #buyer.requiredRooms
	for _, reqRoom in ipairs(buyer.requiredRooms) do
		if roomsPresent[reqRoom] then
			requiredRoomScore = requiredRoomScore + 1
		end
	end
	local roomSatisfaction = requiredRoomCount > 0 and (requiredRoomScore / requiredRoomCount) or 1.0
	totalScore = totalScore + roomSatisfaction * 0.3
	totalWeight = totalWeight + 0.3

	-- 3. Preferred rooms bonus
	local preferredRoomScore = 0
	for _, prefRoom in ipairs(buyer.preferredRooms) do
		if roomsPresent[prefRoom] then
			preferredRoomScore = preferredRoomScore + 1
		end
	end
	if #buyer.preferredRooms > 0 then
		totalScore = totalScore + (preferredRoomScore / #buyer.preferredRooms) * 0.1
		totalWeight = totalWeight + 0.1
	end

	-- 4. Cleanliness
	local cleanPercent = 1
	local totalDirt = house.condition.trashCount + house.condition.stainCount
	if totalDirt > 0 then
		local remainingDirt = (state.trashRemaining or 0) + (state.stainsRemaining or 0)
		cleanPercent = 1 - (remainingDirt / totalDirt)
	end
	totalScore = totalScore + cleanPercent * 0.2
	totalWeight = totalWeight + 0.2

	-- 5. Style matching (check furniture styles against buyer preference)
	local styleMatchCount = 0
	local totalFurniture = #state.furniture
	if totalFurniture > 0 then
		for _, placed in ipairs(state.furniture) do
			local item = FurnitureData.getById(placed.furnitureId)
			if item and item.style == buyer.preferredStyle then
				styleMatchCount = styleMatchCount + 1
			end
		end
		local stylePercent = styleMatchCount / totalFurniture
		totalScore = totalScore + stylePercent * 0.2
		totalWeight = totalWeight + 0.2
	else
		totalScore = totalScore + 0.05 -- Small score for empty (at least it's clean)
		totalWeight = totalWeight + 0.2
	end

	-- 6. Liked items bonus
	local likedCount = 0
	for _, placed in ipairs(state.furniture) do
		local item = FurnitureData.getById(placed.furnitureId)
		if item then
			for _, liked in ipairs(buyer.likedItems) do
				if item.roomTag == liked or item.style == liked then
					likedCount = likedCount + 1
					break
				end
			end
		end
	end
	if totalFurniture > 0 then
		totalScore = totalScore + math.min(likedCount / 5, 1.0) * 0.1
		totalWeight = totalWeight + 0.1
	end

	-- 7. Disliked items penalty
	local dislikedCount = 0
	for _, placed in ipairs(state.furniture) do
		local item = FurnitureData.getById(placed.furnitureId)
		if item then
			for _, disliked in ipairs(buyer.dislikedItems) do
				if item.roomTag == disliked or item.style == disliked then
					dislikedCount = dislikedCount + 1
					break
				end
			end
		end
	end
	local dislikedPenalty = math.min(dislikedCount * 0.05, 0.3) -- Max 30% penalty
	totalScore = totalScore - dislikedPenalty

	-- Normalize satisfaction
	local satisfaction = totalWeight > 0 and math.clamp(totalScore / totalWeight, 0, 1) or 0

	-- Calculate final offer price
	local offerPrice = math.floor(baseValue * buyer.budgetMultiplier * satisfaction)

	return {
		buyerId = buyerId,
		buyerName = buyer.name,
		buyerBio = buyer.bio,
		price = offerPrice,
		satisfaction = satisfaction,
		details = {
			roomScore = roomSatisfaction,
			cleanScore = cleanPercent,
			styleScore = totalFurniture > 0 and (styleMatchCount / totalFurniture) or 0,
			likedItems = likedCount,
			dislikedItems = dislikedCount,
		},
	}
end

return BuyerSystem
