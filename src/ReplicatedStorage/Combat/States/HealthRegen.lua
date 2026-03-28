local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Dummies = workspace.Dummies

local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local HealthRegen = {}

HealthRegen.rateRegen = 10
HealthRegen.InState = {}

function HealthRegen:CheckState(target: Model)
    return HealthRegen.InState[target]
end

function HealthRegen:AddTarget(target: Model, regenRate)
    if not target then
        return
    end

    local Stats = target:FindFirstChild("Stats")
    if not Stats then
        return
    end

    regenRate = regenRate or HealthRegen.rateRegen

    if HealthRegen.InState[target] then
        return
    end

    Stats:SetAttribute("HealthRegen", true)

    HealthRegen.InState[target] = {
        target = target,
        regenRate = regenRate
    }
end

function HealthRegen:RemoveTarget(target: Model)
    if not target then
        return
    end

    local Stats = target:FindFirstChild("Stats")
    if not Stats then
        return
    end

    Stats:SetAttribute("HealthRegen", false)
    
    if HealthRegen.InState[target] then
        HealthRegen.InState[target] = nil
    end
end

local currTime = 0
local maxTick = 1
function HealthRegen:Update(deltaTime: number)
    currTime += deltaTime
    if currTime < maxTick then
        return
    end

    currTime = 0
    --regenerate health (players)
    --[==[for _, player in pairs(Players:GetChildren()) do
        local character = player.Character
        if not character then
            continue
        end

        if HealthRegen.InState[character] then
            continue
        end

        local humanoid: Humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then
            continue
        end

        if humanoid.Health <= 0 then
            continue
        end

        local Stats = character:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        if Stats:GetAttribute("Stunned") and Stats:GetAttribute("Stunned") == true then
            continue
        end

        if Stats:GetAttribute("Attacked") and Stats:GetAttribute("Attacked") == true then
            continue
        end

        if Stats:GetAttribute("Burn") and Stats:GetAttribute("Burn") == true then
            continue
        end

        HealthManager:Heal(character, HealthRegen.rateRegen * deltaTime)
    end]==]

    --regenerate health (dummy)
    for _, dummy in pairs(Dummies:GetChildren()) do
        if HealthRegen.InState[dummy] then
            continue
        end

        if dummy.Name == "AllyDummy" then
            continue
        end

        local humanoid: Humanoid = dummy:FindFirstChild("Humanoid")
        if not humanoid then
            continue
        end

        if humanoid.Health <= 0 then
            continue
        end

        local Stats = dummy:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        if Stats:GetAttribute("Stunned") and Stats:GetAttribute("Stunned") == true then
            continue
        end

        if Stats:GetAttribute("Attacked") and Stats:GetAttribute("Attacked") == true then
            continue
        end

        if Stats:GetAttribute("Burn") and Stats:GetAttribute("Burn") == true then
            continue
        end

        HealthManager:Heal(dummy, HealthRegen.rateRegen * 10 * deltaTime)
    end

    for targetId, data in pairs(HealthRegen.InState) do
        local Stats = data.target:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        local humanoid: Humanoid = data.target:FindFirstChild("Humanoid")
        if not humanoid then
            continue
        end

        if humanoid.Health <= 0 then
            continue
        end

        if Stats:GetAttribute("Stunned") and Stats:GetAttribute("Stunned") == true then
            continue
        end

        if Stats:GetAttribute("Attacked") and Stats:GetAttribute("Attacked") == true then
            continue
        end

        if Stats:GetAttribute("Burn") and Stats:GetAttribute("Burn") == true then
            continue
        end

        local addedHealth = data.regenRate * deltaTime
        HealthManager:Heal(data.target, addedHealth)
    end
end

return HealthRegen