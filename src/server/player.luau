local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

local playerMod = {}



function playerMod.UpdatePlayer(player)
        --! get the profile here
        --! get the last login
        --! see if it's the first time the player is getting something here


end

function playerMod:Init()
    

    for _,player in pairs(library.Players) do 
        playerMod.UpdatePlayer()(player)

    end
    library.Players.PlayerAdded:Connect(function(player)
        
    end)

end

return playerMod
