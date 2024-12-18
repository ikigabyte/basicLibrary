local dataController = {}

local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local ProfileService = require(script.Parent.Parent:WaitForChild("ProfileService"))

local events = library.Events
local ProfileTemplate = {
	Cash = 0,
	Gems = 0,
	Power = 0,
	Inventory = {
		Tables = {
			"Ruby",
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
	},
	CodesRedeemed = {},
	UnlockedMaps = {},
	CurrentTool = nil,
	TutorialCompleted = false,
}

-- game.Workspace.

local profileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)

if library.RunService:IsStudio() then
	-- profileStore = profileStore.Mock
end

local Profiles = {}

function dataController.SaveProfile(player: Player)
	local profile = Profiles[player]
	if profile then
		profile:Save()
	end
end

function dataController.ResetPlayerProfile(player)
	profileStore:WipeProfileAsync("Player_" .. player.UserId)
end

function dataController.GetProfile(player)
	if Profiles[player] == nil then
		return nil
	end
	return Profiles[player].Data or nil
end

function dataController:SetupProfile(player: Player)
	local profile = profileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile then
		profile:AddUserId(player.UserId) -- Ensures only this player can access their data
		profile:Reconcile() -- Add missing values from template
		Profiles[player] = profile
		warn("Loaded profile for " .. player.Name)

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
function dataController.verifyItem(player, item, inventoryType) end

function dataController.UpdateCurrency(player, currency, ammt)
	local profile = Profiles[player]
	if profile then
		if not profile.Data[currency] then
			warn("this currency type was not found")
			return
		end
		profile.Data[currency] += ammt
		events.UpdateCurrency:FireClient(player, currency, profile.Data[currency])
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
		print(unfilteredText)
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
		return dataController.GetProfile(player)
	end

	-- events.ServerGetProfile.OnInvoke = function(player)
	-- 	return Profiles[player] or nil
	-- end

	events.PlayerSetting.OnServerEvent:Connect(function(player, setting, value)
		local profile = Profiles[player]
		if profile == nil then
			return
		end
		profile.Data.Settings[setting] = value

		-- warn("updated the player setting here")
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
		print("last login time", lastLoginTime)
		print("last reward time", lastRewardTime)
		print("current streak", currentStreak)
		print("day claiming", dayIndex)
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

		print(hoursDifference, " hour difference")
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
