local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local Invulnerable = {}
Invulnerable.InState = {}

function Invulnerable:CheckState(target: Model)
    return Invulnerable.InState[target]
end

function Invulnerable:AddTarget(target: Model, duration)
    if not target then
        return
    end
    
    if Invulnerable.InState[target] then
        return
    end
    
    local Stats = target:FindFirstChild("Stats")
    if not Stats then
        return
    end
    
    Stats:SetAttribute("Invulnerable", true)

    Invulnerable.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
    }
end

function Invulnerable:RemoveTarget(target: Model)
    if not target then
        return
    end

    if not Invulnerable.InState[target] then
        return
    end

    local Stats = target:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = target:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    Stats:SetAttribute("Invulnerable", false)

    if Invulnerable.InState[target] then
        Invulnerable.InState[target] = nil
    end
end

function Invulnerable:Update(deltaTime)
    for targetId, data in pairs(Invulnerable.InState) do
        if data.currTime >= data.duration then
            Invulnerable:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Invulnerable