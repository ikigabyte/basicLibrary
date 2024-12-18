local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

-- local marketplace = require(script.Parent:WaitForChild("marketplace"))
local playerMod = {}
local playerGifts = {}
local loadedPlayers = {}
local debounceChecks = {}

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


function playerMod.setupTool(player : Player, toolName)

	local tool = Instance.new("Tool")
	tool.Name = toolName
	tool.RequiresHandle = false
	tool.Parent = player.Character 
	tool.Activated:Connect(function()
		print("player is training here")
		-- library.Events.UpdateCurrency:Fire(player, "Power", 1)
		-- tool.Parent = player.Backpack
	end)

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

function playerMod.UpdatePlayer(player : Player)
	if loadedPlayers[player] ~= nil then
		return
	end
    -- task.wait(3)
	--! get the profile here
	--! get the last login
	playerMod.setupTool(player, "TrainingTool")
	player.CharacterAdded:Connect(function()
		warn("character added")
		playerMod.setupTool(player, "TrainingTool")
	end)
	local result = library.Events.HasGamepass:Invoke(player, 90058789677835)
	if result then 
	end
	player:SetAttribute("VIP", true)
	-- warn("set the player attribute to vip")
    
	-- local profile = library.Events.ServerGetProfile:Invoke(player)
    local profile = library.Events.serverGetProfile:Invoke(player)
    local retries = 0
    repeat task.wait(1) profile = library.Events.serverGetProfile:Invoke(player) until
    profile ~= nil or retries > 10
    if profile == nil then 
        player:Kick("No data was able to be loaded, please rejoin")
    end
    -- print(profile.. "is the profile")
	loadedPlayers[player] = profile
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
