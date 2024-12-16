local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local notifications = require(script.Parent:WaitForChild("notifications"))
local afkMod = {}

local sfx = require(script.Parent:WaitForChild("sfx"))
local ui = require(script.Parent:WaitForChild("ui"))


local buttonConnections = {}
function afkMod.MatchIndextoSharedGift(layoutOrder)
	if layoutOrder == 0 then
		return library.Shared.TimeGifts[1].Minutes
	end
	return library.Shared.TimeGifts[layoutOrder].Minutes
end

function afkMod.checkIfCanClaim(template, seconds: number, layoutOrder)
	-- local timeTillreward = afkMod.MatchIndextoSharedGift(template.LayoutOrder)
	local plrTime = library.Player:GetAttribute("TimePlayed")
	if seconds <= 0 then
		template.Locked.Visible = false
		--! this is firing 3 times i think
		notifications.PromptTextNotification("You can claim your reward now!", 15)
		-- template.Claim.Visible = true
	end
end

function afkMod.handleButton(button: TextButton | ImageButton)
	local size = button.Size
	local xScale = size.X.Scale * 1.05	
	local yScale = size.Y.Scale * 1.05
	ui.animateButton(button, { Size = UDim2.fromScale(xScale, yScale) }, "ExplosiveButton")
	local result = library.Events.ClaimTimeGift:InvokeServer(button.Parent.LayoutOrder)
	if result then
		button.UIStroke.Enabled = false
		button.BackgroundTransparency = 1
		button.TextLabel.Text = "Claimed!"
		sfx.Play("Click", 0.5)
	end
	if buttonConnections[button] then
		buttonConnections[button]:Disconnect()
	end
	-- return
end

function afkMod:Init()
	task.wait(2)
	local afkFrame = library.PlayerGui.ScreenGui.Frames.AFK.Holder
	local OPPet = library.PlayerGui.ScreenGui.Frames.OPPet
	local progressBar = OPPet.Tasks.Progress.Bar
	local timeLeft = library.Shared.TimeUntilOPPet

	library.Player:GetAttributeChangedSignal("TimePlayed"):Connect(function(test)
		local plrTime = library.Player:GetAttribute("TimePlayed")
		local modulus = plrTime / timeLeft
		print(modulus)
		progressBar.Size = UDim2.fromScale(modulus, 1)
		for _, child: TextLabel? in pairs(afkFrame:GetDescendants()) do
			if
				child:IsA("TextLabel")
				and child.Parent ~= nil
				and child.Parent.Name == "Locked"
				and child.Name == "Timer"
				and child.Parent.Visible
			then
				local template: Frame = child.Parent.Parent
				if template.Visible == false then
					continue
				end
				local timeTillreward = afkMod.MatchIndextoSharedGift(template.LayoutOrder)
				local timeLeft = timeTillreward * 60
				local secondsLeft = timeLeft - plrTime
				local timeFormatted = library.Functions.formatTime(secondsLeft, "minutes")
				child.Text = timeFormatted
				afkMod.checkIfCanClaim(template, secondsLeft, template.LayoutOrder)
				-- local minutestimeLeft = timeLeft - secondsLeft
			end
		end
	end)

	for _, child : TextButton in pairs(afkFrame:GetDescendants()) do
		if not child:IsA("TextButton") then
			continue
		end
		if not child.Name == "Claim" then
			continue
		end

		
		buttonConnections[child] = child.Activated:Connect(function()
			afkMod.handleButton(child)
		end)
	end
end

return afkMod
