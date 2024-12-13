local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

local screenGui
local frames

local animations = {
	["ExplosiveButton"] = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
	["PopupFrame"] = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0),
	["FastScroll"] = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0),
}

local currentVisibleFrame
local currentTween
local debounceBetweenClicks = false
local frameTweens = {}
local uiHandler = {}
local runningTweens = {}
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

function uiHandler.OnButtonActivation(button: ImageButton | TextButton)
	-- print(button.Name)
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

	-- print("the button has been triggered here")
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

uiHandler.Init = function()
	screenGui = library.PlayerGui:WaitForChild("ScreenGui")
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
			warn("close existing frame")
			uiHandler.CloseActiveFrame()
		end)
	end

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
	-- library.Player.AttributeChanged:Connect(function(attribute)
	-- 	-- warn(attribute)
	-- 	if attribute == "DoublePower" then

	-- 	end

	-- end)

	print("initated all the buttons here")
end

return uiHandler
