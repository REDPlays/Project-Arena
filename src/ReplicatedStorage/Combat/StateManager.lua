local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local States = ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("States")

local states = {
    HealthRegen = require(States:WaitForChild("HealthRegen")),
    Stunned = require(States:WaitForChild("Stunned")),
    Blocking = require(States:WaitForChild("Blocking")),
    Attacked = require(States:WaitForChild("Attacked")),
}

local StateManager = {}

function StateManager:CheckState(target: Model, currState)
    if not states[currState] then
        return
    end
    
    return states[currState]:CheckState(target)
end

if RunService:IsServer() then
    function StateManager:AddTarget(target: Model, currState, stateData)
        if not states[currState] then
            return
        end

        states[currState]:AddTarget(target, stateData)
    end

    function StateManager:RemoveTarget(target: Model, currState)
        if not states[currState] then
            return
        end

        states[currState]:RemoveTarget(target)
    end

    function StateManager:Update(deltaTime)
        states.HealthRegen:Update(deltaTime)
        states.Stunned:Update(deltaTime)
        states.Blocking:Update(deltaTime)
        states.Attacked:Update(deltaTime)
    end
end

return StateManager