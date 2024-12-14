local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

local playerMod = {}



function playerMod.getRewardForMinutes(minutesToCheck)
    for giftIndex, giftData in pairs(library.Shared.TimeGifts) do
        if giftData.Minutes > minutesToCheck then
            return {
                rewardType = giftData.RewardType,
                reward = giftData.Reward,
                index = giftIndex
            }
        end
    end
    return nil -- Return nil if no matching reward found
end

function playerMod.UpdatePlayer(player)
        --! get the profile here
        --! get the last login
        --! see if it's the first time the player is getting something here


        task.spawn(function()
            local timePlayed = player:GetAttribute("TimeInGame") or 0
            while player:IsDescendantOf(library.Players) do
                player:SetAttribute("TimePlayed", timePlayed + 1)
                task.wait(1)
                timePlayed = player:GetAttribute("TimePlayed")
                playerMod.getRewardForMinutes(timePlayed / 60)
                warn("ticking here")
            end
        end)

end

function playerMod:Init()
    

    for _,player in pairs(library.Players:GetChildren()) do 
        playerMod.UpdatePlayer(player)

    end
    library.Players.PlayerAdded:Connect(function(player)
        playerMod.UpdatePlayer(player)
    end)

end

return playerMod
