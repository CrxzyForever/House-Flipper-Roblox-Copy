--[[
	BuyerData.lua
	Buyer profiles with preferences, requirements, and personality.
	Location: ReplicatedStorage/Config/BuyerData
]]

local Enums = require(script.Parent.Parent.Shared.Enums)

local BuyerData = {}

-- Each buyer has:
--   id: unique identifier
--   name: display name
--   avatar: avatar image asset ID (placeholder)
--   bio: short personality description
--   preferredStyle: FurnitureStyle they prefer
--   requiredRooms: rooms they MUST have
--   preferredRooms: bonus rooms they'd like
--   dislikedItems: furniture tags they don't want
--   likedItems: furniture tags they give bonus for
--   minHouseSize: minimum size category
--   budgetMultiplier: how much they'll pay above base value (1.0 = base)
--   preferences: detailed scoring weights

BuyerData.Buyers = {
	{
		id = "chang_choi",
		name = "Chang Choi",
		avatar = "rbxassetid://0",
		bio = "A minimalist professional who values clean, simple spaces with a dedicated study area.",
		preferredStyle = Enums.FurnitureStyle.Minimalist,
		requiredRooms = {Enums.RoomType.Bedroom, Enums.RoomType.Kitchen, Enums.RoomType.Bathroom, Enums.RoomType.Office},
		preferredRooms = {},
		dislikedItems = {"Luxury", "Decorative"},
		likedItems = {"Desk", "Bookcase", "OfficeChair"},
		minHouseSize = "Small",
		budgetMultiplier = 1.1,
		preferences = {
			cleanliness = 0.9,
			modernStyle = 0.8,
			minimalism = 1.0, -- Fewer items = better
			expensiveStudy = 0.7, -- Prefers expensive office items
		},
	},
	{
		id = "jantart_family",
		name = "The Jantart Family",
		avatar = "rbxassetid://0",
		bio = "A retired couple who love classic, spacious homes with room to host guests.",
		preferredStyle = Enums.FurnitureStyle.Classic,
		requiredRooms = {Enums.RoomType.Bedroom, Enums.RoomType.Kitchen, Enums.RoomType.Bathroom, Enums.RoomType.LivingRoom},
		preferredRooms = {Enums.RoomType.DiningRoom, Enums.RoomType.Garden},
		dislikedItems = {"Industrial", "Minimalist"},
		likedItems = {"Classic", "Bookcase", "DiningTable", "Armchair"},
		minHouseSize = "Medium",
		budgetMultiplier = 1.2,
		preferences = {
			cleanliness = 0.8,
			classicStyle = 1.0,
			spaciousness = 0.9,
			garden = 0.6,
		},
	},
	{
		id = "jimmy_traitor",
		name = "Jimmy Traitor",
		avatar = "rbxassetid://0",
		bio = "A young bachelor who wants an impressive pad. Expensive taste, no TV in the bedroom.",
		preferredStyle = Enums.FurnitureStyle.Luxury,
		requiredRooms = {Enums.RoomType.Bedroom, Enums.RoomType.Kitchen, Enums.RoomType.Bathroom, Enums.RoomType.LivingRoom},
		preferredRooms = {},
		dislikedItems = {"Rustic", "BedroomTV"},
		likedItems = {"Luxury", "Sofa", "TV", "Expensive"},
		minHouseSize = "Medium",
		budgetMultiplier = 1.3,
		preferences = {
			cleanliness = 0.7,
			luxuryStyle = 1.0,
			spaciousness = 0.9,
			noBedroomTV = 0.5, -- Penalty if TV in bedroom
		},
	},
	{
		id = "garcia_family",
		name = "The Garcia Family",
		avatar = "rbxassetid://0",
		bio = "A large family of five who need lots of bedrooms and a big kitchen.",
		preferredStyle = Enums.FurnitureStyle.Modern,
		requiredRooms = {Enums.RoomType.Kitchen, Enums.RoomType.Bathroom, Enums.RoomType.LivingRoom},
		preferredRooms = {Enums.RoomType.DiningRoom, Enums.RoomType.LaundryRoom},
		dislikedItems = {"Minimalist"},
		likedItems = {"Bed", "DiningTable", "WashingMachine", "Refrigerator"},
		minHouseSize = "Large",
		budgetMultiplier = 1.15,
		preferences = {
			cleanliness = 0.9,
			multipleBedrooms = 1.0, -- Needs 3+ bedrooms
			largeKitchen = 0.8,
			familyFriendly = 0.7,
		},
	},
	{
		id = "artist_luna",
		name = "Luna Artistique",
		avatar = "rbxassetid://0",
		bio = "An eccentric artist who loves colorful, creative spaces with lots of personality.",
		preferredStyle = Enums.FurnitureStyle.Rustic,
		requiredRooms = {Enums.RoomType.Bedroom, Enums.RoomType.Kitchen, Enums.RoomType.Bathroom},
		preferredRooms = {Enums.RoomType.Office}, -- Studio space
		dislikedItems = {"Corporate", "Plain"},
		likedItems = {"Picture", "Plant", "Lamp", "Carpet", "Curtains"},
		minHouseSize = "Small",
		budgetMultiplier = 1.0,
		preferences = {
			cleanliness = 0.5,
			colorful = 1.0, -- Many different paint colors
			decorations = 0.9, -- Lots of decorative items
			uniqueness = 0.8,
		},
	},
	{
		id = "tech_ryan",
		name = "Ryan Techsworth",
		avatar = "rbxassetid://0",
		bio = "A tech entrepreneur who wants a sleek, modern home with a killer home office.",
		preferredStyle = Enums.FurnitureStyle.Modern,
		requiredRooms = {Enums.RoomType.Bedroom, Enums.RoomType.Kitchen, Enums.RoomType.Bathroom, Enums.RoomType.Office},
		preferredRooms = {Enums.RoomType.LivingRoom},
		dislikedItems = {"Classic", "Rustic"},
		likedItems = {"Desk", "OfficeChair", "TV", "AC", "Modern"},
		minHouseSize = "Medium",
		budgetMultiplier = 1.25,
		preferences = {
			cleanliness = 0.8,
			modernStyle = 1.0,
			techFriendly = 0.9,
			officeQuality = 0.8,
		},
	},
	{
		id = "newlyweds",
		name = "The Newlyweds",
		avatar = "rbxassetid://0",
		bio = "A young couple starting their life together. They want cozy and romantic.",
		preferredStyle = Enums.FurnitureStyle.Modern,
		requiredRooms = {Enums.RoomType.Bedroom, Enums.RoomType.Kitchen, Enums.RoomType.Bathroom, Enums.RoomType.LivingRoom},
		preferredRooms = {Enums.RoomType.DiningRoom},
		dislikedItems = {"Industrial", "Old"},
		likedItems = {"Sofa", "Bed", "Curtains", "Lamp", "Plant"},
		minHouseSize = "Small",
		budgetMultiplier = 1.05,
		preferences = {
			cleanliness = 0.9,
			coziness = 1.0,
			romantic = 0.8,
			wellFurnished = 0.7,
		},
	},
	{
		id = "professor_oak",
		name = "Professor Oakley",
		avatar = "rbxassetid://0",
		bio = "A retired professor who needs a library-office and classic charm.",
		preferredStyle = Enums.FurnitureStyle.Classic,
		requiredRooms = {Enums.RoomType.Bedroom, Enums.RoomType.Kitchen, Enums.RoomType.Bathroom, Enums.RoomType.Office},
		preferredRooms = {Enums.RoomType.LivingRoom},
		dislikedItems = {"Modern", "Flashy"},
		likedItems = {"Bookcase", "Desk", "Cabinet", "Picture", "Clock"},
		minHouseSize = "Medium",
		budgetMultiplier = 1.15,
		preferences = {
			cleanliness = 0.7,
			classicStyle = 1.0,
			bookshelves = 0.9,
			studySpace = 0.8,
		},
	},
	{
		id = "fitness_frank",
		name = "Fitness Frank",
		avatar = "rbxassetid://0",
		bio = "A personal trainer who wants a clean, spacious home with room for a home gym.",
		preferredStyle = Enums.FurnitureStyle.Industrial,
		requiredRooms = {Enums.RoomType.Bedroom, Enums.RoomType.Kitchen, Enums.RoomType.Bathroom},
		preferredRooms = {Enums.RoomType.Garage}, -- Gym space
		dislikedItems = {"Luxury", "Fragile"},
		likedItems = {"Radiator", "Shower", "Refrigerator"},
		minHouseSize = "Medium",
		budgetMultiplier = 1.1,
		preferences = {
			cleanliness = 1.0,
			spaciousness = 0.9,
			industrial = 0.7,
			practical = 0.8,
		},
	},
	{
		id = "grandma_rose",
		name = "Grandma Rose",
		avatar = "rbxassetid://0",
		bio = "A sweet grandmother who wants a warm, welcoming home to host her grandchildren.",
		preferredStyle = Enums.FurnitureStyle.Classic,
		requiredRooms = {Enums.RoomType.Bedroom, Enums.RoomType.Kitchen, Enums.RoomType.Bathroom, Enums.RoomType.LivingRoom},
		preferredRooms = {Enums.RoomType.DiningRoom, Enums.RoomType.Garden},
		dislikedItems = {"Industrial", "Modern"},
		likedItems = {"DiningTable", "DiningChair", "Plant", "Curtains", "Rug", "Clock"},
		minHouseSize = "Medium",
		budgetMultiplier = 1.1,
		preferences = {
			cleanliness = 0.9,
			classicStyle = 0.9,
			warmth = 1.0,
			garden = 0.7,
		},
	},
}

-- Helper: get buyer by ID
function BuyerData.getById(id)
	for _, buyer in ipairs(BuyerData.Buyers) do
		if buyer.id == id then
			return buyer
		end
	end
	return nil
end

-- Helper: get all buyers that could afford a house at a given price
function BuyerData.getBuyersForPrice(houseBaseValue)
	local results = {}
	for _, buyer in ipairs(BuyerData.Buyers) do
		table.insert(results, buyer)
	end
	return results
end

return BuyerData
