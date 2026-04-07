--[[
	CameraController.lua
	Manages camera modes: third-person follow, free-look for placement, and first-person option.
	Location: StarterPlayerScripts/Controllers/CameraController
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local CameraController = {}

CameraController._mode = "ThirdPerson" -- ThirdPerson, FreeLook, FirstPerson
CameraController._offset = Vector3.new(0, 8, 12) -- Default third-person offset
CameraController._zoomLevel = 12 -- Current zoom distance
CameraController._minZoom = 5
CameraController._maxZoom = 25
CameraController._sensitivity = 0.3
CameraController._pitch = -20 -- Degrees
CameraController._yaw = 0 -- Degrees

function CameraController.init()
	-- Set camera type
	camera.CameraType = Enum.CameraType.Scriptable

	-- Handle mouse wheel zoom
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			CameraController._zoomLevel = math.clamp(
				CameraController._zoomLevel - input.Position.Z * 2,
				CameraController._minZoom,
				CameraController._maxZoom
			)
		end
	end)

	-- Toggle camera mode with V key
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.V then
			CameraController.toggleMode()
		end
	end)

	-- Update camera every frame
	RunService.RenderStepped:Connect(function(dt)
		CameraController._update(dt)
	end)

	print("[CameraController] Initialized in " .. CameraController._mode .. " mode")
end

function CameraController.toggleMode()
	if CameraController._mode == "ThirdPerson" then
		CameraController._mode = "FirstPerson"
		CameraController._zoomLevel = 0
	else
		CameraController._mode = "ThirdPerson"
		CameraController._zoomLevel = 12
	end
end

function CameraController.setMode(mode)
	CameraController._mode = mode
	if mode == "FirstPerson" then
		CameraController._zoomLevel = 0
	elseif mode == "ThirdPerson" then
		CameraController._zoomLevel = 12
	end
end

function CameraController._update(dt)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local targetPos = humanoidRootPart.Position

	if CameraController._mode == "ThirdPerson" or CameraController._mode == "FreeLook" then
		-- Calculate camera position based on zoom and angle
		local pitchRad = math.rad(CameraController._pitch)
		local yawRad = math.rad(CameraController._yaw)

		local offsetX = CameraController._zoomLevel * math.cos(pitchRad) * math.sin(yawRad)
		local offsetY = CameraController._zoomLevel * math.sin(-pitchRad)
		local offsetZ = CameraController._zoomLevel * math.cos(pitchRad) * math.cos(yawRad)

		local cameraPos = targetPos + Vector3.new(offsetX, offsetY + 3, offsetZ)

		camera.CFrame = CFrame.lookAt(cameraPos, targetPos + Vector3.new(0, 2, 0))

	elseif CameraController._mode == "FirstPerson" then
		local head = character:FindFirstChild("Head")
		if head then
			camera.CFrame = head.CFrame
		end
	end
end

return CameraController
