local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local HitboxManager = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("HitboxManager"))

local IgnoreFolder = workspace.Ignore

local AngelicCharge = {}

function AngelicCharge:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.CFrame = placementCFrame
    Hitbox.Parent = IgnoreFolder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    Stats:SetAttribute("AbilityLocked", true)
    
    local VFX_ID = "AngelicCharge"..HttpService:GenerateGUID(false)

    VisualEffectServer:SpawnEffectsInRange(
        "AngelicCharge",
        nil,
        character,
        {},
        1000,
        VFX_ID
    )

    local duration = .25
    local currTime = 0

    local alreadyHit = {}

    local thread = coroutine.create(function()
        while currTime < duration * 2 do
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

                local isBlocking = StateManager:CheckState(parent, "Blocking")
                if isBlocking then
                    --Block Indication
                    HealthManager:Block(parent, damage, character)
                    continue
                end

                --check modifiers
                HitboxManager:CheckModifiers(
                    classData.MoveData[moveType],
                    classData.MoveDataDurations[moveType],
                    parent, 
                    character
                )

                StateManager:AddTarget(parent, "Attacked", 1)

                HealthManager:Damage(parent, damage, character)

                VisualEffectServer:SpawnEffectsInRange(
                    "AngelicCharge",
                    parent,
                    character,
                    {isHit = true},
                    1000,
                    VFX_ID,
                    true
                )
            end
        end
    end)

    Debris:AddItem(Hitbox, duration * 2)

    task.delay(duration * 2 , function()
        if thread then
            task.cancel(thread)
        end
        Stats:SetAttribute("AbilityLocked", false)

        VisualEffectServer:TerminateVFX(
            "AngelicCharge",
            nil,
            character,
            {},
            VFX_ID
        )
    end)

    coroutine.resume(thread)

    local dashData = {
        duration = duration,
        speed = 75,
        isDash = true,
        allowPass = true,
    }

    Events.Server_Client.Movement:FireAllClients(character, dashData)
end

return AngelicCharge