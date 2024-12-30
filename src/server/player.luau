local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
-- local zone = require(library.ReplicatedStorage.Modules:WaitForChild("Zone"))
-- local marketplace = require(script.Parent:WaitForChild("marketplace"))
local playerMod = {}
local playerGifts = {}
local loadedPlayers = {}
local debounceChecks = {}

local promoCodes = require(script.Parent.promocodes)

function playerMod.checkIfPlayerCanClaim(player, playerTime, indexTable)
	if playerGifts[player] == nil then
		playerGifts[player] = {}
		--! check here if the player already has a history other then that 
	else
		if playerGifts[player][indexTable] then
			warn("you've already claimed this gift")
			return false
		end	
	end
	
	local minutesGift = library.Shared.TimeGifts[indexTable]
	local timeLeft = minutesGift.Minutes / 60
	if playerTime >= timeLeft then 
		table.insert(playerGifts[player], indexTable)
		return true
	end
end



function playerMod.setupTool(player : Player, profile)
	local tool = Instance.new("Tool")
	tool.Name = "TrainingTool"
	tool.RequiresHandle = false

	
	local dumbell = library.Assets.Dumbbells.Starter:Clone()
	dumbell.Parent = player.Character
	local rightHand = player.Character:WaitForChild("RightHand")
	dumbell.CFrame = rightHand.CFrame
	local wc = Instance.new("WeldConstraint")
	wc.Parent = dumbell
	wc.Part0 = dumbell
	wc.Part1 = rightHand

	-- dumbell.Name = "Handle"
	

	tool.Parent = player.Character 
	--! update the tool with the latest profile settings
	tool:SetAttribute("Multiplier", 1)
	--! ability to switch out dummbbels maybe might be fun 

	local multiplierAttribute = tool:GetAttribute("Multiplier")
	tool.Activated:Connect(function()
		if not tool:IsDescendantOf(workspace) then 
			warn("not descendant of workspace here")
			return 
		end
		--! my goal is to start connecting it to the client
		library.Events.GiveCurrency:Fire(player, "Power", 1)
	end)
end

function playerMod.CodeReedemed(player, codeRedeemed)
	local profile = library.Events.serverGetProfile:Invoke(player)
	if not profile then 
		warn("no profile found")
		return
	end
	local checkCode = promoCodes[codeRedeemed]
	if checkCode then
		library.Events.SendNotification:FireClient(player, "Code was succesfully redeemed", "Error")
		print("redeemed the code")
	else
		library.Events.SendNotification:FireClient(player, "Code couldn't be redeemed succesfully", "Success")
		warn("code doesn't exist, sending something back here")
	end

end


function playerMod.giveGift(player, giftType, gift)
	giftType = string.lower(giftType)
	if giftType == "cash" then
		library.Events.GiveCurrency:Fire(player, "Cash", gift.Reward)
		return true
	end
	if giftType == "power" then 
		library.Events.GiveCurrency:Fire(player, "Power", gift.Reward)
		return true
	end
	if giftType == "wins" then
		library.Events.GiveCurrency:Fire(player, "Wins", gift.Reward)
		return true
	end

	warn("No gift of that name was found ", gift)
	return false
end

function playerMod.rewardPlayer(player, rewardIndex)
	local gift = library.Shared.TimeGifts[rewardIndex]
	if gift then
		if gift.RewardType == "Cash" then
			library.Events.GiveCurrency:Fire(player, "Cash", gift.Reward) -- ! this is for the data
		end
		if gift.RewardType == "Pet" then
			warn("giving a pet here,")
			-- library.Events.GiveCurrency(player, "Coins", gift.Reward)
		end
	else
		warn("no gift of that reward index found here")
	end
end


function playerMod.onSpinReward(player: Player)
	local rewardIndex = library.Functions.random(1, #library.Shared.SpinWheelRewards, true)
	-- playerMod.rewardPlayer(player, rewardIndex)
	local reward = library.Shared.SpinWheelRewards[rewardIndex]
	local rewardType = reward.RewardType
	local ammt = reward.Reward
	playerMod.giveGift(player, rewardType, ammt)
	warn("given the player a reward here")

end
function playerMod.UpdatePlayer(player : Player)
	if loadedPlayers[player] ~= nil then
		return
	end
	local profile = library.Events.serverGetProfile:Invoke(player)
    -- task.wait(3)
	--! get the profile here
	--! get the last login
	playerMod.setupTool(player, "TrainingTool", profile)
	player.CharacterAdded:Connect(function()
		warn("character added")
		playerMod.setupTool(player, "TrainingTool")
	end)
	local result = library.Events.HasGamepass:Invoke(player, 90058789677835)
	if result then 
	end
	loadedPlayers[player] = profile
	player:SetAttribute("VIP", true)
	-- warn("set the player attribute to vip")
    
    -- print(profile.. "is the profile")
    -- print(profile)
    -- warn("loaded here")
    library.Events.UpdateCurrency:FireClient(player, "Cash", profile.Cash)
    library.Events.UpdateCurrency:FireClient(player, "Gems", profile.Gems)
	--! see if it's the first time the player is getting something here
	task.spawn(function()
		local timePlayed = player:GetAttribute("TimeInGame") or 0
		while player:IsDescendantOf(library.Players) do
			player:SetAttribute("TimePlayed", timePlayed + 1)
			task.wait(1)
			timePlayed = player:GetAttribute("TimePlayed")
			-- playerMod.getRewardForMinutes(timePlayed / 60)
		end
	end)
end

function playerMod:Init()
	for _, player in pairs(library.Players:GetChildren()) do
		task.spawn(function()
			playerMod.UpdatePlayer(player)
		end)
		-- playerMod.UpdatePlayer(player)
	end
	library.Players.PlayerAdded:Connect(function(player)
		-- playerMod.UpdatePlayer(player)
		task.spawn(function()
			playerMod.UpdatePlayer(player)
		end)
	end)

	library.Events.GetSpinReward.OnServerInvoke = function(player)
		return playerMod.onSpinReward(player)
	end


	
	library.TextChatService:WaitForChild("profile").Triggered:Connect(function(textSource : TextSource, message : string)
		-- print(textSource, message)
		local player = library.Players:GetPlayerByUserId(textSource.UserId)
		local profile = library.Events.serverGetProfile:Invoke(player)
		print(profile)
	end)

	library.TextChatService:WaitForChild("data").Triggered:Connect(function(textSource, message)
		-- print(player.Name .. " said " .. message)
		local player = library.Players:GetPlayerByUserId(textSource.UserId)
		local splitMessage = string.split(message, " ")
		-- print(splitMessage[1])
		if splitMessage[1] == "give" then
			local currency = splitMessage[2]
			local ammt = tonumber(splitMessage[3])
			print("giving the player " .. currency .. " " .. ammt)
			local result = playerMod.giveGift(player, currency, {Reward = ammt, RewardType = currency})
			-- print(result)
			-- print("doing a give command here")
		end
	end)

	library.Events.RedeemCode.OnServerEvent:Connect(function(player, code)
		playerMod.CodeReedemed(player, code)
	end)
	library.Events.ClaimTimeGift.OnServerInvoke = function(player, rewardIndex)
		if debounceChecks[player] ~= nil then
			return false
		end
		debounceChecks[player] = true
		--! check the timed played here
		--* We have to keep track of the timed gifts that the player has recieved
		local playedTime = player:GetAttribute("TimePlayed")
		local result = playerMod.checkIfPlayerCanClaim(player, playedTime, rewardIndex)
		if result then
			playerMod.rewardPlayer(player, rewardIndex)
		end
		debounceChecks[player] = nil
		return result
	end
end

return playerMod
