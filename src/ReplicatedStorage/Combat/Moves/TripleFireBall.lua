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

    local function hitBoxCallBack(Hitbox, alreadyHit)
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
            if classData.MoveData[moveType].Burn then
                StateManager:AddTarget(parent, "Burn", 3)
            end

            --apply stun
            if classData.MoveData[moveType].Stunned then
                StateManager:AddTarget(parent, "Stunned", 2)
            end

            StateManager:AddTarget(parent, "Attacked", 1)

            HealthManager:Damage(parent, damage)
        end
    end

    for i=1, numProjectiles do
        local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
        Hitbox.Transparency = 1
        if ShowHitboxes then
            Hitbox.Transparency = .5
        end

        Hitbox.Size = classData.Hitboxes[moveType].Size
        Hitbox.CFrame = rootPart.CFrame * offSet * CFrame.fromEulerAnglesXYZ(0, math.rad(angle), 0)
        Hitbox.Anchored = true
        Hitbox.Parent = IgnoreFolder

        local projectileData = {
            projectile = Hitbox,
            speed = 75,
            duration = .5,
            currTime = 0,
            damage = damage,
            callBack = hitBoxCallBack,
            alreadyHit = {}
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

            TripleFireBall.projectiles[playerId] = nil

            continue
        end
        
        projectileData.projectile.CFrame *= CFrame.new(0, 0, -projectileData.speed * deltaTime)

        projectileData.callBack(projectileData.projectile, projectileData.alreadyHit)
    end
end

return TripleFireBall