local charMod = {}
local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

local powerBoost = 1

local connection
charMod.SendBallFlying = function(part) end

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
charMod.MakeCharacterSpin = function()
	local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")

	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Parent = root
	alignOrientation.Attachment0 = root:WaitForChild("RootAttachment")
	alignOrientation.Enabled = false
	alignOrientation.Responsiveness = 5

	-- alignOrientation.CFrame = root.CFrame * CFrame.Angles(0, math.rad(359), 0)
	local animation = library.Assets.Animation
	local animator: Animator = char.Humanoid.Animator
	local anim = animator:LoadAnimation(animation)
	anim:Play()

	local spinSpeed = 250 -- Initial spin speed (degrees per frame)
	-- local spinIncrement = 2 -- Amount to increase spin speed per frame
	local runService = game:GetService("RunService")

	-- Spin the player

	connection = runService.RenderStepped:Connect(function(deltaTime)
		if root then
			-- Increment the spin speed
			spinSpeed = spinSpeed * powerBoost
			-- print(deltaTime)
			-- spinSpeed = spinSpeed + spinIncrement * deltaTime
			-- Rotate the player by modifying the CFrame
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed * deltaTime), 0)
		end
	end)

	-- alignOrientation.CFrame = root.CFrame * CFrame.Angles(0, math.rad(0), 0)
	-- local firstPart = {CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)}

	-- alignOrientation.Attachment1 = root:WaitForChild("RootAttachment")
	-- library.TweenService:Create(root, TweenInfo.new(1), {CFrame = root.CFrame * CFrame.Angles(0, math.rad(360), 0)}):Play()
end

function charMod.createSpikeBall()
    
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

	charMod.SetupCollisionGroup(char)
	local root = char:WaitForChild("HumanoidRootPart")

	warn("initated the character mod here")
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
		warn("testing something here")
		charMod.MakeCharacterSpin()
	end)

	library.RunService.RenderStepped:Connect(function()
		local frontOffset = root.CFrame.LookVector * 5
		-- spikeBall.CFrame = root.CFrame + frontOffset
		newPart.CFrame = root.CFrame + frontOffset
	end)

	library.UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			warn("boosted here")
			-- spikeBall.Velocity = Vector3.new(0, 50, 0)
			powerBoost = powerBoost + 10
		end
	end)

	task.delay(3, function()
		connection:Disconnect()
		warn("sending the ball flying")
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
    library.Player.CharacterAdded:Connect(function(char)
        charMod.SetupCollisionGroup(char)
    end)
    


end

return charMod
