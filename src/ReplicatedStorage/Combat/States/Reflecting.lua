local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local Reflecting = {}
Reflecting.InState = {}

function Reflecting:CheckState(target: Model)
    return Reflecting.InState[target]
end

function Reflecting:AddTarget(target: Model, duration: number)
    if not target then
        return
    end

    if Reflecting:CheckState(target) then
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

    duration = duration or 1

    Stats:SetAttribute("Reflecting", true)

    Reflecting.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
    }
end

function Reflecting:RemoveTarget(target: Model)
    if not target then
        return
    end

    if not Reflecting:CheckState(target) then
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

    Stats:SetAttribute("Reflecting", false)

    if Reflecting.InState[target] then
        Reflecting.InState[target] = nil
    end
end

function Reflecting:ReflectAttack(target: Model, attacker: Model, attackName: string)
    if not Reflecting:CheckState(target) then
        return
    end
end

function Reflecting:Update(deltaTime: number)
    for targetId, data in pairs(Reflecting.InState) do
        if not data.target then
            continue
        end

        if data.currTime >= data.duration then
            Reflecting:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Reflecting