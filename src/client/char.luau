local TweenService = game:GetService("TweenService")
local charMod = {}
local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

local powerBoost = 1

local connection
charMod.SendBallFlying = function(part) end
local currentChar
local isThrowing = false

local PowerbarStages = {
	[1] = Color3.fromRGB(70, 224, 255),
	[2] = Color3.fromRGB(81, 75, 255),
	[3] = Color3.fromRGB(255, 82, 82),


}


local function isAnimationPlaying(animator, animation)
    local playingTracks = animator:GetPlayingAnimationTracks()
    for _, track in pairs(playingTracks) do
        if track.Animation == animation then
            return true
        end
    end
    return false
end


local function determinePosition(number, currentStage)
	if number >= 1 and currentStage ~= 3 then
		return 3
	elseif number > 0.6 and currentStage ~= 2 then
		return 2
	elseif number > 0.3 and currentStage ~= 1 then 
		return 1
	end

end

charMod.SetupCollisionGroup = function(model: Model)
	for _, part in pairs(model:GetChildren()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Player"
		end
	end

	model.ChildAdded:Connect(function(child)
		if child:IsA("BasePart") then
			child.CollisionGroup = "Player"
		end
	end)
end

charMod.deactivateControls = function()
	-- print("deactivating the controls here")
end

charMod.relinquishCamera = function()
	local currentCam = library.Camera
	currentCam.CameraType = Enum.CameraType.Custom
	repeat task.wait() until currentCam.CameraType == Enum.CameraType.Custom
	currentCam.CameraSubject = currentChar.Humanoid
end





charMod.StartSpin = function()
	local currentCam = library.Camera 
	local head = currentChar:WaitForChild("Head")
	local tool = currentChar:WaitForChild("PowerTool")
	local powerup = library.PlayerGui.GameGui.PowerUp
	powerup.Visible = true
	-- powerup.BackgroundColor3
	local powerBar = library.PlayerGui.GameGui.PowerUp.Bar
	currentCam.CameraType = Enum.CameraType.Scriptable
	-- currentCam.CFrame = character.PrimaryPart.CFrame * CFrame.new(0, 0, 10)
	repeat task.wait() until currentCam.CameraType == Enum.CameraType.Scriptable
	currentCam.CameraSubject = nil

	local headCFrame = CFrame.new(head.Position) * CFrame.new(0, 10, 10) * CFrame.Angles(math.rad(-45), 0, 0)
    currentCam.CFrame = headCFrame
	-- print("starting the spin here")
	local maxClicks = library.Shared.MaxClicks
	local currentStage = 0
	-- library.TweenService:Create(powerBar.UIGradient)
	task.spawn(function()
		charMod.MakeCharacterSpin()
	end)
	local tween 
	tool.AncestryChanged:Connect(function()
		if not tool:IsDescendantOf(workspace) then
			print("the tool has been destroyed")
			powerup.Visible = false
			charMod.relinquishCamera()
			warn("terminated the function here")
		end
	end)
	
	tool:GetAttributeChangedSignal("Clicks"):Connect(function()
		local clicks = tool:GetAttribute("Clicks")
		-- print(clicks)
		local truePosition = clicks / maxClicks
		if truePosition > 1 then 
			truePosition = 1	
		end
		if tween and tween.PlaybackState == Enum.PlaybackState.Playing then 
			tween:Cancel()
		end
		tween = TweenService:Create(powerBar, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0), {Position = UDim2.fromScale(truePosition, .5)})
		tween:Play()
		-- powerBar.Position = UDim2.fromScale(truePosition, .5)
		local newStage = determinePosition(truePosition,currentStage)-- *Find the stage here
		if currentStage ~= newStage then 
			currentStage = newStage
			local tweeninfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0)
			-- local colorGradient = PowerbarStages[currentStage] or PowerbarStages[1] 
			local tween = library.TweenService:Create(powerup, tweeninfo, {BackgroundColor3 = Color3.fromRGB(255, 118, 118)})
			tween:Play()
		end
		-- print(currentStage)
		-- i want to find the position of it
		--! How do we tween the color if a certain position has been reached
	end)

	--! We're gonna play the spin animation here , maybe with ik controls or not?
	
end
charMod.MakeCharacterSpin = function()
	local char = game.Players.LocalPlayer.Character
	-- local root = char:WaitForChild("HumanoidRootPart")
	-- local alignOrientation = Instance.new("AlignOrientation")
	local anim = library.Assets.Spin
	local animator: Animator = char.Humanoid.Animator
	local animTrack : AnimationTrack = animator:LoadAnimation(anim)
	animTrack:Play()
	-- animTrack:Play()
end


function charMod.HandleTool(tool, char)
	local curl = library.Assets.Curl
	local animator : Animator = char:WaitForChild("Humanoid"):WaitForChild("Animator")
	local curlAnim : AnimationTrack = animator:LoadAnimation(curl)
	tool.Activated:Connect(function()
		print("playing the animation here")
		if not isAnimationPlaying(animator, curl) then return end 
		curlAnim:Play()
		-- charMod.createSpikeBall()
	end)
end


function charMod.createSpikeBall()
    local char = currentChar
	charMod.SetupCollisionGroup(char)
	local root = char:WaitForChild("HumanoidRootPart")
	local spikeBall = game.Workspace["Meshes/spike head"]:Clone()
	spikeBall.Parent = workspace
	spikeBall.Massless = true

	-- warn("doing something here")

	local newPart = Instance.new("Part")
	newPart.Parent = workspace
	local attachment = Instance.new("Attachment")
	attachment.Parent = spikeBall
	newPart.CanCollide = false
	spikeBall.CanCollide = true

	spikeBall.CollisionGroup = "Player"
	local attachment1 = Instance.new("Attachment")
	attachment1.Parent = newPart
	local rope = Instance.new("RopeConstraint")
	rope.Parent = newPart
	-- rope.Attachment0 = root:WaitForChild("RootAttachment")
	rope.Attachment0 = attachment
	rope.Attachment1 = attachment1

	task.delay(2, function()
		charMod.MakeCharacterSpin()
	end)

	library.RunService.RenderStepped:Connect(function()
		local frontOffset = root.CFrame.LookVector * 5
		-- spikeBall.CFrame = root.CFrame + frontOffset
		newPart.CFrame = root.CFrame + frontOffset
	end)

	library.UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- spikeBall.Velocity = Vector3.new(0, 50, 0)
			powerBoost = powerBoost + 10
		end
	end)

	task.delay(3, function()
		connection:Disconnect()
		-- warn("sending the ball flying")
		rope:Destroy()
		spikeBall.CFrame = spikeBall.CFrame
		spikeBall.Anchored = true
		spikeBall.Anchored = false
		-- spikeBall:ApplyImpulse(Vector3.new(15000, 15000, 0))
		local cam = workspace.CurrentCamera
		cam.CameraSubject = spikeBall
	end)

end
function charMod:Init()

	-- task.wait(2)
    library.Player.CharacterAdded:Connect(function(char)
		currentChar = char
        charMod.SetupCollisionGroup(char)
		local tool = char:WaitForChild("TrainingTool")
		charMod.HandleTool(tool, char)
    end)


	library.Events.StartThrowing.OnClientEvent:Connect(function()
		charMod.StartSpin()
		-- print("Staritng the spin here")
		-- if isThrowing == true then 
		-- 	isThrowing = false
		-- 	warn("giving the camera back to the palyer here")
		-- 	charMod.relinquishCamera()
			
		-- else
		-- 	isThrowing = true
		-- 	print("starting the true")
		-- 	charMod.StartSpin()
		-- end
		-- charMod.createSpikeBall()
	end)
	
    


end

return charMod
