local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = {}

Library.RunService = game:GetService("RunService")
Library.ReplicatedStorage = game:GetService("ReplicatedStorage")
Library.Events = ReplicatedStorage:WaitForChild("Events")
Library.TextChatService = game:GetService("TextChatService")
Library.TweenService = game:GetService("TweenService")
Library.StarterGui = game:GetService("TweenService")
Library.Debris = game:GetService("Debris")

Library.Players = game:GetService("Players")
Library.MarketplaceService = game:GetService("MarketplaceService")
Library.SoundService = game:GetService("SoundService")
Library.Shared = require(script.Parent:WaitForChild("Shared"))
Library.Assets = Library.ReplicatedStorage:WaitForChild("Assets")
if Library.RunService:IsClient() then
    Library.Player = game.Players.LocalPlayer
    Library.PlayerGui = Library.Player:WaitForChild("PlayerGui")
    Library.UserInputService = game:GetService("UserInputService")  
    -- setmetatable(Library.PlayerGui, playerGuiMetatable)

    print("continuing here with the rest of the code")

    

    
    -- Library.StarterGui = game.StarterGui
    -- Library.StarterGui.Parent = Library.PlayerGui

end






return Library 
