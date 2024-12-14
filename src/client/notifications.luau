--! i want it match every player gui to the starter gui and make sure everything matches
local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

-- task.wait(10000) -- Until everything is loaded here

local notificationMod = {}

local TIME_BETWEEN_FRIEND_CHECKS = 30
local previousFriends = {}


function notificationMod.PromptTextNotification(text, duration, props)
    warn("prompting a notification here")
    local notificationFrame = library.PlayerGui.ScreenGui.HUD.Notifications
    local template = notificationFrame.TemplateLabel:Clone()
    template.Parent = notificationFrame
    template.Text = text
    -- template.Parent = notificationFrame
    template.Visible = true
    task.delay(duration, function()
        print(duration)
        template:Destroy()
    end)

end


function notificationMod.PromptFriendInvite()
    


end

function notificationMod:Init()


--! you just match this t

while task.wait(TIME_BETWEEN_FRIEND_CHECKS) do 
    local freindsOnline = library.Player:GetFriendsOnline(200)
    -- print(freindsOnline)
    for _, friend in pairs(freindsOnline) do 
        print(friend)

    end


    
end

    

    --! Track the friends here to prompt an invite when a player goes live 
end
return notificationMod