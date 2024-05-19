local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local Knockup = {}
Knockup.InState = {}

function Knockup:CheckState(target: Model)
    return Knockup.InState[target]
end

function Knockup:AddTarget(target: Model, Force)
    if not target then
        return
    end
    
    if Knockup.InState[target] then
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
    
    Force = Force or 15

    local duration = 0.25
    
    Stats:SetAttribute("Knockup", true)

    local knockupData = {
        Force = Force,
        isKnockup = true,
        duration = duration,
    }

    local player = Players:GetPlayerFromCharacter(target)
    if player then
        Events.Server_Client.Movement:FireClient(player, target, knockupData)
    else
        Events.Server_Client.Movement:FireAllClients(target, knockupData)
    end

    Knockup.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
    }
end

function Knockup:RemoveTarget(target: Model)
    if not target then
        return
    end

    if not Knockup.InState[target] then
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

    Stats:SetAttribute("Knockup", false)

    if Knockup.InState[target] then
        Knockup.InState[target] = nil
    end
end

function Knockup:Update(deltaTime)
    for targetId, data in pairs(Knockup.InState) do
        if not data.target then
            continue
        end

        if data.currTime >= data.duration then
            Knockup:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Knockup