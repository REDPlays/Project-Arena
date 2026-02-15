local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Assets = ReplicatedStorage.Assets
local CharacterModels = Assets.CharacterModels
local UI = Assets.UI

local Stunned = {}

Stunned.InState = {}
local Color = Color3.fromRGB(255, 255, 255)

function Stunned:CheckState(target: Model)
    return Stunned.InState[target]
end

function Stunned:AddTarget(target: Model, duration)
    if not target then
        return
    end

    if not duration then
        return
    end

    local Stats = target:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid: Humanoid = target:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local rootPart = target:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local StatusUI = target:FindFirstChild("StatusUI")
    if not StatusUI then
        return
    end

    local HolderFrame = StatusUI:FindFirstChild("Holder")
    if not HolderFrame then
        return
    end

    Stats:SetAttribute("Stunned", true)
    Stats:SetAttribute("AbilityLocked", true)

    if Stunned.InState[target] then
        Stunned.InState[target].currTime = 0
        Stunned.InState[target].duration = duration
        Stunned.InState[target].stunCount += 1

        return
    end

    local prevIcon = HolderFrame:FindFirstChild("Stunned")
    if prevIcon then
        prevIcon:Destroy()
    end

    local Icon = UI.StatusIcons.Stunned:Clone()
    Icon.Name = "Stunned"
    Icon.Parent = HolderFrame

    Stunned.InState[target] = {
        target = target,
        Stats = Stats,
        duration = duration,
        currTime = 0,
        stunCount = 1,
        prevSpeed = Stats:GetAttribute("Speed"),
        prevJump = humanoid.JumpHeight,
        Icon = Icon,
    }

    humanoid.WalkSpeed = 0
end

function Stunned:RemoveTarget(target: Model)
    if not target then
        return
    end

    local Stats = target:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = target:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    Stats:SetAttribute("Stunned", false)
    Stats:SetAttribute("AbilityLocked", false)

    if not Stats:GetAttribute("Slowed") then
        humanoid.WalkSpeed = Stunned.InState[target].prevSpeed
        humanoid.JumpHeight = Stunned.InState[target].prevJump
    end

    if Stunned.InState[target] then
        if Stunned.InState[target].Icon then
            Stunned.InState[target].Icon:Destroy()
        end

        Stunned.InState[target] = nil
    end
end

function Stunned:Update(deltaTime)
    for targetId, data in pairs(Stunned.InState) do
        if data.target then
            local humanoid = data.target:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.WalkSpeed = 0
                humanoid.JumpHeight = 0
            end
        end

        if data.currTime >= data.duration then
            Stunned:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Stunned