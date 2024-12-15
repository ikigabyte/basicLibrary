local zoneController = {}

local zone = require(game.ReplicatedStorage.Modules:WaitForChild("Zone"))


function zoneController:onLeave()
    
    return self
end
function zoneController:onEnter()
    
    return self

end


function zoneController.new(part : Part, size: Vector3)
    zone.new(part, size)
    -- zone:Init()
end



return zoneController
