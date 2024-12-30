local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local zoneMod = require(library.Modules:WaitForChild("Zone"))
local ui = require(script.Parent:WaitForChild("ui"))
local module = {}


function module.SpinWheel(status)
	print("spinning the wheel here")
	library.PlayerGui.ScreenGui.Enabled = not status
	library.PlayerGui.SpinWheel.Enabled = status
end

function module.PromptProduct(padName)
	
	--! For gamepasses and products



end


function module.PromptFrame(pad)
	


end


function module:Init()
	task.wait(1.5) -- This is just for studio
	local blur = game.Lighting:WaitForChild("Blur")
	local pads = library.CollectionService:GetTagged("Pad")
	for _, pad in pairs(pads) do
		-- local atrribute = pad:GetAttribute("Function")
		local zone = zoneMod.fromRegion(pad.CFrame, Vector3.new(8, 20, 8))
		zone.localPlayerEntered:Connect(function(player)
			-- print("testing here")
				-- library.camShaker(library.Camera)
			-- print(player)
			-- library.Functions.camShaker(library.Camera)
			-- print(pad.Name)
			if module[pad.Name] then
				module[pad.Name](true)
			else
				warn("no module found with this name here")
			end
			blur.Size = 0
			blur.Enabled = true
			library.TweenService:Create(blur, TweenInfo.new(.5), {Size = 20}):Play()
		end)
		-- print("zone has been created for " .. pad.Name)
		
		zone.localPlayerExited:Connect(function(player)
				blur.Enabled = false
			blur.Size = 0
			if module[pad.Name] then
				module[pad.Name](false)
			else
				warn("no module found with this name here")
			end

			print(player.Name .. " exited the zone")
			print("player has exited the zone")
		end)	
	end
end	

return module