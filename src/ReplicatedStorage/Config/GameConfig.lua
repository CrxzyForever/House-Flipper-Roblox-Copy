--[[
	GameConfig.lua
	Global game settings and constants.
	Location: ReplicatedStorage/Config/GameConfig
]]

local GameConfig = {}

-- Economy
GameConfig.STARTING_MONEY = 2000
GameConfig.JOB_PARTIAL_COMPLETION = 0.70 -- 70% completion for partial pay
GameConfig.JOB_PARTIAL_PAY_MULTIPLIER = 0.60 -- 60% of full reward for partial completion
GameConfig.HOUSE_SALE_TAX = 0.05 -- 5% tax on house sales
GameConfig.FURNITURE_RESALE_MULTIPLIER = 0.5 -- Sell furniture back at 50%

-- Player
GameConfig.MAX_TOOL_SLOTS = 3 -- Tools visible in hotbar at once
GameConfig.INTERACTION_RANGE = 10 -- Studs
GameConfig.PLACEMENT_RANGE = 20 -- Studs for furniture placement

-- Cleaning
GameConfig.BROOM_BASE_RANGE = 5 -- Studs
GameConfig.BROOM_UPGRADE_RANGE = {5, 8, 12} -- Per perk level
GameConfig.CLEAN_TIME = 1.5 -- Seconds to clean a stain
GameConfig.TRASH_PICKUP_COUNTS = {1, 3, 5} -- Per perk level

-- Painting
GameConfig.PAINT_ROLLER_BASE_WIDTH = 1 -- Stripes at once
GameConfig.PAINT_ROLLER_UPGRADE_WIDTH = {1, 2, 3, 4} -- Per perk level
GameConfig.PAINT_PER_CAN = 20 -- Wall segments per paint can
GameConfig.PAINT_SPEED_BASE = 1.0 -- Seconds per segment
GameConfig.PAINT_EFFICIENCY_MULTIPLIER = {1.0, 0.8, 0.6} -- Paint usage per perk level

-- Tiling
GameConfig.TILES_PER_PICKUP = {1, 3, 5, 10} -- Per perk level
GameConfig.TILE_PLACE_TIME = 0.8 -- Seconds per tile

-- Demolition
GameConfig.SLEDGEHAMMER_HITS_TO_DESTROY = 5
GameConfig.SLEDGEHAMMER_SPEED_MULTIPLIER = {1.0, 1.3, 1.6} -- Per perk level
GameConfig.SLEDGEHAMMER_POWER_MULTIPLIER = {1.0, 1.5, 2.0} -- Per perk level

-- Building
GameConfig.WALL_BUILD_TIME = 3.0 -- Seconds per wall segment
GameConfig.WALLS_PER_BUILD = {1, 2, 3} -- Per perk level

-- Room Detection
GameConfig.MIN_ROOM_SIZE_STUDS = 16 -- Minimum room size in studs²
GameConfig.ROOM_SIZE_SMALL = 33 -- ~10m²
GameConfig.ROOM_SIZE_MEDIUM = 66 -- ~20m²

-- House Selling
GameConfig.BASE_VALUE_MULTIPLIER = 1.2 -- Base renovation appreciation
GameConfig.CLEANLINESS_BONUS = 0.10 -- +10% for perfectly clean
GameConfig.ROOM_MATCH_BONUS = 0.15 -- +15% per matched buyer room preference
GameConfig.STYLE_MATCH_BONUS = 0.20 -- +20% for matching buyer style

-- Negotiation Perks
GameConfig.NEGOTIATION_JOB_BONUS = {0, 0.10, 0.20, 0.30} -- Extra % on job pay
GameConfig.NEGOTIATION_SALE_BONUS = {0, 0.05, 0.10, 0.15} -- Extra % on house sales

-- Miscellaneous
GameConfig.AUTOSAVE_INTERVAL = 120 -- Seconds between autosaves
GameConfig.MAX_HOUSES_OWNED = 3 -- Max houses owned at once
GameConfig.DAY_CYCLE_LENGTH = 600 -- Seconds for one in-game day

return GameConfig
