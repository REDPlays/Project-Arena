local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local ExplosiveArrow = {}

function ExplosiveArrow:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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
   
    local _delay = 1
    local duration = 0.5
    local speed = 100
    local hasExploded = false

    Stats:SetAttribute("AbilityLocked", true)
    task.delay(_delay, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    local startCFrame = rootPart.CFrame * CFrame.new(0, 2, -3)

    local VFX_ID = "PiercingArrow"..HttpService:GenerateGUID(false)

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.CFrame = startCFrame
    Hitbox.Anchored = true
    Hitbox.Parent = IgnoreFolder

    VisualEffectServer:SpawnEffectsInRange(
        "ExplosiveArrow",
        nil,
        character,
        {hitbox  = Hitbox},
        1000,
        VFX_ID
    )

    local function explodeHitDetection(currentHitbox)
        local touched = currentHitbox.Touched:Connect(function() end)
        local touchedObjects = currentHitbox:GetTouchingParts()

        if touched then
            touched:Disconnect()
        end

        local alreadyHit2 = {}

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
            
            local enemyRoot = parent:FindFirstChild("HumanoidRootPart")
            if not enemyRoot then
                continue
            end
            
            if alreadyHit2[parent.Name] then
                continue
            end
            
            if CollectionService:HasTag(parent, "Invulnerable") then
                continue
            end

            alreadyHit2[parent.Name] = true
            
            local isBlocking = StateManager:CheckState(parent, "Blocking")
            if isBlocking then
                --Block Indication
                HealthManager:Block(parent, damage, character)
                continue
            end
            
            --apply burn
            if classData.MoveData[moveType].Burn then
                StateManager:AddTarget(parent, "Burn", 3)
            end

            --apply stun
            if classData.MoveData[moveType].Stunned then
                StateManager:AddTarget(parent, "Stunned", 2)
            end

            --apply slow
            if classData.MoveData[moveType].Slow then
                StateManager:AddTarget(parent, "Slow", 2)
            end

            --apply knockup
            if classData.MoveData[moveType].Knockup then
                StateManager:AddTarget(parent, "Knockup", 50)
            end

            --apply silence
            if classData.MoveData[moveType].Silenced then
                StateManager:AddTarget(parent, "Silenced", 2)
            end

            StateManager:AddTarget(parent, "Attacked", 2)

            HealthManager:Damage(parent, damage, character)
        end
    end

    local function TriggerExplosion()
        if hasExploded then
            return
        end

        hasExploded = true

        local Hitbox2: BasePart = Hitboxes.CircleHitbox:Clone()
        Hitbox2.Transparency = 1
        if ShowHitboxes then
            Hitbox2.Transparency = .5
        end

        Hitbox2.Size = classData.Hitboxes[moveType].Size2 
        Hitbox2.CFrame = Hitbox.CFrame
        Hitbox2.Anchored = true
        Hitbox2.Parent = IgnoreFolder

        VisualEffectServer:TerminateVFX(
            "ExplosiveArrow",
            nil,
            character,
            {spawnCFrame = Hitbox2.CFrame},
            VFX_ID
        )

        explodeHitDetection(Hitbox2)

        Debris:AddItem(Hitbox2, 1)
    end

    local alreadyHit = {}
    local function hitDetection()
        local touched = Hitbox.Touched:Connect(function() end)
        local touchedObjects = Hitbox:GetTouchingParts()

        if touched then
            touched:Disconnect()
        end

        for i=1, #touchedObjects do
            local object = touchedObjects[i]
            local parent = object.Parent

            if parent == workspace.Obstacles then
                TriggerExplosion()
                break
            end
            
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
            
            local enemyRoot = parent:FindFirstChild("HumanoidRootPart")
            if not enemyRoot then
                continue
            end
            
            if alreadyHit[parent.Name] then
                continue
            end
            
            if CollectionService:HasTag(parent, "Invulnerable") then
                continue
            end

            alreadyHit[parent.Name] = true
            
            local isBlocking = StateManager:CheckState(parent, "Blocking")
            if isBlocking then
                --Block Indication
                HealthManager:Block(parent, damage, character)

                TriggerExplosion()
                
                continue
            end
            
            --apply burn
            if classData.MoveData[moveType].Burn then
                StateManager:AddTarget(parent, "Burn", 3)
            end

            --apply stun
            if classData.MoveData[moveType].Stunned then
                StateManager:AddTarget(parent, "Stunned", 2)
            end

            --apply slow
            if classData.MoveData[moveType].Slow then
                StateManager:AddTarget(parent, "Slow", 2)
            end

            --apply knockup
            if classData.MoveData[moveType].Knockup then
                StateManager:AddTarget(parent, "Knockup", 50)
            end

            --apply silence
            if classData.MoveData[moveType].Silenced then
                StateManager:AddTarget(parent, "Silenced", 2)
            end

            StateManager:AddTarget(parent, "Attacked", 2)

            HealthManager:Damage(parent, damage, character)

            TriggerExplosion()

            break
        end
    end

    local function movement(dt)
        Hitbox.CFrame *= CFrame.new(0, 0, -speed * dt)
    end

    local thread = coroutine.create(function()
        while true do
            local dt = task.wait()

            if hasExploded then
                break
            end

            hitDetection()

            movement(dt)
        end
    end)

    task.delay(duration, function()
        if thread then
            task.cancel(thread)
        end



        TriggerExplosion()

        Debris:AddItem(Hitbox, 1)
    end)

    coroutine.resume(thread)
end

return ExplosiveArrow