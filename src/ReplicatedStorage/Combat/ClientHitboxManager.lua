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
local VisualEffectClient = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("VisualEffectClient"))

local IgnoreFolder = workspace.Ignore

local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

local ClientHitboxManager = {}
ClientHitboxManager.projectiles = {}

local function predictPosition(part: BasePart, timeInterval)
    return part.Position + part.AssemblyLinearVelocity * timeInterval
end

function ClientHitboxManager:HitboxProjectile(projectileData)
    local rootPart = projectileData.character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local damage = 1
    if not projectileData.moveCount then
        damage = projectileData.classData.DamageList[projectileData.moveType]
    else
        damage = projectileData.classData.DamageList[projectileData.moveType][projectileData.moveCount]
    end

    local placementCFrame = projectileData.character:GetPivot() * projectileData.classData.Hitboxes[projectileData.moveType].Offset

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    local position = predictPosition(rootPart, 0.1)

    Hitbox.Size = projectileData.classData.Hitboxes[projectileData.moveType].Size
    Hitbox.CFrame = CFrame.new(position, rootPart.CFrame.LookVector + position)
    Hitbox.Anchored = true
    Hitbox.Parent = IgnoreFolder

    local function hitBoxCallBack(HBprojectileData)
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

            if parent == projectileData.character then
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

            if target then
                continue
            end

            target = parent

            --fire to server for target hit
            Events.Client_Server.ProjectileTarget:FireServer(
                target, 
                projectileData.classData, 
                projectileData.moveType, 
                projectileData.moveCount,
                projectileData.ID
            )

            local conditionalData = {}
            conditionalData.spawnCFrame = enemyRoot.CFrame

            VisualEffectClient:TerminateVFX(
                projectileData.classData.VisualEffects[projectileData.moveType],
                target,
                projectileData.character,
                conditionalData,
                HBprojectileData.VisualID
            )

            return true
        end
    end

    local VisualID = projectileData.character.Name.." "..HttpService:GenerateGUID(false)

    local conditionalData = {
        moveCount = projectileData.moveCount, 
        projectile = Hitbox,
    }

    VisualEffectClient:SpawnEffects(
        projectileData.classData.VisualEffects[projectileData.moveType],
        nil,
        projectileData.character,
        conditionalData,
        VisualID
    )

    local HBprojectileData = {
        projectile = Hitbox,
        speed = 50,
        duration = 2,
        currTime = 0,
        damage = damage,
        callBack = hitBoxCallBack,
        alreadyHit = {},
        VisualID = VisualID
    }

    ClientHitboxManager.projectiles[projectileData.ID] = HBprojectileData
end

local function HitboxProjectile(projectileData)
    ClientHitboxManager:HitboxProjectile(projectileData)
end

function ClientHitboxManager:Update(deltaTime)
    ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    for playerId, projectileData in pairs(ClientHitboxManager.projectiles) do
        if not projectileData.projectile then
            continue
        end
        
        projectileData.currTime += deltaTime
        if projectileData.currTime >= projectileData.duration then
            if projectileData.projectile then
                projectileData.projectile:Destroy()
            end

            ClientHitboxManager.projectiles[playerId] = nil

            continue
        end
        
        projectileData.projectile.CFrame *= CFrame.new(0, 0, -projectileData.speed * deltaTime)

        local hasTarget = projectileData.callBack(projectileData)
        if hasTarget then
            if projectileData.projectile then
                projectileData.projectile:Destroy()
            end

            ClientHitboxManager.projectiles[playerId] = nil
            
            continue
        end
    end
end

Events.Server_Client.Hitbox.OnClientEvent:Connect(HitboxProjectile)

return ClientHitboxManager