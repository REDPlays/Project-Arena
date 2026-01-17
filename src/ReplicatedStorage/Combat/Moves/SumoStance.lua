local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local SumoStance = {}

function SumoStance:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local VFX_ID = "SumoStance"..HttpService:GenerateGUID(false)

    VisualEffectServer:SpawnEffectsInRange(
        "SumoStance",
        nil,
        character,
        {},
        1000,
        VFX_ID
    )

    local isAwakened = Stats:GetAttribute("Awakened")

    local duration = 90/60

    StateManager:AddTarget(character, "Slow", duration, {WalkSpeed = 0})

    local function detectTarget(Hitbox, hitType, lifeTime)
        local alreadyHit = {}

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

                    local currentDamage

                    if hitType == 1 then
                        currentDamage = damage[2]

                        StateManager:AddTarget(parent, "Slow", 2)
                        StateManager:AddTarget(parent, "Knockup", 75)
                    elseif hitType == 2 then
                        currentDamage = damage[2]

                        local parentPlayer = Players:GetPlayerFromCharacter(parent)
                        if not parentPlayer then
                            enemyRoot:SetNetworkOwner(player)
                        end

                        StateManager:AddTarget(parent, "Slow", 2)
                        StateManager:AddTarget(parent, "Knockup", 75)
                    end

                    StateManager:AddTarget(parent, "Attacked", 2)
        
                    HealthManager:Damage(parent, currentDamage, character)
                end

                task.wait()
            end
        end)

        task.delay(lifeTime, function()
            if hitDetect then
                task.cancel(hitDetect)
            end

            if Hitbox then
                Hitbox:Destroy()
            end
        end)
    end

    task.delay(36/60, function()
        local Hitbox: BasePart = Hitboxes.CylinderHitbox:Clone()
        Hitbox.Transparency = 1
        if ShowHitboxes then
            Hitbox.Transparency = .5
        end
        Hitbox.Anchored = true
        Hitbox.Size = Vector3.new(8, 20, 20)
        Hitbox.CFrame = character:GetPivot() * CFrame.new(0, 4, 0) * CFrame.Angles(0, 0, math.rad(90))
        Hitbox.Parent = IgnoreFolder

        VisualEffectServer:SpawnEffectsInRange(
            "SumoStance",
            nil,
            character,
            {isStomp = true},
            1000,
            VFX_ID,
            true
        )

        local hitboxLifeTime = 0.15
        detectTarget(Hitbox, 1, hitboxLifeTime)
    end)

    task.delay(75/60, function()
        local Hitbox: BasePart = Hitboxes.CylinderHitbox:Clone()
        Hitbox.Transparency = 1
        if ShowHitboxes then
            Hitbox.Transparency = .5
        end
        Hitbox.Anchored = true
        Hitbox.Size = Vector3.new(8, 20, 20)
        Hitbox.CFrame = character:GetPivot() * CFrame.new(0, 4, 0) * CFrame.Angles(0, 0, math.rad(90))
        Hitbox.Parent = IgnoreFolder

        VisualEffectServer:SpawnEffectsInRange(
            "SumoStance",
            nil,
            character,
            {isStomp = true},
            1000,
            VFX_ID,
            true
        )

        local hitboxLifeTime = 0.15
        detectTarget(Hitbox, 2, hitboxLifeTime)
    end)

    task.delay(duration, function()
        Stats:SetAttribute("AbilityLocked", false)
        
        VisualEffectServer:TerminateVFX(
            "SumoStance",
            nil,
            character,
            {},
            VFX_ID
        )
    end)
end

return SumoStance