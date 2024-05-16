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

    task.delay(duration, function()
        if Stats:GetAttribute("AbilityLocked") then
            Stats:SetAttribute("AbilityLocked", false)
        end

        local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
        Hitbox.Transparency = 1
        if ShowHitboxes then
            Hitbox.Transparency = .5
        end

        Hitbox.Size = classData.Hitboxes[moveType].Size
        Hitbox.CFrame = character:GetPivot() * classData.Hitboxes[moveType].Offset
        Hitbox.Parent = IgnoreFolder

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = Hitbox
        weld.Part1 = rootPart
        weld.Parent = weld.Part0

        Debris:AddItem(Hitbox, duration)
    end)

    local bezierData = {
        duration = duration,
        isBezier = true,
        distance = 25,
    }

    Events.Server_Client.Movement:FireAllClients(character, bezierData)
end

return ShieldJump