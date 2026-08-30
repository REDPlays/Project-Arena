local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local HitboxManager = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("HitboxManager"))

local IgnoreFolder = workspace.Ignore
local ObstaclesFolder = workspace.Obstacles
local Dummies = workspace.Dummies

local SoulSlice = {}

function SoulSlice:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[moveType]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    Stats:SetAttribute("AbilityLocked", true)

    local isAwakened = Stats:GetAttribute("Awakened")

    if not isAwakened then
        damage = damage[1]
    end

    local damageBoost = Stats:GetAttribute("DamageBoost")
    if damageBoost then
        damage = damage * damageBoost
    end

    --local Heal = classData.MoveDataAdditional[moveType].LifeSteal.heal or 1
    local alreadyHit = {}
    local lifeTime = .1

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Anchored = true
    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.CFrame = placementCFrame
    Hitbox.Parent = IgnoreFolder
    Debris:AddItem(Hitbox, lifeTime)

    local hitDetect = task.spawn(function()
        while true do
            if not Hitbox then
                break
            end

            local touched = Hitbox.Touched:Connect(function() end)
            local touchedObjects = Hitbox:GetTouchingParts()
    
            if touched then
                touched:Disconnect()
            end
    
            for i=1, #touchedObjects do
                local object = touchedObjects[i]
                local parent = object.Parent
    
                if not parent:IsA("Model") then
                    continue
                end
    
                if parent == character then
                    continue
                end
    
                --ignoreTargets
                if CollectionService:HasTag(parent, "Ignore") then
                    continue
                end
    
                local enemyHum = parent:FindFirstChild("Humanoid")
                if not enemyHum then
                    continue
                end
    
                local enemyRoot: BasePart = parent:FindFirstChild("HumanoidRootPart")
                if not enemyRoot then
                    continue
                end
    
                if alreadyHit[parent.Name] then
                    continue
                end
    
                if CollectionService:HasTag(parent, "Invulnerable") then
                    continue
                end

                local myTeam = character:GetAttribute("Team")
                local theirTeam = parent:GetAttribute("Team")

                if (myTeam and theirTeam) and myTeam == theirTeam then
                    continue
                end
    
                alreadyHit[parent.Name] = true
    
                local isBlocking = StateManager:CheckState(parent, "Blocking")
                if isBlocking then
                    --Block Indication
                    HealthManager:Block(parent, damage, character)
                    continue
                end

                --check modifiers
                if not isAwakened then
                    HitboxManager:CheckModifiers(
                        classData.MoveData[moveType][1],
                        classData.MoveDataDurations[moveType][1],
                        parent, 
                        character,
                        classData.MoveDataAdditional[moveType][1]
                    )
                end

                StateManager:AddTarget(parent, "Attacked", 1)
    
                --HealthManager:Damage(parent, Heal, character)
            end
            
            task.wait()
        end
    end)

    task.delay(lifeTime, function()
        if hitDetect then
            task.cancel(hitDetect)
        end
    end)

    VisualEffectServer:SpawnEffectsInRange(
        "SoulSlice",
        nil,
        character,
        {},
        1000
    )

    Stats:SetAttribute("AbilityLocked", false)
end

return SoulSlice