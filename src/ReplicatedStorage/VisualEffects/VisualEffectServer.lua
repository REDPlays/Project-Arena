local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local VisualEffectData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("VisualEffectData"))

local VisualEffectServer = {}

function VisualEffectServer:SpawnEffectsInRange(
    vfxName,
    target,
    sourceUnit,
    conditionalData,
    displayRange,
    VFX_ID,
    runFunction
)

    conditionalData = conditionalData or {}
    displayRange = displayRange or 1000

    if not vfxName then
        return
    end

    if not sourceUnit then
        return
    end

    if not VisualEffectData[vfxName] then
        return
    end

    local sourceRootPart = sourceUnit:FindFirstChild("HumanoidRootPart")
    if not sourceRootPart then
        return
    end
    
    for _, player in pairs(Players:GetChildren()) do
        local character = player.Character
        if not character then
            continue
        end
        
        local playerRootPart = character:FindFirstChild("HumanoidRootPart")
        if not playerRootPart then
            continue
        end

        local distance = (playerRootPart.Position - sourceRootPart.Position).Magnitude
        if distance < displayRange then
            --Fire to Client Visual Effects Manager
           Events.Server_Client.VisualEffects:FireClient(
                player,
                vfxName,
                target,
                sourceUnit,
                conditionalData,
                VFX_ID,
                runFunction
           )
        end
    end
end

function VisualEffectServer:TerminateVFX(
    vfxName,
    target,
    sourceUnit,
    conditionalData,
    VFX_ID
)
    conditionalData = conditionalData or {} 
    warn("1")

    if not vfxName then
        return
    end
    warn("2")
    if not sourceUnit then
        return
    end
    warn("3")
    if not VisualEffectData[vfxName] then
        return
    end
    warn("4")
    for _, player in pairs(Players:GetChildren()) do
        local character = player.Character
        if not character then
            continue
        end
        
        local playerRootPart = character:FindFirstChild("HumanoidRootPart")
        if not playerRootPart then
            continue
        end

        Events.Server_Client.TerminateVFX:FireClient(
            player,
            vfxName,
            target,
            sourceUnit,
            conditionalData,
            VFX_ID
        )
    end
end

return VisualEffectServer