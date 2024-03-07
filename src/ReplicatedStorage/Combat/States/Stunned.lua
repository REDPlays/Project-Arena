local Stunned = {}

Stunned.InState = {}

function Stunned:CheckState(target: Model)
    return Stunned.InState[target]
end

function Stunned:AddTarget(target: Model, duration)
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

    local humanoid = target:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    Stats:SetAttribute("Stunned", true)

    if Stunned.InState[target] then
        Stunned.InState[target].currTime = 0
        Stunned.InState[target].duration = duration
        Stunned.InState[target].stunCount += 1

        return
    end

    Stunned.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
        stunCount = 1,
        prevSpeed = humanoid.WalkSpeed
    }

    humanoid.WalkSpeed = 0
end

function Stunned:RemoveTarget(target: Model)
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

    Stats:SetAttribute("Stunned", false)

    humanoid.WalkSpeed = Stunned.InState[target].prevSpeed

    if Stunned.InState[target] then
        Stunned.InState[target] = nil
    end
end

function Stunned:Update(deltaTime)
    for targetId, data in pairs(Stunned.InState) do
        data.currTime += deltaTime

        if data.currTime >= data.duration then
            Stunned:RemoveTarget(targetId)
        end
    end
end

return Stunned