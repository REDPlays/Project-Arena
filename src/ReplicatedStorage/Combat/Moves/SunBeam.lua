local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")
local Indicators = Assets:WaitForChild("Indicators")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local SunBeam = {}

function SunBeam:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.CFrame = placementCFrame
    Hitbox.Parent = IgnoreFolder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    local caution = Indicators.CautionLines:Clone()
    caution.Size = Vector3.new(Hitbox.Size.X, .1, Hitbox.Size.Z)
    caution.A0.Position = Vector3.new(0, .05, -caution.Size.Z/2)
    caution.A1.Position = Vector3.new(0, .05, caution.Size.Z/2)
    caution.Beam.Width0 = caution.Size.X
    caution.Beam.Width1 = caution.Size.X
    caution.CFrame = placementCFrame * CFrame.new(0, -Hitbox.Size.Y/2 + 0.05, 0)
    caution.Parent = IgnoreFolder

    local weld2 = Instance.new("WeldConstraint")
    weld2.Part0 = caution
    weld2.Part1 = rootPart
    weld2.Parent = weld2.Part0

    Stats:SetAttribute("AbilityLocked", true)

    local duration = 3
    local currTime = 0
    local damageTick = .25

    StateManager:AddTarget(character, "Slow", duration)

    VisualEffectServer:SpawnEffectsInRange(
        "SunBeam",
        nil,
        character,
        {},
        1000
    )

    local alreadyHit = {}

    local thread = coroutine.create(function()
        while currTime < duration * 2 do
            currTime += RunService.Heartbeat:Wait()
            
            local touched = Hitbox.Touched:Connect(function() end)
            local touchedObjects = Hitbox:GetTouchingParts()

            if touched then
                touched:Disconnect()
            end

            for i=1, #touchedObjects do
                local object = touchedObjects[i]
                local parent = object.Parent

                if not parent:IsA("Model") then
                    continue
                end

                if parent == character then
                    continue
                end

                --ignoreTargets
                if CollectionService:HasTag(parent, "Ignore") then
                    continue
                end

                local enemyHum = parent:FindFirstChild("Humanoid")
                if not enemyHum then
                    continue
                end

                local enemyRoot = parent:FindFirstChild("HumanoidRootPart")
                if not enemyRoot then
                    continue
                end

                if alreadyHit[parent.Name] then
                    continue
                end

                if CollectionService:HasTag(parent, "Invulnerable") then
                    continue
                end

                alreadyHit[parent.Name] = true

                local isBlocking = StateManager:CheckState(parent, "Blocking")
                if isBlocking then
                    --Block Indication
                    warn("block Sun Beam")
                    task.delay(damageTick, function()
                        if alreadyHit[parent.Name] then
                            alreadyHit[parent.Name] = nil
                        end
                    end)

                    continue
                end

                --apply burn
                if classData.MoveData[moveType].Burn then
                    StateManager:AddTarget(parent, "Burn", 3)
                end

                --apply stun
                if classData.MoveData[moveType].Stunned then
                    StateManager:AddTarget(parent, "Stunned", 2)
                end

                --apply slow
                if classData.MoveData[moveType].Slow then
                    StateManager:AddTarget(parent, "Slow", 1)
                end

                StateManager:AddTarget(parent, "Attacked", 1)

                HealthManager:Damage(parent, damage, character)

                task.delay(damageTick, function()
                    if alreadyHit[parent.Name] then
                        alreadyHit[parent.Name] = nil
                    end
                end)
            end
            
            task.wait()
        end
    end)

    Debris:AddItem(Hitbox, duration)
    Debris:AddItem(caution, duration)

    task.delay(duration, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    coroutine.resume(thread)
end

return SunBeam