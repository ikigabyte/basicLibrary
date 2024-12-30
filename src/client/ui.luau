local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local sfxMod = require(script.Parent:WaitForChild("sfx"))


local animations = {
	["ExplosiveButton"] = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
	["PopupFrame"] = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0),
	["FastScroll"] = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0),
}

local currentVisibleFrame
local currentTween
local screenGui
local frames
local gameGui
local debounceBetweenClicks = false
local frameTweens = {}
local uiHandler = {}
local runningTweens = {}

local iconTypes = {
	["Power"] = "rbxassetid://18804187463",
	-- ["Gems"] = "rbxassetid://6443945014",
	-- ["Cash"] = "rbxassetid://6443945014",
}
function uiHandler.TurnOffAllFrames(frameName: string)
	-- local frames = library.PlayerGui.ScreenGui.Frames
	for _, frame in pairs(frames:GetChildren()) do
		if frame.Name == frameName then
			continue
		else
			frame.Visible = false
		end
	end
end

function uiHandler.CloseActiveFrame()
	for _, frame in pairs(frames:GetChildren()) do
		if not frame.Visible then
			continue
		end
		local origPosition = frame.Position
		local tween =
			library.TweenService:Create(frame, animations["PopupFrame"], { Position = UDim2.new(0.5, 0, 1.4, 0) })
		tween:Play()
		tween.Completed:Connect(function()
			frame.Position = origPosition
			frame.Visible = false
		end)
	end
end

function uiHandler.animateButton(button: TextButton, parameters, animationType: string)
	if runningTweens[button] then
		runningTweens[button]:Cancel()
	end
	runningTweens[button] = library.TweenService:Create(button, animations[animationType], parameters)
	runningTweens[button]:Play()
	print("handling the button here")
end

function uiHandler.animateScroll(frame, parameters: {}, animationType: string)
	if frameTweens[frame] then
		frameTweens[frame]:Cancel()
	end
	frameTweens[frame] = library.TweenService:Create(frame, animations[animationType], parameters)
	frameTweens[frame]:Play()
end

function uiHandler.findDescendantFrameOfName(frames: Frame, name: string)
	for _, frame in pairs(frames:GetDescendants()) do
		if frame.Name == name then
			return frame
		end
	end
end

function uiHandler.spawnRandomFrame(constaints : UDim2, iconType: string, powerAmmt : number, duplicationAmmount : number, endTeleportPosition : UDim2)
	-- local frame = frame:Clone()

	for i = 1, duplicationAmmount do
		local icon = iconTypes[iconType]
		local clone = gameGui.CurrencyTemplate:Clone()
		clone.Parent = gameGui
		local size = clone.Size
		local sizeX = size.X.Scale * 1.15
		local sizeY = size.Y.Scale * 1.15
		local newSize = UDim2.new(sizeX, 0, sizeY, 0)
		library.TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), { Size = newSize }):Play()
		clone.Visible = true
		clone.TextLabel.Text = "+"..tostring(powerAmmt)
		clone.IconLabel.Image = icon
		clone.Rotation = math.random(-3, 3)
		local randomX = math.random() * constaints.X.Scale
        local randomY = math.random() * constaints.Y.Scale
        clone.Position = UDim2.new(randomX, 0, randomY, 0)
		task.delay(0.8, function()
			local information = { Position = endTeleportPosition, Size = UDim2.fromScale(0.05, 0.05) }
			local tween = library.TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, false, 0), { Position = endTeleportPosition })
			tween:Play()
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
		end)
		-- local frame = frames:FindFirstChild("PowerFrame"):Clone()
		-- frame.Parent = frames
		-- frame.Position = UDim2.new(math.random(0, 1), 0, math.random(0, 1), 0)
		-- frame.Visible = true
		-- frame.Icon.Image = iconType
		-- frame.PowerAmmt.Text = tostring(powerAmmt)
		-- uiHandler.animateScroll(frame, { Position = endTeleportPosition }, "FastScroll")
	end
	-- frame.Parent = frame.Parent
	-- frame.Position = UDim2.new(math.random(0, 1), 0, math.random(0, 1), 0)
	-- frame.Visible = true
	-- frame.Icon.Image = icon
	-- frame.PowerAmmt.Text = tostring(powerAmmt)
	-- uiHandler.animateScroll(frame, { Position = endTeleportPosition }, "FastScroll")
end


function uiHandler.OnButtonActivation(button: ImageButton | TextButton)
	if debounceBetweenClicks then
		return
	end
	debounceBetweenClicks = true
	task.delay(0.2, function()
		debounceBetweenClicks = false
	end)
	if currentTween then
		currentTween:Cancel()
	end
	currentTween =
		library.TweenService:Create(button, animations["ExplosiveButton"], { Size = UDim2.new(1.1, 0, 1.1, 0) })
	currentTween:Play()
	local frame = frames:FindFirstChild(button.Name)
	if frame and not frame.Visible then
		sfxMod.Play("Click", 0.5)
		uiHandler.TurnOffAllFrames(button.Name)
		frame.Visible = true
		local frameSize = frame.Size
		local XScale = frameSize.X.Scale
		local YScale = frameSize.Y.Scale
		frame.Visible = true
		frame.Size = UDim2.new(XScale * 0.8, 0, YScale * 0.8, 0)
		local tween =
			library.TweenService:Create(frame, animations["PopupFrame"], { Size = UDim2.new(XScale, 0, YScale, 0) })
		tween:Play()
	else
		uiHandler.CloseActiveFrame()
		-- uiHandler.TurnOffAllFrames(frame)
		-- warn("Frame not found")
	end

	-- local frames = library.PlayerGui.ScreenGui.Frames
	-- local frame = frames:FindFirstChild(button.Name)
	-- if frame then
	--     frame.Visible = false
	-- else

	-- end
end


function uiHandler.InitiateButtons()
	for _, button in library.PlayerGui.ScreenGui:GetDescendants() do
		local validButton = button:IsA("TextButton") or button:IsA("ImageButton")
		if not validButton then
			continue
		end
		if button.Parent.Name == "FrameLeft" or button.Parent.Name == "FrameRight" then
			button.Activated:Connect(function()
				uiHandler.OnButtonActivation(button)
			end)
		end
		--! handle all the main ui that doiesn't belong in anything else
	end
end

function uiHandler.GetPlayerIcon(userId: number)
	local icon, isReady
	local success, errorMsg = pcall(function()
		icon, isReady =
			library.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if success and isReady then
		-- warn("achieved naturally")
		return icon
	end
	-- if not success then
	-- 	warn("error getting the icon", errorMsg)
	-- 	return nil
	-- end
end


uiHandler.Init = function()
	library.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	screenGui = library.PlayerGui:WaitForChild("ScreenGui")
	gameGui = library.PlayerGui:WaitForChild("GameGui")
	frames = screenGui:WaitForChild("Frames")

	uiHandler.InitiateButtons()

	for _, button in pairs(frames:GetDescendants()) do
		if button:IsA("TextButton") == false or button:IsA("ImageButton") then
			continue
		end
		if button.Name ~= "CloseButton" then
			continue
		end
		button.Activated:Connect(function()
			sfxMod.Play("Click", 0.5)
			warn("close existing frame")
			uiHandler.CloseActiveFrame()
		end)
	end

	
	local OPPetButton = screenGui.HUD.Right.OPPet
	OPPetButton.Activated:Connect(function()
		warn("checked here")
		-- warn("activated the pet")
		
		uiHandler.OnButtonActivation(OPPetButton)
		-- library.Events.ActivatePet:FireServer()
	end)

	library.Events.UpdateCurrency.OnClientEvent:Connect(function(currencyName, ammt)
		-- warn("updating the currency here")
		-- warn(currencyName)
		if currencyName == "Power" then
			-- print("this is a training strength here")
			local constraints = UDim2.fromScale(0.5, 0.3) -- ! These are the max constraints
			local iconType = "Power"
			local whereToEnd = UDim2.fromScale(.5,.9)
			uiHandler.spawnRandomFrame(constraints, iconType, ammt, 1, whereToEnd)
			return;
		end
		-- local currency = library.Player:GetAttribute("Currency")
		local currencyFrame = screenGui.HUD.Currencies:FindFirstChild(currencyName)
		if not currencyFrame then
			warn("currency frame not found")
			return
		end
	
		local abbreviated = library.Functions.abbreviations(ammt)
		currencyFrame.Amount.Text = tostring(abbreviated)
	end)
	-- library.Player.attr

	
	library.Player:GetAttributeChangedSignal("DoublePower"):Connect(function()
		warn("double power has been changed here")
		local val = library.Player:GetAttribute("DoublePower")
		local boostFrame = screenGui.HUD.BottomLeft
		local frame = uiHandler.findDescendantFrameOfName(boostFrame, "DoublePower")
		-- warn(frame)
		if not frame then return end
		if not frame.Visible then
			frame.Visible = true
		end
		-- local val = library.Player:GetAttribute(val)
		if val == 0 then
			warn("boost has ended here")
		end
		-- warn(val)
		-- frame.TextLabel.Text = "something here"
		frame.TextLabel.Text = library.Functions.formatTime(val, "minutes")
		warn("formatted here")
	end)


end

return uiHandler
