local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local gameMod = {}

local playerDebounces = {}

function gameMod.StartAction(player, character, platform)
	local hum = character:FindFirstChild("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	hum.WalkSpeed = 0
	library.Events.StartThrowing:FireClient(player)
	local trainingTool: Tool = character:FindFirstChild("TrainingTool")
	trainingTool.Enabled = false
	trainingTool.Parent = player.Backpack
	local tool = Instance.new("Tool")
	tool.Name = "PowerTool"
	tool.Parent = character
	tool.RequiresHandle = false
	local powerAccumulated = 0
	local maxClicks = library.Shared.MaxClicks

	tool.Activated:Connect(function()
		powerAccumulated = powerAccumulated + 1
		tool:SetAttribute("Clicks", powerAccumulated)
	end)

	task.spawn(function()
		while true do
			task.wait(1)
			if powerAccumulated <= 0 then
				continue
			end
			powerAccumulated -= 1
			-- print("redueced power here")
			tool:SetAttribute("Clicks", powerAccumulated)
			if not tool:IsDescendantOf(workspace) then
				break
			end
		end
	end)

	-- warn("power accumulated is", powerAccumulated)
	library.Events.StartThrowing:FireClient(player)

    local determineEndPosition = Vector3.new(15,0,0) --* TEMP
	local finishingDistance = character.PrimaryPart.Position + determineEndPosition
    local endPart = Instance.new("Part")
    local trophies = 5
	endPart.CFrame = CFrame.new(finishingDistance)
	endPart.Parent = workspace
	endPart.Anchored = true
    -- print(finishingDistance)
	task.delay(5, function()
		tool:Destroy()
		-- Return the character tool so he can train
		--Find a way to activate it again
		-- library.Events.StartThrowing:FireClient(player)
		trainingTool.Parent = character
		trainingTool.Enabled = true
		library.Debris:AddItem(tool, 0)
		hum.WalkSpeed = library.Shared.Defaults.WalkSpeed
        --! give the trophies to the player here
        
		--! Award the trophies here if the player hasn't left
		print("the throw has finished here")
		-- if playerDebounces[player] then
		--     playerDebounces[player] = nil
		-- end
		-- table.remove(playerDebounces, player)
		-- library.Events.
		-- library.Debris:AddItem(tool, 0)
	end)
	--! Launch the ball here
end

function gameMod:Init()
	task.wait(2)
	local throwingPlatforms = library.CollectionService:GetTagged("ThrowingPlatforms")
	for _, platform in pairs(throwingPlatforms) do
		platform.Touched:Connect(function(hit)
			if
				hit.Parent
				and hit.Parent:FindFirstChild("Humanoid")
				and library.Players:GetPlayerFromCharacter(hit.Parent)
			then
				local player = library.Players:GetPlayerFromCharacter(hit.Parent)
				if playerDebounces[player] then
					return
				end
				playerDebounces[player] = true
				gameMod.StartAction(player, hit.Parent, platform)
				-- local humanoid = hit.Parent:FindFirstChild("Humanoid")
				-- humanoid:TakeDamage(10)
			end
		end)
	end
end

return gameMod
