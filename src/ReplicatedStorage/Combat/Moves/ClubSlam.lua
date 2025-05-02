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

local ClubSlam = {}

function ClubSlam:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local isAwakened = Stats:GetAttribute("Awakened")

    local duration = 1
    local hitboxDelay = 0.025

    task.delay(duration / 2, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    local size = classData.Hitboxes[moveType].Size
    local startCFrame = character:GetPivot() * classData.Hitboxes[moveType].Offset

    if not isAwakened then
        damage = damage[1]
    elseif isAwakened then
        damage = damage[2]
        size = Vector3.new(10.5, 10.5, 21)
        startCFrame = character:GetPivot() * CFrame.new(0, 5.25, -10.5)
    end

    local numHits = 1

    local alreadyHit = {}

    for _=1, numHits do
        local lifeTime = .1

        local characterList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            local plrChar = plr.Character
            if not plrChar then
                continue
            end
            table.insert(characterList, plrChar)
        end

        local rayparams = RaycastParams.new()
        rayparams.FilterDescendantsInstances = {workspace.Dummies, workspace.Ignore, workspace.Obstacles, workspace.VFX, characterList}
        rayparams.FilterType = Enum.RaycastFilterType.Exclude

        local sudoCFrame = startCFrame * CFrame.new(0, 15, 0)

        local ray = workspace:Raycast(sudoCFrame.Position, sudoCFrame.UpVector * -100, rayparams)
        if ray then
            local floorPosition = ray.Position
            local newPosition = Vector3.new(startCFrame.Position.X, floorPosition.Y, startCFrame.Position.Z)

            local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
            Hitbox.Transparency = 1
            if ShowHitboxes then
                Hitbox.Transparency = .5
            end

            Hitbox.Size = size
            Hitbox.Anchored = true
            Hitbox.CFrame = startCFrame
            Hitbox.Position = newPosition + Vector3.new(0, Hitbox.Size.Y/2, 0)
            Hitbox.Parent = IgnoreFolder
            Debris:AddItem(Hitbox, lifeTime)

            VisualEffectServer:SpawnEffectsInRange(
                "ClubSlam",
                nil,
                character,
                {
                    spawnCFrame = Hitbox.CFrame * CFrame.new(0, -Hitbox.Size.Y/2, 0),
                    isAwakened = isAwakened,
                },
                1000
            )

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

                        if not isAwakened then
                            StateManager:AddTarget(parent, "Slow", 2)

                        elseif isAwakened then
                            StateManager:AddTarget(parent, "Slow", 3)

                            local parentPlayer = Players:GetPlayerFromCharacter(parent)
                            if not parentPlayer then
                                enemyRoot:SetNetworkOwner(player)
                            end

                            StateManager:AddTarget(parent, "Knockup", 50)
                        end

                        StateManager:AddTarget(parent, "Attacked", 1)
            
                        HealthManager:Damage(parent, damage, character)
                    end
                    
                    task.wait()
                end
            end)

            task.delay(lifeTime, function()
                if hitDetect then
                    task.cancel(hitDetect)
                end
            end)
        end

        startCFrame *= CFrame.new(0, 0, -(size.Z + 2))

        task.wait(hitboxDelay)
    end
end

return ClubSlam