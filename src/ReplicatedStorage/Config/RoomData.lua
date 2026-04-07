--[[
	RoomData.lua
	Room type definitions and furniture requirements for auto-detection.
	Location: ReplicatedStorage/Config/RoomData
]]

local Enums = require(script.Parent.Parent.Shared.Enums)

local RoomData = {}

-- Room detection rules
-- A room is classified based on the furniture tags present within its walls.
-- requiredTags: ALL of these must be present for the room to qualify
-- optionalTags: bonus items that improve the room's quality score
-- minSize: minimum room area in studs² for this classification
-- sizeLabels: size thresholds for Small/Medium/Large variants

RoomData.RoomTypes = {
	[Enums.RoomType.Kitchen] = {
		name = "Kitchen",
		icon = "rbxassetid://0",
		requiredTags = {"KitchenSink", "Oven"},
		-- Must have sink + oven/stove. Refrigerator is common but optional for detection
		optionalTags = {"Refrigerator", "Counter", "Cabinet", "Microwave", "DiningTable"},
		minSize = 20,
		sizeLabels = {
			{threshold = 0, label = "Tiny Kitchen"},
			{threshold = 33, label = "Small Kitchen"},
			{threshold = 50, label = "Kitchen"},
			{threshold = 66, label = "Large Kitchen"},
		},
		qualityFactors = {
			baseScore = 50,
			perOptionalItem = 10,
			cleanlinessWeight = 0.2,
			paintWeight = 0.15,
			tileWeight = 0.15,
		},
	},

	[Enums.RoomType.Bathroom] = {
		name = "Bathroom",
		icon = "rbxassetid://0",
		requiredTags = {"Toilet", "BathroomSink"},
		optionalTags = {"Shower", "Bathtub", "Mirror", "TowelRack", "Cabinet"},
		minSize = 16,
		sizeLabels = {
			{threshold = 0, label = "Tiny Bathroom"},
			{threshold = 25, label = "Small Bathroom"},
			{threshold = 40, label = "Bathroom"},
			{threshold = 60, label = "Large Bathroom"},
		},
		qualityFactors = {
			baseScore = 50,
			perOptionalItem = 12,
			cleanlinessWeight = 0.3, -- Bathrooms care more about cleanliness
			paintWeight = 0.1,
			tileWeight = 0.2, -- Tiling is important in bathrooms
		},
	},

	[Enums.RoomType.Bedroom] = {
		name = "Bedroom",
		icon = "rbxassetid://0",
		requiredTags = {"Bed"},
		optionalTags = {"Wardrobe", "Dresser", "Nightstand", "Lamp", "Curtains", "Carpet"},
		minSize = 30,
		sizeLabels = {
			{threshold = 0, label = "Tiny Bedroom"},
			{threshold = 40, label = "Small Bedroom"},
			{threshold = 60, label = "Bedroom"},
			{threshold = 80, label = "Large Bedroom"},
			{threshold = 100, label = "Master Bedroom"},
		},
		qualityFactors = {
			baseScore = 40,
			perOptionalItem = 10,
			cleanlinessWeight = 0.2,
			paintWeight = 0.2,
			tileWeight = 0.05,
		},
	},

	[Enums.RoomType.LivingRoom] = {
		name = "Living Room",
		icon = "rbxassetid://0",
		requiredTags = {"Sofa", "CoffeeTable"},
		optionalTags = {"TV", "TVStand", "Bookcase", "Lamp", "Carpet", "Curtains", "Plant", "Picture"},
		minSize = 36, -- ~11m²
		sizeLabels = {
			{threshold = 0, label = "Small Living Room"},
			{threshold = 50, label = "Living Room"},
			{threshold = 80, label = "Large Living Room"},
			{threshold = 110, label = "Grand Living Room"},
		},
		qualityFactors = {
			baseScore = 45,
			perOptionalItem = 8,
			cleanlinessWeight = 0.2,
			paintWeight = 0.2,
			tileWeight = 0.1,
		},
	},

	[Enums.RoomType.Office] = {
		name = "Office",
		icon = "rbxassetid://0",
		requiredTags = {"Desk", "OfficeChair", "Cabinet", "Bookcase"},
		-- Original game requires 5 items including picture/carpet
		optionalTags = {"Picture", "Carpet", "Lamp", "Plant", "Clock"},
		minSize = 25,
		sizeLabels = {
			{threshold = 0, label = "Small Office"},
			{threshold = 40, label = "Office"},
			{threshold = 65, label = "Large Office"},
		},
		qualityFactors = {
			baseScore = 55,
			perOptionalItem = 10,
			cleanlinessWeight = 0.15,
			paintWeight = 0.2,
			tileWeight = 0.1,
		},
	},

	[Enums.RoomType.DiningRoom] = {
		name = "Dining Room",
		icon = "rbxassetid://0",
		requiredTags = {"DiningTable", "DiningChair"},
		optionalTags = {"Cabinet", "Lamp", "Curtains", "Picture", "Plant"},
		minSize = 30,
		sizeLabels = {
			{threshold = 0, label = "Small Dining Room"},
			{threshold = 45, label = "Dining Room"},
			{threshold = 70, label = "Large Dining Room"},
		},
		qualityFactors = {
			baseScore = 40,
			perOptionalItem = 10,
			cleanlinessWeight = 0.2,
			paintWeight = 0.15,
			tileWeight = 0.1,
		},
	},

	[Enums.RoomType.Garage] = {
		name = "Garage",
		icon = "rbxassetid://0",
		requiredTags = {"Workbench"},
		optionalTags = {"Cabinet", "Radiator"},
		minSize = 40,
		sizeLabels = {
			{threshold = 0, label = "Small Garage"},
			{threshold = 60, label = "Garage"},
			{threshold = 90, label = "Large Garage"},
		},
		qualityFactors = {
			baseScore = 30,
			perOptionalItem = 8,
			cleanlinessWeight = 0.1,
			paintWeight = 0.05,
			tileWeight = 0.05,
		},
	},

	[Enums.RoomType.LaundryRoom] = {
		name = "Laundry Room",
		icon = "rbxassetid://0",
		requiredTags = {"WashingMachine"},
		optionalTags = {"Cabinet", "Counter"},
		minSize = 16,
		sizeLabels = {
			{threshold = 0, label = "Laundry Closet"},
			{threshold = 25, label = "Laundry Room"},
			{threshold = 40, label = "Large Laundry Room"},
		},
		qualityFactors = {
			baseScore = 30,
			perOptionalItem = 8,
			cleanlinessWeight = 0.15,
			paintWeight = 0.1,
			tileWeight = 0.15,
		},
	},
}

-- Helper: check if a set of furniture tags satisfies a room type
function RoomData.checkRoomType(furnitureTags, roomArea)
	local detectedRooms = {}

	for roomType, roomDef in pairs(RoomData.RoomTypes) do
		if roomArea >= roomDef.minSize then
			-- Check all required tags are present
			local allRequired = true
			for _, reqTag in ipairs(roomDef.requiredTags) do
				local found = false
				for _, tag in ipairs(furnitureTags) do
					if tag == reqTag then
						found = true
						break
					end
				end
				if not found then
					allRequired = false
					break
				end
			end

			if allRequired then
				-- Count optional items
				local optionalCount = 0
				for _, optTag in ipairs(roomDef.optionalTags) do
					for _, tag in ipairs(furnitureTags) do
						if tag == optTag then
							optionalCount = optionalCount + 1
							break
						end
					end
				end

				-- Determine size label
				local sizeLabel = roomDef.name
				for _, sl in ipairs(roomDef.sizeLabels) do
					if roomArea >= sl.threshold then
						sizeLabel = sl.label
					end
				end

				table.insert(detectedRooms, {
					type = roomType,
					label = sizeLabel,
					optionalItems = optionalCount,
					score = roomDef.qualityFactors.baseScore + (optionalCount * roomDef.qualityFactors.perOptionalItem),
				})
			end
		end
	end

	return detectedRooms
end

return RoomData
