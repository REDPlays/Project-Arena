local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

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

local ReaperCompanionHelper = require(ReplicatedStorage.RepFiles.Combat.Companions.ReaperCompanion)
local CompanionLibrary = require(ReplicatedStorage.RepFiles.Player.CompanionLibrary)
local CharacterMoveLibrary = require(ReplicatedStorage.RepFiles.Player.CharacterMoveLibrary)

local IgnoreFolder = workspace.Ignore
local ObstaclesFolder = workspace.Obstacles
local CachedCompanions = workspace.CachedCompanions

local ReapersCalling = {}

function ReapersCalling:Activate(player, character, rootPart, placementCFrame, class, classData, moveType, currentMove)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[currentMove]

    local rigName = player.Name.." Companion"

    local shouldDistance = 4
    local backDistance = 3
    local upDistance = 1

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local currentCompanion: Model = CachedCompanions:FindFirstChild(rigName)
    if not currentCompanion then
        return
    end

    local companionRoot = currentCompanion:FindFirstChild("HumanoidRootPart")
    if not companionRoot then
        return
    end

    local isEnshroud = Stats:GetAttribute("Enshroud")
    if isEnshroud then
        return
    end

    local ignoreList = {"Left Arm", "Right Arm", "Torso"}

    local baseTransparency = {
        ["Group1"] = 0,
        ["Group2"] = 0,
        ["Group3"] = 0,
        ["Left Arm"] = 0,
        ["Right Arm"] = 0,
        ["Torso"] = 0,
    }

    for _, object in ipairs(currentCompanion:GetChildren()) do
        if object:IsA("BasePart") and not table.find(ignoreList, object.Name) then
            object.Transparency = 1
        end
    end

    for _, object in ipairs(currentCompanion:GetDescendants()) do
        if object:IsA("Decal") then
            object.Transparency = 1
        end
    end

    Stats:SetAttribute("AbilityLocked", true)

    local isAwakened = Stats:GetAttribute("Awakened")

    VisualEffectServer:SpawnEffectsInRange(
        "ReapersCalling",
        nil,
        character,
        {companion = currentCompanion},
        1000
    )

    if not isAwakened then
        if CompanionLibrary.CurrentReapers[player] then return end

        CharacterMoveLibrary.Movesets[player] = {
            ["LMBMove"] = "M1",
            ["QMove"] = "Reapers Blight",
            ["EMove"] = "Reapers Calling",
            ["FMove"] = "Enshroud",
        }
        Events.Server_Client.UpdateMoveNumber:FireClient(player, CharacterMoveLibrary.Movesets[player])

        local restOffset = CFrame.new(shouldDistance, upDistance, backDistance)
        local originOffset = CFrame.new(0, 0, 0)

        local team = character:GetAttribute("Team")

        CompanionLibrary.CurrentReapers[player] = ReaperCompanionHelper.new(player, currentCompanion, restOffset, classData.MoveData, team)
        CompanionLibrary.CurrentReapers[player]:Init()

        Stats:SetAttribute("Awakened", true)

        local tweenTime = 0.25

        for _, object in ipairs(currentCompanion:GetDescendants()) do
            if object:IsA("BasePart") then
                object.Transparency = 1
            end
        end

        currentCompanion:PivotTo(rootPart.CFrame)
        companionRoot.Anchored = false

        local weld = Instance.new("Weld")
        weld.Name = "CompanionWeld"
        weld.Part0 = rootPart
        weld.Part1 = companionRoot
        weld.C0 = originOffset
        weld.Parent = weld.Part0

        local info = TweenInfo.new(tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        TweenService:Create(weld, info, {C0 = restOffset}):Play()

        for _, object in ipairs(currentCompanion:GetDescendants()) do
            if object:IsA("BasePart") then
                if baseTransparency[object.Name] then
                    TweenService:Create(object, info, {Transparency = baseTransparency[object.Name]}):Play()
                end
            end
        end

        task.delay(tweenTime, function()
            Stats:SetAttribute("AbilityLocked", false)
        end)
    elseif isAwakened then
        if not CompanionLibrary.CurrentReapers[player] then return end

        Stats:SetAttribute("Awakened", false)

        CharacterMoveLibrary.Movesets[player] = {
            ["LMBMove"] = CharacterMoveLibrary.BaseMovesets.Reaper.LMBMove,
            ["QMove"] = CharacterMoveLibrary.BaseMovesets.Reaper.QMove,
            ["EMove"] = CharacterMoveLibrary.BaseMovesets.Reaper.EMove,
            ["FMove"] = CharacterMoveLibrary.BaseMovesets.Reaper.FMove,
        }
        Events.Server_Client.UpdateMoveNumber:FireClient(player, CharacterMoveLibrary.Movesets[player])

        local tweenTime = 0.25

        local CompanionWeld = rootPart:FindFirstChild("CompanionWeld")
        if CompanionWeld then
            local info = TweenInfo.new(tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
            TweenService:Create(CompanionWeld, info, {C0 = CFrame.new(0, 0, 0)}):Play()

            for _, object in ipairs(currentCompanion:GetDescendants()) do
                if object:IsA("BasePart") then
                    TweenService:Create(object, info, {Transparency = 1}):Play()
                end
            end

            task.delay(tweenTime, function()
                Stats:SetAttribute("AbilityLocked", false)

                CompanionLibrary.CurrentReapers[player]:Destroy()
                CompanionLibrary.CurrentReapers[player] = nil

                CompanionWeld:Destroy()
                companionRoot.Anchored = true
                currentCompanion:PivotTo(CFrame.new(0, 0, 0))

                for _, object in ipairs(currentCompanion:GetDescendants()) do
                    if object:IsA("BasePart") then
                        if baseTransparency[object.Name] then
                            object.Transparency = baseTransparency[object.Name]
                        end
                    end
                end
            end)
        end
    end
end

function ReapersCalling:Update(deltaTime: number)
    for player, reaperCompanion in pairs(CompanionLibrary.CurrentReapers) do
        reaperCompanion:Update(deltaTime)
    end
end

return ReapersCalling