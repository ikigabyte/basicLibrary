
--Experimenting with the spike ball/ this doesn't get uploaded to the library 


-- task.wai
while true do 
    task.wait(2)
    local ball = game.Workspace.BallSpawner
    local position1 = workspace.BallSpawner.Position
    local position2 = workspace.BallSpawner2.Position

    local direction = position2 - position1
    local duration = math.log(1.001 + direction.Magnitude * 0.01)
    local force = direction / duration + Vector3.new(0, game.Workspace.Gravity * duration * 0.5, 0)
    local ballClone = ball:Clone()
    ballClone.Anchored = false
    ballClone.Parent = game.Workspace
    ballClone.Position = position1
    ballClone.CustomPhysicalProperties = PhysicalProperties.new(
        10,     -- High density for stability
        0.01,   -- Very low friction for sliding
        0,      -- Zero elasticity for no bounce
        0.01,   -- Minimal friction weight
        0       -- Zero elasticity weight
    )
    

    
    ballClone:ApplyImpulse(force * ballClone.AssemblyMass)
    ballClone:SetNetworkOwner(nil)
    ballClone.CanCollide = true

    
end