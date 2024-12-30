--[[
This script defines a `dataController` table and sets up the initial data structure for player profiles in a game.
It requires necessary modules from the game's replicated storage and parent directories.

The `ProfileTemplate` table defines the default values for a player's profile, including:
- Cash: The amount of in-game currency the player has.
- Gems: Another form of in-game currency.
- Power: A metric for the player's power level.
- Wins: The number of wins the player has achieved.
- Inventory: A nested table containing:
  - Balls: A list of different types of balls the player can own.
  - Pets: An empty table for storing pets the player may acquire.
- Boosts: A nested table containing different types of boosts the player can own, each with an `Owned` count.

]]

local dataController = {}

local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local ProfileService = require(script.Parent.Parent:WaitForChild("ProfileService"))

local events = library.Events
local promoCodes = library.PromoCodes

local ProfileTemplate = {
	Cash = 0,
	Gems = 0,
	Power = 0,
	Wins = 0,
	Inventory = {
		Balls = {
			"Spike Ball",
			"Emerald",
			"Sapphire",
			"Diamond",
			"Gold",
			"Silver",
			"Bronze",
			"Iron",
			"Wood",
		},
		Pets = {},
	},
	Boosts = {
		["DoublePower"] = {
			Owned = 0,
		},
		["DoubleWins"] = {
			Owned = 0,
		},
		["DoubleLuck"] = {
			Owned = 0,
		},
	},
	LastLogin = os.time(),
	LastRewardTime = 0,
	CurrentStreak = 0,
	LastReward = 0,
	FirstPlay = false,
	Settings = {
		Music = true,
		Sound = true,
		Pets = true,
	},
	CodesRedeemed = {},
	UnlockedMaps = {},
	CurrentTool = nil,
	TutorialCompleted = false,
}

local profileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)

if library.RunService:IsStudio() then
	profileStore = profileStore.Mock--!Disable this if you don't need it
end

local Profiles = {}

function dataController.GetDataAsync(player: Player)
	local Profile = Profiles[player]
	-- print(Profile)
	local attempts, max = 0, 75
	--Make sure data is loaded---------------------------
	if Profile == nil then
		repeat
			print("attempting to get the profile here")
			Profile = Profiles[player]
			attempts += 1
			task.wait(0.3)
		until Profile ~= nil or attempts >= max
	end

	--Kick player if data hasn't loaded---------------------------
	if Profile == nil then
		player:Kick("You're data failed to load, please rejoin!")
		return
	end
	return Profiles[player].Data
end

function dataController.SaveProfile(player: Player)
	local profile = Profiles[player]
	if profile then
		profile:Save()
	end
end

function dataController.ResetPlayerProfile(player)
	profileStore:WipeProfileAsync("Player_" .. player.UserId)
end

function dataController:SetupProfile(player: Player)
	local profile = profileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile then
		profile:AddUserId(player.UserId) -- Ensures only this player can access their data
		profile:Reconcile() -- Add missing values from template
		Profiles[player] = profile
		-- warn("Loaded profile for " .. player.Name)
		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick("Your data is being released.")
		end)

		if player:IsDescendantOf(game.Players) then
			-- Player data loaded successfully
			events.SetupProfile:FireClient(player, profile.Data)
			-- Events.SendProfile:FireClient(player, profile.Data)
			return profile
		else
			profile:Release()
		end
	else
		player:Kick("Failed to load your data.")
	end
end

function dataController.forceSetLoginTime(player, hoursInSeconds: number)
	local profile = Profiles[player]
	if profile then
		profile.Data.LastRewardTime = os.time() - hoursInSeconds
		print("force reset the login time here")
	end
end

function dataController.verifyItem(player, item, inventoryType)
	print("verifying this item here", item)
end

function dataController.UpdateCurrency(player, currency, ammt)
	local profile = Profiles[player]
	if profile then
		if not profile.Data[currency] then
			warn("this currency type was not found")
			return
		end
		profile.Data[currency] += ammt
		events.UpdateCurrency:FireClient(player, currency, profile.Data[currency])
	else
		warn("No profile for this player here")
	end
end

-- function dataController.setupTextCommands()

function dataController.setupTextCommands()
	local wipeCmmd: TextChatCommand = library.TextChatService.wipe
	local setTimeCmmd: TextChatCommand = library.TextChatService.time
	wipeCmmd.Triggered:Connect(function(originTextSource, unfilteredText)
		warn("RESETTING DATA HERE")
		local UserId = originTextSource.UserId
		local player = game.Players:GetPlayerByUserId(UserId)
		dataController.ResetPlayerProfile(player)
		-- dataController.forceSetLoginTime(player, os.time() - (24 * 3600))
	end)

	setTimeCmmd.Triggered:Connect(function(originTextSource, unfilteredText: string)
		warn("force setting the time to a specific time")
		local UserId = originTextSource.UserId
		local player = game.Players:GetPlayerByUserId(UserId)
		-- dataController.ResetPlayerProfile(player)

		local splitStrings = string.split(unfilteredText, " ")
		-- print(splitStrings);
		local timeDifference = splitStrings[2]
		-- print(timeDifference)
		if timeDifference == nil then
			return
		end
		local hours = timeDifference * 3600
		dataController.forceSetLoginTime(player, hours)
		-- dataController.forceSetLoginTime(player, os.time() - (24 * 3600))
	end)
end

function dataController.RewardDailyPlayer(player, currentStreak)
	local rewards = library.Shared.DailyRewards
	local reward = rewards[currentStreak]
	if player and player:IsDescendantOf(library.Players) then
		warn("rewarding the player now")
		if reward.RewardType == "Cash" then
			dataController.UpdateCurrency(player, "Cash", reward.Reward)
			return
		elseif reward.RewardType == "Pet" then
			warn("giivng a pet here")
		end
	end
end

function dataController.Init()
	dataController.setupTextCommands()
	-- Initialize profiles for existing players
	for _, player in library.Players:GetChildren() do
		dataController:SetupProfile(player)
	end

	-- Add new profiles as players join
	library.Players.PlayerAdded:Connect(function(player)
		dataController:SetupProfile(player)
	end)

	-- Clean up profiles when players leave
	library.Players.PlayerRemoving:Connect(function(player)
		dataController.SaveProfile(player)
		Profiles[player] = nil
	end)

	events.GetProfile.OnServerInvoke = function(player)
		return Profiles[player].Data or nil
	end

	events.serverGetProfile.OnInvoke = function(player)
		return dataController.GetDataAsync(player)
		-- proint
		-- return Profiles[player].Data or nil
		-- return dataController.GetDataAsync(player)
	end

	-- events.ServerGetProfile.OnInvoke = function(player)
	-- 	return Profiles[player] or nil
	-- end

	events.GetAllProfiles.OnInvoke = function()
		local profileTable = {}

		for player, profile in pairs(Profiles) do
			profileTable[player] = profile.Data
		end
		return profileTable
	end

	events.PlayerSetting.OnServerEvent:Connect(function(player, setting, status)
		local profile = Profiles[player]
		if profile == nil then
			warn("no profile found here")
			return
		end
		profile.Data.Settings[setting] = status
		warn("updated the setting here")
		-- warn("updated the player setting here")
	end)

	events.IncreasePower.Event:Connect(function(player, powerAmmt)
		local profile = Profiles[player]
		if profile == nil then
			return
		end
		--! find the multiplier from the pets
		--! find the strength of the player here
		profile.Data.Power += 1
		-- events.UpdatePower:FireClient(player, profile.Data.Power)
	end)

	events.GiveCurrency.Event:Connect(function(player, currency, ammt)
		dataController.UpdateCurrency(player, currency, ammt)
	end)

	events.CheckDailyGift.OnServerInvoke = function(player, dayIndex: number)
		local profile = Profiles[player]
		if profile == nil then
			return false
		end

		local lastLoginTime = profile.Data.LastLogin
		local lastRewardTime = profile.Data.LastRewardTime or 0
		-- print(lastLoginTime)
		local currentTime = os.time()
		local currentStreak = profile.Data.CurrentStreak
		-- print("last login time", lastLoginTime)
		-- print("last reward time", lastRewardTime)
		-- print("current streak", currentStreak)
		-- print("day claiming", dayIndex)
		dayIndex = tonumber(dayIndex)
		if dayIndex == currentStreak + 1 then
			-- Player is claiming the next day in sequence
			warn("Player is claiming the next day in sequence")
		elseif dayIndex > currentStreak + 1 then
			-- Player is trying to claim a day too far ahead
			warn("Player is trying to claim a day too far ahead")
			return false
		end
		if lastRewardTime == 0 then
			warn("this is the first reward of the player")
			-- If there's no last login time, set it to current time and return false
			dataController.RewardDailyPlayer(player, 1)
			profile.Data.CurrentStreak = 1 --!restart from day one
			profile.Data.LastRewardTime = currentTime
			-- dataController.
			return true
		end

		local timeDifference = currentTime - lastRewardTime
		local hoursDifference = timeDifference / 3600
		-- print(hoursDifference, " hour difference")
		if hoursDifference > 24 and hoursDifference < 48 then
			-- profile.Data.LastRewardTime = os.time()
			-- warn(profile.Data.CurrentStreak)
			profile.Data.LastRewardTime = currentTime
			print("reset the data here, now waiting")
			if profile.Data.CurrentStreak >= 7 then
				profile.Data.CurrentStreak = 0 --!restart from day one
			else
				profile.Data.CurrentStreak = profile.Data.CurrentStreak + 1
			end
			dataController.RewardDailyPlayer(player, profile.Data.CurrentStreak)
			return true
		elseif hoursDifference > 48 then
			warn("broken streak")
			profile.Data.CurrentStreak = 0
			profile.Data.LastRewardTime = 0
			-- profile.Data.LastLogin = os.time()
		else
			return false

			-- print(false)
		end
	end
	-- events.EquipItem.OnServerEvent:Connect(function(itemToEquip, inventoryType)
	-- 	warn("equipping something here")
	-- 	local profile = Profiles[library.Players.LocalPlayer]
	-- 	if profile == nil then return end
	-- 	profile.CurrentTool = itemToEquip
	-- 	warn("updated the current tool here")
	-- 	--Do i return anything or nah

	-- 	warn("equipped the item ehre")
	-- end)
end

return dataController
