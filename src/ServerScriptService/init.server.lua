--[[
	Server Bootstrap
	Initializes all server-side systems for House Flipper.
	Location: ServerScriptService/init (Script, not ModuleScript)

	NOTE: In Roblox Studio, this should be a regular Script (not ModuleScript).
	It runs automatically when the server starts.
]]

print("========================================")
print("  House Flipper - Roblox Edition")
print("  Starting server systems...")
print("========================================")

-- STEP 1: Build the 3D world FIRST (independent of all other systems)
local worldOk, worldErr = pcall(function()
	local WorldBuilder = require(script.Systems.WorldBuilder)
	WorldBuilder.init()
end)

if worldOk then
	print("[Bootstrap] World built successfully!")
else
	warn("[Bootstrap] WorldBuilder FAILED: " .. tostring(worldErr))
end

-- STEP 2: Initialize game systems (can fail without breaking the world)
local gameOk, gameErr = pcall(function()
	local GameManager = require(script.Core.GameManager)
	GameManager.init()
end)

if gameOk then
	print("========================================")
	print("  Server ready! Waiting for players...")
	print("========================================")
else
	warn("========================================")
	warn("  Game systems FAILED: " .. tostring(gameErr))
	warn("  (World should still be visible)")
	warn("========================================")
end

-- If BOTH failed, create a fallback spawn
if not worldOk and not gameOk then
	warn("[Bootstrap] EVERYTHING FAILED - creating emergency spawn")
	local fallbackSpawn = Instance.new("SpawnLocation")
	fallbackSpawn.Name = "FallbackSpawn"
	fallbackSpawn.Size = Vector3.new(30, 1, 30)
	fallbackSpawn.Position = Vector3.new(0, 0.5, 0)
	fallbackSpawn.Color = Color3.fromRGB(255, 0, 0)
	fallbackSpawn.Material = Enum.Material.Neon
	fallbackSpawn.Anchored = true
	fallbackSpawn.Parent = workspace
end
