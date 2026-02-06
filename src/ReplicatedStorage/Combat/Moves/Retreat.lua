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

local Retreat = {}

function Retreat:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local teleportCFrame = character:GetAttribute("teleportCFrame")
    if not teleportCFrame then
        local floorCFrame = character:GetPivot()

        local characterList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            local plrChar = plr.Character
            if not plrChar then
                continue
            end
            table.insert(characterList, plrChar)
        end

        local rayparams = RaycastParams.new()
        rayparams.FilterDescendantsInstances = {workspace.Dummies, workspace.Ignore, workspace.Obstacles, workspace.VFX, characterList}
        rayparams.FilterType = Enum.RaycastFilterType.Exclude
        
        local ray = workspace:Raycast(rootPart.Position, Vector3.new(0, -5, 0), rayparams)
        if ray then
            floorCFrame = CFrame.new(ray.Position, ray.Position + rootPart.CFrame.LookVector)
        end

        character:SetAttribute("DoubleCooldown", moveType)
        character:SetAttribute("teleportCFrame", floorCFrame)

        VisualEffectServer:SpawnEffectsInRange(
            "Retreat",
            nil,
            character,
            {floorCFrame = floorCFrame},
            1000,
            "Retreat_"..character.Name
        )
    else
        character:PivotTo(teleportCFrame)
        character:SetAttribute("teleportCFrame", nil)
        character:SetAttribute("DoubleCooldown", nil)

        VisualEffectServer:TerminateVFX(
            "Retreat",
            nil,
            character,
            {},
            "Retreat_"..character.Name
        )
    end
end

return Retreat