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

    Stats:SetAttribute("Stunned", true)
    Stats:SetAttribute("AbilityLocked", true)

    if Stunned.InState[target] then
        Stunned.InState[target].currTime = 0
        Stunned.InState[target].duration = duration
        Stunned.InState[target].stunCount += 1

        return
    end

    local display = UI.StatusUI:Clone()
    display.Adornee = UIAttach
    display.StatusName.Text = "STUNNED"
    display.StatusName.TextColor3 = Color
    display.Parent = target

    Stunned.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
        stunCount = 1,
        prevSpeed = humanoid.WalkSpeed,
        display = display,
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

    humanoid.WalkSpeed = Stunned.InState[target].prevSpeed

    if Stunned.InState[target] then
        if Stunned.InState[target].display then
            Stunned.InState[target].display:Destroy()
        end

        Stunned.InState[target] = nil
    end
end

function Stunned:Update(deltaTime)
    for targetId, data in pairs(Stunned.InState) do
        if data.currTime >= data.duration then
            Stunned:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime
    end
end

return Stunned