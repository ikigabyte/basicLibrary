local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))



repeat task.wait(1) until #game.Players:GetChildren() > 0

for _, modScript : ModuleScript in pairs(script:GetChildren()) do 
    local module = require(modScript)
    if type(module.Init) == "function" then
        module.Init()
    else
        print("No init function found in module: " .. modScript.Name)
    end

    
end
