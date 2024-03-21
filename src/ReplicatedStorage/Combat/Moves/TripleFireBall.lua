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

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local TripleFireBall = {}
TripleFireBall.projectiles = {}

local function predictPosition(part: BasePart, timeInterval)
    return part.Position + part.AssemblyLinearVelocity * timeInterval
end

function TripleFireBall:Activate(character, rootPart, placementCFrame, classData, moveType)
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

    local angle = -15
    local angleDiff = 15
    local numProjectiles = 3

    local offSet = classData.Hitboxes[moveType].Offset

    local function hitBoxCallBack(Hitbox)
        local target = nil

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

            if target then
                continue
            end

            local isUserStun = StateManager:CheckState(character, "Stunned")
            if isUserStun then
                return
            end

            target = parent

            local isBlocking = StateManager:CheckState(parent, "Blocking")
            if isBlocking then
                --Block Indication
                warn("block m1s")
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

            StateManager:AddTarget(parent, "Attacked", 1)

            HealthManager:Damage(parent, damage)

            return true
        end
    end

    for i=1, numProjectiles do
        local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
        Hitbox.Transparency = 1
        if ShowHitboxes then
            Hitbox.Transparency = .5
        end

        local position = predictPosition(rootPart, 0.1)

        Hitbox.Size = classData.Hitboxes[moveType].Size
        Hitbox.CFrame = CFrame.new(position, rootPart.CFrame.LookVector + position) * offSet * CFrame.fromEulerAnglesXYZ(0, math.rad(angle), 0)
        Hitbox.Anchored = true
        Hitbox.Parent = IgnoreFolder

        local VisualID = character.Name.." "..HttpService:GenerateGUID(false)

        local conditionalData = {
            projectile = Hitbox
        }

        VisualEffectServer:SpawnEffectsInRange(
            classData.VisualEffects[moveType],
            nil,
            character,
            conditionalData,
            1000,
            VisualID
        )

        local projectileData = {
            classData = classData,
            sourceUnit = character,
            moveType = moveType,
            projectile = Hitbox,
            speed = 75,
            duration = 1,
            currTime = 0,
            damage = damage,
            callBack = hitBoxCallBack,
            alreadyHit = {},
            VisualID = VisualID
        }

        local projectileId = character.Name..HttpService:GenerateGUID(false)

        TripleFireBall.projectiles[projectileId] = projectileData

        angle += angleDiff
    end
end

function TripleFireBall:Update(deltaTime)
    for playerId, projectileData in pairs(TripleFireBall.projectiles) do
        if not projectileData.projectile then
            continue
        end
        
        projectileData.currTime += deltaTime
        if projectileData.currTime >= projectileData.duration then
            if projectileData.projectile then
                projectileData.projectile:Destroy()
            end

            local conditionalData = {}
            conditionalData.spawnCFrame = projectileData.projectile.CFrame

            VisualEffectServer:TerminateVFX(
                projectileData.classData.VisualEffects[projectileData.moveType],
                nil,
                projectileData.sourceUnit,
                conditionalData,
                projectileData.VisualID
            )

            TripleFireBall.projectiles[playerId] = nil

            continue
        end
        
        projectileData.projectile.CFrame *= CFrame.new(0, 0, -projectileData.speed * deltaTime)

        local hasTarget = projectileData.callBack(projectileData.projectile)
        if hasTarget then
            if projectileData.projectile then
                projectileData.projectile:Destroy()
            end

            TripleFireBall.projectiles[playerId] = nil

            continue
        end
    end
end

return TripleFireBall