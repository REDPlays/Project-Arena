local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local Assets = ReplicatedStorage.Assets
local CharacterModels = Assets.CharacterModels
local UI = Assets.UI

local Burn = {}

Burn.InState = {}
local Color = Color3.fromRGB(255, 119, 0)

local maxStacks = 2
local burnDamage = .5
local currTick = 0
local maxTick = 1

function Burn:CheckState(target: Model)
    return Burn.InState[target]
end

function Burn:AddTarget(target: Model, duration)
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

    Stats:SetAttribute("Burn", true)

    if Burn.InState[target] then
        Burn.InState[target].currTime = 0
        Burn.InState[target].duration = duration
        
        if Burn.InState[target].burnCount < maxStacks then
            Burn.InState[target].burnCount += 1
        end

        return
    end

    local VFX_ID = "Burn_" .. HttpService:GenerateGUID(false)

    local prevIcon = HolderFrame:FindFirstChild("Burn")
    if prevIcon then
        prevIcon:Destroy()
    end

    local Icon = UI.StatusIcons.Burn:Clone()
    Icon.Name = "Burn"
    Icon.Parent = HolderFrame

    VisualEffectServer:SpawnEffectsInRange(
        "Burn",
        nil,
        target,
        {},
        1000,
        VFX_ID
    )

    Burn.InState[target] = {
        target = target,
        duration = duration,
        currTime = 0,
        burnCount = 1,
        Icon = Icon,
        VFX_ID = VFX_ID,
    }
end

function Burn:RemoveTarget(target: Model)
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

    Stats:SetAttribute("Burn", nil)

    if Burn.InState[target] then
        if Burn.InState[target].Icon then
            Burn.InState[target].Icon:Destroy()
        end

        VisualEffectServer:TerminateVFX(
            "Burn",
            nil,
            Burn.InState[target].target,
            {},
            Burn.InState[target].VFX_ID
        )

        Burn.InState[target] = nil
    end
end

function Burn:Update(deltaTime: number)
    currTick += deltaTime
    if currTick < maxTick then
        return
    end

    currTick = 0

    for targetId, data in pairs(Burn.InState) do
        if data.currTime >= data.duration then
            Burn:RemoveTarget(targetId)
            continue
        end

        data.currTime += 1

        local Stats = data.target:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        local humanoid = data.target:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            HealthManager:Damage(data.target, burnDamage * data.burnCount, nil)
        end
    end
end

return Burn