local CollectionService = game:GetService("CollectionService")

local Burn = {}

Burn.InState = {}
local maxStacks = 3
local burnDamage = .01
local currTick = 0
local maxTick = 1

function Burn:CheckState(target: Model)
    return Burn.InState[target]
end

function Burn:AddTarget(target: Model, duration)
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

    Stats:SetAttribute("Burn", true)

    if Burn.InState[target] then
        Burn.InState[target].currTime = 0
        Burn.InState[target].duration = duration
        
        if Burn.InState[target].burnCount < maxStacks then
            Burn.InState[target].burnCount += 1
        end

        return
    end

    Burn.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
        burnCount = 1,
    }
end

function Burn:RemoveTarget(target: Model)
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

    Stats:SetAttribute("Burn", nil)

    if Burn.InState[target] then
        Burn.InState[target] = nil
    end
end

function Burn:Update(deltaTime)
    for targetId, data in pairs(Burn.InState) do
        if data.currTime >= data.duration then
            Burn:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime

        local Stats = data.target:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        local humanoid = data.target:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local isDummy = CollectionService:HasTag(data.target, "Dummies")
            if isDummy and humanoid.Health <= burnDamage * data.burnCount then
                continue
            end
            
            humanoid:TakeDamage(burnDamage * data.burnCount)

            local health = humanoid.Health 
            local maxHealth = humanoid.MaxHealth

            Stats:SetAttribute("Health", health)
            Stats:SetAttribute("MaxHealth", maxHealth)
        end
    end
end

return Burn