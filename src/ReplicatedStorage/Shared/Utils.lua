--[[
	Utils.lua
	Shared utility functions for House Flipper.
	Location: ReplicatedStorage/Shared/Utils
]]

local Utils = {}

-- Format money with commas and dollar sign
function Utils.formatMoney(amount)
	local formatted = tostring(math.floor(amount))
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return "$" .. formatted
end

-- Calculate distance between two Vector3 positions
function Utils.distance(a, b)
	return (a - b).Magnitude
end

-- Lerp between two values
function Utils.lerp(a, b, t)
	return a + (b - a) * math.clamp(t, 0, 1)
end

-- Deep copy a table
function Utils.deepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = Utils.deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

-- Calculate area of a room (given a list of corner positions on the XZ plane)
function Utils.calculateRoomArea(corners)
	-- Shoelace formula for polygon area
	local n = #corners
	if n < 3 then return 0 end

	local area = 0
	for i = 1, n do
		local j = (i % n) + 1
		area = area + (corners[i].X * corners[j].Z)
		area = area - (corners[j].X * corners[i].Z)
	end
	return math.abs(area) / 2
end

-- Convert studs² to m² (Roblox studs to game meters)
-- 1 stud = 0.28 meters roughly, but we use 1 stud = 1 foot for gameplay
-- We'll say 10 studs = 3 meters for simplicity
function Utils.studsToMeters(studs)
	return studs * 0.3
end

function Utils.metersToStuds(meters)
	return meters / 0.3
end

-- Check if a point is inside a rectangular boundary
function Utils.isPointInBounds(point, minBound, maxBound)
	return point.X >= minBound.X and point.X <= maxBound.X
		and point.Z >= minBound.Z and point.Z <= maxBound.Z
end

-- Get random element from a table
function Utils.randomChoice(tbl)
	if #tbl == 0 then return nil end
	return tbl[math.random(1, #tbl)]
end

-- Merge two tables (shallow)
function Utils.merge(base, override)
	local result = {}
	for k, v in pairs(base) do
		result[k] = v
	end
	for k, v in pairs(override) do
		result[k] = v
	end
	return result
end

-- Create a debounce wrapper
function Utils.debounce(cooldown)
	local lastTime = 0
	return function()
		local now = tick()
		if now - lastTime >= cooldown then
			lastTime = now
			return true
		end
		return false
	end
end

return Utils
