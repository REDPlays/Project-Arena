local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local Assets = ReplicatedStorage.Assets
local CharacterModels = Assets.CharacterModels
local UI = Assets.UI

local Burn = {}

Burn.InState = {}
local Color = Color3.fromRGB(255, 119, 0)

local maxStacks = 3
local burnDamage = .005
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

    local UIAttach = rootPart:FindFirstChild("UI")
    if not UIAttach then
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

    local display = UI.StatusUI:Clone()
    display.Adornee = UIAttach
    display.StatusName.Text = "BURNED"
    display.StatusName.TextColor3 = Color
    display.Parent = target

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
        display = display,
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
        if Burn.InState[target].display then
            Burn.InState[target].display:Destroy()
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

function Burn:Update(deltaTime)
    for targetId, data in pairs(Burn.InState) do
        if data.currTime >= data.duration then
            Burn:RemoveTarget(targetId)
            continue
        end

        data.currTime += deltaTime

        local Stats = data.target:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        local humanoid = data.target:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local isDummy = CollectionService:HasTag(data.target, "Dummies")
            if isDummy and humanoid.Health <= burnDamage * data.burnCount then
                continue
            end
            
            humanoid:TakeDamage(burnDamage * data.burnCount)

            local health = humanoid.Health 
            local maxHealth = humanoid.MaxHealth

            Stats:SetAttribute("Health", health)
            Stats:SetAttribute("MaxHealth", maxHealth)
        end
    end
end

return Burn