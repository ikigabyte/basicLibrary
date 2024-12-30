
local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local uiHandler = require(script.Parent:WaitForChild("ui"))


local inventory = {}


local debounce = false



function inventory.addInventoryButton(item)
    local screenGui = library.PlayerGui.ScreenGui
    local itemButton = library.Assets:FindFirstChild(item)
    -- if not itemButton then
    -- 	warn(item .. " not found in assets")
    -- 	return
    -- end
    uiHandler.animateButton(itemButton, { Size = UDim2.new(1.1, 0, 1.1, 0) }, "ExplosiveButton")
    local scrollingFrame = screenGui.Frames.Inventory.Holder.ScrollingFrame
    local copyButton = screenGui.Frames.Inventory.Holder.ScrollingFrame.Template:Clone()
    copyButton.Name = item
    copyButton.Visible = true
    copyButton.TextLabel.Text = item
    copyButton.Parent = screenGui.Frames.Inventory.Holder.ScrollingFrame

    copyButton.Activated:Connect(function()
        if debounce then
            return
        end
        debounce = true
        library.Events.EquipItem:FireServer(item)
        copyButton.UIStroke.Thickness = 6
        for _, button in pairs(scrollingFrame) do
            if button:IsA("TextButton") then
                button.UIStroke.Thickness = 4
            end
        end

        task.delay(1, function()
            debounce = false
        end)
    end)

    
end

function inventory:Init()
    library.Events.SetupProfile.OnClientEvent:Connect(function(data : {})
        -- local tables = data.Inventory.Tables
        -- for _, item in pairs(tables) do 
            -- inventory.addInventoryButton(item)   
        -- end
    end)

    library.Events.NewItem.OnClientEvent:Connect(function(item : string)
        -- inventory.addInventoryButton(item)
        -- uiHandler.addInventoryButton(item)
    end)
end


return inventory