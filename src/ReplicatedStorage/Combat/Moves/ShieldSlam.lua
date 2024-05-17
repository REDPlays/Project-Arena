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

local ShieldSlam = {}

function ShieldSlam:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    Stats:SetAttribute("AbilityLocked", true)

    local duration = 1

    task.delay(duration, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    local size = classData.Hitboxes[moveType].Size
    local startCFrame = character:GetPivot() * classData.Hitboxes[moveType].Offset

    local alreadyHit = {}
    for _=1, 3 do
        local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
        Hitbox.Transparency = 1
        if ShowHitboxes then
            Hitbox.Transparency = .5
        end

        Hitbox.Size = classData.Hitboxes[moveType].Size
        Hitbox.Anchored = true
        Hitbox.CFrame = startCFrame
        Hitbox.Parent = IgnoreFolder

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
                warn("block Shield Slam")

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

            --apply knockup
            if classData.MoveData[moveType].Knockup then
                StateManager:AddTarget(parent, "Knockup", 50)
            end

            StateManager:AddTarget(parent, "Attacked", 1)

            HealthManager:Damage(parent, damage, character)
        end

        Debris:AddItem(Hitbox, duration)

        startCFrame *= CFrame.new(0, 0, -size.Z)

        task.wait(.05)
    end

    alreadyHit = nil
end

return ShieldSlam