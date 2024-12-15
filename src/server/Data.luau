local dataController = {}

local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local ProfileService = require(script.Parent.Parent:WaitForChild("ProfileService"))


local events = library.Events
local ProfileTemplate = {
	Cash = 0,
	Gems = 0,
	Inventory = {

		Tables = {
			"Ruby", "Emerald", "Sapphire", "Diamond", "Gold", "Silver", "Bronze", "Iron", "Wood"
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
	CurrentStreak = 0,
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
	profileStore = profileStore.Mock
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
	if Profiles[player] == nil then return nil end
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

function dataController.verifyItem(player, item, inventoryType)
	

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
	end
end

function dataController.Init()
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

	local textCommand: TextChatCommand = library.TextChatService.test
	textCommand.Triggered:Connect(function(originTextSource, unfilteredText)
		warn("RESETTING DATA HERE")
		local UserId = originTextSource.UserId
		local player = game.Players:GetPlayerByUserId(UserId)
		dataController.ResetPlayerProfile(player)
	end)

	events.GetProfile.OnServerInvoke = function(player)
		return Profiles[player].Data or nil
	end

	events.serverGetProfile.OnInvoke  = function(player)
		return dataController.GetProfile(player)
	end

	-- events.ServerGetProfile.OnInvoke = function(player)
	-- 	return Profiles[player] or nil
	-- end

	events.PlayerSetting.OnServerEvent:Connect(function(player, setting, value)
		local profile = Profiles[player]
		if profile == nil then return end
		profile.Data.Settings[setting] = value
		-- warn("updated the player setting here")
	end)
	
	events.GiveCurrency.Event:Connect(function(player, currency, ammt)
		dataController.UpdateCurrency(player, currency, ammt)
	end)
	--* Still need to work on 
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
