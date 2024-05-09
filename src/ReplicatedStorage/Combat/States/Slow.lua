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

function Slow:AddTarget(target: Model, duration)
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

    local UIAttach = rootPart:FindFirstChild("UI")
    if not UIAttach then
        return
    end

    if Slow.InState[target] then
        Slow.InState[target].currTime = 0
        Slow.InState[target].duration = duration
        
        return
    end

    Stats:SetAttribute("Slowed", true)

    local display = UI.StatusUI:Clone()
    display.Adornee = UIAttach
    display.StatusName.Text = "SLOWED"
    display.StatusName.TextColor3 = Color
    display.Parent = target

    Slow.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
        prevSpeed = humanoid.WalkSpeed,
        display = display,
    }

    humanoid.WalkSpeed = 4
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

    humanoid.WalkSpeed = Slow.InState[target].prevSpeed

    if Slow.InState[target] then
        if Slow.InState[target].display then
            Slow.InState[target].display:Destroy()
        end

        Slow.InState[target] = nil
    end
end

function Slow:Update(deltaTime)
    for targetId, data in pairs(Slow.InState) do
        if data.currTime >= data.duration then
            Slow:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Slow