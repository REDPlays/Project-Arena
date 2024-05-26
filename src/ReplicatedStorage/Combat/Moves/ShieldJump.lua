local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local ShieldJump = {}

function ShieldJump:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    local duration = .5

    local bezierData = {
        duration = duration,
        isBezier = true,
        distance = 25,
    }

    local startCFrame = rootPart.CFrame
    local endCFrame = startCFrame * CFrame.new(0, 0, -bezierData.distance)
    local middleCFrame = startCFrame:Lerp(endCFrame, 0.5) * CFrame.new(0, 20, 0)

    bezierData.startCFrame = startCFrame
    bezierData.endCFrame = endCFrame
    bezierData.middleCFrame = middleCFrame

    task.delay(duration, function()
        VisualEffectServer:SpawnEffectsInRange(
            "ShieldJump",
            nil,
            character,
            {spawnCFrame = endCFrame},
            1000
        )
        
        local alreadyHit = {}

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

        local ray = workspace:Raycast(endCFrame.Position, endCFrame.UpVector * -100, rayparams)
        if ray then
           local floorPosition = ray.Position
           
           local Hitbox: BasePart = Hitboxes.CylinderHitbox:Clone()
            Hitbox.Transparency = 1
            if ShowHitboxes then
                Hitbox.Transparency = .5
            end

            Hitbox.Size = classData.Hitboxes[moveType].Size
            Hitbox.Anchored = true
            Hitbox.CFrame = CFrame.new(floorPosition) * classData.Hitboxes[moveType].Offset
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
        end

        if Stats:GetAttribute("AbilityLocked") then
            Stats:SetAttribute("AbilityLocked", false)
        end
    end)

    Events.Server_Client.Movement:FireAllClients(character, bezierData)
end

return ShieldJump