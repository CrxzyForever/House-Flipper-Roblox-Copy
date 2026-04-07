--[[
	PerkSystem.lua
	Handles perk unlocking, XP tracking, and perk effect calculations.
	Location: ServerScriptService/Systems/PerkSystem
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerkData = require(ReplicatedStorage.Config.PerkData)
local RemoteManager = require(script.Parent.Parent.Core.RemoteManager)
local PlayerDataManager = require(script.Parent.Parent.Core.PlayerDataManager)

local PerkSystem = {}

function PerkSystem.init()
	-- Handle perk unlock requests
	local unlockEvent = RemoteManager.getEvent("UnlockPerk")
	if unlockEvent then
		unlockEvent.OnServerEvent:Connect(function(player, categoryName, perkId)
			PerkSystem.unlockPerk(player, categoryName, perkId)
		end)
	end

	print("[PerkSystem] Initialized")
end

-- Unlock or upgrade a perk for a player
function PerkSystem.unlockPerk(player, categoryName, perkId)
	local data = PlayerDataManager.getData(player)
	if not data then return end

	-- Validate category
	local category = PerkData.Perks[categoryName]
	if not category then
		PerkSystem._notify(player, "Invalid perk category!")
		return
	end

	-- Find the perk
	local perkDef = nil
	for _, p in ipairs(category.perks) do
		if p.id == perkId then
			perkDef = p
			break
		end
	end

	if not perkDef then
		PerkSystem._notify(player, "Invalid perk!")
		return
	end

	-- Get current level
	local currentLevel = data.perks[categoryName] and data.perks[categoryName][perkId] or 0
	local nextLevel = currentLevel + 1

	-- Check if already maxed
	if nextLevel > #perkDef.levels then
		PerkSystem._notify(player, perkDef.name .. " is already at max level!")
		return
	end

	-- Check perk point cost
	local cost = perkDef.levels[nextLevel].cost
	if data.perkPoints < cost then
		PerkSystem._notify(player, "Not enough perk points! Need " .. cost .. ", have " .. data.perkPoints)
		return
	end

	-- Check XP requirement for the category
	local xpRequired = PerkData.XP_PER_LEVEL[nextLevel]
	local currentXP = data.xp[categoryName] or 0
	if currentXP < xpRequired then
		PerkSystem._notify(player, string.format(
			"Not enough %s XP! Need %d, have %d. Keep using %s tools to gain XP!",
			categoryName, xpRequired, currentXP, categoryName
		))
		return
	end

	-- Unlock the perk
	data.perkPoints = data.perkPoints - cost
	if not data.perks[categoryName] then
		data.perks[categoryName] = {}
	end
	data.perks[categoryName][perkId] = nextLevel

	-- Notify client
	local perkEvent = RemoteManager.getEvent("PerkUnlocked")
	if perkEvent then
		perkEvent:FireClient(player, categoryName, perkId, nextLevel)
	end

	local levelInfo = perkDef.levels[nextLevel]
	PerkSystem._notify(player, string.format(
		"Perk unlocked: %s - %s (Level %d)!",
		perkDef.name, levelInfo.name, nextLevel
	))

	print("[PerkSystem] " .. player.Name .. " unlocked " .. perkId .. " level " .. nextLevel)
end

-- Award XP for performing an action
function PerkSystem.awardXP(player, taskType)
	local data = PlayerDataManager.getData(player)
	if not data then return end

	local xpAmount = PerkData.XP_REWARDS[taskType]
	if not xpAmount then return end

	-- Map task types to perk categories
	local categoryMap = {
		Clean = "Cleaning",
		Paint = "Painting",
		Tile = "Handyman",
		Demolish = "Demolition",
		Build = "Building",
		Install = "Handyman",
		Furnish = "Negotiation", -- Furnishing earns negotiation XP
		Plaster = "Handyman",
		CleanWindows = "Cleaning",
	}

	local category = categoryMap[taskType]
	if not category then return end

	local newXP = PlayerDataManager.addXP(player, category, xpAmount)

	-- Check if player earned a perk point (every 100 XP across all categories)
	local totalXP = 0
	for _, xp in pairs(data.xp) do
		totalXP = totalXP + xp
	end

	-- Award perk point every 200 total XP
	local expectedPoints = math.floor(totalXP / 200)
	local currentPointsSpent = PerkData.getTotalPointsSpent(data.perks)
	local totalPointsEarned = data.perkPoints + currentPointsSpent

	if expectedPoints > totalPointsEarned then
		data.perkPoints = data.perkPoints + 1
		PerkSystem._notify(player, "You earned a Perk Point! Open the Perks menu to spend it.")
	end

	-- Notify XP gain
	local xpEvent = RemoteManager.getEvent("XPGained")
	if xpEvent then
		xpEvent:FireClient(player, category, xpAmount, newXP)
	end
end

-- Get the effective value of a perk for a player
function PerkSystem.getPerkValue(player, categoryName, perkId)
	local data = PlayerDataManager.getData(player)
	if not data then return nil end

	local level = data.perks[categoryName] and data.perks[categoryName][perkId] or 0
	if level == 0 then return nil end

	local effect, value = PerkData.getEffectValue(categoryName, perkId, level)
	return effect, value
end

-- Get all active perk effects for a player (used by tool systems)
function PerkSystem.getAllEffects(player)
	local data = PlayerDataManager.getData(player)
	if not data then return {} end

	local effects = {}

	for categoryName, perks in pairs(data.perks) do
		for perkId, level in pairs(perks) do
			if level > 0 then
				local effect, value = PerkData.getEffectValue(categoryName, perkId, level)
				if effect then
					effects[effect] = value
				end
			end
		end
	end

	return effects
end

function PerkSystem._notify(player, message)
	local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
	if notifyEvent then
		notifyEvent:FireClient(player, message)
	end
end

return PerkSystem
