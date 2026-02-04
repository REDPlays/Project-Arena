local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local HydroStack = {}

HydroStack.InPassive = {}

local maxStacks = 3
local currTick = 0
local maxTick = 1

function HydroStack:CheckPassive(target: Model)
    return HydroStack.InPassive[target]
end

function HydroStack:AddStack(target: Model, passiveData: {})
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

    local rootPart = target:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    if not HydroStack.InPassive[target] then
        local VFX_ID = "HydroStack" .. HttpService:GenerateGUID(false)

        HydroStack.InPassive[target] = {
            target = target,
            stack = 1,
            VFX_ID = VFX_ID,
        }
        
        Stats:SetAttribute("HydroStack", 1)

        VisualEffectServer:SpawnEffectsInRange(
            "HydroStack",
            nil,
            target,
            {},
            1000,
            VFX_ID
        )
    elseif HydroStack.InPassive[target] then
        HydroStack.InPassive[target].stack += 1
        if HydroStack.InPassive[target].stack > maxStacks then
            HydroStack.InPassive[target].stack = maxStacks
        else
            VisualEffectServer:SpawnEffectsInRange(
                "HydroStack",
                nil,
                target,
                {add = true},
                1000,
                HydroStack.InPassive[target].VFX_ID,
                true
            )
        end

        Stats:SetAttribute("HydroStack", HydroStack.InPassive[target].stack)
    end
end

function HydroStack:RemoveStack(target: Model)
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

    local rootPart = target:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    if not HydroStack.InPassive[target] then
        return
    end

    HydroStack.InPassive[target].stack -= 1

    if HydroStack.InPassive[target].stack <= 0 then
        HydroStack.InPassive[target] = nil

        Stats:SetAttribute("HydroStack", nil)

        VisualEffectServer:TerminateVFX(
            "HydroStack",
            nil,
            target,
            {},
            HydroStack.InPassive[target].VFX_ID
        )
    else
        VisualEffectServer:SpawnEffectsInRange(
            "HydroStack",
            nil,
            target,
            {remove = true},
            1000,
            HydroStack.InPassive[target].VFX_ID,
            true
        )
    end
end

function HydroStack:ClearStack(target: Model)
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

    local rootPart = target:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    if not HydroStack.InPassive[target] then
        return
    end

    HydroStack.InPassive[target] = nil
    
    Stats:SetAttribute("HydroStack", nil)

    VisualEffectServer:TerminateVFX(
        "HydroStack",
        nil,
        target,
        {},
        HydroStack.InPassive[target].VFX_ID
    )
end

function HydroStack:Update(deltaTime: number)
    
end

return HydroStack