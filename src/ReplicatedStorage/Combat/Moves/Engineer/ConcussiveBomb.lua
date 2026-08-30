local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
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

local ConcussiveBomb = {}

local function quadratic(t, p0, p1, p2)
	return (1 - t) ^ 2 * p0 + 2 * (1 - t) * t * p1 + t ^ 2 * p2
end

local function predictPosition(part: BasePart, timeInterval)
    return part.Position + part.AssemblyLinearVelocity * timeInterval
end

function ConcussiveBomb:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local travelDistance = 24
    local speed = 48
    local travelTime = travelDistance/speed
    local targetHit = false

    local lifeTime = 6

    local size = classData.Hitboxes[moveType].Size
    local startCFrame = character:GetPivot() + Vector3.new(0, size.Y/4, 0)
    
    local Hitbox: BasePart = Hitboxes.CylinderHitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end
    Hitbox.Size = size
    Hitbox.Anchored = true
    Hitbox.CFrame = startCFrame * CFrame.Angles(0, 0, math.rad(90))
    Hitbox.Parent = IgnoreFolder

    local VFX_ID = "ConcussiveBomb"..HttpService:GenerateGUID(false)

    local primaryColor = player:GetAttribute("Primary")
    local secondaryColor = player:GetAttribute("Secondary")
    local energyColor = player:GetAttribute("Energy")

    VisualEffectServer:SpawnEffectsInRange(
        "ConcussiveBomb",
        nil,
        character,
        {hitbox = Hitbox, primaryColor = primaryColor, secondaryColor = secondaryColor, energyColor = energyColor},
        1000,
        VFX_ID
    )

    local thread = task.spawn(function()
        local currentTime = 0
        local stoppedMoving = false

        local rayparams = RaycastParams.new()
        local forwardCFrame = startCFrame

        local function AoeHitDetection()
            local characterList = {}
            for _, plr in pairs(Players:GetPlayers()) do
                local plrChar = plr.Character
                if not plrChar then
                    continue
                end
                table.insert(characterList, plrChar)
            end

            for _, dummy in pairs(workspace.Dummies:GetChildren()) do
                if dummy:IsA("Model") then
                    table.insert(characterList, dummy)
                end
            end

            local aoeCenterPos = Hitbox.Position - Vector3.new(0, size.X/2, 0)
            local aoeRange = 9 --half of vfx explosion hitbox
            local alreadyHit = {}

            VisualEffectServer:SpawnEffectsInRange(
                "ConcussiveBomb",
                nil,
                character,
                {action = "Trap", spawnPosition = aoeCenterPos},
                1000,
                VFX_ID,
                true
            )

            for _, entity: Model in pairs(characterList) do
                --ignoreTargets
                if CollectionService:HasTag(entity, "Ignore") then
                    continue
                end

                local enemyHum = entity:FindFirstChild("Humanoid")
                if not enemyHum then
                    continue
                end

                local enemyRoot = entity:FindFirstChild("HumanoidRootPart")
                if not enemyRoot then
                    continue
                end

                local distanceFromCenter = (aoeCenterPos - enemyRoot.Position).Magnitude
                if distanceFromCenter > aoeRange then
                    continue
                end

                if alreadyHit[entity.Name] then
                    continue
                end

                if CollectionService:HasTag(entity, "Invulnerable") then
                    continue
                end

                local isUserStun = StateManager:CheckState(character, "Stunned")
                if isUserStun then
                    return
                end

                local myTeam = character:GetAttribute("Team")
                local theirTeam = entity:GetAttribute("Team")

                if (myTeam and theirTeam) and myTeam == theirTeam then
                    continue
                end

                alreadyHit[entity.Name] = true

                local isBlocking = StateManager:CheckState(entity, "Blocking")
                if isBlocking then
                    --Block Indication
                    HealthManager:Block(entity, damage, character)
                    continue
                end

                --check modifiers
                HitboxManager:CheckModifiers(
                    classData.MoveData[moveType],
                    classData.MoveDataDurations[moveType],
                    entity, 
                    character
                )

                StateManager:AddTarget(entity, "Attacked", 1)

                HealthManager:Damage(entity, damage, character)
            end
        end

        local function Movement(deltaTime)
           forwardCFrame *= CFrame.new(0, 0, -speed * deltaTime)

            local characterList = {}
            for _, plr in pairs(Players:GetPlayers()) do
                local plrChar = plr.Character
                if not plrChar then
                    continue
                end
                table.insert(characterList, plrChar)
            end

            rayparams.FilterDescendantsInstances = {workspace.Dummies, workspace.Ignore, workspace.Obstacles, workspace.VFX, characterList}
            rayparams.FilterType = Enum.RaycastFilterType.Exclude

            local ray = workspace:Raycast(forwardCFrame.Position + Vector3.new(0, 5, 0), Vector3.new(0, -50, 0), rayparams)
            if ray then
                local floorPostion = ray.Position + Vector3.new(0, size.Y/4, 0)
                forwardCFrame = CFrame.new(floorPostion, floorPostion + forwardCFrame.LookVector)
            end

            Hitbox.CFrame = forwardCFrame * CFrame.Angles(0, 0, math.rad(90)) 
        end

        local function hitDetection()
            local hasTarget = false

            local listOfChars = {}
            for _, plr in pairs(game.Players:GetPlayers()) do
                local _chr = plr.Character
                if _chr then
                    table.insert(listOfChars, _chr)
                end
            end

            local overlapParams = OverlapParams.new()
            overlapParams.FilterDescendantsInstances = {listOfChars, workspace.Dummies}
            overlapParams.FilterType = Enum.RaycastFilterType.Include

            local alreadyHit = {}

            local parts = workspace:GetPartsInPart(Hitbox, overlapParams)
            for _, object in parts do
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

                if CollectionService:HasTag(parent, "Invulnerable") then
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

                hasTarget = true

                AoeHitDetection()

                if Hitbox then
                    Debris:AddItem(Hitbox, 1)
                end

                break
            end

            return hasTarget
        end

        while true do
            local deltaTime = task.wait()

            currentTime += deltaTime
            if currentTime < travelTime then
                Movement(deltaTime)
            elseif currentTime >= travelTime and not stoppedMoving then
                stoppedMoving = true

                VisualEffectServer:SpawnEffectsInRange(
                    "ConcussiveBomb",
                    nil,
                    character,
                    {action = "Stop"},
                    1000,
                    VFX_ID,
                    true
                )
            end

            if hitDetection() then
                targetHit = true
                break
            end
        end
    end)

    task.delay(travelTime, function()
       task.delay(lifeTime, function()
            if thread then
                task.cancel(thread)
            end

            if not targetHit then
                VisualEffectServer:TerminateVFX(
                    "ConcussiveBomb",
                    nil,
                    character,
                    {},
                    VFX_ID
                )
            end
            
            if Hitbox then
                Debris:AddItem(Hitbox, 1)
            end
        end)
    end)
end

return ConcussiveBomb