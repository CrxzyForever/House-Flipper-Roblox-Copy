--[[
	PlacementController.lua
	Client-side furniture placement system with grid snapping, rotation, and preview.
	Location: StarterPlayerScripts/Controllers/PlacementController
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FurnitureData = require(ReplicatedStorage.Config.FurnitureData)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local PlacementController = {}

PlacementController._isPlacing = false
PlacementController._currentItem = nil
PlacementController._previewModel = nil
PlacementController._rotation = 0 -- Degrees (0, 90, 180, 270)
PlacementController._gridSize = 1 -- Stud grid snapping
PlacementController._canPlace = false
PlacementController._currentHouseId = nil
PlacementController._renderConnection = nil

function PlacementController.init()
	-- Input handling for placement mode
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if not PlacementController._isPlacing then return end

		-- R to rotate
		if input.KeyCode == Enum.KeyCode.R then
			PlacementController._rotation = (PlacementController._rotation + 90) % 360
		end

		-- G to toggle grid size
		if input.KeyCode == Enum.KeyCode.G then
			if PlacementController._gridSize == 1 then
				PlacementController._gridSize = 0.5
			elseif PlacementController._gridSize == 0.5 then
				PlacementController._gridSize = 2
			else
				PlacementController._gridSize = 1
			end
		end

		-- Escape to cancel placement
		if input.KeyCode == Enum.KeyCode.Escape then
			PlacementController.cancelPlacement()
		end

		-- Click to place
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			PlacementController._confirmPlacement()
		end
	end)

	print("[PlacementController] Initialized")
end

-- Start placing a furniture item
function PlacementController.startPlacement(furnitureId, houseId)
	local itemData = FurnitureData.getById(furnitureId)
	if not itemData then
		warn("[PlacementController] Unknown furniture: " .. furnitureId)
		return
	end

	-- Cancel any existing placement
	if PlacementController._isPlacing then
		PlacementController.cancelPlacement()
	end

	PlacementController._isPlacing = true
	PlacementController._currentItem = itemData
	PlacementController._currentHouseId = houseId
	PlacementController._rotation = 0
	PlacementController._canPlace = false

	-- Create preview model (semi-transparent ghost of the furniture)
	PlacementController._createPreview(itemData)

	-- Start render step for preview following mouse
	PlacementController._renderConnection = RunService.RenderStepped:Connect(function()
		PlacementController._updatePreview()
	end)

	print("[PlacementController] Started placing: " .. itemData.name)
end

-- Cancel the current placement
function PlacementController.cancelPlacement()
	PlacementController._isPlacing = false
	PlacementController._currentItem = nil

	-- Remove preview
	if PlacementController._previewModel then
		PlacementController._previewModel:Destroy()
		PlacementController._previewModel = nil
	end

	-- Disconnect render
	if PlacementController._renderConnection then
		PlacementController._renderConnection:Disconnect()
		PlacementController._renderConnection = nil
	end
end

-- Confirm placement at current position
function PlacementController._confirmPlacement()
	if not PlacementController._isPlacing or not PlacementController._canPlace then return end

	local itemData = PlacementController._currentItem
	local previewCFrame = PlacementController._previewModel and PlacementController._previewModel:GetPrimaryPartCFrame()

	if not previewCFrame then return end

	-- Fire placement event to server
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local events = remotes:FindFirstChild("Events")
		if events then
			local placeEvent = events:FindFirstChild("PlaceFurniture")
			if placeEvent then
				placeEvent:FireServer(
					PlacementController._currentHouseId,
					itemData.id,
					previewCFrame.Position,
					PlacementController._rotation
				)
			end
		end
	end

	-- Clean up
	PlacementController.cancelPlacement()
end

-- Create a preview model for the furniture
function PlacementController._createPreview(itemData)
	-- Create a simple box preview (in full implementation, clone the actual model)
	local preview = Instance.new("Model")
	preview.Name = "FurniturePreview"

	local primaryPart = Instance.new("Part")
	primaryPart.Name = "PrimaryPart"
	primaryPart.Size = Vector3.new(itemData.size[1], itemData.size[2], itemData.size[3])
	primaryPart.Anchored = true
	primaryPart.CanCollide = false
	primaryPart.Transparency = 0.5
	primaryPart.Color = Color3.fromRGB(100, 200, 100) -- Green tint for valid placement
	primaryPart.Material = Enum.Material.ForceField
	primaryPart.Parent = preview

	preview.PrimaryPart = primaryPart
	preview.Parent = workspace

	-- Add a BillboardGui showing the item name
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, itemData.size[2] / 2 + 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = primaryPart

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.Text = itemData.name
	nameLabel.Parent = billboard

	PlacementController._previewModel = preview
end

-- Update preview position to follow mouse
function PlacementController._updatePreview()
	if not PlacementController._previewModel then return end

	local target = mouse.Target
	local hitPos = mouse.Hit.Position

	if not target then
		PlacementController._canPlace = false
		PlacementController._setPreviewColor(false)
		return
	end

	-- Check range
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local distance = (hrp.Position - hitPos).Magnitude
	if distance > GameConfig.PLACEMENT_RANGE then
		PlacementController._canPlace = false
		PlacementController._setPreviewColor(false)
		return
	end

	-- Snap to grid
	local itemData = PlacementController._currentItem
	local gridSize = PlacementController._gridSize
	local snappedPos = Vector3.new(
		math.round(hitPos.X / gridSize) * gridSize,
		hitPos.Y + (itemData.size[2] / 2), -- Place on surface
		math.round(hitPos.Z / gridSize) * gridSize
	)

	-- Handle wall-mounted items
	if itemData.placementType == "wall" then
		-- Snap to wall surface
		local normal = mouse.TargetSurface
		if normal == Enum.NormalId.Front then
			snappedPos = snappedPos + Vector3.new(0, 0, -0.1)
		elseif normal == Enum.NormalId.Back then
			snappedPos = snappedPos + Vector3.new(0, 0, 0.1)
		elseif normal == Enum.NormalId.Left then
			snappedPos = snappedPos + Vector3.new(-0.1, 0, 0)
		elseif normal == Enum.NormalId.Right then
			snappedPos = snappedPos + Vector3.new(0.1, 0, 0)
		end
	end

	-- Apply rotation
	local rotationCFrame = CFrame.Angles(0, math.rad(PlacementController._rotation), 0)
	local finalCFrame = CFrame.new(snappedPos) * rotationCFrame

	PlacementController._previewModel:SetPrimaryPartCFrame(finalCFrame)

	-- Check for collisions (simplified)
	local primaryPart = PlacementController._previewModel.PrimaryPart
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {PlacementController._previewModel, character}

	local overlapping = workspace:GetPartsInPart(primaryPart, overlapParams)
	local hasCollision = false
	for _, part in ipairs(overlapping) do
		if part.CanCollide and not part:HasTag("Floor") and not part:HasTag("BuildSurface") then
			hasCollision = true
			break
		end
	end

	PlacementController._canPlace = not hasCollision
	PlacementController._setPreviewColor(not hasCollision)
end

-- Set preview color (green = valid, red = invalid)
function PlacementController._setPreviewColor(valid)
	if not PlacementController._previewModel then return end
	local primaryPart = PlacementController._previewModel.PrimaryPart
	if primaryPart then
		if valid then
			primaryPart.Color = Color3.fromRGB(100, 200, 100)
		else
			primaryPart.Color = Color3.fromRGB(200, 100, 100)
		end
	end
end

return PlacementController
