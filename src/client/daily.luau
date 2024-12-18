local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

local dailyMod = {}
local sfx = require(script.Parent:WaitForChild("sfx"))
local ui = require(script.Parent:WaitForChild("ui"))

local debounce = true
local buttonsConnections = {}

function dailyMod.onButtonCheck(button: TextButton?)
	if not debounce then
		return
	end
	debounce = false
	task.delay(1, function()
		debounce = true
	end)
	local buttonSize = button.Size
	local xScale = buttonSize.X.Scale * 1.05
	local yScale = buttonSize.Y.Scale * 1.05
	sfx.Play("Click", 0.5)
	ui.animateButton(button, { Size = UDim2.new(xScale, 0, yScale, 0) }, "ExplosiveButton")
	-- print(button.Parent.Name)
	local buttonIndex = string.split(button.Parent.Name, "Day")[2]
	local result = library.Events.CheckDailyGift:InvokeServer(buttonIndex)
	if result then 
		if buttonsConnections[button] then
			buttonsConnections[button]:Disconnect()
		end	
		button.UIStroke.Enabled = false
		button.BackgroundTransparency = 1
		button.TextLabel.Text = "Claimed!"
	end
	-- print(result)
end

function dailyMod.SetupDailyRewards(dailyFrame: Frame)
	local dailyFrame = library.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Frames"):WaitForChild("DailyRewards")
	local profile = library.Events.GetProfile:InvokeServer()
	if not profile then
		warn("profile not here")
		return
	end
	local currentStreak = profile.CurrentStreak

	for index, rewardTable in pairs(library.Shared.DailyRewards) do
		-- print(index, rewardTable)
		local convertedName = "Day" .. index
		local rewardFrame = dailyFrame.Frame:FindFirstChild(convertedName)
		if index == 7 then
			rewardFrame = dailyFrame:FindFirstChild("Day7")
		end
		local claimButton: TextButton = rewardFrame.TextButton
		if index > currentStreak then
		buttonsConnections[claimButton] = claimButton.Activated:Connect(function()
				dailyMod.onButtonCheck(claimButton)
			end)
		else
			claimButton.BackgroundTransparency = 1
			claimButton.UIStroke.Enabled = false
			claimButton.TextLabel.Text = "Claimed!"
		end
		
		if not rewardFrame then
			warn("no frame found for this index")
			continue
		end
		-- print(rewardFrame)
		local prizeLabel = rewardFrame.PrizeLabel
		prizeLabel.Text = rewardTable.DisplayName
	end
end

function dailyMod:Init()
	task.wait(1)
	dailyMod.SetupDailyRewards()
end

return dailyMod
