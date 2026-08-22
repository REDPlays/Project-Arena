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

local CompanionLibrary = require(ReplicatedStorage.RepFiles.Player.CompanionLibrary)
local CharacterMoveLibrary = require(ReplicatedStorage.RepFiles.Player.CharacterMoveLibrary)

local IgnoreFolder = workspace.Ignore
local ObstaclesFolder = workspace.Obstacles
local CachedCompanions = workspace.CachedCompanions

local Enshroud = {}
Enshroud.threads = {}

function Enshroud:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[moveType][2]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local healthLossPerTick = damage
    local tickRate = 0.5 --every second
    local _tick = 0
    local damageBonus = 2 --multiplier

    local rigName = player.Name.." Companion"

    local isEnshroud = Stats:GetAttribute("Enshroud")

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

    if not isEnshroud then
        DisableCompanion()

        CharacterMoveLibrary.Movesets[player] = {
            ["QMove"] = 1,
            ["EMove"] = 1,
            ["FMove"] = 2,
        }
        Events.Server_Client.UpdateMoveNumber:FireClient(player, CharacterMoveLibrary.Movesets[player])

        Stats:SetAttribute("Enshroud", true)
        humanoid.WalkSpeed = classData.Speed * 2

        StateManager:AddTarget(character, "DamageBoost", damageBonus)

        if Enshroud.threads[character] then
            if Enshroud.threads[character].thread then
                task.cancel(Enshroud.threads[character].thread)
            end

            Enshroud.threads[character] = nil
        end

        local VFX_ID = "Enshroud_"..HttpService:GenerateGUID(false)

        local function cleanup()
            StateManager:RemoveTarget(character, "DamageBoost")

            VisualEffectServer:TerminateVFX(
                "Enshroud",
                nil,
                character,
                {},
                Enshroud.threads[character].VFX_ID
            )

            Enshroud.threads[character] = nil
        end

        Enshroud.threads[character] = {}
        Enshroud.threads[character].VFX_ID = VFX_ID
        Enshroud.threads[character].thread = task.spawn(function()
            while true do
                local deltaTime = task.wait()

                local humanoid = character:FindFirstChild("Humanoid")
                if not humanoid or humanoid and humanoid.Health <= 0 then
                    cleanup()
                    break
                end

                if not Stats:GetAttribute("Enshroud") then
                    cleanup()
                    break
                end

                _tick += deltaTime
                if _tick >=tickRate then
                    _tick = 0

                    HealthManager:Damage(character, healthLossPerTick, character)
                end
            end
        end)

        VisualEffectServer:SpawnEffectsInRange(
            "Enshroud",
            nil,
            character,
            {},
            1000,
            VFX_ID
        )

    elseif isEnshroud then
        Stats:SetAttribute("Enshroud", nil)
        humanoid.WalkSpeed = classData.Speed

        CharacterMoveLibrary.Movesets[player] = {
            ["QMove"] = 1,
            ["EMove"] = 1,
            ["FMove"] = 1,
        }
        Events.Server_Client.UpdateMoveNumber:FireClient(player, CharacterMoveLibrary.Movesets[player])

        StateManager:RemoveTarget(character, "DamageBoost")

        if Enshroud.threads[character] then
            if Enshroud.threads[character].thread then
                task.cancel(Enshroud.threads[character].thread)
            end

            VisualEffectServer:TerminateVFX(
                "Enshroud",
                nil,
                character,
                {},
                Enshroud.threads[character].VFX_ID
            )

            Enshroud.threads[character] = nil
        end
    end
end

return Enshroud