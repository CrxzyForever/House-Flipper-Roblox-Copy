--[[
	TabletUI.lua
	Main tablet interface - the central hub for all menus.
	Opened with TAB key. Contains tabs: Shop, Jobs, Houses, Perks, Buyers.
	Location: StarterGui/TabletUI (LocalScript)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TabletUI = {}
TabletUI._isOpen = false
TabletUI._currentTab = "Jobs"
TabletUI._tabs = {"Jobs", "Shop", "Houses", "Perks", "Buyers"}

function TabletUI.init()
	-- Create main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TabletUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.Parent = playerGui

	-- Dark overlay background
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.Parent = screenGui

	-- Main tablet frame
	local tabletFrame = Instance.new("Frame")
	tabletFrame.Name = "TabletFrame"
	tabletFrame.Size = UDim2.new(0, 700, 0, 500)
	tabletFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
	tabletFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	tabletFrame.BorderSizePixel = 0
	tabletFrame.Parent = screenGui

	local tabletCorner = Instance.new("UICorner")
	tabletCorner.CornerRadius = UDim.new(0, 16)
	tabletCorner.Parent = tabletFrame

	local tabletStroke = Instance.new("UIStroke")
	tabletStroke.Color = Color3.fromRGB(80, 80, 120)
	tabletStroke.Thickness = 2
	tabletStroke.Parent = tabletFrame

	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 45)
	titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = tabletFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 16)
	titleCorner.Parent = titleBar

	-- Fix bottom corners of title bar
	local titleFix = Instance.new("Frame")
	titleFix.Size = UDim2.new(1, 0, 0, 16)
	titleFix.Position = UDim2.new(0, 0, 1, -16)
	titleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	titleFix.BorderSizePixel = 0
	titleFix.Parent = titleBar

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 200, 1, 0)
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "House Flipper Tablet"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleBar

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 35, 0, 35)
	closeBtn.Position = UDim2.new(1, -40, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.Parent = titleBar

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		TabletUI.close()
	end)

	-- Tab buttons
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, -20, 0, 40)
	tabBar.Position = UDim2.new(0, 10, 0, 50)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = tabletFrame

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.Parent = tabBar

	for i, tabName in ipairs(TabletUI._tabs) do
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "Tab_" .. tabName
		tabBtn.Size = UDim2.new(0, 130, 1, 0)
		tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
		tabBtn.Text = tabName
		tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		tabBtn.Font = Enum.Font.GothamBold
		tabBtn.TextSize = 14
		tabBtn.LayoutOrder = i
		tabBtn.Parent = tabBar

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 8)
		btnCorner.Parent = tabBtn

		tabBtn.MouseButton1Click:Connect(function()
			TabletUI.switchTab(tabName)
		end)
	end

	-- Content area
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -20, 1, -105)
	contentFrame.Position = UDim2.new(0, 10, 0, 95)
	contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	contentFrame.BorderSizePixel = 0
	contentFrame.Parent = tabletFrame

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 10)
	contentCorner.Parent = contentFrame

	-- Create content pages for each tab
	for _, tabName in ipairs(TabletUI._tabs) do
		local page = Instance.new("ScrollingFrame")
		page.Name = "Page_" .. tabName
		page.Size = UDim2.new(1, -10, 1, -10)
		page.Position = UDim2.new(0, 5, 0, 5)
		page.BackgroundTransparency = 1
		page.ScrollBarThickness = 6
		page.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
		page.Visible = (tabName == TabletUI._currentTab)
		page.Parent = contentFrame

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Padding = UDim.new(0, 8)
		pageLayout.Parent = page
	end

	-- Store references
	TabletUI._screenGui = screenGui
	TabletUI._tabletFrame = tabletFrame
	TabletUI._contentFrame = contentFrame
	TabletUI._tabBar = tabBar

	-- Toggle with TAB key
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Tab then
			TabletUI.toggle()
		end
	end)

	-- Set initial tab highlight
	TabletUI.switchTab("Jobs")

	print("[TabletUI] Initialized")
end

function TabletUI.toggle()
	if TabletUI._isOpen then
		TabletUI.close()
	else
		TabletUI.open()
	end
end

function TabletUI.open()
	TabletUI._isOpen = true
	TabletUI._screenGui.Enabled = true

	-- Animate in
	TabletUI._tabletFrame.Position = UDim2.new(0.5, -350, 1, 50) -- Start below screen
	local tween = TweenService:Create(
		TabletUI._tabletFrame,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, -350, 0.5, -250)}
	)
	tween:Play()
end

function TabletUI.close()
	TabletUI._isOpen = false

	local tween = TweenService:Create(
		TabletUI._tabletFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Position = UDim2.new(0.5, -350, 1, 50)}
	)
	tween:Play()
	tween.Completed:Connect(function()
		TabletUI._screenGui.Enabled = false
	end)
end

function TabletUI.switchTab(tabName)
	TabletUI._currentTab = tabName

	-- Update tab button highlights
	for _, btn in ipairs(TabletUI._tabBar:GetChildren()) do
		if btn:IsA("TextButton") then
			if btn.Name == "Tab_" .. tabName then
				btn.BackgroundColor3 = Color3.fromRGB(80, 80, 150)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
				btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
		end
	end

	-- Show/hide content pages
	for _, page in ipairs(TabletUI._contentFrame:GetChildren()) do
		if page:IsA("ScrollingFrame") then
			page.Visible = (page.Name == "Page_" .. tabName)
		end
	end
end

-- Get a content page to populate (used by other UI modules)
function TabletUI.getPage(tabName)
	if TabletUI._contentFrame then
		return TabletUI._contentFrame:FindFirstChild("Page_" .. tabName)
	end
	return nil
end

return TabletUI
