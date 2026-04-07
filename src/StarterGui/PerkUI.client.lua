--[[
	PerkUI.lua
	Skill tree / perk upgrade interface.
	Populates the "Perks" tab of the Tablet UI.
	Location: StarterGui/PerkUI (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerkData = require(ReplicatedStorage.Config.PerkData)
local Enums = require(ReplicatedStorage.Shared.Enums)

local player = Players.LocalPlayer

local PerkUI = {}

function PerkUI.init(tabletUI)
	PerkUI._tabletUI = tabletUI
	task.wait(0.5)

	local perksPage = tabletUI.getPage("Perks")
	if not perksPage then return end

	-- Perk points display
	local pointsFrame = Instance.new("Frame")
	pointsFrame.Name = "PointsFrame"
	pointsFrame.Size = UDim2.new(1, 0, 0, 40)
	pointsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	pointsFrame.LayoutOrder = 0
	pointsFrame.Parent = perksPage

	local pointsCorner = Instance.new("UICorner")
	pointsCorner.CornerRadius = UDim.new(0, 8)
	pointsCorner.Parent = pointsFrame

	local pointsLabel = Instance.new("TextLabel")
	pointsLabel.Name = "PointsLabel"
	pointsLabel.Size = UDim2.new(1, -10, 1, 0)
	pointsLabel.Position = UDim2.new(0, 5, 0, 0)
	pointsLabel.BackgroundTransparency = 1
	pointsLabel.Text = "Perk Points: 0"
	pointsLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
	pointsLabel.Font = Enum.Font.GothamBold
	pointsLabel.TextSize = 16
	pointsLabel.TextXAlignment = Enum.TextXAlignment.Center
	pointsLabel.Parent = pointsFrame

	-- Create perk category sections
	local layoutOrder = 1
	for categoryName, categoryData in pairs(PerkData.Perks) do
		local section = PerkUI._createCategorySection(categoryName, categoryData, layoutOrder)
		section.Parent = perksPage
		layoutOrder = layoutOrder + 1
	end

	PerkUI._pointsLabel = pointsLabel
	PerkUI._perksPage = perksPage

	-- Listen for perk updates
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local events = remotes:WaitForChild("Events")

	events:WaitForChild("PerkUnlocked").OnClientEvent:Connect(function(category, perkId, level)
		PerkUI._refreshPerks()
	end)

	events:WaitForChild("XPGained").OnClientEvent:Connect(function(category, amount, totalXP)
		PerkUI._refreshPerks()
	end)

	print("[PerkUI] Initialized")
end

function PerkUI._createCategorySection(categoryName, categoryData, order)
	local section = Instance.new("Frame")
	section.Name = "Category_" .. categoryName
	section.Size = UDim2.new(1, 0, 0, 50 + #categoryData.perks * 60)
	section.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	section.LayoutOrder = order

	local sectionCorner = Instance.new("UICorner")
	sectionCorner.CornerRadius = UDim.new(0, 8)
	sectionCorner.Parent = section

	-- Category title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -10, 0, 30)
	title.Position = UDim2.new(0, 5, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = categoryData.name .. " - " .. categoryData.description
	title.TextColor3 = Color3.fromRGB(255, 200, 100)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = section

	-- Perk rows
	for i, perk in ipairs(categoryData.perks) do
		local perkRow = Instance.new("Frame")
		perkRow.Name = "Perk_" .. perk.id
		perkRow.Size = UDim2.new(1, -10, 0, 50)
		perkRow.Position = UDim2.new(0, 5, 0, 35 + (i - 1) * 55)
		perkRow.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		perkRow.Parent = section

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 6)
		rowCorner.Parent = perkRow

		-- Perk name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.4, 0, 0, 20)
		nameLabel.Position = UDim2.new(0, 8, 0, 4)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = perk.name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 12
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = perkRow

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(0.4, 0, 0, 16)
		descLabel.Position = UDim2.new(0, 8, 0, 26)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = perk.description
		descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextSize = 10
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = perkRow

		-- Level buttons (3 levels)
		for lvl = 1, 3 do
			local levelBtn = Instance.new("TextButton")
			levelBtn.Name = "Level_" .. lvl
			levelBtn.Size = UDim2.new(0, 50, 0, 35)
			levelBtn.Position = UDim2.new(0.45 + (lvl - 1) * 0.18, 0, 0, 7)
			levelBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80) -- Locked
			levelBtn.Text = perk.levels[lvl].name
			levelBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			levelBtn.Font = Enum.Font.Gotham
			levelBtn.TextSize = 9
			levelBtn.TextWrapped = true
			levelBtn.Parent = perkRow

			local lvlCorner = Instance.new("UICorner")
			lvlCorner.CornerRadius = UDim.new(0, 4)
			lvlCorner.Parent = levelBtn

			levelBtn.MouseButton1Click:Connect(function()
				PerkUI._unlockPerk(categoryName, perk.id)
			end)
		end
	end

	return section
end

function PerkUI._unlockPerk(categoryName, perkId)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local events = remotes:FindFirstChild("Events")
		if events then
			local unlockEvent = events:FindFirstChild("UnlockPerk")
			if unlockEvent then
				unlockEvent:FireServer(categoryName, perkId)
			end
		end
	end
end

function PerkUI._refreshPerks()
	-- Request updated player data
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local functions = remotes:FindFirstChild("Functions")
		if functions then
			local getDataFunc = functions:FindFirstChild("GetPlayerData")
			if getDataFunc then
				local data = getDataFunc:InvokeServer()
				if data then
					PerkUI._pointsLabel.Text = "Perk Points: " .. (data.perkPoints or 0)

					-- Update perk level visuals
					-- Green = unlocked, Yellow = available, Gray = locked
					for _, section in ipairs(PerkUI._perksPage:GetChildren()) do
						if section:IsA("Frame") and section.Name:find("Category_") then
							local catName = section.Name:gsub("Category_", "")
							for _, perkRow in ipairs(section:GetChildren()) do
								if perkRow:IsA("Frame") and perkRow.Name:find("Perk_") then
									local perkId = perkRow.Name:gsub("Perk_", "")
									local currentLevel = data.perks[catName] and data.perks[catName][perkId] or 0

									for lvl = 1, 3 do
										local lvlBtn = perkRow:FindFirstChild("Level_" .. lvl)
										if lvlBtn then
											if lvl <= currentLevel then
												lvlBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 60) -- Unlocked
											elseif lvl == currentLevel + 1 then
												lvlBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 50) -- Available
											else
												lvlBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80) -- Locked
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

return PerkUI
