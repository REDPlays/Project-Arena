local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local DamageBoost = {}
DamageBoost.InState = {}

function DamageBoost:CheckState(target: Model)
    return DamageBoost.InState[target]
end

function DamageBoost:AddTarget(target: Model, damageBonus: number)
    if not target then
        return
    end

    if DamageBoost:CheckState(target) then
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

    local rootPart = target:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    Stats:SetAttribute("DamageBoost", damageBonus)

    DamageBoost.InState[target] = {
        target = target,
        damageBonus = damageBonus,
    }
end

function DamageBoost:RemoveTarget(target: Model)
    if not target then
        return
    end

    if not DamageBoost:CheckState(target) then
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

    Stats:SetAttribute("DamageBoost", nil)

    if DamageBoost.InState[target] then
        DamageBoost.InState[target] = nil
    end
end

function DamageBoost:Update(deltaTime: number)
    
end

return DamageBoost