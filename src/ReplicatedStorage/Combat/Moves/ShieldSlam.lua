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

local ShieldSlam = {}

function ShieldSlam:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local duration = 1

    task.delay(duration, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    local size = classData.Hitboxes[moveType].Size
    local startCFrame = character:GetPivot() * classData.Hitboxes[moveType].Offset

    for _=1, 3 do
        local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
        Hitbox.Transparency = 1
        if ShowHitboxes then
            Hitbox.Transparency = .5
        end

        Hitbox.Size = classData.Hitboxes[moveType].Size
        Hitbox.Anchored = true
        Hitbox.CFrame = startCFrame
        Hitbox.Parent = IgnoreFolder

        Debris:AddItem(Hitbox, duration * 2)

        startCFrame *= CFrame.new(0, 0, -size.Z)

        task.wait(.05)
    end

    --[==[VisualEffectServer:SpawnEffectsInRange(
        "ShieldBash",
        nil,
        character,
        {},
        1000
    )]==]
end

return ShieldSlam