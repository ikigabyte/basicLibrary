
local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local uiHandler = require(script.Parent:WaitForChild("ui"))


local spinWheel = {}
local isSpinning = false


local wheelUI = library.PlayerGui.SpinWheel
local spinWheelFrame = library.PlayerGui.SpinWheel.Frame
-- local wheelUI = spinWheelFrame.Container
local timerFrame = spinWheelFrame.TimerFrame
local prizes = library.Shared.SpinWheelRewards

function spinWheel.OnSpin(spinButton)
    isSpinning = true
    local item = library.Events.GetSpinReward:InvokeServer() -- Gets the index of the number needed
    -- print(item.. " Is the item")
    if not item then 
        isSpinning = false
        warn("no item has been detected")
        return
    end
    -- print("spinnng now getting the reward here")
    wheelUI.Frame.Container.Rotation = 0
	local wheelSizeOffset = 360 / #prizes
	local spins =  0
	local maxSpins = library.Functions.random(5,10,true)
	task.wait(0.3)
	
	local tweenInfo = TweenInfo.new(maxSpins, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
	local randomized = (library.Functions.random(-1, 1, true)*math.random()*library.Functions.random(1, wheelSizeOffset - wheelSizeOffset/3, true))
	local spins = library.TweenService:Create(wheelUI.Frame.Container, tweenInfo, {Rotation = (25 - item*wheelSizeOffset + randomized) + ( 360*maxSpins)})
	print("spinning here")
	spins:Play()
	spins.Completed:Connect(function()
		isSpinning = false
        print("reward recieving here")
	end)



end


function spinWheel.PromptPurchase(spinButton)

    library.MarketplaceService:PromptProductPurchase(library.Players.LocalPlayer, library.Shared.DevProduct.BuySpins)

end


function spinWheel:Init()
    
    -- task.wait(2)
    local profile = library.Events.GetProfile:InvokeServer()--! I need to get how many things to get
    local spinWheelGui = library.PlayerGui.SpinWheel.Frame
    local spinButton = spinWheelGui.Spin
    local purhcaseButton = spinWheelGui.Purchase


    spinButton.Activated:Connect(function()
        if not isSpinning then
            local size = spinButton.Size
            local xScale = size.X.Scale * 1.05
            local yScale = size.Y.Scale * 1.05
            uiHandler.animateButton(spinButton, { Size = UDim2.new(xScale, 0, yScale, 0) }, "ExplosiveButton")
            spinWheel.OnSpin(spinButton)
        end
    end)
    local debounce = false
    purhcaseButton.Activated:Connect(function()
        if not debounce then 
            debounce = true
            spinWheel.PromptPurchase(purhcaseButton)
            task.wait(.5)
            debounce = false
        end
        --! Doesn't matter if you prompt it during the spin
    end)

    

end


return spinWheel




-- -- BORROWED CODE
-- local Library = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
-- while (not Library.Loaded) do game:GetService("RunService").Heartbeat:Wait() end

-- --Variables---------------------------
-- local GUI = Library.GUI
-- local TweenService = Library.TweenService
-- local index = Library.Index
-- local Prizes = index.Prizes
-- local wheelUI = GUI.SpinWheel
-- local player = Library.Players.LocalPlayer

-- local isSpinning = false
-- local Debounce = false

-- --Spins the wheel---------------------------
-- local function Spin()
-- 	local item = Library.Assets.Signals.Functions.GetItem:InvokeServer()
-- 	if not (typeof(item) == "number") then
-- 		if Library.Functions.Policies.HasAccessToRandomItems(game.Players.LocalPlayer) then
-- 			Library.MarketplaceService:PromptProductPurchase(player, 1572748410)
-- 		end
		
-- 		return false 
-- 	end
	
-- 	isSpinning = true
	
-- 	wheelUI.Frame.Container.Rotation = 0
-- 	local wheelSizeOffset = 360 / #Prizes
-- 	local spins =  0
-- 	local maxSpins = Library.Functions.Random(5, 10, true)
	
-- 	task.wait(0.3)
	
-- 	local tweenInfo = TweenInfo.new(maxSpins, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
-- 	local randomized = (Library.Functions.Random(-1, 1, true)*math.random()*Library.Functions.Random(1, wheelSizeOffset - wheelSizeOffset/3, true))
-- 	local spins = TweenService:Create(wheelUI.Frame.Container, tweenInfo, {Rotation = (25 - item*wheelSizeOffset + randomized) + ( 360*maxSpins)})
	
-- 	spins:Play()
-- 	spins.Completed:Connect(function()
-- 		isSpinning = false
-- 	end)
-- end

-- if not Library.Functions.Policies.HasAccessToRandomItems(game.Players.LocalPlayer) then
-- 	wheelUI.Frame.Purchase.Visible = false
-- end

-- --Signals---------------------------
-- Library.Assets.Signals.Events.UpdateSpinTimer.OnClientEvent:Connect(function(spins, lastSpin)
-- 	pcall(function()
-- 	wheelUI.Frame.Spin.Title.Text = "Spin (x" .. tostring(spins) .. ")"
-- 		wheelUI.Frame.TimerFrame.TimeLabel.Text = Library.Functions.FormatSeconds(86400 - lastSpin)
-- 	end)
-- end)

-- wheelUI.Frame.Purchase.Activated:Connect(function()
-- 	if not Debounce then
-- 		Debounce = not Debounce
-- 		Library.MarketplaceService:PromptProductPurchase(player, 1572748410)
		
-- 		task.wait(); Debounce = not Debounce
-- 	end
-- end)

-- wheelUI.Frame.Spin.Activated:Connect(function()
-- 	if not isSpinning then
-- 		Spin()
-- 	end
-- end)

-- Library.GUIFX.ButtonFX(wheelUI.Frame.Spin)
-- Library.GUIFX.ButtonFX(wheelUI.Frame.Close)
-- Library.GUIFX.ButtonFX(wheelUI.Frame.Purchase)
