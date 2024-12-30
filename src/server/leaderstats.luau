-- --Library---------------------------

-- local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"):WaitForChild("Library"))
-- while (not Library.Loaded) do  game:GetService("RunService").Heartbeat:Wait() end

local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

-- -- Services---------------------------
local players: Players = library.Players
local dataStoreService: DataStoreService = library.DataStoreService

local boards = {
	["Wins"] = {
		Stat = "Wins",
		MaxPlayers = 30,
	},

	["Global EggsOpened"] = {
		Stat = "EggsOpened",
		MaxPlayers = 30,
	},
}

-- Modules---------------------------
-- local dataSystem = Library.DataSystem
-- local boards = Library.Index.Leaderboards
local abbreviations = library.Functions.abbreviations
-- local updateTime = 200
local updateTime = 15 -- Reset to 200 again
local boardSizeWins = 30
local entryUI = library.Assets.UI.Player
-- DataStore Variables
local dataVersion = 1
local winsData: OrderedDataStore = dataStoreService:GetOrderedDataStore("Leaderboards", "Wins" .. tostring(dataVersion))
-- local eggsData: OrderedDataStore = dataStoreService:GetOrderedDataStore("Leaderboards", "EggsOpened" .. tostring(dataVersion))

local leaderstatsMod = {}

local function WaitForRequestBudget(requestType)
	local currentBudget = dataStoreService:GetRequestBudgetForRequestType(requestType)

	while currentBudget < 1 do
		currentBudget = dataStoreService:GetRequestBudgetForRequestType(requestType)
		task.wait(5)
	end
end



local function ResetScale(character, scale)
	character.Humanoid.BodyDepthScale.Value = scale or 1
	character.Humanoid.BodyHeightScale.Value = scale or 1
	character.Humanoid.BodyWidthScale.Value = scale or 1
	character.Humanoid.HeadScale.Value = scale or 1
end



function leaderstatsMod.setGold(character)
	local humanoidDesc:HumanoidDescription = character.Humanoid.HumanoidDescription
	humanoidDesc.HeadColor = Color3.fromRGB(253, 233, 120)
	humanoidDesc.LeftArmColor = Color3.fromRGB(253, 233, 120)
	humanoidDesc.LeftLegColor = Color3.fromRGB(253, 233, 120)
	humanoidDesc.RightArmColor = Color3.fromRGB(253, 233, 120)
	humanoidDesc.RightLegColor = Color3.fromRGB(253, 233, 120)
	humanoidDesc.TorsoColor = Color3.fromRGB(253, 233, 120)
	character["Body Colors"].HeadColor3 = Color3.fromRGB(253, 233, 120)
	character["Body Colors"].LeftArmColor3 = Color3.fromRGB(253, 233, 120)
	character["Body Colors"].LeftLegColor3 = Color3.fromRGB(253, 233, 120)
	character["Body Colors"].RightArmColor3 = Color3.fromRGB(253, 233, 120)
	character["Body Colors"].RightLegColor3 = Color3.fromRGB(253, 233, 120)
	character["Body Colors"].TorsoColor3 = Color3.fromRGB(253, 233, 120)

	local shirt = character:FindFirstChild("Shirt")
	local pants = character:FindFirstChild("Pants")
	local graphic = character:FindFirstChild("Shirt Graphic")

	local face = character.Head:FindFirstChild("face")

	if face then
		face.Transparency = 0.7
	end

	if shirt then shirt:Destroy() end
	if pants then pants:Destroy() end
	if graphic then graphic:Destroy() end

	for i, v in ipairs(character:GetDescendants()) do
		if v:IsA("Accessory") then
			v.Handle.TextureID = ""
			v.Handle.Color = Color3.fromRGB(253, 233, 120)
		end

		if v:IsA("SurfaceAppearance") then
			v:Destroy()
		end
	end
end

function leaderstatsMod.updateLeaderboard(boardType, board)
	local currentDataStore = winsData
	if boardType == "EggsOpened" then -- Different egg type
		-- currentDataStore = eggsData
	end
	local profiles = library.Events.GetAllProfiles:Invoke()
	for i, player in ipairs(players:GetPlayers()) do
		local playerData = profiles[player]
		if not playerData then
			continue
		end
		local plrBoardData = playerData[boardType] or 0

		currentDataStore:SetAsync(player.UserId, plrBoardData)
	end
	local success, err
	local page
	repeat
		success = pcall(function()
			local data = currentDataStore:GetSortedAsync(false, boardSizeWins)
			page = data:GetCurrentPage()
		end)

		WaitForRequestBudget(Enum.DataStoreRequestType.GetSortedAsync)
	until success or #players:GetPlayers() < 1

	for i, v in ipairs(board.Board.Main.List:GetChildren()) do
		if not v:IsA("GuiObject") then
			continue
		end
		v:Destroy()
	end

	if page then
		for rank, data in ipairs(page) do
			local username
			pcall(function()
				username = players:GetNameFromUserIdAsync(data.key)
			end)
			if not username then
				pcall(function()
					currentDataStore:RemoveAsync(data.key)
				end)
			end
			local coins = data.value
			local newEntry = entryUI:Clone()
			newEntry.Username.Text = username
			newEntry.Amount.Text = abbreviations(coins)
			newEntry.Rank.Text = "#" .. tostring(rank)
			newEntry.Name = rank
			newEntry.Parent = board.Board.Main.List

			--if rank == 1 then
			--	local character = board.NPC
			--	local humanoidDescription = players:GetHumanoidDescriptionFromUserId(data.key)

			--	character.Humanoid:ApplyDescriptionReset(humanoidDescription)

			--	ResetScale(character, 1.8)
			--	pcall(function() Gold(character) end)
			--end
		end
	end

	if not success then
		return false
	end
end

function leaderstatsMod:Init()
	task.wait(6)
	local winsLeaderboard = workspace.Leaderboards.Wins
	-- local eggsLeaderboard = workspace.Leaderboards.EggsOpened
	leaderstatsMod.updateLeaderboard("Wins", winsLeaderboard)
	task.spawn(function()
		while true do
			task.wait(updateTime)
			leaderstatsMod.updateLeaderboard("Wins", winsLeaderboard)
		end
	end)
end

return leaderstatsMod
