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
local HitboxManager = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("HitboxManager"))

local IgnoreFolder = workspace.Ignore

local SumoRush = {}

function SumoRush:Activate(player, character, rootPart, placementCFrame, class, classData, moveType, currentMove)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[currentMove]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    Stats:SetAttribute("AbilityLocked", true)

    local VFX_ID = "SumoRush"..HttpService:GenerateGUID(false)

    VisualEffectServer:SpawnEffectsInRange(
        "SumoRush",
        nil,
        character,
        {},
        1000,
        VFX_ID
    )

    local duration = 2
    local damageTick = 0.5
    local currTime = 0

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = Vector3.new(6, 6, 6)
    Hitbox.CFrame = character:GetPivot() * CFrame.new(0, 3, 0)
    Hitbox.Parent = IgnoreFolder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    local alreadyHit = {}

    local thread = task.spawn(function()
        while currTime < duration do
            local dt = task.wait()

            currTime += dt
            
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

                if CollectionService:HasTag(parent, "Invulnerable") then
                    continue
                end

                local myTeam = character:GetAttribute("Team")
                local theirTeam = parent:GetAttribute("Team")

                if (myTeam and theirTeam) and myTeam == theirTeam then
                    continue
                end

                alreadyHit[parent.Name] = true
                task.delay(damageTick, function()
                    if alreadyHit[parent.Name] then
                        alreadyHit[parent.Name] = nil
                    end
                end)

                local isBlocking = StateManager:CheckState(parent, "Blocking")
                if isBlocking then
                    --Block Indication
                    HealthManager:Block(parent, damage, character)
                    continue
                end

                --check modifiers
                HitboxManager:CheckModifiers(
                    classData.MoveData[moveType][1],
                    classData.MoveDataDurations[moveType][1],
                    parent, 
                    character
                )

                StateManager:AddTarget(parent, "Attacked", 1)

                HealthManager:Damage(parent, damage, character)
            end
        end
    end)

    task.delay(duration, function()
        if thread then
            task.cancel(thread)
        end

        if Hitbox then
            Hitbox:Destroy()
        end

        Stats:SetAttribute("AbilityLocked", false)

        VisualEffectServer:TerminateVFX(
            "SumoRush",
            nil,
            character,
            {},
            VFX_ID
        )
    end)

    local dashData = {
        duration = duration,
        force = 75,
        isLinear = true,
        allowPass = true,
    }

    Events.Server_Client.Movement:FireAllClients(character, dashData)
end

return SumoRush