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

local Range = 16

local function GetTargets(user: Player)
    local targets = {}

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= user then
            local character = plr.Character
            if character then
                table.insert(targets, character)
            end
        end
    end

    for _, dummy in pairs(Dummies:GetChildren()) do
        table.insert(targets, dummy)
    end

    return targets
end

local Whirlpool = {}

function Whirlpool:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local duration = 5
    local damageTick = 0.25

    local Hitbox: BasePart = Hitboxes.CircleHitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = Vector3.new(Range * 2, Range * 2, Range * 2)
    Hitbox.CFrame = rootPart.CFrame
    Hitbox.Anchored = false
    Hitbox.CanCollide = false
    Hitbox.Massless = true
    Hitbox.Parent = IgnoreFolder
    Debris:AddItem(Hitbox, duration)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    local VFX_ID = "Whirlpool"..HttpService:GenerateGUID(false)

    VisualEffectServer:SpawnEffectsInRange(
        "Whirlpool",
        nil,
        character,
        {range = Range},
        1000,
        VFX_ID
    )

    local thread = task.spawn(function()
        local alreadyHit = {}

        while true do
            local dt = task.wait()

            local explosionOrigin = rootPart.Position

            local targets = GetTargets(player)

            for _, target: Model in targets do
                local targetRoot = target:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local distance = (targetRoot.Position - explosionOrigin).Magnitude
                    if distance < Range then
                        --ignoreTargets
                        if CollectionService:HasTag(target, "Ignore") then
                            continue
                        end

                        local enemyHum = target:FindFirstChild("Humanoid")
                        if not enemyHum then
                            continue
                        end

                        local enemyRoot = target:FindFirstChild("HumanoidRootPart")
                        if not enemyRoot then
                            continue
                        end

                        if CollectionService:HasTag(target, "Invulnerable") then
                            continue
                        end

                        local isUserStun = StateManager:CheckState(character, "Stunned")
                        if isUserStun then
                            return
                        end

                        local myTeam = character:GetAttribute("Team")
                        local theirTeam = target:GetAttribute("Team")

                        if (myTeam and theirTeam) and myTeam == theirTeam then
                            continue
                        end

                        if alreadyHit[target] then
                            continue
                        end

                        alreadyHit[target] = true
                        task.delay(damageTick, function()
                            alreadyHit[target] = nil
                        end)

                        VisualEffectServer:SpawnEffectsInRange(
                            "Whirlpool",
                            target,
                            character,
                            {isHit = true},
                            1000,
                            VFX_ID,
                            true
                        )

                        local isBlocking = StateManager:CheckState(target, "Blocking")
                        if isBlocking then
                            --Block Indication
                            HealthManager:Block(target, damage, character)
                            continue
                        end

                        --check modifiers
                        HitboxManager:CheckModifiers(
                            classData.MoveData[moveType],
                            classData.MoveDataDurations[moveType],
                            target, 
                            character
                        )

                        StateManager:AddTarget(target, "Attacked", 1)

                        HealthManager:Damage(target, damage, character)
                    end
                end
            end
        end
    end)

    task.delay(duration, function()
        if thread then
            task.cancel(thread)
        end

        VisualEffectServer:TerminateVFX(
            "Whirlpool",
            nil,
            character,
            {},
            VFX_ID
        )
        
    end)
end

return Whirlpool