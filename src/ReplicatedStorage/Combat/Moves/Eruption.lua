local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
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

local Eruption = {}

local function predictPosition2(model: Model, timeInterval)
    return model:GetPivot().Position + model.PrimaryPart.AssemblyLinearVelocity * timeInterval
end

function Eruption:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local Hitbox: BasePart = Hitboxes.CircleHitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    local position = predictPosition2(character, .35)

    local newCFrame = CFrame.new(position, rootPart.CFrame.LookVector + position) * classData.Hitboxes[moveType].Offset

    local conditionalData = {}
    conditionalData.spawnCFrame = newCFrame
    conditionalData.size = classData.Hitboxes[moveType].Size

    VisualEffectServer:SpawnEffectsInRange(
        "Eruption",
        nil,
        character,
        conditionalData,
        1000
    )

    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.CFrame = newCFrame
    Hitbox.Anchored = true
    Hitbox.Parent = IgnoreFolder
    Debris:AddItem(Hitbox, .25)

    local alreadyHit = {}

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
        task.delay(.25, function()
            alreadyHit[parent.Name] = nil
        end)

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
    end
end

return Eruption