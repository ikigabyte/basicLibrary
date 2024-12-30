local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local uiHandler = require(script.Parent:WaitForChild("ui"))

local gameShop = {}

local debounce = false

function gameShop.getMostRecentPrice(productId: number)
	local existingPrice
	local success, errorMsg = pcall(function()
		existingPrice = library.MarketplaceService:GetProductInfo(productId, Enum.InfoType.GamePass)
	end)
	if success then
		return existingPrice.PriceInRobux
	else
		warn("error getting the price for ", productId, errorMsg)
	end
end

function gameShop.setupViewport(button, nameOfProduct)
	local product = library.Assets.Balls:FindFirstChild(nameOfProduct)
	if not product then
		-- warn("no product found here of that name ")
		return
	end
	local viewport: ViewportFrame = button.ViewportFrame
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	local cloneProduct = product:Clone()
	cloneProduct.Parent = viewport
	-- camera.CFrame = cloneProduct.CFrame * CFrame.new(0, 5, 5)
	local newCFrame = CFrame.new(cloneProduct.Position + Vector3.new(0, 4.5, 6)) * CFrame.Angles(math.rad(-45), 0, 0)
	-- camera.FieldOfView = 30
	camera.CFrame = newCFrame
	camera.FieldOfView = 60
end

local debounce = false

function gameShop.onButtonPress(button: TextButton, isGamepass: boolean, infoTable: {})
	if debounce then
		return
	end
	debounce = true
	task.delay(0.2, function()
		debounce = false
	end)
	-- warn("clicked here")
	local size = button.Size
	local sizeX = size.X.Scale * 1.1
	local sizeY = size.Y.Scale * 1.1
	uiHandler.animateButton(button, { Size = UDim2.new(sizeX,0,sizeY,0) }, "ExplosiveButton")
	if isGamepass then
		library.MarketplaceService:PromptGamePassPurchase(library.Player, 1003212013)
	else
		library.Events.HandleItem:FireServer(button.Name) -- Purchase / or equip this item
		-- warn("handling the button here")
	end
end

function gameShop:Init()
	local profile = library.Events.GetProfile:InvokeServer()
	local playerBalls = profile.Inventory.Balls
	local sharedBalls = library.Shared.Balls
	local scrollingContainer = library.PlayerGui.ScreenGui.Frames.GameShop.Holder.ScrollingFrame
	local Container = scrollingContainer.Container

	for name, infoTable in pairs(sharedBalls) do
		local price = infoTable.Price
		local boost = infoTable.Boost
		local id = infoTable.Id or nil
		local isGamepass = price == "Gamepass"
		local cloneContainer = Container:Clone()
		local cloneButton = cloneContainer.TextButton
		cloneContainer.Parent = scrollingContainer
		gameShop.setupViewport(cloneButton, name)
		cloneContainer.Visible = true
		-- cloneButton.Visible = true
		cloneButton.TextLabel.Text = tostring(name)
		cloneButton.Name = name
		--You need to setup the balls in the shop, based on the order of the item
		-- You need to find out which ones the player owns by looking into the shop
		-- then activate the button

		if table.find(playerBalls, name) then
			cloneButton.PriceLabel.Visible = false
			-- gameShop.addInventoryButton(item)
			-- warn("the player has this ball here")
		end

		if price == "Gamepass" then
			local passPrice = gameShop.getMostRecentPrice(id) or warn("something errored out here")
			cloneButton.PriceLabel.Text = " " .. passPrice
		else
			cloneButton.PriceLabel.Text = "🏆 " .. price
		end
		-- 🏆
		cloneButton.Activated:Connect(function()
			gameShop.onButtonPress(cloneButton, isGamepass)
		end)
	end

	-- for _, item in pairs(balls) do

	--     -- gameShop.addInventoryButton(item)
	-- end
end

return gameShop
