local premiumMod = {}
local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))


function premiumMod:Init()
	library.TextChatService.OnIncomingMessage = function(message)
		local Properties = Instance.new("TextChatMessageProperties")
		if message.TextSource then
			local player = library.Players:GetPlayerByUserId(message.TextSource.UserId)	
			if player:GetAttribute("VIP") == true then
				Properties.PrefixText = "<font color='#00ffee'>[VIP] </font> "..message.PrefixText
			end
		end
	
		return Properties	
	end
end


return premiumMod