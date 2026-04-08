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

-- Require with error handling so we can see what fails
local ok, err = pcall(function()
	local GameManager = require(script.Core.GameManager)
	GameManager.init()
end)

if ok then
	print("========================================")
	print("  Server ready! Waiting for players...")
	print("========================================")
else
	warn("========================================")
	warn("  SERVER INIT FAILED!")
	warn("  Error: " .. tostring(err))
	warn("========================================")

	-- Even if init fails, create a basic spawn so player isn't stuck
	local fallbackSpawn = Instance.new("SpawnLocation")
	fallbackSpawn.Name = "FallbackSpawn"
	fallbackSpawn.Size = Vector3.new(30, 1, 30)
	fallbackSpawn.Position = Vector3.new(0, 0.5, 0)
	fallbackSpawn.Color = Color3.fromRGB(255, 0, 0)
	fallbackSpawn.Material = Enum.Material.Neon
	fallbackSpawn.Anchored = true
	fallbackSpawn.Parent = workspace
end
