--[[
	FurnitureData.lua
	Complete furniture catalog with categories, styles, prices, and room tags.
	Location: ReplicatedStorage/Config/FurnitureData
]]

local Enums = require(script.Parent.Parent.Shared.Enums)

local FurnitureData = {}

-- Each furniture item has:
--   id: unique string identifier
--   name: display name
--   category: FurnitureCategory enum
--   style: FurnitureStyle enum
--   price: cost in game dollars
--   roomTag: what room type this counts toward (for room detection)
--   size: {X, Y, Z} bounding box in studs
--   modelId: Roblox asset ID for the 3D model (placeholder)
--   placementType: "floor", "wall", "ceiling"

FurnitureData.Items = {
	-- ============ KITCHEN ============
	{
		id = "kitchen_sink_basic",
		name = "Basic Kitchen Sink",
		category = Enums.FurnitureCategory.Kitchen,
		style = Enums.FurnitureStyle.Modern,
		price = 150,
		roomTag = "KitchenSink",
		size = {4, 3, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
		requiresInstallation = true,
	},
	{
		id = "oven_standard",
		name = "Standard Oven",
		category = Enums.FurnitureCategory.Kitchen,
		style = Enums.FurnitureStyle.Modern,
		price = 300,
		roomTag = "Oven",
		size = {3, 4, 3},
		modelId = "rbxassetid://0",
		placementType = "floor",
		requiresInstallation = true,
	},
	{
		id = "refrigerator_standard",
		name = "Standard Refrigerator",
		category = Enums.FurnitureCategory.Kitchen,
		style = Enums.FurnitureStyle.Modern,
		price = 400,
		roomTag = "Refrigerator",
		size = {3, 6, 3},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "kitchen_counter",
		name = "Kitchen Counter",
		category = Enums.FurnitureCategory.Kitchen,
		style = Enums.FurnitureStyle.Modern,
		price = 100,
		roomTag = "Counter",
		size = {4, 3, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "kitchen_cabinet",
		name = "Wall Cabinet",
		category = Enums.FurnitureCategory.Kitchen,
		style = Enums.FurnitureStyle.Modern,
		price = 80,
		roomTag = "Cabinet",
		size = {4, 2, 2},
		modelId = "rbxassetid://0",
		placementType = "wall",
	},
	{
		id = "microwave",
		name = "Microwave",
		category = Enums.FurnitureCategory.Kitchen,
		style = Enums.FurnitureStyle.Modern,
		price = 120,
		roomTag = "Appliance",
		size = {2, 1, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},

	-- ============ BATHROOM ============
	{
		id = "toilet_basic",
		name = "Basic Toilet",
		category = Enums.FurnitureCategory.Bathroom,
		style = Enums.FurnitureStyle.Modern,
		price = 200,
		roomTag = "Toilet",
		size = {2, 3, 3},
		modelId = "rbxassetid://0",
		placementType = "floor",
		requiresInstallation = true,
	},
	{
		id = "bathroom_sink",
		name = "Bathroom Sink",
		category = Enums.FurnitureCategory.Bathroom,
		style = Enums.FurnitureStyle.Modern,
		price = 150,
		roomTag = "BathroomSink",
		size = {2, 3, 2},
		modelId = "rbxassetid://0",
		placementType = "wall",
		requiresInstallation = true,
	},
	{
		id = "shower_basic",
		name = "Basic Shower",
		category = Enums.FurnitureCategory.Bathroom,
		style = Enums.FurnitureStyle.Modern,
		price = 350,
		roomTag = "Shower",
		size = {4, 7, 4},
		modelId = "rbxassetid://0",
		placementType = "floor",
		requiresInstallation = true,
	},
	{
		id = "bathtub_standard",
		name = "Standard Bathtub",
		category = Enums.FurnitureCategory.Bathroom,
		style = Enums.FurnitureStyle.Classic,
		price = 500,
		roomTag = "Bathtub",
		size = {6, 3, 3},
		modelId = "rbxassetid://0",
		placementType = "floor",
		requiresInstallation = true,
	},
	{
		id = "bathroom_mirror",
		name = "Bathroom Mirror",
		category = Enums.FurnitureCategory.Bathroom,
		style = Enums.FurnitureStyle.Modern,
		price = 60,
		roomTag = "Mirror",
		size = {3, 3, 0},
		modelId = "rbxassetid://0",
		placementType = "wall",
	},
	{
		id = "towel_rack",
		name = "Towel Rack",
		category = Enums.FurnitureCategory.Bathroom,
		style = Enums.FurnitureStyle.Modern,
		price = 30,
		roomTag = "TowelRack",
		size = {3, 1, 1},
		modelId = "rbxassetid://0",
		placementType = "wall",
	},

	-- ============ BEDROOM ============
	{
		id = "bed_single",
		name = "Single Bed",
		category = Enums.FurnitureCategory.Bedroom,
		style = Enums.FurnitureStyle.Modern,
		price = 250,
		roomTag = "Bed",
		size = {4, 3, 7},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "bed_double",
		name = "Double Bed",
		category = Enums.FurnitureCategory.Bedroom,
		style = Enums.FurnitureStyle.Modern,
		price = 500,
		roomTag = "Bed",
		size = {6, 3, 7},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "bed_luxury",
		name = "King Size Bed",
		category = Enums.FurnitureCategory.Bedroom,
		style = Enums.FurnitureStyle.Luxury,
		price = 1200,
		roomTag = "Bed",
		size = {8, 4, 8},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "wardrobe_basic",
		name = "Basic Wardrobe",
		category = Enums.FurnitureCategory.Bedroom,
		style = Enums.FurnitureStyle.Modern,
		price = 200,
		roomTag = "Wardrobe",
		size = {4, 7, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "dresser",
		name = "Dresser",
		category = Enums.FurnitureCategory.Bedroom,
		style = Enums.FurnitureStyle.Classic,
		price = 180,
		roomTag = "Dresser",
		size = {4, 3, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "nightstand",
		name = "Nightstand",
		category = Enums.FurnitureCategory.Bedroom,
		style = Enums.FurnitureStyle.Modern,
		price = 60,
		roomTag = "Nightstand",
		size = {2, 2, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},

	-- ============ LIVING ROOM ============
	{
		id = "sofa_basic",
		name = "Basic Sofa",
		category = Enums.FurnitureCategory.LivingRoom,
		style = Enums.FurnitureStyle.Modern,
		price = 350,
		roomTag = "Sofa",
		size = {6, 3, 3},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "sofa_luxury",
		name = "L-Shaped Sofa",
		category = Enums.FurnitureCategory.LivingRoom,
		style = Enums.FurnitureStyle.Luxury,
		price = 900,
		roomTag = "Sofa",
		size = {8, 3, 8},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "coffee_table",
		name = "Coffee Table",
		category = Enums.FurnitureCategory.LivingRoom,
		style = Enums.FurnitureStyle.Modern,
		price = 120,
		roomTag = "CoffeeTable",
		size = {4, 2, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "tv_stand",
		name = "TV Stand",
		category = Enums.FurnitureCategory.LivingRoom,
		style = Enums.FurnitureStyle.Modern,
		price = 150,
		roomTag = "TVStand",
		size = {5, 2, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "tv_flatscreen",
		name = "Flat Screen TV",
		category = Enums.FurnitureCategory.LivingRoom,
		style = Enums.FurnitureStyle.Modern,
		price = 600,
		roomTag = "TV",
		size = {5, 3, 0},
		modelId = "rbxassetid://0",
		placementType = "wall",
	},
	{
		id = "bookshelf",
		name = "Bookshelf",
		category = Enums.FurnitureCategory.LivingRoom,
		style = Enums.FurnitureStyle.Classic,
		price = 200,
		roomTag = "Bookcase",
		size = {4, 7, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "armchair",
		name = "Armchair",
		category = Enums.FurnitureCategory.LivingRoom,
		style = Enums.FurnitureStyle.Classic,
		price = 250,
		roomTag = "Chair",
		size = {3, 3, 3},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},

	-- ============ OFFICE ============
	{
		id = "desk_basic",
		name = "Office Desk",
		category = Enums.FurnitureCategory.Office,
		style = Enums.FurnitureStyle.Modern,
		price = 200,
		roomTag = "Desk",
		size = {5, 3, 3},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "office_chair",
		name = "Office Chair",
		category = Enums.FurnitureCategory.Office,
		style = Enums.FurnitureStyle.Modern,
		price = 150,
		roomTag = "OfficeChair",
		size = {2, 4, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "filing_cabinet",
		name = "Filing Cabinet",
		category = Enums.FurnitureCategory.Office,
		style = Enums.FurnitureStyle.Modern,
		price = 100,
		roomTag = "Cabinet",
		size = {2, 4, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},

	-- ============ DINING ============
	{
		id = "dining_table",
		name = "Dining Table",
		category = Enums.FurnitureCategory.Dining,
		style = Enums.FurnitureStyle.Classic,
		price = 300,
		roomTag = "DiningTable",
		size = {6, 3, 4},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "dining_chair",
		name = "Dining Chair",
		category = Enums.FurnitureCategory.Dining,
		style = Enums.FurnitureStyle.Classic,
		price = 60,
		roomTag = "DiningChair",
		size = {2, 3, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},

	-- ============ DECORATIVE ============
	{
		id = "painting_small",
		name = "Small Painting",
		category = Enums.FurnitureCategory.Decorative,
		style = Enums.FurnitureStyle.Classic,
		price = 50,
		roomTag = "Picture",
		size = {2, 2, 0},
		modelId = "rbxassetid://0",
		placementType = "wall",
	},
	{
		id = "painting_large",
		name = "Large Painting",
		category = Enums.FurnitureCategory.Decorative,
		style = Enums.FurnitureStyle.Luxury,
		price = 200,
		roomTag = "Picture",
		size = {4, 3, 0},
		modelId = "rbxassetid://0",
		placementType = "wall",
	},
	{
		id = "potted_plant",
		name = "Potted Plant",
		category = Enums.FurnitureCategory.Decorative,
		style = Enums.FurnitureStyle.Modern,
		price = 40,
		roomTag = "Plant",
		size = {2, 3, 2},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "rug_medium",
		name = "Medium Rug",
		category = Enums.FurnitureCategory.Decorative,
		style = Enums.FurnitureStyle.Classic,
		price = 80,
		roomTag = "Carpet",
		size = {6, 0, 4},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "wall_clock",
		name = "Wall Clock",
		category = Enums.FurnitureCategory.Decorative,
		style = Enums.FurnitureStyle.Classic,
		price = 35,
		roomTag = "Clock",
		size = {1, 1, 0},
		modelId = "rbxassetid://0",
		placementType = "wall",
	},
	{
		id = "floor_lamp",
		name = "Floor Lamp",
		category = Enums.FurnitureCategory.Decorative,
		style = Enums.FurnitureStyle.Modern,
		price = 70,
		roomTag = "Lamp",
		size = {1, 6, 1},
		modelId = "rbxassetid://0",
		placementType = "floor",
	},
	{
		id = "curtains",
		name = "Curtains",
		category = Enums.FurnitureCategory.Decorative,
		style = Enums.FurnitureStyle.Classic,
		price = 60,
		roomTag = "Curtains",
		size = {4, 6, 0},
		modelId = "rbxassetid://0",
		placementType = "wall",
	},

	-- ============ APPLIANCES ============
	{
		id = "washing_machine",
		name = "Washing Machine",
		category = Enums.FurnitureCategory.Appliances,
		style = Enums.FurnitureStyle.Modern,
		price = 450,
		roomTag = "WashingMachine",
		size = {3, 3, 3},
		modelId = "rbxassetid://0",
		placementType = "floor",
		requiresInstallation = true,
	},
	{
		id = "radiator",
		name = "Radiator",
		category = Enums.FurnitureCategory.Appliances,
		style = Enums.FurnitureStyle.Modern,
		price = 180,
		roomTag = "Radiator",
		size = {3, 2, 1},
		modelId = "rbxassetid://0",
		placementType = "wall",
		requiresInstallation = true,
	},
	{
		id = "ac_unit",
		name = "Air Conditioner",
		category = Enums.FurnitureCategory.Appliances,
		style = Enums.FurnitureStyle.Modern,
		price = 350,
		roomTag = "AC",
		size = {3, 2, 1},
		modelId = "rbxassetid://0",
		placementType = "wall",
		requiresInstallation = true,
	},
}

-- Paint colors available in the shop
FurnitureData.PaintColors = {
	{id = "white", name = "White", color = Color3.fromRGB(255, 255, 255), price = 10},
	{id = "cream", name = "Cream", color = Color3.fromRGB(255, 253, 208), price = 10},
	{id = "beige", name = "Beige", color = Color3.fromRGB(245, 245, 220), price = 10},
	{id = "light_gray", name = "Light Gray", color = Color3.fromRGB(200, 200, 200), price = 10},
	{id = "dark_gray", name = "Dark Gray", color = Color3.fromRGB(100, 100, 100), price = 12},
	{id = "light_blue", name = "Light Blue", color = Color3.fromRGB(173, 216, 230), price = 15},
	{id = "navy", name = "Navy Blue", color = Color3.fromRGB(0, 0, 128), price = 15},
	{id = "sky_blue", name = "Sky Blue", color = Color3.fromRGB(135, 206, 235), price = 15},
	{id = "red", name = "Red", color = Color3.fromRGB(200, 50, 50), price = 15},
	{id = "burgundy", name = "Burgundy", color = Color3.fromRGB(128, 0, 32), price = 18},
	{id = "green", name = "Green", color = Color3.fromRGB(76, 153, 0), price = 15},
	{id = "sage", name = "Sage Green", color = Color3.fromRGB(188, 184, 138), price = 18},
	{id = "yellow", name = "Yellow", color = Color3.fromRGB(255, 255, 102), price = 12},
	{id = "orange", name = "Orange", color = Color3.fromRGB(255, 165, 0), price = 15},
	{id = "pink", name = "Pink", color = Color3.fromRGB(255, 192, 203), price = 15},
	{id = "purple", name = "Purple", color = Color3.fromRGB(128, 0, 128), price = 18},
	{id = "brown", name = "Brown", color = Color3.fromRGB(139, 90, 43), price = 12},
	{id = "black", name = "Black", color = Color3.fromRGB(30, 30, 30), price = 15},
	{id = "amaranth", name = "Amaranth", color = Color3.fromRGB(229, 43, 80), price = 20},
	{id = "teal", name = "Teal", color = Color3.fromRGB(0, 128, 128), price = 18},
}

-- Tile/panel options
FurnitureData.TileOptions = {
	{id = "white_tile", name = "White Ceramic Tile", price = 8, textureId = "rbxassetid://0"},
	{id = "blue_tile", name = "Blue Ceramic Tile", price = 10, textureId = "rbxassetid://0"},
	{id = "marble_tile", name = "Marble Tile", price = 25, textureId = "rbxassetid://0"},
	{id = "mosaic_tile", name = "Mosaic Tile", price = 20, textureId = "rbxassetid://0"},
	{id = "wood_panel_oak", name = "Oak Wood Panel", price = 15, textureId = "rbxassetid://0"},
	{id = "wood_panel_dark", name = "Dark Wood Panel", price = 18, textureId = "rbxassetid://0"},
	{id = "wood_panel_pine", name = "Pine Wood Panel", price = 12, textureId = "rbxassetid://0"},
	{id = "stone_tile", name = "Stone Tile", price = 22, textureId = "rbxassetid://0"},
	{id = "subway_tile", name = "Subway Tile", price = 14, textureId = "rbxassetid://0"},
	{id = "herringbone", name = "Herringbone Pattern", price = 30, textureId = "rbxassetid://0"},
}

-- Helper: get furniture by category
function FurnitureData.getByCategory(category)
	local results = {}
	for _, item in ipairs(FurnitureData.Items) do
		if item.category == category then
			table.insert(results, item)
		end
	end
	return results
end

-- Helper: get furniture by ID
function FurnitureData.getById(id)
	for _, item in ipairs(FurnitureData.Items) do
		if item.id == id then
			return item
		end
	end
	return nil
end

-- Helper: get furniture by style
function FurnitureData.getByStyle(style)
	local results = {}
	for _, item in ipairs(FurnitureData.Items) do
		if item.style == style then
			table.insert(results, item)
		end
	end
	return results
end

return FurnitureData
