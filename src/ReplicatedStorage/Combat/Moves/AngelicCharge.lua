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

local IgnoreFolder = workspace.Ignore

local AngelicCharge = {}

function AngelicCharge:Activate(character, rootPart, placementCFrame, classData, moveType)
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

    local duration = .25
    local currTime = 0

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

                alreadyHit[parent.Name] = true

                local isBlocking = StateManager:CheckState(parent, "Blocking")
                if isBlocking then
                    --Block Indication
                    warn("block angelic charge")
                    continue
                end

                --apply burn
                if classData.MoveData[moveType].Burn then
                    StateManager:AddTarget(parent, "Burn", 3)
                end

                StateManager:AddTarget(parent, "Attacked", 1)

                HealthManager:Damage(parent, damage)
            end
            
            task.wait()
        end
    end)

    Debris:AddItem(Hitbox, duration * 2)

    coroutine.resume(thread)

    local dashData = {
        duration = duration,
        speed = 100,
        isDash = true,
    }

    Events.Server_Client.Movement:FireAllClients(character, dashData)
end

return AngelicCharge