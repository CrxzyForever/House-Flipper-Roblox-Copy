--[[
	Server Bootstrap
	Initializes all server-side systems for House Flipper.
	Location: ServerScriptService/init (Script, not ModuleScript)

	NOTE: In Roblox Studio, this should be a regular Script (not ModuleScript).
	It runs automatically when the server starts.
]]

local GameManager = require(script.Core.GameManager)

-- Start the game
print("========================================")
print("  House Flipper - Roblox Edition")
print("  Starting server systems...")
print("========================================")

GameManager.init()

print("========================================")
print("  Server ready! Waiting for players...")
print("========================================")
