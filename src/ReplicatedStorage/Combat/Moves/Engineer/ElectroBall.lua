local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")
local CharacterModels = Assets:WaitForChild("CharacterModels")
local EngineerFolder = CharacterModels:WaitForChild("Engineer")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local HitboxManager = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("HitboxManager"))

local IgnoreFolder = workspace.Ignore

local ElectroBall = {}

function ElectroBall:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local moveDamage = classData.DamageList[moveType][1]
    local explodeDamage = classData.DamageList[moveType][2]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local shotDelay = 0.4
    local duration = 1
    local _delay = 1
    local speed = 75
    local damageTick = 0.25

    Stats:SetAttribute("AbilityLocked", true)
    task.delay(_delay, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    local startCFrame = placementCFrame * CFrame.new(0, 2, -5)

    local VFX_ID = "ElectroBall"..HttpService:GenerateGUID(false)

    local rayparams = RaycastParams.new()
    rayparams.FilterType = Enum.RaycastFilterType.Exclude

    local Hitbox: BasePart = Hitboxes.CircleHitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = classData.Hitboxes[moveType].Size.Size1
    Hitbox.CFrame = startCFrame
    Hitbox.Anchored = false
    Hitbox.Massless = true
    Hitbox.Parent = IgnoreFolder

    VisualEffectServer:SpawnEffectsInRange(
        "ElectroBall",
        nil,
        character,
        {hitbox  = Hitbox},
        1000,
        VFX_ID
    )

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    task.delay(shotDelay, function()
        weld.Enabled = false
        Hitbox.Anchored = true

        local alreadyHit1 = {}
        local alreadyHit2 = {}

        local function moveHitDetection()
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
                
                if alreadyHit1[parent.Name] then
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

                alreadyHit1[parent.Name] = true
                
                local isBlocking = StateManager:CheckState(parent, "Blocking")
                if isBlocking then
                    --Block Indication
                    HealthManager:Block(parent, moveDamage, character)
                    continue
                end

                --check modifiers
                HitboxManager:CheckModifiers(
                    classData.MoveData[moveType],
                    classData.MoveDataDurations[moveType],
                    parent, 
                    character
                )

                StateManager:AddTarget(parent, "Attacked", 2)

                HealthManager:Damage(parent, moveDamage, character)

                task.delay(damageTick, function()
                    if alreadyHit1[parent.Name] then
                        alreadyHit1[parent.Name] = nil
                    end
                end)
            end
        end

        local function explodeHitDetection()
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
                
                if alreadyHit2[parent.Name] then
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

                alreadyHit2[parent.Name] = true
                
                local isBlocking = StateManager:CheckState(parent, "Blocking")
                if isBlocking then
                    --Block Indication
                    HealthManager:Block(parent, explodeDamage, character)
                    continue
                end

                --check modifiers
                HitboxManager:CheckModifiers(
                    classData.MoveData[moveType],
                    classData.MoveDataDurations[moveType],
                    parent, 
                    character
                )

                StateManager:AddTarget(parent, "Attacked", 2)

                HealthManager:Damage(parent, explodeDamage, character)
            end
        end

        local function movement(dt)
            Hitbox.CFrame *= CFrame.new(0, 0, -speed * dt)

            local newCFR = Hitbox.CFrame

            local characterList = {}
            for _, plr in pairs(Players:GetPlayers()) do
                local plrChar = plr.Character
                if not plrChar then
                    continue
                end
                table.insert(characterList, plrChar)
            end

            rayparams.FilterDescendantsInstances = {workspace.Dummies, workspace.Ignore, workspace.Obstacles, workspace.VFX, characterList}

            local ray = workspace:Raycast(newCFR.Position, newCFR.UpVector * -1000, rayparams)
            if ray then
                local rayPosition = ray.Position

                Hitbox.Position = rayPosition + Vector3.new(0, Hitbox.Size.Y/2, 0)
            end
        end

        local thread = coroutine.create(function()
            while true do
                local dt = task.wait()

                moveHitDetection()

                movement(dt)
            end
        end)

        task.delay(duration, function()
            if thread then
                task.cancel(thread)
            end

            Hitbox.Size = classData.Hitboxes[moveType].Size.Size2

            VisualEffectServer:SpawnEffectsInRange(
                "ElectroBall",
                nil,
                character,
                {spawnCFrame = Hitbox.CFrame},
                1000,
                VFX_ID,
                true
            )

            explodeHitDetection()

            Debris:AddItem(Hitbox, 1)
        end)

        coroutine.resume(thread)
    end)
end

return ElectroBall