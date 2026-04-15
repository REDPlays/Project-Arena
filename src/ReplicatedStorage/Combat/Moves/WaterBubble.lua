local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

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
local Dummies = workspace.Dummies

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

    local duration = 4
    local TeamHeal = 0.75
    local range = 16

    if hydroStacks and hydroStacks.stack >= 5 then
        maxStacks = true
        damage *= 1.5
        duration *= 1.5
        PassiveManager:ClearStack(character, "HydroStack")
    end

    StateManager:AddTarget(character, "HealthRegen", 5, {})

    local thread = task.spawn(function()
        if not maxStacks then return end

        local currTick = 0
        local tickRate = 0.1

        while true do
            local dt = task.wait()

            currTick += dt
            if currTick < tickRate then
                continue
            end

            currTick = 0

            local possibleTargets = {}

            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name ~= player.Name then
                    local targetChar = plr.Character
                    if targetChar then
                        table.insert(possibleTargets, targetChar)
                    end
                end
            end

            for _, dummy in pairs(Dummies:GetChildren()) do
                table.insert(possibleTargets, dummy)
            end

            local teammates = {}
            for i, target in possibleTargets do
                local myTeam = character:GetAttribute("Team")
                local theirTeam = target:GetAttribute("Team")

                if (myTeam and theirTeam) and myTeam == theirTeam then
                    table.insert(teammates, target)
                end

                if target:GetAttribute("DummyAlly") then
                    table.insert(teammates, target)
                end
            end

            for i, teammate in teammates do
                local teammateRoot = teammate:FindFirstChild("HumanoidRootPart")
                if not teammateRoot then continue end

                local distance = (teammateRoot.Position - rootPart.Position).Magnitude
                if distance <= range then
                    HealthManager:Heal(teammate, TeamHeal)
                end
            end
        end
    end)

    local VFX_ID = "WaterBubble"..HttpService:GenerateGUID(false)
    
    VisualEffectServer:SpawnEffectsInRange(
        "WaterBubble",
        nil,
        character,
        {maxStacks = maxStacks, range = range},
        1000,
        VFX_ID
    )

    task.delay(duration, function()
        if thread then
            task.cancel(thread)
        end
        
        StateManager:RemoveTarget(character, "HealthRegen")

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