--! i want it match every player gui to the starter gui and make sure everything matches
local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

-- task.wait(1)
for _, child in pairs(script:GetChildren()) do 
    if child:IsA("ModuleScript") then 
        task.spawn(function()
            local mod = require(child)
            if mod["Init"] == nil then return end
            mod:Init()
            warn("Initiated " .. child.Name .. " on the client side")
        end)
        -- mod.Init()
    end
end