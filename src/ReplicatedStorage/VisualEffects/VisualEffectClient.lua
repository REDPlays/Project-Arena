local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local VisualEffectData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("VisualEffectData"))

local VisualEffectClient = {}

local ActiveVisualEffects = {}

function VisualEffectClient:SpawnEffects(vfxName, target, sourceUnit, conditionalData, VFX_ID, runFunction, displayRange)
    displayRange = displayRange or 1000
    
    local  LocalCharacter = LocalPlayer.Character
    if not LocalCharacter then  return end

    local LocalRoot = LocalCharacter:FindFirstChild("HumanoidRootPart")
    if  not LocalRoot then return end

    local sourceRoot = sourceUnit:FindFirstChild("HumanoidRootPart")
    if not sourceRoot then return end

    local distance = (LocalRoot.Position - sourceRoot.Position).Magnitude
    if distance >= displayRange then
        return
    end

    if ActiveVisualEffects[VFX_ID] then
        if runFunction then
            ActiveVisualEffects[VFX_ID].Instance:RunFunction(target, sourceUnit, conditionalData)
        end
        return
    end

    local VFX_Instance
    if VisualEffectData[vfxName] and not runFunction then
        VFX_Instance = VisualEffectData[vfxName]:Activate(target, sourceUnit, conditionalData)

        if VFX_ID then
            ActiveVisualEffects[VFX_ID] = {}
            ActiveVisualEffects[VFX_ID].vfxName = vfxName
            ActiveVisualEffects[VFX_ID].sourceUnit = sourceUnit

            if VFX_Instance then
                ActiveVisualEffects[VFX_ID].Instance = VFX_Instance
            end
        end
    end
end

function VisualEffectClient:TerminateVFX(vfxName, target, sourceUnit, conditionalData, VFX_ID)
    if ActiveVisualEffects[VFX_ID] then
        ActiveVisualEffects[VFX_ID].Instance:Terminate(target, sourceUnit, conditionalData)

        ActiveVisualEffects[VFX_ID] = nil
    end
end

function VisualEffectClient:Update(deltaTime)
    for VFX_ID, visualData in pairs(ActiveVisualEffects) do
        if visualData.Instance.Update then
            visualData.Instance:Update(deltaTime)
        end

        if visualData.Instance.isTerminate then
            VisualEffectClient:TerminateVFX(
                visualData.vfxName,
                nil,
                visualData.sourceUnit,
                {},
                VFX_ID
            )
        end
    end
end

local function SpawnEffects(vfxName, target, sourceUnit, conditionalData, VFX_ID, runFunction)
    VisualEffectClient:SpawnEffects(vfxName, target, sourceUnit, conditionalData, VFX_ID, runFunction)
end

local function TerminateVFX(vfxName, target, sourceUnit, conditionalData, VFX_ID)
    VisualEffectClient:TerminateVFX(vfxName, target, sourceUnit, conditionalData, VFX_ID)
end

Events.Server_Client.VisualEffects.OnClientEvent:Connect(SpawnEffects)
Events.Server_Client.TerminateVFX.OnClientEvent:Connect(TerminateVFX)

return VisualEffectClient