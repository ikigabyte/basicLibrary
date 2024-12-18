--! i want it match every player gui to the starter gui and make sure everything matches
local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

local currentTime = tick()
-- task.wait(1)
for _, child in pairs(script:GetChildren()) do 
    if child:IsA("ModuleScript") then 
        task.spawn(function()
            local mod = require(child)
            if mod["Init"] == nil then return end
            mod:Init()
            -- warn("Initiated " .. child.Name .. " on the client side")
        end)
        -- mod.Init()
    end
end

local timeToInitateModule = tick() - currentTime
local seconds = math.floor(timeToInitateModule)
local milliseconds = (timeToInitateModule - seconds) * 1000
print(string.format("Time to initiate module: %d.%d seconds", seconds, milliseconds))