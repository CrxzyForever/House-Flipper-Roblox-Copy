--[[
	ShopUI.lua
	Furniture, paint, and tile shop interface.
	Populates the "Shop" tab of the Tablet UI.
	Location: StarterGui/ShopUI (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FurnitureData = require(ReplicatedStorage.Config.FurnitureData)
local Enums = require(ReplicatedStorage.Shared.Enums)
local Utils = require(ReplicatedStorage.Shared.Utils)

local player = Players.LocalPlayer

local ShopUI = {}

ShopUI._selectedCategory = "All"
ShopUI._categories = {"All", "Kitchen", "Bathroom", "Bedroom", "LivingRoom", "Office", "Dining", "Decorative", "Appliances", "Paint", "Tiles"}

function ShopUI.init(tabletUI)
	ShopUI._tabletUI = tabletUI
	task.wait(0.5) -- Wait for tablet to initialize

	local shopPage = tabletUI.getPage("Shop")
	if not shopPage then return end

	-- Category filter bar
	local filterFrame = Instance.new("Frame")
	filterFrame.Name = "FilterFrame"
	filterFrame.Size = UDim2.new(1, 0, 0, 35)
	filterFrame.BackgroundTransparency = 1
	filterFrame.LayoutOrder = 0
	filterFrame.Parent = shopPage

	local filterLayout = Instance.new("UIListLayout")
	filterLayout.FillDirection = Enum.FillDirection.Horizontal
	filterLayout.SortOrder = Enum.SortOrder.LayoutOrder
	filterLayout.Padding = UDim.new(0, 4)
	filterLayout.Parent = filterFrame

	for i, cat in ipairs(ShopUI._categories) do
		local catBtn = Instance.new("TextButton")
		catBtn.Name = "Cat_" .. cat
		catBtn.Size = UDim2.new(0, 80, 1, 0)
		catBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
		catBtn.Text = cat == "LivingRoom" and "Living" or cat
		catBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		catBtn.Font = Enum.Font.Gotham
		catBtn.TextSize = 11
		catBtn.LayoutOrder = i
		catBtn.Parent = filterFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = catBtn

		catBtn.MouseButton1Click:Connect(function()
			ShopUI.filterCategory(cat)
		end)
	end

	-- Items container
	local itemsFrame = Instance.new("Frame")
	itemsFrame.Name = "ItemsFrame"
	itemsFrame.Size = UDim2.new(1, 0, 0, 2000) -- Will auto-resize
	itemsFrame.BackgroundTransparency = 1
	itemsFrame.LayoutOrder = 1
	itemsFrame.Parent = shopPage

	local itemsGrid = Instance.new("UIGridLayout")
	itemsGrid.CellSize = UDim2.new(0, 200, 0, 120)
	itemsGrid.CellPadding = UDim2.new(0, 8, 0, 8)
	itemsGrid.SortOrder = Enum.SortOrder.LayoutOrder
	itemsGrid.Parent = itemsFrame

	ShopUI._shopPage = shopPage
	ShopUI._itemsFrame = itemsFrame
	ShopUI._filterFrame = filterFrame

	-- Populate with all items
	ShopUI.filterCategory("All")

	print("[ShopUI] Initialized")
end

function ShopUI.filterCategory(category)
	ShopUI._selectedCategory = category

	-- Clear existing items
	for _, child in ipairs(ShopUI._itemsFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Update filter button highlights
	for _, btn in ipairs(ShopUI._filterFrame:GetChildren()) do
		if btn:IsA("TextButton") then
			if btn.Name == "Cat_" .. category then
				btn.BackgroundColor3 = Color3.fromRGB(80, 80, 150)
			else
				btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
			end
		end
	end

	if category == "Paint" then
		ShopUI._populatePaint()
	elseif category == "Tiles" then
		ShopUI._populateTiles()
	else
		ShopUI._populateFurniture(category)
	end
end

function ShopUI._populateFurniture(category)
	local items
	if category == "All" then
		items = FurnitureData.Items
	else
		items = FurnitureData.getByCategory(category)
	end

	for i, item in ipairs(items) do
		ShopUI._createItemCard(item, i)
	end
end

function ShopUI._populatePaint()
	for i, paint in ipairs(FurnitureData.PaintColors) do
		local card = Instance.new("Frame")
		card.Name = "Paint_" .. paint.id
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		card.LayoutOrder = i
		card.Parent = ShopUI._itemsFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = card

		-- Color swatch
		local swatch = Instance.new("Frame")
		swatch.Size = UDim2.new(0, 40, 0, 40)
		swatch.Position = UDim2.new(0, 10, 0, 10)
		swatch.BackgroundColor3 = paint.color
		swatch.Parent = card

		local swatchCorner = Instance.new("UICorner")
		swatchCorner.CornerRadius = UDim.new(0, 8)
		swatchCorner.Parent = swatch

		-- Name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -60, 0, 20)
		nameLabel.Position = UDim2.new(0, 55, 0, 10)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = paint.name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 13
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		-- Price
		local priceLabel = Instance.new("TextLabel")
		priceLabel.Size = UDim2.new(1, -60, 0, 20)
		priceLabel.Position = UDim2.new(0, 55, 0, 30)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Text = Utils.formatMoney(paint.price) .. " per can"
		priceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		priceLabel.Font = Enum.Font.Gotham
		priceLabel.TextSize = 12
		priceLabel.TextXAlignment = Enum.TextXAlignment.Left
		priceLabel.Parent = card

		-- Buy button
		local buyBtn = Instance.new("TextButton")
		buyBtn.Size = UDim2.new(1, -20, 0, 30)
		buyBtn.Position = UDim2.new(0, 10, 1, -40)
		buyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
		buyBtn.Text = "Buy"
		buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyBtn.Font = Enum.Font.GothamBold
		buyBtn.TextSize = 13
		buyBtn.Parent = card

		local buyCorner = Instance.new("UICorner")
		buyCorner.CornerRadius = UDim.new(0, 6)
		buyCorner.Parent = buyBtn

		buyBtn.MouseButton1Click:Connect(function()
			ShopUI._purchaseItem("paint", paint.id, 5) -- Buy 5 cans at a time
		end)
	end
end

function ShopUI._populateTiles()
	for i, tile in ipairs(FurnitureData.TileOptions) do
		local card = Instance.new("Frame")
		card.Name = "Tile_" .. tile.id
		card.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		card.LayoutOrder = i
		card.Parent = ShopUI._itemsFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = card

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -10, 0, 20)
		nameLabel.Position = UDim2.new(0, 5, 0, 10)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = tile.name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 13
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		local priceLabel = Instance.new("TextLabel")
		priceLabel.Size = UDim2.new(1, -10, 0, 20)
		priceLabel.Position = UDim2.new(0, 5, 0, 32)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Text = Utils.formatMoney(tile.price) .. " per tile"
		priceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		priceLabel.Font = Enum.Font.Gotham
		priceLabel.TextSize = 12
		priceLabel.TextXAlignment = Enum.TextXAlignment.Left
		priceLabel.Parent = card

		local buyBtn = Instance.new("TextButton")
		buyBtn.Size = UDim2.new(1, -20, 0, 30)
		buyBtn.Position = UDim2.new(0, 10, 1, -40)
		buyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
		buyBtn.Text = "Buy x10"
		buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyBtn.Font = Enum.Font.GothamBold
		buyBtn.TextSize = 13
		buyBtn.Parent = card

		local buyCorner = Instance.new("UICorner")
		buyCorner.CornerRadius = UDim.new(0, 6)
		buyCorner.Parent = buyBtn

		buyBtn.MouseButton1Click:Connect(function()
			ShopUI._purchaseItem("tile", tile.id, 10)
		end)
	end
end

function ShopUI._createItemCard(item, order)
	local card = Instance.new("Frame")
	card.Name = "Item_" .. item.id
	card.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	card.LayoutOrder = order
	card.Parent = ShopUI._itemsFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card

	-- Item name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 20)
	nameLabel.Position = UDim2.new(0, 5, 0, 8)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = card

	-- Category & Style tags
	local tagLabel = Instance.new("TextLabel")
	tagLabel.Size = UDim2.new(1, -10, 0, 16)
	tagLabel.Position = UDim2.new(0, 5, 0, 28)
	tagLabel.BackgroundTransparency = 1
	tagLabel.Text = item.category .. " | " .. item.style
	tagLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
	tagLabel.Font = Enum.Font.Gotham
	tagLabel.TextSize = 11
	tagLabel.TextXAlignment = Enum.TextXAlignment.Left
	tagLabel.Parent = card

	-- Price
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(1, -10, 0, 20)
	priceLabel.Position = UDim2.new(0, 5, 0, 48)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = Utils.formatMoney(item.price)
	priceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.TextSize = 15
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Parent = card

	-- Buy & Place button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(1, -20, 0, 28)
	buyBtn.Position = UDim2.new(0, 10, 1, -38)
	buyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
	buyBtn.Text = "Buy & Place"
	buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyBtn.Font = Enum.Font.GothamBold
	buyBtn.TextSize = 13
	buyBtn.Parent = card

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 6)
	buyCorner.Parent = buyBtn

	buyBtn.MouseButton1Click:Connect(function()
		ShopUI._purchaseAndPlace(item.id)
	end)
end

function ShopUI._purchaseItem(itemType, itemId, quantity)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local events = remotes:FindFirstChild("Events")
		if events then
			local purchaseEvent = events:FindFirstChild("PurchaseItem")
			if purchaseEvent then
				purchaseEvent:FireServer(itemType, itemId, quantity)
			end
		end
	end
end

function ShopUI._purchaseAndPlace(furnitureId)
	-- Purchase the item
	ShopUI._purchaseItem("furniture", furnitureId, 1)

	-- Close tablet and start placement mode
	if ShopUI._tabletUI then
		ShopUI._tabletUI.close()
	end

	-- Start placement (PlacementController handles this)
	local PlacementController = require(player.PlayerScripts.Controllers.PlacementController)
	PlacementController.startPlacement(furnitureId, "current_house") -- TODO: pass actual house ID
end

return ShopUI
