local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local zoneMod = require(library.Modules:WaitForChild("Zone"))
local module = {}



function module:Init()
	task.wait(1)
	local pads = library.CollectionService:GetTagged("Pad")
	for _, pad in pairs(pads) do
		local atrribute = pad:GetAttribute("Function")
		local zone = zoneMod.fromRegion(pad.CFrame, Vector3.new(20, 20, 20))
		zone.playerEntered:Connect(function(player)
			-- library.camShaker(library.Camera)
			library.Functions.camShaker(library.Camera)
			
		end)	
		zone.playerExited:Connect(function(player)
			-- print(player.Name .. " exited the zone")
		end)
	end
end	

return module