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
local PassiveManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("PassiveManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))
local CombatTags = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("Constants"):WaitForChild("CombatTags"))
local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local HitboxManager = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("HitboxManager"))

local IgnoreFolder = workspace.Ignore
local ObstaclesFolder = workspace.Obstacles

local WaterBubble = {}

function WaterBubble:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local hydroStacks = PassiveManager:CheckPassive(character, "HydroStack")
    local maxStacks = false

    local duration = 6

    if hydroStacks and hydroStacks.stack >= 5 then
        maxStacks = true
        damage *= 1.5
        duration *= 1.5
        PassiveManager:ClearStack(character, "HydroStack")
    end

    local VFX_ID = "WaterBubble"..HttpService:GenerateGUID(false)
    
    VisualEffectServer:SpawnEffectsInRange(
        "WaterBubble",
        nil,
        character,
        {maxStacks = maxStacks},
        1000,
        VFX_ID
    )

    task.delay(duration, function()
        VisualEffectServer:TerminateVFX(
            "WaterBubble",
            nil,
            character,
            {},
            VFX_ID
        )
    end)

    StateManager:AddTarget(character, "Reflecting", duration, {})
end

return WaterBubble