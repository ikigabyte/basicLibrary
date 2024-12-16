local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

local module = {}
local playerButtons = {}

local debounceTime = 0.5
local debounce = false

local tradeScreen
local scrollingFrame
local template

function module.GetPlayerIcon(userId: number)
	local icon, isReady
	local success, errorMsg = pcall(function()
		icon, isReady =
			library.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if success and isReady then
		warn("achieved naturally")
		return icon
	end
	-- if not success then
	-- 	warn("error getting the icon", errorMsg)
	-- 	return nil
	-- end
end

function module.FindPlayerFrame(player: Player)
	for _, frame: Frame in pairs(scrollingFrame:GetChildren()) do
		if frame.Frame.UserName.Text == player.Name then
			return frame
		end
	end
end

function module.HandleFrameTemplate(player: Player)
	if player:IsDescendantOf(library.Players) == false then
		return
	end
	local clone: Frame = template:Clone()
	clone.Parent = scrollingFrame
	clone.Visible = true
	local displayName = player.DisplayName
	local playerName = player.Name
	local playerIcon = module.GetPlayerIcon(player.UserId)
	print(playerIcon)
	clone.Frame.PlayerIcon.Image = playerIcon
	clone.Frame.UserName.Text = "@" .. playerName
	clone.Frame.DisplayName.Text = displayName
	local tradeButton: TextButton = clone.Trade
	playerButtons[player] = tradeButton.Activated:Connect(function()
		if debounce then
			return
		end
		debounce = true
		task.delay(debounceTime, function()
			debounce = false
		end)
		library.Events.TradeRequest:FireServer(player)
		--! fire the event to the server
	end)
end


function module:Init()
	task.wait(2)

	tradeScreen = library.PlayerGui.ScreenGui.Frames.Trade
	scrollingFrame = tradeScreen.ScrollingFrame
	template = scrollingFrame.Template

	for _, player: Player in pairs(library.Players:GetPlayers()) do
		-- if player == library.Player then continue end
		if playerButtons[player] ~= nil then
			continue
		end
		task.spawn(function()
			module.HandleFrameTemplate(player)
		end)
	end

	library.Players.PlayerAdded:Connect(function(player)
		if playerButtons[player] ~= nil then
			return
		end
		task.spawn(function()
			module.HandleFrameTemplate(player)
		end)
	end)

	library.Players.PlayerRemoving:Connect(function(player)
		-- print("removign the player fromt he frame here")
		if playerButtons[player] then
			playerButtons[player]:Disconnect()
			local button = module.FindPlayerFrame(player)
			button:Destroy()
		end
	end)
end

return module
