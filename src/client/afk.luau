local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local notifications = require(script.Parent:WaitForChild("notifications"))
local afkMod = {}



function afkMod.MatchIndextoSharedGift(layoutOrder)
	if layoutOrder == 0 then
		return library.Shared.TimeGifts[1].Minutes
	end
	return library.Shared.TimeGifts[layoutOrder].Minutes

end

function afkMod.checkIfCanClaim(template, seconds : number, layoutOrder)
	-- local timeTillreward = afkMod.MatchIndextoSharedGift(template.LayoutOrder)
	local plrTime = library.Player:GetAttribute("TimePlayed")
	if seconds <= 0 then
		template.Locked.Visible = false
		notifications.PromptTextNotification("You can claim your reward now!", 15)
		-- template.Claim.Visible = true
	end
end



function afkMod:Init()
	task.wait(2)

	local afkFrame = library.PlayerGui.ScreenGui.Frames.AFK.Holder
	library.Player:GetAttributeChangedSignal("TimePlayed"):Connect(function(test)
		local plrTime = library.Player:GetAttribute("TimePlayed")
	
		for _, child: TextLabel? in pairs(afkFrame:GetDescendants()) do
			if child:IsA("TextLabel") and child.Parent ~= nil and child.Parent.Name == "Locked" and child.Name == "Timer" and child.Parent.Visible then
				local template : Frame = child.Parent.Parent
				local timeTillreward = afkMod.MatchIndextoSharedGift(template.LayoutOrder)
				-- print(timeLeft)
				local timeLeft = timeTillreward * 60
				local secondsLeft = timeLeft - plrTime
				local timeFormatted = library.Functions.formatTime(secondsLeft, "minutes")
				child.Text = timeFormatted
				afkMod.checkIfCanClaim(template, secondsLeft, template.LayoutOrder)
				-- local minutestimeLeft = timeLeft - secondsLeft
			
				
			end
		end
	end)
	-- library.Player.Idled:Connect(function()
	-- 	library.Player:Kick("You were afk for too long")
	-- end)
end

return afkMod
