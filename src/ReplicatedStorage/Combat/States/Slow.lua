local Slow = {}

Slow.InState = {}

function Slow:CheckState(target: Model)
    return Slow.InState[target]
end

function Slow:AddTarget(target: Model, duration)
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

    if Slow.InState[target] then
        return
    end

    Stats:SetAttribute("Slowed", true)

    Slow.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
        prevSpeed = humanoid.WalkSpeed
    }

    humanoid.WalkSpeed = 4
end

function Slow:RemoveTarget(target: Model)
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

    Stats:SetAttribute("Slowed", false)

    humanoid.WalkSpeed = Slow.InState[target].prevSpeed

    if Slow.InState[target] then
        Slow.InState[target] = nil
    end
end

function Slow:Update(deltaTime)
    for targetId, data in pairs(Slow.InState) do
        if data.currTime >= data.duration then
            Slow:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Slow