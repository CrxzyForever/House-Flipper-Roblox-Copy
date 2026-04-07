--[[
	PerkData.lua
	Skill tree / perk definitions with categories and level progression.
	Location: ReplicatedStorage/Config/PerkData
]]

local Enums = require(script.Parent.Parent.Shared.Enums)

local PerkData = {}

-- XP required per perk level
PerkData.XP_PER_LEVEL = {
	[1] = 100,
	[2] = 300,
	[3] = 600,
}

-- XP earned per action type
PerkData.XP_REWARDS = {
	[Enums.TaskType.Clean] = 10,
	[Enums.TaskType.Paint] = 15,
	[Enums.TaskType.Tile] = 20,
	[Enums.TaskType.Demolish] = 25,
	[Enums.TaskType.Build] = 25,
	[Enums.TaskType.Install] = 20,
	[Enums.TaskType.Furnish] = 10,
	[Enums.TaskType.Plaster] = 15,
	[Enums.TaskType.CleanWindows] = 10,
}

-- Perk tree definitions
-- Each category has 3 perks, each with 3 levels
PerkData.Perks = {
	[Enums.PerkCategory.Cleaning] = {
		name = "Cleaning",
		icon = "rbxassetid://0",
		description = "Improve your cleaning tools and efficiency.",
		perks = {
			{
				id = "clean_range",
				name = "Better Mop",
				description = "Increases cleaning range.",
				levels = {
					{name = "Good Mop", effect = "cleaningRange", value = 8, cost = 1},
					{name = "Ultra Mop", effect = "cleaningRange", value = 12, cost = 2},
					{name = "Hyper Mop", effect = "cleaningRange", value = 16, cost = 3},
				},
			},
			{
				id = "trash_multi",
				name = "Trash Disposal",
				description = "Pick up multiple trash items at once.",
				levels = {
					{name = "Double Bag", effect = "trashPickup", value = 3, cost = 1},
					{name = "Heavy Duty", effect = "trashPickup", value = 5, cost = 2},
					{name = "Industrial", effect = "trashPickup", value = 10, cost = 3},
				},
			},
			{
				id = "clean_vision",
				name = "Penetrating Vision",
				description = "Filth and trash appear on your minimap/radar.",
				levels = {
					{name = "Keen Eye", effect = "dirtRadar", value = 30, cost = 1},
					{name = "Eagle Eye", effect = "dirtRadar", value = 60, cost = 2},
					{name = "X-Ray Vision", effect = "dirtRadar", value = 100, cost = 3},
				},
			},
		},
	},

	[Enums.PerkCategory.Painting] = {
		name = "Painting",
		icon = "rbxassetid://0",
		description = "Paint faster and use less paint.",
		perks = {
			{
				id = "paint_width",
				name = "Wider Roller",
				description = "Paint more wall surface per stroke.",
				levels = {
					{name = "Wide Roller", effect = "paintWidth", value = 2, cost = 1},
					{name = "Pro Roller", effect = "paintWidth", value = 3, cost = 2},
					{name = "Master Roller", effect = "paintWidth", value = 4, cost = 3},
				},
			},
			{
				id = "paint_speed",
				name = "Quick Painter",
				description = "Paint walls faster.",
				levels = {
					{name = "Steady Hand", effect = "paintSpeed", value = 1.3, cost = 1},
					{name = "Swift Stroke", effect = "paintSpeed", value = 1.6, cost = 2},
					{name = "Speed Demon", effect = "paintSpeed", value = 2.0, cost = 3},
				},
			},
			{
				id = "paint_efficiency",
				name = "Paint Saver",
				description = "Use less paint per wall segment.",
				levels = {
					{name = "Careful", effect = "paintEfficiency", value = 0.8, cost = 1},
					{name = "Efficient", effect = "paintEfficiency", value = 0.6, cost = 2},
					{name = "Master", effect = "paintEfficiency", value = 0.4, cost = 3},
				},
			},
		},
	},

	[Enums.PerkCategory.Handyman] = {
		name = "Handyman",
		icon = "rbxassetid://0",
		description = "Install fixtures faster and tile more efficiently.",
		perks = {
			{
				id = "install_speed",
				name = "Quick Install",
				description = "Install fixtures and appliances faster.",
				levels = {
					{name = "Handy", effect = "installSpeed", value = 1.3, cost = 1},
					{name = "Skilled", effect = "installSpeed", value = 1.6, cost = 2},
					{name = "Master Plumber", effect = "installSpeed", value = 2.0, cost = 3},
				},
			},
			{
				id = "tile_multi",
				name = "Tile Expert",
				description = "Place more tiles at once.",
				levels = {
					{name = "Steady Hands", effect = "tilesPerPlace", value = 3, cost = 1},
					{name = "Quick Tiler", effect = "tilesPerPlace", value = 5, cost = 2},
					{name = "Master Tiler", effect = "tilesPerPlace", value = 10, cost = 3},
				},
			},
			{
				id = "plaster_speed",
				name = "Plaster Pro",
				description = "Plaster walls faster.",
				levels = {
					{name = "Smooth", effect = "plasterSpeed", value = 1.3, cost = 1},
					{name = "Quick Set", effect = "plasterSpeed", value = 1.6, cost = 2},
					{name = "Instant Patch", effect = "plasterSpeed", value = 2.0, cost = 3},
				},
			},
		},
	},

	[Enums.PerkCategory.Demolition] = {
		name = "Demolition",
		icon = "rbxassetid://0",
		description = "Demolish walls faster and with more power.",
		perks = {
			{
				id = "demo_speed",
				name = "Faster Swing",
				description = "Swing the sledgehammer faster.",
				levels = {
					{name = "Quick Swing", effect = "demoSpeed", value = 1.3, cost = 1},
					{name = "Rapid Swing", effect = "demoSpeed", value = 1.6, cost = 2},
					{name = "Lightning Swing", effect = "demoSpeed", value = 2.0, cost = 3},
				},
			},
			{
				id = "demo_power",
				name = "Power Strike",
				description = "Each hit deals more damage to walls.",
				levels = {
					{name = "Strong Arm", effect = "demoPower", value = 1.5, cost = 1},
					{name = "Triceps of Steel", effect = "demoPower", value = 2.0, cost = 2},
					{name = "Wrecking Ball", effect = "demoPower", value = 3.0, cost = 3},
				},
			},
			{
				id = "demo_aoe",
				name = "Shockwave",
				description = "Hits affect a wider area.",
				levels = {
					{name = "Tremor", effect = "demoAOE", value = 2, cost = 1},
					{name = "Quake", effect = "demoAOE", value = 4, cost = 2},
					{name = "Earthquake", effect = "demoAOE", value = 6, cost = 3},
				},
			},
		},
	},

	[Enums.PerkCategory.Building] = {
		name = "Building",
		icon = "rbxassetid://0",
		description = "Build walls faster and with better quality.",
		perks = {
			{
				id = "build_paint",
				name = "Mason",
				description = "New walls come pre-painted in the room's color.",
				levels = {
					{name = "Primer", effect = "prePaint", value = true, cost = 1},
					{name = "Color Match", effect = "prePaintQuality", value = true, cost = 2},
					{name = "Perfect Finish", effect = "prePaintPerfect", value = true, cost = 3},
				},
			},
			{
				id = "build_multi",
				name = "One Man Crew",
				description = "Build multiple wall segments at once.",
				levels = {
					{name = "Double Time", effect = "wallsPerBuild", value = 2, cost = 1},
					{name = "Triple Threat", effect = "wallsPerBuild", value = 3, cost = 2},
					{name = "Construction Crew", effect = "wallsPerBuild", value = 4, cost = 3},
				},
			},
			{
				id = "build_speed",
				name = "Speed Builder",
				description = "Build walls faster.",
				levels = {
					{name = "Quick Layer", effect = "buildSpeed", value = 1.3, cost = 1},
					{name = "Rapid Build", effect = "buildSpeed", value = 1.6, cost = 2},
					{name = "Instant Build", effect = "buildSpeed", value = 2.0, cost = 3},
				},
			},
		},
	},

	[Enums.PerkCategory.Negotiation] = {
		name = "Negotiation",
		icon = "rbxassetid://0",
		description = "Earn more money from jobs and house sales.",
		perks = {
			{
				id = "job_bonus",
				name = "Smooth Talker",
				description = "Earn more money from completed jobs.",
				levels = {
					{name = "Charming", effect = "jobPayBonus", value = 0.10, cost = 1},
					{name = "Persuasive", effect = "jobPayBonus", value = 0.20, cost = 2},
					{name = "Silver Tongue", effect = "jobPayBonus", value = 0.30, cost = 3},
				},
			},
			{
				id = "sale_bonus",
				name = "Real Estate Pro",
				description = "Houses sell for more money.",
				levels = {
					{name = "Good Pitch", effect = "saleBonus", value = 0.05, cost = 1},
					{name = "Great Pitch", effect = "saleBonus", value = 0.10, cost = 2},
					{name = "Master Closer", effect = "saleBonus", value = 0.15, cost = 3},
				},
			},
			{
				id = "discount",
				name = "Bargain Hunter",
				description = "Get discounts on furniture and materials.",
				levels = {
					{name = "Coupon Clipper", effect = "shopDiscount", value = 0.05, cost = 1},
					{name = "Deal Finder", effect = "shopDiscount", value = 0.10, cost = 2},
					{name = "Wholesale", effect = "shopDiscount", value = 0.15, cost = 3},
				},
			},
		},
	},
}

-- Helper: get total perk points spent
function PerkData.getTotalPointsSpent(playerPerks)
	local total = 0
	for _, category in pairs(playerPerks) do
		for _, level in pairs(category) do
			total = total + level
		end
	end
	return total
end

-- Helper: get perk effect value for a player
function PerkData.getEffectValue(perkCategory, perkId, level)
	local category = PerkData.Perks[perkCategory]
	if not category then return nil end

	for _, perk in ipairs(category.perks) do
		if perk.id == perkId and level > 0 and level <= #perk.levels then
			return perk.levels[level].effect, perk.levels[level].value
		end
	end
	return nil
end

return PerkData
