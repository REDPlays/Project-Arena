local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local Assets = ReplicatedStorage.Assets
local CharacterModels = Assets.CharacterModels
local UI = Assets.UI

type LSData = {
    ID: string,
    owner: Model,
    target: Model,
    currTime: number,
    duration: number,
    currRate: number,
    rate: number,
    heal: number,
}

local LifeSteal = {}

LifeSteal.InState = {}
LifeSteal.rate = 1
LifeSteal.heal = 5

function LifeSteal:CheckState(participant: Model)
    local inState = false

    for ID, lifeStealData: LSData in pairs(LifeSteal.InState) do
        local owner = lifeStealData.owner

        if participant == owner then
            inState = true
            break
        end
    end

    return inState
end

--if duration is 0 then its a burst of life steal
function LifeSteal:AddTarget(owner: Model, duration: number, additionalData: {})
    local target: Model = additionalData.target
    local newRate: number = additionalData.newRate or LifeSteal.rate
    local heal: number = additionalData.heal or LifeSteal.heal

    if not owner then return end
    if not target then return end
    
    local ownerStats = owner:FindFirstChild("Stats")
    local targetStats = target:FindFirstChild("Stats")
    if not ownerStats or not targetStats then return end
    
    local ownerHum = owner:FindFirstChild("Humanoid")
    local targetHum = target:FindFirstChild("Humanoid")
    if not ownerHum or not targetHum then return end
    
    local ownerRoot = owner:FindFirstChild("HumanoidRootPart")
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not ownerRoot or not targetRoot then return end

    if duration and duration > 0 then
        local ID = HttpService:GenerateGUID(false)

        ownerStats:SetAttribute("LifeSteal", true)

        LifeSteal.InState[ID] = {
            ID = ID,
            owner = owner,
            target = target,
            currTime = 0,
            duration = duration,
            currRate = 0,
            rate = newRate,
            heal = heal,
        }
    elseif not duration or duration == 0 then
        HealthManager:Heal(owner, heal)
        HealthManager:Damage(target, heal, owner)
    end
end

function LifeSteal:RemoveTarget(participant: Model)
    local removeID = ""

    for ID, lifeStealData: LSData in pairs(LifeSteal.InState) do
        local owner = lifeStealData.owner

        if participant == owner then
            removeID = ID

            local ownerStats = owner:FindFirstChild("Stats")
            if ownerStats then
                ownerStats:SetAttribute("LifeSteal", false)
            end

            break
        end
    end

    if LifeSteal[removeID] then
        LifeSteal[removeID] = nil
    end
end

function LifeSteal:Update(deltaTime: number)
    for ID, lifeStealData: LSData in pairs(LifeSteal.InState) do
        lifeStealData.currTime += deltaTime
        lifeStealData.currRate += deltaTime

        local owner = lifeStealData.owner
        local target = lifeStealData.target

        if not owner or not target then
            LifeSteal.InState[ID] = nil
            continue 
        end

        local ownerHum = owner:FindFirstChild("Humanoid")
        local targetHum = target:FindFirstChild("Humanoid")
        if not ownerHum or not targetHum then
            LifeSteal.InState[ID] = nil
            continue
        end

        if ownerHum.Health <= 0 or targetHum.Health <= 0 then
            LifeSteal.InState[ID] = nil
            continue
        end

        if lifeStealData.currTime >= lifeStealData.duration then
            LifeSteal.InState[ID] = nil
            continue
        end

        if lifeStealData.currRate >= lifeStealData.rate then
            lifeStealData.currRate = 0

            HealthManager:Heal(owner, lifeStealData.heal)
            HealthManager:Damage(target, lifeStealData.heal, owner)
        end
    end
end

return LifeSteal