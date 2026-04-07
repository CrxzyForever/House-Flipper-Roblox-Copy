--[[
	BuyerUI.lua
	Buyer profiles and offer viewing interface.
	Populates the "Buyers" and "Houses" tabs of the Tablet UI.
	Location: StarterGui/BuyerUI (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuyerData = require(ReplicatedStorage.Config.BuyerData)
local HouseData = require(ReplicatedStorage.Config.HouseData)
local Utils = require(ReplicatedStorage.Shared.Utils)

local player = Players.LocalPlayer

local BuyerUI = {}

function BuyerUI.init(tabletUI)
	BuyerUI._tabletUI = tabletUI
	task.wait(0.5)

	-- === BUYERS TAB ===
	local buyersPage = tabletUI.getPage("Buyers")
	if buyersPage then
		BuyerUI._populateBuyerProfiles(buyersPage)
	end

	-- === HOUSES TAB ===
	local housesPage = tabletUI.getPage("Houses")
	if housesPage then
		BuyerUI._populateHouseListings(housesPage)
	end

	-- Listen for buyer offers
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local events = remotes:WaitForChild("Events")

	events:WaitForChild("BuyerOffersReceived").OnClientEvent:Connect(function(houseId, offers)
		BuyerUI._displayOffers(houseId, offers)
	end)

	print("[BuyerUI] Initialized")
end

function BuyerUI._populateBuyerProfiles(page)
	for i, buyer in ipairs(BuyerData.Buyers) do
		local card = Instance.new("Frame")
		card.Name = "Buyer_" .. buyer.id
		card.Size = UDim2.new(1, 0, 0, 120)
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		card.LayoutOrder = i
		card.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = card

		-- Name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.6, 0, 0, 25)
		nameLabel.Position = UDim2.new(0, 10, 0, 8)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = buyer.name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 16
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		-- Style preference badge
		local styleBadge = Instance.new("TextLabel")
		styleBadge.Size = UDim2.new(0, 80, 0, 22)
		styleBadge.Position = UDim2.new(1, -90, 0, 10)
		styleBadge.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
		styleBadge.Text = buyer.preferredStyle
		styleBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
		styleBadge.Font = Enum.Font.GothamBold
		styleBadge.TextSize = 10
		styleBadge.Parent = card

		local badgeCorner = Instance.new("UICorner")
		badgeCorner.CornerRadius = UDim.new(0, 6)
		badgeCorner.Parent = styleBadge

		-- Bio
		local bioLabel = Instance.new("TextLabel")
		bioLabel.Size = UDim2.new(1, -20, 0, 30)
		bioLabel.Position = UDim2.new(0, 10, 0, 35)
		bioLabel.BackgroundTransparency = 1
		bioLabel.Text = buyer.bio
		bioLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
		bioLabel.Font = Enum.Font.Gotham
		bioLabel.TextSize = 12
		bioLabel.TextWrapped = true
		bioLabel.TextXAlignment = Enum.TextXAlignment.Left
		bioLabel.TextYAlignment = Enum.TextYAlignment.Top
		bioLabel.Parent = card

		-- Requirements
		local reqText = "Needs: "
		for j, room in ipairs(buyer.requiredRooms) do
			reqText = reqText .. room
			if j < #buyer.requiredRooms then
				reqText = reqText .. ", "
			end
		end

		local reqLabel = Instance.new("TextLabel")
		reqLabel.Size = UDim2.new(1, -20, 0, 18)
		reqLabel.Position = UDim2.new(0, 10, 0, 70)
		reqLabel.BackgroundTransparency = 1
		reqLabel.Text = reqText
		reqLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		reqLabel.Font = Enum.Font.Gotham
		reqLabel.TextSize = 11
		reqLabel.TextXAlignment = Enum.TextXAlignment.Left
		reqLabel.Parent = card

		-- Likes/Dislikes
		local likesText = "Likes: " .. table.concat(buyer.likedItems, ", ")
		local likesLabel = Instance.new("TextLabel")
		likesLabel.Size = UDim2.new(0.5, -10, 0, 18)
		likesLabel.Position = UDim2.new(0, 10, 0, 92)
		likesLabel.BackgroundTransparency = 1
		likesLabel.Text = likesText
		likesLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		likesLabel.Font = Enum.Font.Gotham
		likesLabel.TextSize = 10
		likesLabel.TextXAlignment = Enum.TextXAlignment.Left
		likesLabel.TextTruncate = Enum.TextTruncate.AtEnd
		likesLabel.Parent = card

		local dislikesText = "Dislikes: " .. table.concat(buyer.dislikedItems, ", ")
		local dislikesLabel = Instance.new("TextLabel")
		dislikesLabel.Size = UDim2.new(0.5, -10, 0, 18)
		dislikesLabel.Position = UDim2.new(0.5, 0, 0, 92)
		dislikesLabel.BackgroundTransparency = 1
		dislikesLabel.Text = dislikesText
		dislikesLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		dislikesLabel.Font = Enum.Font.Gotham
		dislikesLabel.TextSize = 10
		dislikesLabel.TextXAlignment = Enum.TextXAlignment.Left
		dislikesLabel.TextTruncate = Enum.TextTruncate.AtEnd
		dislikesLabel.Parent = card
	end
end

function BuyerUI._populateHouseListings(page)
	-- Section title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 30)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Available Properties"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.LayoutOrder = 0
	titleLabel.Parent = page

	for i, house in ipairs(HouseData.Houses) do
		local card = Instance.new("Frame")
		card.Name = "House_" .. house.id
		card.Size = UDim2.new(1, 0, 0, 110)
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		card.LayoutOrder = i
		card.Parent = page

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = card

		-- House name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.7, 0, 0, 25)
		nameLabel.Position = UDim2.new(0, 10, 0, 5)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = house.name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 15
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		-- Size badge
		local sizeBadge = Instance.new("TextLabel")
		sizeBadge.Size = UDim2.new(0, 70, 0, 20)
		sizeBadge.Position = UDim2.new(1, -80, 0, 8)
		sizeBadge.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
		sizeBadge.Text = house.sizeCategory
		sizeBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
		sizeBadge.Font = Enum.Font.GothamBold
		sizeBadge.TextSize = 10
		sizeBadge.Parent = card

		local sizCorner = Instance.new("UICorner")
		sizCorner.CornerRadius = UDim.new(0, 5)
		sizCorner.Parent = sizeBadge

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, -20, 0, 25)
		descLabel.Position = UDim2.new(0, 10, 0, 30)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = house.description
		descLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextSize = 11
		descLabel.TextWrapped = true
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = card

		-- Stats
		local statsText = string.format("%d rooms | %d floor(s) | %s",
			house.rooms, house.floors, house.hasGarden and "Garden" or "No Garden")
		local statsLabel = Instance.new("TextLabel")
		statsLabel.Size = UDim2.new(0.6, 0, 0, 18)
		statsLabel.Position = UDim2.new(0, 10, 0, 58)
		statsLabel.BackgroundTransparency = 1
		statsLabel.Text = statsText
		statsLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
		statsLabel.Font = Enum.Font.Gotham
		statsLabel.TextSize = 11
		statsLabel.TextXAlignment = Enum.TextXAlignment.Left
		statsLabel.Parent = card

		-- Price
		local priceLabel = Instance.new("TextLabel")
		priceLabel.Size = UDim2.new(0.4, 0, 0, 25)
		priceLabel.Position = UDim2.new(0, 10, 0, 78)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Text = Utils.formatMoney(house.purchasePrice)
		priceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		priceLabel.Font = Enum.Font.GothamBold
		priceLabel.TextSize = 16
		priceLabel.TextXAlignment = Enum.TextXAlignment.Left
		priceLabel.Parent = card

		-- Buy button
		local buyBtn = Instance.new("TextButton")
		buyBtn.Name = "BuyButton"
		buyBtn.Size = UDim2.new(0, 120, 0, 32)
		buyBtn.Position = UDim2.new(1, -130, 0, 68)
		buyBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
		buyBtn.Text = "Purchase"
		buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyBtn.Font = Enum.Font.GothamBold
		buyBtn.TextSize = 14
		buyBtn.Parent = card

		local buyCorner = Instance.new("UICorner")
		buyCorner.CornerRadius = UDim.new(0, 6)
		buyCorner.Parent = buyBtn

		buyBtn.MouseButton1Click:Connect(function()
			BuyerUI._buyHouse(house.id)
		end)
	end
end

function BuyerUI._buyHouse(houseId)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local events = remotes:FindFirstChild("Events")
		if events then
			local buyEvent = events:FindFirstChild("BuyHouse")
			if buyEvent then
				buyEvent:FireServer(houseId)
			end
		end
	end
end

function BuyerUI._displayOffers(houseId, offers)
	-- Could create a popup or update the houses tab
	-- For now, notify through the console
	if #offers > 0 then
		local bestOffer = offers[1]
		print(string.format("[BuyerUI] Best offer for %s: %s offers %s (%.0f%% satisfied)",
			houseId, bestOffer.buyerName, Utils.formatMoney(bestOffer.price), bestOffer.satisfaction * 100))
	end
end

return BuyerUI
