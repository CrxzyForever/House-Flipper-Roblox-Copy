--[[
	ToolConfig.lua
	Tool definitions, unlock requirements, and upgrade paths.
	Location: ReplicatedStorage/Config/ToolConfig
]]

local Enums = require(script.Parent.Parent.Shared.Enums)

local ToolConfig = {}

ToolConfig.Tools = {
	[Enums.ToolType.Broom] = {
		name = "Broom",
		displayName = "Broom / Mop",
		description = "Clean dirt, stains, and debris from surfaces.",
		icon = "rbxassetid://0", -- Replace with actual asset ID
		unlockMethod = "Starting Tool",
		unlockJobId = nil,
		taskTypes = {Enums.TaskType.Clean},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
		},
		upgrades = {
			{name = "Good Mop", description = "Increases cleaning range", level = 1},
			{name = "Ultra Mop", description = "Further increases cleaning range", level = 2},
			{name = "Hyper Mop", description = "Maximum cleaning range", level = 3},
		},
	},

	[Enums.ToolType.TrashBag] = {
		name = "TrashBag",
		displayName = "Trash Bag",
		description = "Pick up garbage and dispose of it.",
		icon = "rbxassetid://0",
		unlockMethod = "Starting Tool",
		unlockJobId = nil,
		taskTypes = {Enums.TaskType.Clean},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
		},
		upgrades = {
			{name = "Double Bag", description = "Pick up 3 items at once", level = 1},
			{name = "Heavy Duty", description = "Pick up 5 items at once", level = 2},
			{name = "Industrial", description = "Pick up all nearby trash", level = 3},
		},
	},

	[Enums.ToolType.PaintRoller] = {
		name = "PaintRoller",
		displayName = "Paint Roller",
		description = "Paint walls and surfaces. Requires paint cans from the shop.",
		icon = "rbxassetid://0",
		unlockMethod = "Complete Job",
		unlockJobId = "amaranth_walls",
		taskTypes = {Enums.TaskType.Paint},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
			refill = "rbxassetid://0",
		},
		upgrades = {
			{name = "Wide Roller", description = "Paint 2 stripes at once", level = 1},
			{name = "Pro Roller", description = "Paint 3 stripes at once", level = 2},
			{name = "Master Roller", description = "Paint 4 stripes at once", level = 3},
		},
	},

	[Enums.ToolType.TilingTool] = {
		name = "TilingTool",
		displayName = "Tiling & Paneling Tool",
		description = "Apply tiles or wood panels to walls and floors.",
		icon = "rbxassetid://0",
		unlockMethod = "Complete Job",
		unlockJobId = "extra_bathroom",
		taskTypes = {Enums.TaskType.Tile},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
		},
		upgrades = {
			{name = "Steady Hands", description = "Place 3 tiles at once", level = 1},
			{name = "Quick Tiler", description = "Place 5 tiles at once", level = 2},
			{name = "Master Tiler", description = "Place 10 tiles at once", level = 3},
		},
	},

	[Enums.ToolType.Sledgehammer] = {
		name = "Sledgehammer",
		displayName = "Sledgehammer",
		description = "Demolish walls to reshape rooms.",
		icon = "rbxassetid://0",
		unlockMethod = "Complete Job",
		unlockJobId = "additional_walls",
		taskTypes = {Enums.TaskType.Demolish},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
			impact = "rbxassetid://0",
		},
		upgrades = {
			{name = "Faster Swing", description = "Swing the hammer faster", level = 1},
			{name = "Power Strike", description = "Stronger hits, fewer needed", level = 2},
			{name = "Wrecking Ball", description = "Maximum destruction power", level = 3},
		},
	},

	[Enums.ToolType.WallBuilder] = {
		name = "WallBuilder",
		displayName = "Wall Builder",
		description = "Construct new walls and lintels to create rooms.",
		icon = "rbxassetid://0",
		unlockMethod = "Complete Job",
		unlockJobId = "additional_walls",
		taskTypes = {Enums.TaskType.Build},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
		},
		upgrades = {
			{name = "Mason", description = "New walls come pre-painted", level = 1},
			{name = "Bricklayer", description = "Build 2 walls at once", level = 2},
			{name = "One Man Crew", description = "Build 3 walls at once", level = 3},
		},
	},

	[Enums.ToolType.WindowCleaner] = {
		name = "WindowCleaner",
		displayName = "Window Cleaning Tool",
		description = "Clean dirty windows to crystal clarity.",
		icon = "rbxassetid://0",
		unlockMethod = "Context Tool",
		unlockJobId = nil, -- Unlocks on any job requiring window cleaning
		taskTypes = {Enums.TaskType.CleanWindows},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
		},
		upgrades = {},
	},

	[Enums.ToolType.PlasterTool] = {
		name = "PlasterTool",
		displayName = "Plaster Tool",
		description = "Repair damaged walls with fresh plaster.",
		icon = "rbxassetid://0",
		unlockMethod = "Context Tool",
		unlockJobId = nil,
		taskTypes = {Enums.TaskType.Plaster},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
		},
		upgrades = {},
	},

	[Enums.ToolType.Vacuum] = {
		name = "Vacuum",
		displayName = "Vacuum Cleaner",
		description = "Clean up broken glass and pests.",
		icon = "rbxassetid://0",
		unlockMethod = "Context Tool",
		unlockJobId = nil,
		taskTypes = {Enums.TaskType.Clean},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
		},
		upgrades = {},
	},

	[Enums.ToolType.InstallationTool] = {
		name = "InstallationTool",
		displayName = "Wrench / Installation Tool",
		description = "Install plumbing fixtures, radiators, and appliances.",
		icon = "rbxassetid://0",
		unlockMethod = "Complete Job",
		unlockJobId = "first_installation",
		taskTypes = {Enums.TaskType.Install},
		animations = {
			idle = "rbxassetid://0",
			use = "rbxassetid://0",
		},
		upgrades = {
			{name = "Quick Install", description = "Install fixtures faster", level = 1},
			{name = "Pro Installer", description = "Much faster installations", level = 2},
			{name = "Master Plumber", description = "Instant installations", level = 3},
		},
	},
}

-- Get starting tools (unlocked by default)
function ToolConfig.getStartingTools()
	local starting = {}
	for toolType, config in pairs(ToolConfig.Tools) do
		if config.unlockMethod == "Starting Tool" then
			table.insert(starting, toolType)
		end
	end
	return starting
end

-- Check if a tool is unlocked by a specific job
function ToolConfig.getToolUnlockedByJob(jobId)
	for toolType, config in pairs(ToolConfig.Tools) do
		if config.unlockJobId == jobId then
			return toolType
		end
	end
	return nil
end

return ToolConfig
