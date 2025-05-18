local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Assets = ReplicatedStorage.Assets
local CharacterModels = Assets.CharacterModels
local UI = Assets.UI

local Slow = {}

Slow.InState = {}
local Color = Color3.fromRGB(160, 190, 255)

function Slow:CheckState(target: Model)
    return Slow.InState[target]
end

function Slow:AddTarget(target: Model, duration, additionalData)
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

    local newSpeed = 4
    if additionalData and additionalData.WalkSpeed then
        newSpeed = additionalData.WalkSpeed
    end

    if Slow.InState[target] then
        Slow.InState[target].currTime = 0
        Slow.InState[target].duration = duration
        Slow.InState[target].speed = newSpeed

        humanoid.WalkSpeed = newSpeed
        
        return
    end

    Stats:SetAttribute("Slowed", true)

    local prevIcon = HolderFrame:FindFirstChild("Slowed")
    if prevIcon then
        prevIcon:Destroy()
    end

    local Icon = UI.StatusIcons.Slowed:Clone()
    Icon.Name = "Slowed"
    Icon.Parent = HolderFrame

    Slow.InState[target] = {
        target = target,
        Stats = Stats,
        duration = duration,
        currTime = 0,
        prevSpeed = Stats:GetAttribute("Speed"),
        speed = newSpeed,
        Icon = Icon,
    }

    humanoid.WalkSpeed = newSpeed
end

function Slow:RemoveTarget(target: Model)
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

    Stats:SetAttribute("Slowed", false)

    if not Stats:GetAttribute("Stunned") then
        humanoid.WalkSpeed = Slow.InState[target].prevSpeed
    end

    if Slow.InState[target] then
        if Slow.InState[target].Icon then
            Slow.InState[target].Icon:Destroy()
        end

        Slow.InState[target] = nil
    end
end

function Slow:Update(deltaTime)
    for targetId, data in pairs(Slow.InState) do
        if data.target then
            local Stats = data.Stats
            if not Stats then
                continue
            end
            
            local humanoid = data.target:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if not Stats:GetAttribute("Stunned") then
                    humanoid.WalkSpeed = data.speed
                end
            end
        end

        if data.currTime >= data.duration then
            Slow:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Slow