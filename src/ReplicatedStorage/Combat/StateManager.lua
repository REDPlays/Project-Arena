local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local States = ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("States")

local states = {
    HealthRegen = require(States:WaitForChild("HealthRegen")),
    Stunned = require(States:WaitForChild("Stunned")),
    Blocking = require(States:WaitForChild("Blocking")),
    Attacked = require(States:WaitForChild("Attacked")),
    Burn = require(States:WaitForChild("Burn")),
    Slow = require(States:WaitForChild("Slow")),
    Knockup = require(States:WaitForChild("Knockup")),
    Invulnerable = require(States:WaitForChild("Invulnerable")),
    Silenced = require(States:WaitForChild("Silenced")),
    Knockback = require(States:WaitForChild("Knockback")),
    Reflecting = require(States:WaitForChild("Reflecting")),
}

local StateManager = {}

function StateManager:CheckState(target: Model, currState)
    if not states[currState] then
        return
    end
    
    return states[currState]:CheckState(target)
end

if RunService:IsServer() then
    function StateManager:AddTarget(target: Model, currState: string, stateData, additionalData)
        if not states[currState] then
            return
        end

        states[currState]:AddTarget(target, stateData, additionalData)
    end

    function StateManager:RemoveTarget(target: Model, currState)
        if not states[currState] then
            return
        end

        states[currState]:RemoveTarget(target)
    end

    --Only for reflecting state at the moment
    function StateManager:ReflectAttack(target: Model, currState: string, attacker: Model, attackName: string)
        if not states[currState] then
            return
        end

        states[currState]:ReflectAttack(target, attacker, attackName)
    end

    function StateManager:RemoveAll(target: Model)
        for stateName, state in pairs(states) do
            if state:CheckState(target) then
                state:RemoveTarget(target)
            end
        end
    end

    function StateManager:Update(deltaTime)
        for stateName, state in pairs(states) do
            state:Update(deltaTime)
        end
    end
end

return StateManager