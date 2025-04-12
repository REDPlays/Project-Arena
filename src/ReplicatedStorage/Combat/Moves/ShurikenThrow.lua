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

local ShurikenThrow = {}

function ShurikenThrow:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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
    local duration = 0.15

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.Anchored = true
    Hitbox.CFrame = placementCFrame
    Hitbox.Parent = IgnoreFolder

    local VFX_ID = HttpService:GenerateGUID(false)

    VisualEffectServer:SpawnEffectsInRange(
        "ShurikenThrow",
        nil,
        character,
        {
            startCFrame = rootPart.CFrame, 
            endCFrame = Hitbox.CFrame * CFrame.new(0, -Hitbox.Size.Y/2, 0),
            Size = Hitbox.Size,
        },
        1000
    )

    local alreadyHit = {}
    local lifeTime = 0.2

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
                    StateManager:AddTarget(parent, "Slow", 1)
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

                    StateManager:AddTarget(parent, "Knockup", 50)
                end

                StateManager:AddTarget(parent, "Attacked", 1)
    
                HealthManager:Damage(parent, damage, character)

                VisualEffectServer:SpawnEffectsInRange(
                    "ShurikenThrow",
                    parent,
                    character,
                    {isHit = true},
                    1000,
                    VFX_ID,
                    true
                )
            end
            
            task.wait()
        end
    end)

    task.delay(lifeTime, function()
        if hitDetect then
            task.cancel(hitDetect)
        end
    end)

    local force = 100
    local upForce = 75

    local dashData = {
        isAssembly = true,
        force = rootPart.CFrame.LookVector * -force + Vector3.new(0, upForce, 0),
    }

    Events.Server_Client.Movement:FireAllClients(character, dashData)

    task.delay(duration , function()
        Hitbox:Destroy()
        Stats:SetAttribute("AbilityLocked", false)
    end)
end

return ShurikenThrow