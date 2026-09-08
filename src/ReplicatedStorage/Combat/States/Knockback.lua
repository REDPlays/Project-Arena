local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local Knockback = {}
Knockback.InState = {}

function Knockback:CheckState(target: Model)
    return Knockback.InState[target]
end

function Knockback:AddTarget(target: Model, Force: number, additionalData: {})
    if not target then
        return
    end
    
    if Knockback.InState[target] then
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

    additionalData = additionalData or {}
    local originCFrame = additionalData.originCFrame or rootPart.CFrame
    
    Force = Force or 15

    local direction = originCFrame.LookVector * Force + originCFrame.UpVector * (Force * 0.5)

    local duration = additionalData.duration or 0.25
    
    Stats:SetAttribute("Knockback", true)

    local knockBackData = {
        Force = Force,
        isKnockback = true,
        duration = duration,
        direction = direction,
    }

    local player = Players:GetPlayerFromCharacter(target)
    if player then
        Events.Server_Client.Movement:FireClient(player, target, knockBackData)
    else
        Events.Server_Client.Movement:FireAllClients(target, knockBackData)
    end

    Knockback.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
        direction = direction,
    }
end

function Knockback:RemoveTarget(target: Model)
    if not target then
        return
    end

    if not Knockback.InState[target] then
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

    Stats:SetAttribute("Knockback", false)

    if Knockback.InState[target] then
        Knockback.InState[target] = nil
    end
end

function Knockback:Update(deltaTime)
    for targetId, data in pairs(Knockback.InState) do
        if not data.target then
            continue
        end

        if data.currTime >= data.duration then
            Knockback:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Knockback