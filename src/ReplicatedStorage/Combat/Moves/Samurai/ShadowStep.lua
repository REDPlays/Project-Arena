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
local HitboxManager = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("HitboxManager"))

local IgnoreFolder = workspace.Ignore

local ShadowStep = {}

function ShadowStep:Activate(player, character, rootPart, placementCFrame, class, classData, moveType, currentMove)
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

    local duration = 1

    Stats:SetAttribute("AbilityLocked", true)
    Stats:SetAttribute("HideUI", true)
    humanoid.WalkSpeed = classData.Speed * 1.25

    local VFX_ID = "ShadowStep"..HttpService:GenerateGUID(false)

    VisualEffectServer:SpawnEffectsInRange(
        "ShadowStep",
        nil,
        character,
        {},
        1000,
        VFX_ID
    )

    task.delay(duration, function()
        VisualEffectServer:TerminateVFX(
            "ShadowStep",
            nil,
            character,
            {},
            VFX_ID
        )

        Stats:SetAttribute("AbilityLocked", false)
        Stats:SetAttribute("HideUI", false)
        humanoid.WalkSpeed = classData.Speed
    end)
end

return ShadowStep