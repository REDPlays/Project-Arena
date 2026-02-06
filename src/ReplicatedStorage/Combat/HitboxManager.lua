local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager
local HealthManager
local PassiveManager
local VisualEffectServer = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("VisualEffectServer"))

local CombatFiles = ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat")
local PassiveFiles = CombatFiles:WaitForChild("Passives")
local StatusFiles = CombatFiles:WaitForChild("States")

local IgnoreFolder = workspace.Ignore

local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

if RunService:IsServer() then
    StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
    HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))
    PassiveManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("PassiveManager"))
end

local HitboxManager = {}
HitboxManager.projectiles = {}

function HitboxManager:CheckModifiers(moveData: {}, moveDataDurations: {}, target: Model, attacker: Model)
    for mod, enabled in pairs(moveData) do
        if enabled then
            local isStatus = StatusFiles:FindFirstChild(mod)
            local isPassive = PassiveFiles:FindFirstChild(mod)

            if isStatus then
                StateManager:AddTarget(
                    target, 
                    mod, 
                    moveDataDurations[mod] or 1
                )
            end

            if isPassive then
                if mod == "HydroStack" then
                    PassiveManager:AddStack(attacker, mod, {})
                end
            end
        end
    end
end

function HitboxManager:HitboxDebugger(character, isStun, isBurn, isSlow, isKnockup, isSilenced)
    local currentClassData = ClassData["Base"]
    if not currentClassData then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local damage = 2
    if character.Name == "DummyAttacker" then
        damage = 10
    end

    local placementCFrame = character:GetPivot() * currentClassData.Hitboxes["LMBMove"].Offset

    local hitboxLifeTime = .5

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = currentClassData.Hitboxes["LMBMove"].Size
    Hitbox.CFrame = placementCFrame
    Hitbox.Parent = IgnoreFolder
    Debris:AddItem(Hitbox, .25)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    local alreadyHit = {}

    local hitDetect = coroutine.create(function()
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
                if CollectionService:HasTag(parent, "Ignore") or CollectionService:HasTag(parent, "Dummies") then
                    continue
                end

                if CollectionService:HasTag(parent, "Invulnerable") then
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

                local Stats = parent:FindFirstChild("Stats")
                if not Stats then
                    continue
                end

                local isUserStun = StateManager:CheckState(character, "Stunned")
                if isUserStun then
                    return
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

                if isStun then
                    StateManager:AddTarget(parent, "Stunned", 1)
                end

                if isBurn then
                    StateManager:AddTarget(parent, "Burn", 3)
                end

                if isSlow then
                    StateManager:AddTarget(parent, "Slow", 2)
                end

                if isKnockup then
                    StateManager:AddTarget(parent, "Knockup", 50)
                end

                if isSilenced then
                    StateManager:AddTarget(parent, "Silenced", 2)
                end

                StateManager:AddTarget(parent, "Attacked", 1)

                HealthManager:Damage(parent, damage, character)
            end

            task.wait()
        end
    end)

    coroutine.resume(hitDetect)

    task.delay(hitboxLifeTime, function()
        if hitDetect then
            coroutine.close(hitDetect)
        end
    end)
end

function HitboxManager:HitboxCreateMove(player, class, moveType, moveCount, conditionalData)
    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class then
        warn("Wrong Class Equipped")
        return
    end

    local currentClassData = ClassData[class]
    if not currentClassData then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local isAwakened = Stats:GetAttribute("Awakened")

    local damage = 1
    if not moveCount then
        damage = currentClassData.DamageList[moveType]
    else
        damage = currentClassData.DamageList[moveType][moveCount]
    end

    local VisualID = character.Name.." "..HttpService:GenerateGUID(false)

    VisualEffectServer:SpawnEffectsInRange(
        currentClassData.VisualEffects[moveType],
        nil,
        character,
        {moveCount = moveCount},
        nil,
        VisualID
    )
    
    local Offset
    local HitboxSize

    if not isAwakened then
        Offset = currentClassData.Hitboxes[moveType].Offset
        HitboxSize = currentClassData.Hitboxes[moveType].Size
    elseif isAwakened then
        if currentClassData.Hitboxes[moveType].Offset2 then
            Offset = currentClassData.Hitboxes[moveType].Offset2
        else
            Offset = currentClassData.Hitboxes[moveType].Offset
        end

        if currentClassData.Hitboxes[moveType].Size2 then
            HitboxSize = currentClassData.Hitboxes[moveType].Size2
        else
            HitboxSize = currentClassData.Hitboxes[moveType].Size
        end
    end

    if typeof(Offset) == "table" then
        Offset = Offset[moveCount]
    end

    local placementCFrame = character:GetPivot() * Offset

    local hitboxLifeTime = .5

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = HitboxSize
    Hitbox.CFrame = placementCFrame
    Hitbox.Parent = IgnoreFolder
    Debris:AddItem(Hitbox, hitboxLifeTime)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    local alreadyHit = {}

    local hitDetect = coroutine.create(function()
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
        
                local enemyRoot = parent:FindFirstChild("HumanoidRootPart")
                if not enemyRoot then
                    continue
                end
        
                if alreadyHit[parent.Name] then
                    continue
                end
        
                local enemyStats = parent:FindFirstChild("Stats")
                if not enemyStats then
                    continue
                end
        
                local isUserStun = StateManager:CheckState(character, "Stunned")
                if isUserStun then
                    return
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
                HitboxManager:CheckModifiers(
                    currentClassData.MoveData[moveType],
                    currentClassData.MoveDataDurations[moveType],
                    parent, 
                    character
                )
        
                VisualEffectServer:SpawnEffectsInRange(
                    currentClassData.VisualEffects[moveType],
                    parent,
                    character,
                    {moveCount = moveCount, isHit = true},
                    nil,
                    VisualID,
                    true
                )
        
                StateManager:AddTarget(parent, "Attacked", 1)
        
                HealthManager:Damage(parent, damage, character)
            end

            task.wait()
        end
    end)

    coroutine.resume(hitDetect)

    task.delay(hitboxLifeTime, function()
        if hitDetect then
            coroutine.close(hitDetect)
        end
    end)
end

function HitboxManager:HitboxProjectile(player, class, moveType, moveCount, offSet, conditionalData)
    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class then
        warn("Wrong Class Equipped")
        return
    end

    local currentClassData = ClassData[class]
    if not currentClassData then
        return
    end

    local character = nil
    if player:IsA("Model") then
        character = player
    else
        character = player.Character
    end
    if not character then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    conditionalData = conditionalData or {}

    local projectileId = player.Name..HttpService:GenerateGUID(false)

    local projectileData = {
        ID = projectileId,
        character = character,
        speed = currentClassData.ProjectileSpeed or 50,
        duration = currentClassData.ProjectileDuration or 1,
        classData = currentClassData,
        moveType = moveType,
        moveCount = moveCount,
        offSet = offSet,
        conditionalData = conditionalData
    }

    HitboxManager.projectiles[projectileId] = projectileData

    Events.Server_Client.Hitbox:FireAllClients(projectileData)
end

local function HitboxCreateMove(player, class, moveType, moveCount, moveData, conditionalData)
    if moveData.isProjectile then
        if not moveData.isMultiShot then
            HitboxManager:HitboxProjectile(player, class, moveType, moveCount, conditionalData)
        elseif moveData.isMultiShot then
            --default ammo
            local ammo = 1

            local currentClassData = ClassData[class]
            if currentClassData then
                ammo = currentClassData.Ammo
            end

            for i=1, ammo do
                HitboxManager:HitboxProjectile(player, class, moveType, moveCount, conditionalData)
                task.wait(currentClassData.ShotDelay)
            end
        end
    elseif moveData.isAOE then
        warn("AOE")
    else
        HitboxManager:HitboxCreateMove(player, class, moveType, moveCount, conditionalData)
    end
end

local function ProjectileHitboxTarget(player, target, classData, moveType, moveCount, projectileId)
    if not HitboxManager.projectiles[projectileId] then
        return
    end

    if not target then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    if character ~= HitboxManager.projectiles[projectileId].character then
        return
    end

    local damage = 1
    if not moveCount then
        damage = classData.DamageList[moveType]
    else
        damage = classData.DamageList[moveType][moveCount]
    end

    local Stats = target:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local isUserStun = StateManager:CheckState(character, "Stunned")
    if isUserStun then
        return
    end

    if CollectionService:HasTag(target, "Invulnerable") then
        return
    end

    local isBlocking = StateManager:CheckState(target, "Blocking")
    if isBlocking then
        --Block Indication
        HealthManager:Block(target, damage, character)
        return
    end

    local myTeam = character:GetAttribute("Team")
    local theirTeam = target:GetAttribute("Team")

    if (myTeam and theirTeam) and myTeam == theirTeam then
        return
    end

    --check modifiers
    HitboxManager:CheckModifiers(
        classData.MoveData[moveType],
        classData.MoveDataDurations[moveType],
        target, 
        character
    )

    StateManager:AddTarget(target, "Attacked", 1)

    HealthManager:Damage(target, damage, character)
end

local function HitboxProjectile(player, class, moveType, moveCount, offSet, conditionalData)
    HitboxManager:HitboxProjectile(player, class, moveType, moveCount, offSet, conditionalData)
end

function HitboxManager:Update(deltaTime)
    ShowHitboxes = workspace:GetAttribute("ShowHitboxes")
end

Events.Client_Server.Hitbox.OnServerEvent:Connect(HitboxCreateMove)
Events.Client_Server.ProjectileTarget.OnServerEvent:Connect(ProjectileHitboxTarget)
Events.Server_Server.Hitbox.Event:Connect(HitboxProjectile)

return HitboxManager