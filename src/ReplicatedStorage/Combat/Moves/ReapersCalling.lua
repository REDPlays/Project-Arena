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
local CachedCompanions = workspace.CachedCompanions

local ReapersCalling = {}

function ReapersCalling:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[moveType]

    local rigName = player.Name.." Companion"

    local shouldDistance = 5
    local backDistance = 3
    local upDistance = 2

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

    local ignoreList = {"Left Arm", "Right Arm", "Torso"}

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

    if not isAwakened then
        Stats:SetAttribute("Awakened", true)

        local restOffset = rootPart.CFrame * CFrame.new(shouldDistance, upDistance, backDistance)

        currentCompanion:PivotTo(restOffset)
        companionRoot.Anchored = false

        local attachment = Instance.new("Attachment")
        attachment.Parent = companionRoot

        local AlignPos: AlignPosition = Instance.new("AlignPosition")
        AlignPos.MaxForce = 100000
        AlignPos.MaxVelocity = 100000
        AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
        AlignPos.RigidityEnabled = true
        AlignPos.Position = restOffset.Position
        AlignPos.Attachment0 = attachment
        AlignPos.Parent = companionRoot

        local AlignOri: AlignOrientation = Instance.new("AlignOrientation")
        AlignOri.MaxTorque = 100000
        AlignOri.MaxAngularVelocity = 100000
        AlignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
        AlignOri.Attachment0 = attachment
        AlignOri.RigidityEnabled = true
        AlignOri.Parent = companionRoot
        
        task.spawn(function()
            while true do
                if not character then break end
                if not Stats then break end
                if not currentCompanion then break end

                local deltaTime = task.wait()

                restOffset = rootPart.CFrame * CFrame.new(shouldDistance, upDistance, backDistance)
                local lookVector = rootPart.CFrame.LookVector
                local facingCFrame = CFrame.new(restOffset.Position, restOffset.Position + lookVector)

                AlignPos.Position = restOffset.Position
                AlignOri.CFrame = facingCFrame
            end
        end)
        
    elseif isAwakened then
        Stats:SetAttribute("Awakened", false)


    end
end

return ReapersCalling