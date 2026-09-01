local Players = game:GetService("Players")
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
local CharacterMoveLibrary = require(ReplicatedStorage.RepFiles.Player.CharacterMoveLibrary)

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

local ReflectionWhiteList = {
    ["Triple Fire Ball"] = true,
    ["Turret"] = true,
}

local HitboxManager = {}
HitboxManager.projectiles = {}

local function predictPosition(part: BasePart, timeInterval)
    return part.Position + part.AssemblyLinearVelocity * timeInterval
end

function HitboxManager:CheckModifiers(moveData: {}, moveDataDurations: {}, target: Model, attacker: Model, additionalData: {})
    for mod, enabled in pairs(moveData) do
        if enabled then
            local isStatus = StatusFiles:FindFirstChild(mod)
            local isPassive = PassiveFiles:FindFirstChild(mod)

            if isStatus then
                if mod == "LifeSteal" then
                    local modAdditional = additionalData and additionalData[mod] or {}
                    modAdditional.target = target

                    StateManager:AddTarget(
                        attacker,
                        mod,
                        moveDataDurations[mod],
                        modAdditional
                    )
                else
                    StateManager:AddTarget(
                        target, 
                        mod, 
                        moveDataDurations[mod] or 1,
                        additionalData
                    )
                end
            end

            if isPassive then
                --can check if the mod is stackable?
                if mod == "HydroStack" then
                    PassiveManager:AddStack(attacker, mod, {})
                end
            end
        end
    end
end

function HitboxManager:CheckReflecting(attacker: Model, target: Model, attackerClass, moveType: string, currentMove: string, moveCount: number, alreadyReflected: boolean)
    local canReflect = false

    if alreadyReflected then
        return canReflect
    end

    if not StateManager:CheckState(target, "Reflecting") then
        return canReflect
    end

    local attackerRoot = attacker:FindFirstChild("HumanoidRootPart")
    if not attackerRoot then return end

    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    if attackerClass.MoveData[currentMove].isProjectile and (moveType == "LMBMove" or ReflectionWhiteList[currentMove]) then
        canReflect = true

        local attackerCFrame = attackerRoot.CFrame
        local targetCFrame = targetRoot.CFrame
        local direction: Vector3 = (predictPosition(attackerRoot, 0.25) - targetCFrame.Position).Unit

        local reflectCFrame = CFrame.new(targetRoot.Position, targetRoot.Position + direction)

        HitboxManager:HitboxProjectile(target, attackerClass.ClassName, moveType, moveCount, nil, {
            reflecting = true,
            spawnCFrame = reflectCFrame,
            currentMove = currentMove,
        })
    else
        canReflect = true
    end

    return canReflect
end

function HitboxManager:HitboxCreateMove(player: Player | Model, class, moveType, moveCount, conditionalData, ignoreList)
    conditionalData = conditionalData or {}
    conditionalData.conditionalData = conditionalData.conditionalData or {}

    ignoreList = ignoreList or {}

    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class and not conditionalData.reflecting then
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
        player = Players:GetPlayerFromCharacter(character) or character

        if conditionalData.isCompanion then
            player = conditionalData.player
        end
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

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    if not CharacterMoveLibrary.Movesets[player] then
        return
    end

    local currentMove: string = CharacterMoveLibrary.Movesets[player][moveType]
    if not currentMove then
        return
    end

    local isAwakened = Stats:GetAttribute("Awakened")

    local damage = 1
    if not moveCount then
        damage = currentClassData.DamageList[currentMove]

        Stats:SetAttribute("M1", 0)
    else
        damage = currentClassData.DamageList[currentMove][moveCount]

        Stats:SetAttribute("M1", moveCount)
    end

    local damageBoost = Stats:GetAttribute("DamageBoost")
    if damageBoost then
        damage = damage * damageBoost
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
        Offset = currentClassData.Hitboxes[currentMove].Offset
        HitboxSize = currentClassData.Hitboxes[currentMove].Size
    elseif isAwakened then
        if currentClassData.Hitboxes[currentMove].Offset2 then
            Offset = currentClassData.Hitboxes[currentMove].Offset2
        else
            Offset = currentClassData.Hitboxes[currentMove].Offset
        end

        if currentClassData.Hitboxes[currentMove].Size2 then
            HitboxSize = currentClassData.Hitboxes[currentMove].Size2
        else
            HitboxSize = currentClassData.Hitboxes[currentMove].Size
        end
    end

    if typeof(Offset) == "table" then
        Offset = Offset[moveCount]
    end

    local placementCFrame = character:GetPivot() * Offset

    local hitboxLifeTime = .35

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

                --ignore Targets in IgnoreList
                if table.find(ignoreList, parent) then
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

                local isReflecting = HitboxManager:CheckReflecting(character, parent, currentClassData, moveType, currentMove, moveCount, conditionalData.conditionalData.reflecting)
                if isReflecting and not conditionalData.reflecting then
                    break
                end

                --check modifiers
                HitboxManager:CheckModifiers(
                    currentClassData.MoveData[currentMove],
                    currentClassData.MoveDataDurations[currentMove],
                    parent, 
                    character,
                    currentClassData.MoveDataAdditional and currentClassData.MoveDataAdditional[currentMove]
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

function HitboxManager:HitboxProjectile(player: Player | Model, class, moveType, moveCount, offSet, conditionalData, ignoreList)
    conditionalData = conditionalData or {}

    ignoreList = ignoreList or {}

    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class and not conditionalData.reflecting then
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
        player = Players:GetPlayerFromCharacter(character) or character
    else
        character = player.Character
    end

    if player:IsA("Model") then
        return
    end

    if not character then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    if not CharacterMoveLibrary.Movesets[player] then
        return
    end

    local currentMove: string = CharacterMoveLibrary.Movesets[player][moveType]
    if not currentMove then
        return
    end

    if conditionalData.reflecting then
        currentMove = conditionalData.currentMove or currentMove
    end

    local projectileId = player.Name..HttpService:GenerateGUID(false)

    local projectileData = {
        player = player,
        ID = projectileId,
        character = character,
        speed = currentClassData.ProjectileSpeed or 50,
        duration = currentClassData.ProjectileDuration or 1,
        classData = currentClassData,
        moveType = moveType,
        currentMove = currentMove,
        moveCount = moveCount,
        offSet = offSet,
        conditionalData = conditionalData,
        ignoreList = ignoreList,
    }

    HitboxManager.projectiles[projectileId] = projectileData

    Events.Server_Client.Hitbox:FireAllClients(projectileData)
end

local function HitboxCreateMove(player, class, moveType, moveCount, moveData, conditionalData)
    if moveData.isProjectile and moveType == "LMBMove" then
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
    else
        HitboxManager:HitboxCreateMove(player, class, moveType, moveCount, conditionalData)
    end
end

local function ProjectileHitboxTarget(player, target, classData, moveType, currentMove, moveCount, projectileId, projectileData)
    if not HitboxManager.projectiles[projectileId] then
        return
    end
    
    if not target then
        return
    end

    local character = player.Character == target and projectileData.character or player.Character
    if not character then
        return
    end

    --ignore Targets in IgnoreList
    if table.find(projectileData.ignoreList, target) then
        return
    end
    
    if character ~= HitboxManager.projectiles[projectileId].character then
        return
    end
    
    local damage = 1
    if not moveCount then
        damage = classData.DamageList[currentMove]
    else
        damage = classData.DamageList[currentMove][moveCount]
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

    local damageBoost = Stats:GetAttribute("DamageBoost")
    if damageBoost then
        damage = damage * damageBoost
    end
    
    local isBlocking = StateManager:CheckState(target, "Blocking")
    if isBlocking then
        --Block Indication
        HealthManager:Block(target, damage, character)
        return
    end
    
    local isReflecting = HitboxManager:CheckReflecting(character, target, classData, moveType, currentMove, moveCount, projectileData.conditionalData.reflecting)
    if isReflecting and not projectileData.reflecting then
        return
    end

    local myTeam = character:GetAttribute("Team")
    local theirTeam = target:GetAttribute("Team")

    if (myTeam and theirTeam) and myTeam == theirTeam then
        return
    end

    --check modifiers
    HitboxManager:CheckModifiers(
        classData.MoveData[currentMove],
        classData.MoveDataDurations[currentMove],
        target, 
        character,
        classData.MoveDataAdditional and classData.MoveDataAdditional[currentMove]
    )

    StateManager:AddTarget(target, "Attacked", 1)

    HealthManager:Damage(target, damage, character)
end

local function HitboxProjectile(player, class, moveType, moveCount, offSet, conditionalData)
    HitboxManager:HitboxProjectile(player, class, moveType, moveCount, offSet, conditionalData)
end

function HitboxManager:Update(deltaTime: number)
    ShowHitboxes = workspace:GetAttribute("ShowHitboxes")
end

Events.Client_Server.Hitbox.OnServerEvent:Connect(HitboxCreateMove)
Events.Client_Server.ProjectileTarget.OnServerEvent:Connect(ProjectileHitboxTarget)
Events.Server_Server.Hitbox.Event:Connect(HitboxProjectile)
Events.Server_Server.DummyHitbox.Event:Connect(HitboxCreateMove)

return HitboxManager