--[[
	Enums.lua
	Shared enumerations for the House Flipper game.
	Location: ReplicatedStorage/Shared/Enums
]]

local Enums = {}

Enums.ToolType = {
	Broom = "Broom",
	TrashBag = "TrashBag",
	PaintRoller = "PaintRoller",
	TilingTool = "TilingTool",
	Sledgehammer = "Sledgehammer",
	WallBuilder = "WallBuilder",
	WindowCleaner = "WindowCleaner",
	PlasterTool = "PlasterTool",
	Vacuum = "Vacuum",
	InstallationTool = "InstallationTool",
}

Enums.RoomType = {
	Kitchen = "Kitchen",
	Bathroom = "Bathroom",
	Bedroom = "Bedroom",
	LivingRoom = "LivingRoom",
	Office = "Office",
	DiningRoom = "DiningRoom",
	Garage = "Garage",
	LaundryRoom = "LaundryRoom",
	Hallway = "Hallway",
	Garden = "Garden",
}

Enums.FurnitureCategory = {
	Kitchen = "Kitchen",
	Bathroom = "Bathroom",
	Bedroom = "Bedroom",
	LivingRoom = "LivingRoom",
	Office = "Office",
	Dining = "Dining",
	Decorative = "Decorative",
	Appliances = "Appliances",
	Outdoor = "Outdoor",
}

Enums.FurnitureStyle = {
	Modern = "Modern",
	Classic = "Classic",
	Rustic = "Rustic",
	Luxury = "Luxury",
	Industrial = "Industrial",
	Minimalist = "Minimalist",
}

Enums.PerkCategory = {
	Cleaning = "Cleaning",
	Painting = "Painting",
	Handyman = "Handyman",
	Demolition = "Demolition",
	Building = "Building",
	Negotiation = "Negotiation",
}

Enums.JobStatus = {
	Available = "Available",
	InProgress = "InProgress",
	Completed = "Completed",
	Failed = "Failed",
}

Enums.HouseStatus = {
	ForSale = "ForSale",
	Owned = "Owned",
	Renovating = "Renovating",
	Listed = "Listed",
	Sold = "Sold",
}

Enums.TaskType = {
	Clean = "Clean",
	Paint = "Paint",
	Tile = "Tile",
	Demolish = "Demolish",
	Build = "Build",
	Install = "Install",
	Furnish = "Furnish",
	Plaster = "Plaster",
	CleanWindows = "CleanWindows",
}

Enums.SurfaceType = {
	Wall = "Wall",
	Floor = "Floor",
	Ceiling = "Ceiling",
}

return Enums
