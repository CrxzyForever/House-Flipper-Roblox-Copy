--[[
	RoomDetector.lua
	Auto-detects room types based on furniture placed within walls.
	Location: ServerScriptService/Systems/RoomDetector
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoomData = require(ReplicatedStorage.Config.RoomData)
local FurnitureData = require(ReplicatedStorage.Config.FurnitureData)
local RemoteManager = require(script.Parent.Parent.Core.RemoteManager)

local RoomDetector = {}

-- Cache of detected rooms per house: {[houseId] = {[roomIndex] = {type, label, score}}}
RoomDetector._detectedRooms = {}

function RoomDetector.init()
	-- Listen for furniture placement to re-detect rooms
	local furniturePlacedEvent = RemoteManager.getEvent("FurniturePlaced")
	if furniturePlacedEvent then
		furniturePlacedEvent.OnServerEvent:Connect(function(player, houseId)
			RoomDetector.detectRooms(houseId, player)
		end)
	end

	-- Remote function to get rooms for a house
	local getFurnitureFunc = RemoteManager.getFunction("GetFurnitureInRoom")
	if getFurnitureFunc then
		getFurnitureFunc.OnServerInvoke = function(player, houseId)
			return RoomDetector._detectedRooms[houseId] or {}
		end
	end

	print("[RoomDetector] Initialized")
end

-- Detect rooms in a house based on furniture placement
-- In Roblox, rooms are defined by physical wall parts that enclose an area.
-- Furniture within those walls determines the room type.
function RoomDetector.detectRooms(houseId, notifyPlayer)
	local HouseSystem = require(script.Parent.HouseSystem)
	local houseState = HouseSystem.getHouseState(houseId)
	if not houseState then return end

	-- In a full implementation, we'd use raycasting to determine which furniture
	-- is inside which walled area. For now, we use a simplified zone-based approach.

	-- Group furniture by their zone (determined by position within house layout)
	local zones = RoomDetector._groupFurnitureByZone(houseId, houseState.furniture)

	local detectedRooms = {}

	for zoneIndex, zoneFurniture in ipairs(zones) do
		-- Collect all room tags from furniture in this zone
		local tags = {}
		for _, placedItem in ipairs(zoneFurniture.items) do
			local furnitureInfo = FurnitureData.getById(placedItem.furnitureId)
			if furnitureInfo and furnitureInfo.roomTag then
				table.insert(tags, furnitureInfo.roomTag)
			end
		end

		-- Check against room type definitions
		local roomMatches = RoomData.checkRoomType(tags, zoneFurniture.area)

		if #roomMatches > 0 then
			-- Pick the best matching room type (highest score)
			local bestMatch = roomMatches[1]
			for _, match in ipairs(roomMatches) do
				if match.score > bestMatch.score then
					bestMatch = match
				end
			end
			detectedRooms[zoneIndex] = bestMatch
		end
	end

	RoomDetector._detectedRooms[houseId] = detectedRooms

	-- Notify the player about updated room detection
	if notifyPlayer then
		local roomsEvent = RemoteManager.getEvent("RoomsUpdated")
		if roomsEvent then
			roomsEvent:FireClient(notifyPlayer, houseId, detectedRooms)
		end
	end

	return detectedRooms
end

-- Group furniture into zones based on position
-- This is a simplified version; a full implementation would use
-- wall collision detection or region3 checks
function RoomDetector._groupFurnitureByZone(houseId, furnitureList)
	-- For the prototype, we'll use a grid-based zone system
	-- Each 20x20 stud area counts as a potential room zone
	local ZONE_SIZE = 20
	local zones = {} -- {[zoneKey] = {items = {}, area = number}}
	local zoneArray = {}

	for _, placed in ipairs(furnitureList) do
		if placed.position then
			local zoneX = math.floor(placed.position.X / ZONE_SIZE)
			local zoneZ = math.floor(placed.position.Z / ZONE_SIZE)
			local key = zoneX .. "_" .. zoneZ

			if not zones[key] then
				zones[key] = {
					items = {},
					area = ZONE_SIZE * ZONE_SIZE, -- Simplified: each zone is ZONE_SIZE²
					center = Vector3.new(zoneX * ZONE_SIZE + ZONE_SIZE/2, 0, zoneZ * ZONE_SIZE + ZONE_SIZE/2),
				}
			end

			table.insert(zones[key].items, placed)
		end
	end

	-- Convert to array
	for _, zone in pairs(zones) do
		table.insert(zoneArray, zone)
	end

	return zoneArray
end

-- Get detected rooms for a house
function RoomDetector.getDetectedRooms(houseId)
	return RoomDetector._detectedRooms[houseId] or {}
end

-- Count rooms of a specific type in a house
function RoomDetector.countRoomType(houseId, roomType)
	local rooms = RoomDetector._detectedRooms[houseId] or {}
	local count = 0
	for _, room in pairs(rooms) do
		if room.type == roomType then
			count = count + 1
		end
	end
	return count
end

return RoomDetector
