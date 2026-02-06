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

local ClubSpin_Fire = {}

function ClubSpin_Fire:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[moveType][1]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    Stats:SetAttribute("AbilityLocked", true)

    local duration = 2

    local Hitbox: BasePart = Hitboxes.CylinderHitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.Anchored = false
    Hitbox.Massless = true
    Hitbox.CFrame = placementCFrame * classData.Hitboxes[moveType].Offset * CFrame.Angles(0, 0, math.rad(90))
    Hitbox.Parent = IgnoreFolder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    local alreadyHit = {}
    local attackRate = 0.01

    local rate = 0
    local maxRate = 0.1

    local hitDetect = task.spawn(function()
        while true do
            local deltaTime = task.wait()

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
                task.delay(attackRate, function()
                    alreadyHit[parent.Name] = nil
                end)
    
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

                --apply silence
                if classData.MoveData[moveType].Silenced then
                    StateManager:AddTarget(parent, "Silenced", 2)
                end
    
                --apply knockup
                if classData.MoveData[moveType].Knockup then
                    local parentPlayer = Players:GetPlayerFromCharacter(parent)
                    if not parentPlayer then
                        enemyRoot:SetNetworkOwner(player)
                    end

                    StateManager:AddTarget(parent, "Knockup", 25)
                end

                StateManager:AddTarget(parent, "Attacked", 1)
    
                rate += deltaTime
                if rate >= maxRate then
                    rate = 0
                    HealthManager:Damage(parent, damage, character)
                end

                local force = 60
                local knockBackData = {
                    force = rootPart.CFrame.LookVector * force,
                    isAssembly = true,
                }
                Events.Server_Client.Movement:FireAllClients(parent, knockBackData)
            end
        end
    end)

    task.delay(duration, function()
        if hitDetect then
            task.cancel(hitDetect)
        end

        if Hitbox then
            Hitbox:Destroy()
        end

        Stats:SetAttribute("AbilityLocked", false)
    end)

    local assemblyData = {
        force = 50,
        duration = duration,
        isAssemblyDuration = true,
    }

    Events.Server_Client.Movement:FireAllClients(character, assemblyData)
end

return ClubSpin_Fire