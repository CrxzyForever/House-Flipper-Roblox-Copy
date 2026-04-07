--[[
	HudUI.lua
	Main HUD: money display, current tool, minimap, notifications.
	Location: StarterGui/HudUI (LocalScript)

	NOTE: In Roblox Studio, this should be a LocalScript inside a ScreenGui.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Utils = require(ReplicatedStorage.Shared.Utils)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local HudUI = {}

function HudUI.init()
	-- Create the main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HouseFlipperHUD"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- === MONEY DISPLAY (Top Right) ===
	local moneyFrame = Instance.new("Frame")
	moneyFrame.Name = "MoneyFrame"
	moneyFrame.Size = UDim2.new(0, 250, 0, 50)
	moneyFrame.Position = UDim2.new(1, -260, 0, 10)
	moneyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	moneyFrame.BackgroundTransparency = 0.3
	moneyFrame.Parent = screenGui

	local moneyCorner = Instance.new("UICorner")
	moneyCorner.CornerRadius = UDim.new(0, 10)
	moneyCorner.Parent = moneyFrame

	local moneyIcon = Instance.new("TextLabel")
	moneyIcon.Name = "MoneyIcon"
	moneyIcon.Size = UDim2.new(0, 40, 1, 0)
	moneyIcon.Position = UDim2.new(0, 5, 0, 0)
	moneyIcon.BackgroundTransparency = 1
	moneyIcon.Text = "$"
	moneyIcon.TextColor3 = Color3.fromRGB(100, 255, 100)
	moneyIcon.Font = Enum.Font.GothamBold
	moneyIcon.TextSize = 28
	moneyIcon.Parent = moneyFrame

	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(1, -50, 1, 0)
	moneyLabel.Position = UDim2.new(0, 45, 0, 0)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "2,000"
	moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.TextSize = 24
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
	moneyLabel.Parent = moneyFrame

	-- === TOOL DISPLAY (Bottom Center) ===
	local toolFrame = Instance.new("Frame")
	toolFrame.Name = "ToolFrame"
	toolFrame.Size = UDim2.new(0, 300, 0, 70)
	toolFrame.Position = UDim2.new(0.5, -150, 1, -80)
	toolFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	toolFrame.BackgroundTransparency = 0.3
	toolFrame.Parent = screenGui

	local toolCorner = Instance.new("UICorner")
	toolCorner.CornerRadius = UDim.new(0, 10)
	toolCorner.Parent = toolFrame

	local toolName = Instance.new("TextLabel")
	toolName.Name = "ToolName"
	toolName.Size = UDim2.new(1, -10, 0.5, 0)
	toolName.Position = UDim2.new(0, 5, 0, 0)
	toolName.BackgroundTransparency = 1
	toolName.Text = "Broom / Mop"
	toolName.TextColor3 = Color3.fromRGB(255, 255, 255)
	toolName.Font = Enum.Font.GothamBold
	toolName.TextSize = 18
	toolName.TextXAlignment = Enum.TextXAlignment.Center
	toolName.Parent = toolFrame

	local toolHint = Instance.new("TextLabel")
	toolHint.Name = "ToolHint"
	toolHint.Size = UDim2.new(1, -10, 0.5, 0)
	toolHint.Position = UDim2.new(0, 5, 0.5, 0)
	toolHint.BackgroundTransparency = 1
	toolHint.Text = "Click to clean | Q to switch | 1-6 for tools"
	toolHint.TextColor3 = Color3.fromRGB(180, 180, 180)
	toolHint.Font = Enum.Font.Gotham
	toolHint.TextSize = 14
	toolHint.TextXAlignment = Enum.TextXAlignment.Center
	toolHint.Parent = toolFrame

	-- === NOTIFICATION AREA (Top Center) ===
	local notifFrame = Instance.new("Frame")
	notifFrame.Name = "NotificationFrame"
	notifFrame.Size = UDim2.new(0, 400, 0, 50)
	notifFrame.Position = UDim2.new(0.5, -200, 0, -60) -- Starts off-screen
	notifFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	notifFrame.BackgroundTransparency = 0.2
	notifFrame.Parent = screenGui

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 10)
	notifCorner.Parent = notifFrame

	local notifLabel = Instance.new("TextLabel")
	notifLabel.Name = "NotifLabel"
	notifLabel.Size = UDim2.new(1, -20, 1, 0)
	notifLabel.Position = UDim2.new(0, 10, 0, 0)
	notifLabel.BackgroundTransparency = 1
	notifLabel.Text = ""
	notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	notifLabel.Font = Enum.Font.GothamBold
	notifLabel.TextSize = 16
	notifLabel.TextWrapped = true
	notifLabel.Parent = notifFrame

	-- === JOB PROGRESS (Left Side) ===
	local jobFrame = Instance.new("Frame")
	jobFrame.Name = "JobFrame"
	jobFrame.Size = UDim2.new(0, 280, 0, 200)
	jobFrame.Position = UDim2.new(0, 10, 0, 70)
	jobFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	jobFrame.BackgroundTransparency = 0.3
	jobFrame.Visible = false -- Hidden until a job is active
	jobFrame.Parent = screenGui

	local jobCorner = Instance.new("UICorner")
	jobCorner.CornerRadius = UDim.new(0, 10)
	jobCorner.Parent = jobFrame

	local jobTitle = Instance.new("TextLabel")
	jobTitle.Name = "JobTitle"
	jobTitle.Size = UDim2.new(1, -10, 0, 30)
	jobTitle.Position = UDim2.new(0, 5, 0, 5)
	jobTitle.BackgroundTransparency = 1
	jobTitle.Text = "Current Job"
	jobTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
	jobTitle.Font = Enum.Font.GothamBold
	jobTitle.TextSize = 16
	jobTitle.TextXAlignment = Enum.TextXAlignment.Left
	jobTitle.Parent = jobFrame

	local jobTaskList = Instance.new("ScrollingFrame")
	jobTaskList.Name = "TaskList"
	jobTaskList.Size = UDim2.new(1, -10, 1, -40)
	jobTaskList.Position = UDim2.new(0, 5, 0, 35)
	jobTaskList.BackgroundTransparency = 1
	jobTaskList.ScrollBarThickness = 4
	jobTaskList.Parent = jobFrame

	local taskLayout = Instance.new("UIListLayout")
	taskLayout.SortOrder = Enum.SortOrder.LayoutOrder
	taskLayout.Padding = UDim.new(0, 4)
	taskLayout.Parent = jobTaskList

	-- Store references
	HudUI._screenGui = screenGui
	HudUI._moneyLabel = moneyLabel
	HudUI._toolName = toolName
	HudUI._toolHint = toolHint
	HudUI._notifFrame = notifFrame
	HudUI._notifLabel = notifLabel
	HudUI._jobFrame = jobFrame
	HudUI._jobTitle = jobTitle
	HudUI._taskList = jobTaskList

	-- Connect to remote events
	HudUI._connectEvents()

	print("[HudUI] Initialized")
end

function HudUI._connectEvents()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local events = remotes:WaitForChild("Events")

	-- Money updates
	events:WaitForChild("MoneyChanged").OnClientEvent:Connect(function(amount)
		HudUI.updateMoney(amount)
	end)

	-- Notifications
	events:WaitForChild("NotifyPlayer").OnClientEvent:Connect(function(message)
		HudUI.showNotification(message)
	end)

	-- Tool equip updates
	events:WaitForChild("ToolEquipped").OnClientEvent:Connect(function(toolType)
		local ToolConfig = require(ReplicatedStorage.Config.ToolConfig)
		local toolDef = ToolConfig.Tools[toolType]
		if toolDef then
			HudUI.updateTool(toolDef.displayName, toolDef.description)
		end
	end)
end

function HudUI.updateMoney(amount)
	if HudUI._moneyLabel then
		local formatted = Utils.formatMoney(amount)
		HudUI._moneyLabel.Text = formatted

		-- Flash green briefly
		HudUI._moneyLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		task.delay(0.5, function()
			HudUI._moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
	end
end

function HudUI.updateTool(name, hint)
	if HudUI._toolName then
		HudUI._toolName.Text = name
	end
	if HudUI._toolHint then
		HudUI._toolHint.Text = hint or "Click to use | Q to switch"
	end
end

function HudUI.showNotification(message, duration)
	duration = duration or 3

	if HudUI._notifLabel then
		HudUI._notifLabel.Text = message
	end

	if HudUI._notifFrame then
		-- Slide in from top
		local slideIn = TweenService:Create(
			HudUI._notifFrame,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Position = UDim2.new(0.5, -200, 0, 10)}
		)
		slideIn:Play()

		-- Slide out after duration
		task.delay(duration, function()
			local slideOut = TweenService:Create(
				HudUI._notifFrame,
				TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{Position = UDim2.new(0.5, -200, 0, -60)}
			)
			slideOut:Play()
		end)
	end
end

function HudUI.showJobProgress(jobTitle, tasks, progress)
	if HudUI._jobFrame then
		HudUI._jobFrame.Visible = true
		HudUI._jobTitle.Text = jobTitle

		-- Clear existing task items
		for _, child in ipairs(HudUI._taskList:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		-- Add task items
		for i, taskInfo in ipairs(tasks) do
			local taskLabel = Instance.new("TextLabel")
			taskLabel.Size = UDim2.new(1, 0, 0, 22)
			taskLabel.BackgroundTransparency = 1
			taskLabel.Font = Enum.Font.Gotham
			taskLabel.TextSize = 13
			taskLabel.TextXAlignment = Enum.TextXAlignment.Left
			taskLabel.LayoutOrder = i

			local prog = progress[i] or 0
			local completed = prog >= taskInfo.count

			if completed then
				taskLabel.Text = "  [DONE] " .. taskInfo.description
				taskLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			else
				taskLabel.Text = string.format("  [%d/%d] %s", prog, taskInfo.count, taskInfo.description)
				taskLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
			end

			taskLabel.Parent = HudUI._taskList
		end
	end
end

function HudUI.hideJobProgress()
	if HudUI._jobFrame then
		HudUI._jobFrame.Visible = false
	end
end

return HudUI
