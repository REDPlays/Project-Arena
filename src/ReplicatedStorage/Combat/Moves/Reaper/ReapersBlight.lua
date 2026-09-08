local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local CharacterCompanions = Assets:WaitForChild("CharacterCompanions")
local ReaperCompanionAssets = CharacterCompanions:WaitForChild("Reaper")
local ReaperCompanionAnimations = ReaperCompanionAssets:WaitForChild("Animations")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local PassiveManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("PassiveManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))
local CombatTags = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("Constants"):WaitForChild("CombatTags"))
local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local HitboxManager = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("HitboxManager"))

local CompanionLibrary = require(ReplicatedStorage.RepFiles.Player.CompanionLibrary)

local IgnoreFolder = workspace.Ignore
local ObstaclesFolder = workspace.Obstacles
local CachedCompanions = workspace.CachedCompanions

local ReapersBlight = {}

function ReapersBlight:Activate(player, character, rootPart, placementCFrame, class, classData, moveType, currentMove)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[currentMove]
    local maxDistance = 50

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local rigName = player.Name.." Companion"

    local RetrieveTarget = Events.Server_Client.GetTarget:InvokeClient(player)

    local function DisableCompanion()
        if not CompanionLibrary.CurrentReapers[player] then return end

        local currentCompanion: Model = CachedCompanions:FindFirstChild(rigName)
        if not currentCompanion then return end

        local companionRoot = currentCompanion:FindFirstChild("HumanoidRootPart")
        if not companionRoot then return end

        Stats:SetAttribute("Awakened", false)

        local tweenTime = 0.01

        local CompanionWeld = rootPart:FindFirstChild("CompanionWeld")
        if CompanionWeld then
            local baseTransparency = {
                ["Group1"] = 0,
                ["Group2"] = 0,
                ["Group3"] = 0,
                ["Left Arm"] = 0,
                ["Right Arm"] = 0,
                ["Torso"] = 0,
            }
            
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

    if not RetrieveTarget then
        return
    elseif RetrieveTarget then
        local targetRoot = RetrieveTarget:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        local targetHum = RetrieveTarget:FindFirstChild("Humanoid")
        if not targetHum or targetHum and targetHum.Health <= 0 then return end

        local distance = (targetRoot.Position - rootPart.Position).Magnitude
        if distance > maxDistance then return end

        local currentCompanion: Model = CachedCompanions:FindFirstChild(rigName)
        if not currentCompanion then return end

        local clonedCompanion: Model = currentCompanion:Clone()
        clonedCompanion.Parent = workspace.Ignore

        DisableCompanion()

        local clonedCompanionRoot = clonedCompanion:FindFirstChild("HumanoidRootPart")
        if not clonedCompanionRoot then return end

        local clonedCompanionController = clonedCompanion:FindFirstChild("Controller")
        if not clonedCompanionController then return end

        local clonedCompanionAnimator = clonedCompanionController:FindFirstChild("Animator")
        if not clonedCompanionAnimator then return end

        Stats:SetAttribute("AbilityLocked", true)

        local weld = Instance.new("Weld")
        weld.Name = "CompanionWeld"
        weld.Part0 = targetRoot
        weld.Part1 = clonedCompanionRoot
        weld.C0 = CFrame.new(0, 1, 5)
        weld.Parent = weld.Part0

        local attack: AnimationTrack = clonedCompanionAnimator:LoadAnimation(ReaperCompanionAnimations["M1_3"])

        attack:GetMarkerReachedSignal("Attack"):Once(function()
            VisualEffectServer:SpawnEffectsInRange(
                "ReapersBlight",
                nil,
                clonedCompanion,
                {},
                1000
            )
            
            local isBlocking = StateManager:CheckState(RetrieveTarget, "Blocking")
            if isBlocking then
                --Block Indication
                HealthManager:Block(RetrieveTarget, damage, character)
                return
            end

            --check modifiers
            HitboxManager:CheckModifiers(
                classData.MoveData[currentMove],
                classData.MoveDataDurations[currentMove],
                RetrieveTarget,
                character,
                classData.MoveDataAdditional and classData.MoveDataAdditional[currentMove]
            )

            HealthManager:Damage(RetrieveTarget, damage, character)
        end)

        attack.Stopped:Once(function()
            Debris:AddItem(clonedCompanion, 0.1)
        end)

        attack:Play()
    end
end

return ReapersBlight