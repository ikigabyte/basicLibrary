-- local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))

repeat task.wait() until #game.Players:GetChildren() > 0

for _, modScript : ModuleScript in pairs(script:GetChildren()) do 
    if not modScript:IsA("ModuleScript") then 
        continue
    end
    local module = require(modScript)
    if type(module.Init) == "function" then
        module.Init()
    else
        warn("No init function found in module: " .. modScript.Name)
    end

    
end
