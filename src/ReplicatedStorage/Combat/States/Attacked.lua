local Players = game:GetService("Players")

local Dummies = workspace.Dummies

local Attacked = {}

Attacked.InState = {}

function Attacked:CheckState(target: Model)
    return Attacked.InState[target]
end

function Attacked:AddTarget(target: Model, duration)
    if not target then
        return
    end

    if not duration then
        return
    end

    local Stats = target:FindFirstChild("Stats")
    if not Stats then
        return
    end

    Stats:SetAttribute("Attacked", true)

    if Attacked.InState[target] then
        Attacked.InState[target].currTime = 0
        Attacked.InState[target].duration = duration

        return
    end

    Attacked.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
    }
end

function Attacked:RemoveTarget(target: Model)
    if not target then
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

    Stats:SetAttribute("Attacked", false)

    if Attacked.InState[target] then
        Attacked.InState[target] = nil
    end
end

function Attacked:Update(deltaTime)
    for targetId, data in pairs(Attacked.InState) do
        data.currTime += deltaTime

        if data.currTime >= data.duration then
            Attacked:RemoveTarget(targetId)
        end
    end
end

return Attacked
