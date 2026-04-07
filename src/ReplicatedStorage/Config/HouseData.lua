--[[
	HouseData.lua
	House definitions with prices, sizes, locations, and initial conditions.
	Location: ReplicatedStorage/Config/HouseData
]]

local HouseData = {}

-- House size categories (in studs²)
HouseData.SizeCategory = {
	Small = {min = 0, max = 330},     -- < ~100m²
	Medium = {min = 330, max = 660},   -- 100-200m²
	Large = {min = 660, max = math.huge}, -- > 200m²
}

-- All purchasable houses
HouseData.Houses = {
	-- ============ STARTER HOUSES ============
	{
		id = "starter_shack",
		name = "The Old Shack",
		description = "A tiny rundown shack. Perfect for a beginner flipper.",
		purchasePrice = 5000,
		baseValue = 8000,
		sizeStuds = 200, -- ~60m²
		sizeCategory = "Small",
		location = Vector3.new(100, 0, 100),
		rooms = 3, -- Number of rooms
		floors = 1,
		hasGarden = false,
		condition = {
			cleanliness = 0.2,
			wallCondition = 0.3,
			needsPaint = true,
			needsTiling = true,
			hasDamage = false,
			trashCount = 15,
			stainCount = 10,
		},
		preInstalledFurniture = {}, -- Comes empty
	},
	{
		id = "suburban_fixer",
		name = "Suburban Fixer-Upper",
		description = "A neglected suburban home with good bones.",
		purchasePrice = 15000,
		baseValue = 25000,
		sizeStuds = 400,
		sizeCategory = "Medium",
		location = Vector3.new(200, 0, 100),
		rooms = 5,
		floors = 1,
		hasGarden = true,
		condition = {
			cleanliness = 0.3,
			wallCondition = 0.4,
			needsPaint = true,
			needsTiling = true,
			hasDamage = true,
			trashCount = 25,
			stainCount = 20,
		},
		preInstalledFurniture = {"toilet_basic", "kitchen_sink_basic"},
	},
	{
		id = "cottage_ruin",
		name = "Ruined Cottage",
		description = "A charming cottage that needs serious TLC.",
		purchasePrice = 12000,
		baseValue = 22000,
		sizeStuds = 300,
		sizeCategory = "Small",
		location = Vector3.new(300, 0, 100),
		rooms = 4,
		floors = 1,
		hasGarden = true,
		condition = {
			cleanliness = 0.1,
			wallCondition = 0.2,
			needsPaint = true,
			needsTiling = true,
			hasDamage = true,
			trashCount = 30,
			stainCount = 25,
		},
		preInstalledFurniture = {},
	},

	-- ============ MID-TIER HOUSES ============
	{
		id = "city_apartment",
		name = "Downtown Apartment",
		description = "A city apartment with modern potential.",
		purchasePrice = 30000,
		baseValue = 50000,
		sizeStuds = 350,
		sizeCategory = "Medium",
		location = Vector3.new(400, 0, 200),
		rooms = 4,
		floors = 1,
		hasGarden = false,
		condition = {
			cleanliness = 0.4,
			wallCondition = 0.5,
			needsPaint = true,
			needsTiling = false,
			hasDamage = false,
			trashCount = 10,
			stainCount = 8,
		},
		preInstalledFurniture = {"toilet_basic", "bathroom_sink", "kitchen_sink_basic"},
	},
	{
		id = "family_home",
		name = "Family Home",
		description = "A spacious family home that's seen better days.",
		purchasePrice = 45000,
		baseValue = 75000,
		sizeStuds = 600,
		sizeCategory = "Medium",
		location = Vector3.new(500, 0, 200),
		rooms = 7,
		floors = 2,
		hasGarden = true,
		condition = {
			cleanliness = 0.3,
			wallCondition = 0.4,
			needsPaint = true,
			needsTiling = true,
			hasDamage = true,
			trashCount = 35,
			stainCount = 30,
		},
		preInstalledFurniture = {"toilet_basic", "bathtub_standard", "oven_standard"},
	},
	{
		id = "ranch_house",
		name = "Ranch House",
		description = "A sprawling single-story ranch with big potential.",
		purchasePrice = 40000,
		baseValue = 65000,
		sizeStuds = 550,
		sizeCategory = "Medium",
		location = Vector3.new(600, 0, 300),
		rooms = 6,
		floors = 1,
		hasGarden = true,
		condition = {
			cleanliness = 0.25,
			wallCondition = 0.35,
			needsPaint = true,
			needsTiling = true,
			hasDamage = true,
			trashCount = 20,
			stainCount = 15,
		},
		preInstalledFurniture = {"kitchen_sink_basic", "toilet_basic"},
	},

	-- ============ HIGH-TIER HOUSES ============
	{
		id = "victorian_mansion",
		name = "Victorian Mansion",
		description = "A grand Victorian home with enormous renovation potential.",
		purchasePrice = 90000,
		baseValue = 160000,
		sizeStuds = 900,
		sizeCategory = "Large",
		location = Vector3.new(700, 0, 400),
		rooms = 10,
		floors = 2,
		hasGarden = true,
		condition = {
			cleanliness = 0.15,
			wallCondition = 0.2,
			needsPaint = true,
			needsTiling = true,
			hasDamage = true,
			trashCount = 50,
			stainCount = 40,
		},
		preInstalledFurniture = {"bathtub_standard", "toilet_basic"},
	},
	{
		id = "modern_villa",
		name = "Modern Villa",
		description = "A contemporary villa with luxury renovation opportunity.",
		purchasePrice = 120000,
		baseValue = 200000,
		sizeStuds = 800,
		sizeCategory = "Large",
		location = Vector3.new(800, 0, 400),
		rooms = 8,
		floors = 2,
		hasGarden = true,
		condition = {
			cleanliness = 0.35,
			wallCondition = 0.5,
			needsPaint = true,
			needsTiling = false,
			hasDamage = false,
			trashCount = 15,
			stainCount = 10,
		},
		preInstalledFurniture = {"toilet_basic", "bathroom_sink", "shower_basic", "kitchen_sink_basic", "oven_standard"},
	},
	{
		id = "penthouse",
		name = "Skyline Penthouse",
		description = "A premium penthouse with city views. Top-tier flip.",
		purchasePrice = 180000,
		baseValue = 300000,
		sizeStuds = 700,
		sizeCategory = "Large",
		location = Vector3.new(900, 50, 500),
		rooms = 6,
		floors = 1,
		hasGarden = false,
		condition = {
			cleanliness = 0.5,
			wallCondition = 0.6,
			needsPaint = true,
			needsTiling = false,
			hasDamage = false,
			trashCount = 5,
			stainCount = 5,
		},
		preInstalledFurniture = {"toilet_basic", "bathroom_sink", "kitchen_sink_basic"},
	},
}

-- Helper: get house by ID
function HouseData.getById(id)
	for _, house in ipairs(HouseData.Houses) do
		if house.id == id then
			return house
		end
	end
	return nil
end

-- Helper: get houses by price range
function HouseData.getByPriceRange(minPrice, maxPrice)
	local results = {}
	for _, house in ipairs(HouseData.Houses) do
		if house.purchasePrice >= minPrice and house.purchasePrice <= maxPrice then
			table.insert(results, house)
		end
	end
	return results
end

-- Helper: get houses by size category
function HouseData.getBySizeCategory(category)
	local results = {}
	for _, house in ipairs(HouseData.Houses) do
		if house.sizeCategory == category then
			table.insert(results, house)
		end
	end
	return results
end

return HouseData
