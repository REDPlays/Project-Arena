local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Assets = ReplicatedStorage.Assets
local CharacterModels = Assets.CharacterModels
local UI = Assets.UI

local Silenced = {}

Silenced.InState = {}

function Silenced:CheckState(target: Model)
    return Silenced.InState[target]
end

function Silenced:AddTarget(target: Model, duration)
    if not target then
        return
    end

    if Silenced.InState[target] then
        return
    end

    if not duration then
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

    Stats:SetAttribute("AbilityLocked", true)
    Stats:SetAttribute("Silenced", true)

    local prevIcon = HolderFrame:FindFirstChild("Stunned")
    if prevIcon then
        prevIcon:Destroy()
    end

    local Icon = UI.StatusIcons.Silenced:Clone()
    Icon.Name = "Silenced"
    Icon.Parent = HolderFrame

    Silenced.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
        Icon = Icon,
    }
end

function Silenced:RemoveTarget(target: Model)
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

    Stats:SetAttribute("AbilityLocked", false)
    Stats:SetAttribute("Silenced", false)

    if Silenced.InState[target] then
        if Silenced.InState[target].Icon then
            Silenced.InState[target].Icon:Destroy()
        end

        Silenced.InState[target] = nil
    end
end

function Silenced:Update(deltaTime)
    for targetId, data in pairs(Silenced.InState) do
        if data.currTime >= data.duration then
            Silenced:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Silenced