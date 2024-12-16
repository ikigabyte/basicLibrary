-- local library = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"))
local ShakerMod = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CamShaker"))

return function(camera, Preset)
    if not camera then 
        -- warn("No camera found")
        return
    end
    local camShake = ShakerMod.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
        camera.CFrame = camera.CFrame * shakeCf
    end)
    camShake:Start()
-- Explosion shake:
    camShake:Shake(ShakerMod.Presets.Explosion)
end


