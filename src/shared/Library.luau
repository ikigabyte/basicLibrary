local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = {}

Library.RunService = game:GetService("RunService")
Library.ReplicatedStorage = game:GetService("ReplicatedStorage")
Library.Events = ReplicatedStorage:WaitForChild("Events")
Library.TextChatService = game:GetService("TextChatService")
Library.TweenService = game:GetService("TweenService")
Library.StarterGui = game:GetService("TweenService")
Library.Debris = game:GetService("Debris")
Library.CollectionService = game:GetService("CollectionService")
Library.Players = game:GetService("Players")
Library.MarketplaceService = game:GetService("MarketplaceService")
Library.SoundService = game:GetService("SoundService")
Library.Shared = require(script.Parent:WaitForChild("Shared"))
Library.Assets = Library.ReplicatedStorage:WaitForChild("Assets")
Library.Modules = Library.ReplicatedStorage:WaitForChild("Modules")
Library.Functions = {
    ["formatTime"] = require(game.ReplicatedStorage.Shared.Functions.formatTime),
    ["abbreviations"] = require(game.ReplicatedStorage.Shared.Functions.abbreviations),
    ["camShaker"] = require(game.ReplicatedStorage.Shared.Functions.camShaker)
   
}
-- for _, modScript in pairs(game.ReplicatedStorage.Shared.Functions:GetChildren()) do 
--     if modScript:IsA("ModuleScript") then 
--         Library.Functions[modScript.Name] = require(modScript)
--         -- table.insert(Library.Functions, require(modScript))
--     end
-- end


if Library.RunService:IsClient() then
    -- table.insert(Library.Functions, ["camShaker"] = require(game.ReplicatedStorage.Shared.Functions.camShaker))
    Library.Player = game.Players.LocalPlayer
    Library.PlayerGui = Library.Player:WaitForChild("PlayerGui")
    Library.Camera = workspace.CurrentCamera
    Library.UserInputService = game:GetService("UserInputService")  
    -- setmetatable(Library.PlayerGui, playerGuiMetatable)
    -- Library.StarterGui = game.StarterGui
    -- Library.StarterGui.Parent = Library.PlayerGui

end






return Library 
