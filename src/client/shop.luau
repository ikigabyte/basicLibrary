local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local ui = require(script.Parent:WaitForChild("ui"))
local sfx = require(script.Parent:WaitForChild("sfx"))

local shopMod = {}



function shopMod.setupCurrentPrice(button, category: string, productId : number)
    local typeOfProduct = Enum.InfoType.Product
    if category == "Gamepass" then
        typeOfProduct = Enum.InfoType.GamePass
    end
    local existingPrice
    local priceLabel : TextLabel = button:FindFirstChild("Price")
    local success, errorMsg = pcall(function()
        -- library.MarketplaceService:GetProductInfo(productId, typeOfProduct)
        existingPrice = library.MarketplaceService:GetProductInfo(productId, typeOfProduct)
    end)
    if success and priceLabel then 
        -- warn("got the price")
        priceLabel.Text = ""..tostring(existingPrice.PriceInRobux) --  Is the ROBLOX Icon for prices, don't worry about it
    else
        warn("error getting the price for " , productId , category, errorMsg)
    end
end



function shopMod.setupBoosts(boost, boostStats, shopFrame)

    for _, frame: Frame? in pairs(shopFrame:GetDescendants()) do
        if frame.Name == tostring(boost) then
            local owned = frame:FindFirstChild("Use")
            if owned then
                owned.TextLabel.Text = `Use ({boostStats.Owned})`
            end
            warn("updated here")
        end
    end
    -- must find the boost in the shopFrame
    -- then change the owned ammount to the boost thing
end

function shopMod.ValidateButton(button)
    
	local devProductAttribute = button:GetAttribute("DevProduct")
	local gamepassAttribute = button:GetAttribute("Gamepass")
	local functionality = button:GetAttribute("Functionality")
	if functionality then
        if functionality == "Boost" then 
            local boostType = button:GetAttribute("BoostType") or nil
            button.Activated:Connect(function()
                sfx.Play("Click", 0.5)
                -- ui.animateButton(button, { Size = UDim2.new(1.1, 0, 1.1, 0), Rotation = 10 }, "ExplosiveButton")
                -- library.Events.PlayerSetting:FireServer("Boost", true)
                -- warn("firing to the server to initate the boost")
                library.Events.UseBoost:FireServer(boostType)
            end)
        end
		warn("this is a functional button")
	end
	if gamepassAttribute then
        local gamepassId = library.Shared.Gamepasses[gamepassAttribute]
        if gamepassId == nil then warn("no gamepass id found here") return end 
        shopMod.setupCurrentPrice(button, "Gamepass", gamepassId)
        button.Activated:Connect(function()
            sfx.Play("Click", 0.5)
            local size = button.Size
            local xScale = size.X.Scale * 1.05
            local yScale = size.Y.Scale * 1.05
            ui.animateButton(button, { Size = UDim2.fromScale(xScale,yScale) }, "ExplosiveButton")
            library.MarketplaceService:PromptGamePassPurchase(game.Players.LocalPlayer, gamepassId) 
        end)
		-- button.Activated:Connect(function()
        --     ui.animateButton(button.ImageLabel, { Size = UDim2.new(1.1, 0, 1.1, 0), Rotation = 10 }, "ExplosiveButton")
		-- 	game:GetService("MarketplaceService"):PromptGamePassPurchase(game.Players.LocalPlayer, gamepassId)
		-- end)
	end
	if devProductAttribute ~= nil then
        local devProductId = library.Shared.DevProduct[devProductAttribute]
        if not devProductId then warn("no dev product id found") return end
        local size = button.Size
        local xScale = size.X.Scale * 1.05
        local yScale = size.Y.Scale * 1.05
        shopMod.setupCurrentPrice(button, "DevProduct", devProductId)
		button.Activated:Connect(function()
            sfx.Play("Click", 0.5)
            if button.Name == "Boost" then
                ui.animateButton(button, { Size =  UDim2.new(xScale,0,yScale,0)}, "ExplosiveButton")
            else
                size = button.ImageLabel.Size
                xScale = size.X.Scale * 1.05
                yScale = size.Y.Scale * 1.05
                ui.animateButton(button.ImageLabel, { Size =  UDim2.fromScale(xScale, yScale), Rotation = 8}, "ExplosiveButton")
            end
			game:GetService("MarketplaceService"):PromptProductPurchase(game.Players.LocalPlayer, devProductId)
		end)
	end
end


function shopMod:Init()
	task.wait(1.5)
    local profile = library.Events.GetProfile:InvokeServer()
    local screenGui = library.PlayerGui:WaitForChild("ScreenGui")
    local shop = screenGui:WaitForChild("Frames"):WaitForChild("Shop")
    local afkBuyButton = screenGui.Frames.AFK.BuyButton
    local buyOPPet = screenGui.Frames.OPPet.Button
    for boostName, boostStats in pairs(profile.Boosts) do
        shopMod.setupBoosts(boostName, boostStats, shop)
    end

    --You have to update the shop with the boosts that you have
	for _, button in pairs(shop:GetDescendants()) do
        if not button:IsA("TextButton") and  not button:IsA("ImageButton") then
            continue
        end
		shopMod.ValidateButton(button)
	end
    shopMod.ValidateButton(afkBuyButton)
    shopMod.ValidateButton(buyOPPet)

	local scrollingFrame = shop:WaitForChild("ScrollingFrame")
	shop.ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
	local canvasSize = shop.ScrollingFrame.AbsoluteCanvasSize

	for _, shopBookmarkButton: TextButton in pairs(shop.Buttons:GetChildren()) do
		if not shopBookmarkButton:IsA("TextButton") or shopBookmarkButton:IsA("ImageButton") then
			continue
		end
        local positionAttribute = shopBookmarkButton:GetAttribute("UIPosition") or 0
        local uiPosition = canvasSize.Y * positionAttribute
		shopBookmarkButton.Activated:Connect(function()
            ui.animateScroll(scrollingFrame, { CanvasPosition = Vector2.new(0, uiPosition) }, "FastScroll")
			-- warn("reset bookmark here")
		end)
	end
end

return shopMod
