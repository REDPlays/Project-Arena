local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local Blocking = {}

Blocking.rateDecay = 10
Blocking.rateRegen = 2.5
Blocking.InState = {}

function Blocking:CheckState(target: Model)
    return Blocking.InState[target]
end

function Blocking:AddTarget(target: Model)
    if not target then
        return
    end
    
    if Blocking.InState[target] then
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
    
    Stats:SetAttribute("Blocking", true)

    Blocking.InState[target] = {
        target = target,
        prevSpeed = humanoid.WalkSpeed
    }

    humanoid.WalkSpeed = 6
end

function Blocking:RemoveTarget(target: Model)
    if not target then
        return
    end

    if not Blocking.InState[target] then
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

    Stats:SetAttribute("Blocking", false)

    humanoid.WalkSpeed = Blocking.InState[target].prevSpeed

    if Blocking.InState[target] then
        Blocking.InState[target] = nil
    end

    local player = Players:GetPlayerFromCharacter(target)
    if player then
        Events.Server_Client.Cooldown:FireClient(player, "Block")
    end
end

function Blocking:Update(deltaTime)
    --regenerate blocking (players)
    for _, player in pairs(Players:GetChildren()) do
        local character = player.Character
        if not character then
            continue
        end

        if Blocking.InState[character] then
            continue
        end

        local Stats = character:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        local defense = Stats:GetAttribute("Defense")
        local maxDefense = Stats:GetAttribute("MaxDefense")

        if defense < maxDefense then
            defense += Blocking.rateRegen * deltaTime
            defense = math.clamp(defense, 0, maxDefense)
            Stats:SetAttribute("Defense", defense)
        end
    end

    for targetId, data in pairs(Blocking.InState) do
        local Stats = data.target:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        if CollectionService:HasTag(data.target, "Dummies") then
            continue
        end

        local defense = Stats:GetAttribute("Defense")
        local maxDefense = Stats:GetAttribute("MaxDefense")

        if defense > 0 then
            defense -= Blocking.rateDecay * deltaTime
            defense = math.clamp(defense, 0, maxDefense)
            Stats:SetAttribute("Defense", defense)
        elseif defense <= 0 then
            Blocking:RemoveTarget(targetId)
            continue
        end
    end
end

return Blocking