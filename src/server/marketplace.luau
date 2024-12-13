

local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local marketplace = {}
local marketplaceFunctions = {}
--! We're gonna handle vip people

--! we're gonna handle gamepass functionality here 
--! handle developer products here


local currentPlayerFunctions = {}



marketplaceFunctions["DoublePower"] = function(player : Player)
    warn("activating a potion here")
    if player:GetAttribute("DoublePower") then 
        player:SetAttribute("DoublePower", player:GetAttribute("DoublePower") + (60 * 15))
        return
    end
    player:SetAttribute("DoublePower", 60 * 15)
    local doublePower = player:GetAttribute("DoublePower")
    task.delay(1, function()
        while player:IsDescendantOf(library.Players) and doublePower >= 0 do
            doublePower = player:GetAttribute("DoublePower")
            player:SetAttribute("DoublePower", doublePower - 1)
            task.wait(1)
        end
        warn("finished the boost here")
    end) 
end

function marketplace.handlePurchase(player, productId)
    warn("handling the purchase here")
    local name
    for productName, id in pairs(library.Shared.DevProducts) do 
        print(productName, productId)
        if id == productId then 
            name = productName
        end
    end
    if name and marketplaceFunctions[name] ~= nil then
        marketplaceFunctions[name](player)
    end
end


marketplace.Init = function()
    library.MarketplaceService.ProcessReceipt = function(receiptInfo)
        local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then return false end
        warn("handlign the purchase here")
        return marketplace.handlePurchase(player, receiptInfo.ProductId)
    end

    

end


return marketplace