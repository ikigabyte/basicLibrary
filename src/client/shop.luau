local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local ui = require(script.Parent:WaitForChild("ui"))
local sfx = require(script.Parent:WaitForChild("sfx"))

local shopMod = {}


function shopMod.setupCurrentPrice(button)
    local productID = library.Shared.DevProducts[button:GetAttribute("DevProduct")]
    if not productID then
        warn("no product id found")
        return
    end
    local existingPrice = library.MarketplaceService:GetProductInfo(productID, Enum.InfoType.Product)
    local price : TextLabel = button:FindFirstChild("Price")
    price.Text = ""..tostring(existingPrice.PriceInRobux) --  Is the ROBLOX Icon for prices, don't worry about it
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
	if not button:IsA("TextButton") and not button:IsA("ImageButton") then
        return
    end
	local devId = button:GetAttribute("DevProduct")
	local gamepassId = button:GetAttribute("Gamepass")
	local functionality = button:GetAttribute("Functionality")

	if functionality then
        if functionality == "Boost" then 
            local boostType = button:GetAttribute("BoostType") or nil
            button.Activated:Connect(function()
                sfx.Play("Click", 0.5)
                -- ui.animateButton(button, { Size = UDim2.new(1.1, 0, 1.1, 0), Rotation = 10 }, "ExplosiveButton")
                -- library.Events.PlayerSetting:FireServer("Boost", true)
                warn("firing to the server to initate the boost")
                library.Events.UseBoost:FireServer(boostType)
            end)
        end
		warn("this is a functional button")
	end
	if gamepassId then
		-- button.Activated:Connect(function()
        --     ui.animateButton(button.ImageLabel, { Size = UDim2.new(1.1, 0, 1.1, 0), Rotation = 10 }, "ExplosiveButton")
		-- 	game:GetService("MarketplaceService"):PromptGamePassPurchase(game.Players.LocalPlayer, gamepassId)
		-- end)
	end
	if devId ~= nil then
        local size = button.Size
        local xScale = size.X.Scale * 1.05
        local yScale = size.Y.Scale * 1.05
        -- print(devId)
        shopMod.setupCurrentPrice(button)
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
            local devProductId = library.Shared.DevProducts[devId]
            if not devProductId then warn("no dev product id found") return end
			game:GetService("MarketplaceService"):PromptProductPurchase(game.Players.LocalPlayer, devProductId)
		end)
	end
end


function shopMod:Init()
	task.wait(1)
    local profile = library.Events.GetProfile:InvokeServer()
    print(profile);
    local shop = library.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Frames"):WaitForChild("Shop")
    for boostName, boostStats in pairs(profile.Boosts) do
        print(tostring(boostName))
        shopMod.setupBoosts(boostName, boostStats, shop)
    end
    --You have to update the shop with the boosts that you have
	
	for _, button in pairs(shop:GetDescendants()) do
		shopMod.ValidateButton(button)
	end
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
