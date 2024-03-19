local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))
local VisualEffectServer = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("VisualEffectServer"))

local IgnoreFolder = workspace.Ignore

local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

local HitboxManager = {}
HitboxManager.projectiles = {}

local function predictPosition(part: BasePart, timeInterval)
    return part.Position + part.AssemblyLinearVelocity * timeInterval
end

function HitboxManager:HitboxDebugger(character, isStun, isBurn, isSlow)
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

    local touched = Hitbox.Touched:Connect(function() end)
    local touchedObjects = Hitbox:GetTouchingParts()

    if touched then
        touched:Disconnect()
    end

    local alreadyHit = {}
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

        alreadyHit[parent.Name] = true

        local isBlocking = StateManager:CheckState(parent, "Blocking")
        if isBlocking then
            --Block Indication
            warn("block m1s")
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

        StateManager:AddTarget(parent, "Attacked", 1)

        HealthManager:Damage(parent, damage)
    end
end

function HitboxManager:HitboxCreateMove(player, class, moveType, moveCount)
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

    local placementCFrame = character:GetPivot() * currentClassData.Hitboxes[moveType].Offset

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = currentClassData.Hitboxes[moveType].Size
    Hitbox.CFrame = placementCFrame
    Hitbox.Parent = IgnoreFolder
    Debris:AddItem(Hitbox, .25)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    local touched = Hitbox.Touched:Connect(function() end)
    local touchedObjects = Hitbox:GetTouchingParts()

    if touched then
        touched:Disconnect()
    end

    local alreadyHit = {}
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

        local Stats = parent:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        local isUserStun = StateManager:CheckState(character, "Stunned")
        if isUserStun then
            return
        end

        alreadyHit[parent.Name] = true

        local isBlocking = StateManager:CheckState(parent, "Blocking")
        if isBlocking then
            --Block Indication
            warn("block m1s")
            continue
        end

        --apply burn
        if currentClassData.MoveData[moveType].Burn then
            StateManager:AddTarget(parent, "Burn", 3)
        end

        --apply stun
        if currentClassData.MoveData[moveType].Stunned then
            StateManager:AddTarget(parent, "Stunned", 2)
        end

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

        HealthManager:Damage(parent, damage)
    end
end

function HitboxManager:HitboxProjectile(player, class, moveType, moveCount)
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

    local damage = 1
    if not moveCount then
        damage = currentClassData.DamageList[moveType]
    else
        damage = currentClassData.DamageList[moveType][moveCount]
    end

    local placementCFrame = character:GetPivot() * currentClassData.Hitboxes[moveType].Offset

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    local position = predictPosition(rootPart, 0.1)

    Hitbox.Size = currentClassData.Hitboxes[moveType].Size
    --Hitbox.CFrame = rootPart.CFrame * currentClassData.Hitboxes[moveType].Offset + position
    Hitbox.CFrame = CFrame.new(position, rootPart.CFrame.LookVector + position)
    Hitbox.Anchored = true
    Hitbox.Parent = IgnoreFolder

    local function hitBoxCallBack(alreadyHit, projectileData)
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

            --threshhold for projectile hit detection
            local distance = (enemyRoot.Position - Hitbox.Position).Magnitude
            if distance > Hitbox.Size.Z * .5 then
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

            alreadyHit[parent.Name] = true
            task.delay(.25, function()
                alreadyHit[parent.Name] = nil
            end)

            local isBlocking = StateManager:CheckState(parent, "Blocking")
            if isBlocking then
                --Block Indication
                warn("block m1s")
                continue
            end

            --apply burn
            if currentClassData.MoveData[moveType].Burn then
                StateManager:AddTarget(parent, "Burn", 3)
            end

            --apply stun
            if currentClassData.MoveData[moveType].Stunned then
                StateManager:AddTarget(parent, "Stunned", 2)
            end

            StateManager:AddTarget(parent, "Attacked", 1)

            HealthManager:Damage(parent, damage)

            local conditionalData = {}
            conditionalData.spawnCFrame = enemyRoot.CFrame

            VisualEffectServer:TerminateVFX(
                currentClassData.VisualEffects[moveType],
                parent,
                character,
                conditionalData,
                projectileData.VisualID
            )

            return true
        end
    end

    local VisualID = character.Name.." "..HttpService:GenerateGUID(false)

    local conditionalData = {
        moveCount = moveCount, 
        projectile = Hitbox,
    }

    VisualEffectServer:SpawnEffectsInRange(
        currentClassData.VisualEffects[moveType],
        nil,
        character,
        conditionalData,
        nil,
        VisualID
    )

    local projectileData = {
        projectile = Hitbox,
        speed = 50,
        duration = 2,
        currTime = 0,
        damage = damage,
        callBack = hitBoxCallBack,
        alreadyHit = {},
        VisualID = VisualID
    }

    local projectileId = player.Name..HttpService:GenerateGUID(false)

    HitboxManager.projectiles[projectileId] = projectileData
end

local function HitboxCreateMove(player, class, moveType, moveCount, moveData)
    if moveData.isProjectile then
        HitboxManager:HitboxProjectile(player, class, moveType, moveCount)
    elseif moveData.isAOE then
        warn("AOE")
    else
        HitboxManager:HitboxCreateMove(player, class, moveType, moveCount)
    end
end

function HitboxManager:Update(deltaTime)
    ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    for playerId, projectileData in pairs(HitboxManager.projectiles) do
        if not projectileData.projectile then
            continue
        end
        
        projectileData.currTime += deltaTime
        if projectileData.currTime >= projectileData.duration then
            if projectileData.projectile then
                projectileData.projectile:Destroy()
            end

            HitboxManager.projectiles[playerId] = nil

            continue
        end
        
        projectileData.projectile.CFrame *= CFrame.new(0, 0, -projectileData.speed * deltaTime)

        local hasTarget = projectileData.callBack(projectileData.alreadyHit, projectileData)
        if hasTarget then
            task.delay(.1, function()
                if projectileData.projectile then
                    projectileData.projectile:Destroy()
                end

                HitboxManager.projectiles[playerId] = nil
            end)

            continue
        end
    end
end

Events.Client_Server.Hitbox.OnServerEvent:Connect(HitboxCreateMove)

return HitboxManager