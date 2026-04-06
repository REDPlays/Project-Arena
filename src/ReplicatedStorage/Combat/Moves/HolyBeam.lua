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

local IgnoreFolder = workspace.Ignore
local ObstaclesFolder = workspace.Obstacles
local Dummies = workspace.Dummies

local HolyBeam = {}

local function findTeammates(player: Player, character: Model)
    local possibleTargets = {}
    local teammates = {}

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
    
    return teammates
end

function HolyBeam:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local healing = classData.DamageList[moveType]
    local TeamHeal = 15
    local range = 10

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local teammates = findTeammates(player, character)

    for i, teammate in teammates do
        local teammateRoot = teammate:FindFirstChild("HumanoidRootPart")
        if not teammateRoot then continue end

        local distance = (teammateRoot.Position - rootPart.Position).Magnitude
        if distance <= range then
            HealthManager:Heal(teammate, TeamHeal)
        end
    end

    VisualEffectServer:SpawnEffectsInRange(
        "HolyBeam",
        nil,
        character,
        {},
        1000
    )

    HealthManager:Heal(character, healing)
end

return HolyBeam