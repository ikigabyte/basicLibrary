local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local notificationMod = {}

-- task.wait(10000) -- Until everything is loaded here
local sfxMod = require(script.Parent:WaitForChild("sfx"))
local uiHandler = require(script.Parent:WaitForChild("ui"))


local TIME_BETWEEN_FRIEND_CHECKS = 5
local previousFriends = {}
local invitedFriends = {}
-- local firstTime = true
local friendTemplate : Frame = library.PlayerGui.ScreenGui.Frames.FriendInvite


function notificationMod.PromptTextNotification(text, duration, props)
    -- print("new notification here")
    local notificationFrame = library.PlayerGui.ScreenGui.HUD.Notifications
    local template = notificationFrame.TemplateLabel:Clone()
    template.Parent = notificationFrame
    template.Text = text
    -- template.Parent = notificationFrame
    template.Visible = true
    -- sfxMod.Play("Click")


    task.delay(duration, function()
        template:Destroy()
    end)
end



function notificationMod.GetFriendsOnline()
    local cleanedUpFriends = {}
    local friends = library.Player:GetFriendsOnline(200)
    for _, stats in pairs(friends) do
        local userId = stats.VisitorId
        table.insert(cleanedUpFriends, userId)
    end
    return cleanedUpFriends
end


function notificationMod.PromptFriendInvitation(playerId : number)
    print("prompting friend invitation")


    local friendFrame = friendTemplate:Clone()
    friendFrame.Parent = library.PlayerGui.ScreenGui
    local playerName  : string = library.Players:GetNameFromUserIdAsync(playerId)
    local playerIcon = uiHandler.GetPlayerIcon(playerId)
    friendFrame.PlayerIcon.Image = playerIcon
    friendFrame.Visible = true
    friendFrame.TextLabel.Text = playerName.. " is online! Invite them to play!"
    task.delay(5, function()
        friendFrame:Destroy()
        print("the invitation is now expired")
    end)
    friendFrame.Invite.Activated:Once(function()
        print("Invited player")
        local experienceOptions = Instance.new("ExperienceInviteOptions")
        experienceOptions.InviteUser = playerId
        experienceOptions.InviteMessageId = "Invite this player"
        local promptInvite = library.SocialService:PromptGameInvite(library.Player, experienceOptions)
        sfxMod.Play("Click", 0.5) 
        table.insert(invitedFriends, playerId)
        -- library.Player:RequestFriendship(playerId)
        friendFrame:Destroy()
    end)
end

function notificationMod.GetAssignedFriend(friends)
    for _, friendId in pairs(friends) do
        if not table.find(previousFriends, friendId) and not table.find(invitedFriends, friendId)then
            notificationMod.PromptFriendInvitation(friendId)
            -- notificationMod.PromptTextNotification(friend .. " is online! Invite them to play!", 5)
            return friendId
        end
    end


end

function notificationMod.CheckFriends()

	-- if firstTime then
	-- 	local friends = notificationMod.GetFriendsOnline()
	-- 	local chosenFriend = friends[library.Functions.random(0, #friends)]
    --     notificationMod.PromptFriendInvitation(chosenFriend)
    --     firstTime = false
	-- end
    while true do
        -- print("checking again")
        task.wait(TIME_BETWEEN_FRIEND_CHECKS)
        local friends = notificationMod.GetFriendsOnline()
        if #friends == 0 then
            continue
        else
            local friend = notificationMod.GetAssignedFriend(friends)
            if not friend then continue end
            notificationMod.PromptFriendInvitation(friend)
        end
        previousFriends = friends
    end
end

function notificationMod:Init()
	--! you just match this t
    task.spawn(notificationMod.CheckFriends)
    library.Events.SendNotification.OnClientEvent:Connect(function(text, validation)
        notificationMod.PromptTextNotification(text, 2)
    end)

	--! Track the friends here to prompt an invite when a player goes live
end


return notificationMod