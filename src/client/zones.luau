local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local zoneMod = require(library.Modules:WaitForChild("Zone"))
local module = {}



function module:Init()
	task.wait(1)
	local pads = library.CollectionService:GetTagged("Pad")
	warn("pads now initiating here")
	for _, pad in pairs(pads) do
		print(pad)
		local atrribute = pad:GetAttribute("Function")
		local zone = zoneMod.fromRegion(pad.CFrame, Vector3.new(20, 20, 20))
		print(zone)
		zone.playerEntered:Connect(function(player)
			-- library.camShaker(library.Camera)
			library.Functions.camShaker(library.Camera)
			print(player.Name .. " entered the zone")
			
		end)	
		zone.playerExited:Connect(function(player)
			print(player.Name .. " exited the zone")
		end)
	end
end	

return module