local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local OniVFX = VFXAssets:WaitForChild("Oni")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SumoStance = {}
SumoStance.__index = SumoStance

function SumoStance.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, SumoStance)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function SumoStance:Activate(target, sourceUnit, conditionalData)
    local vfx = SumoStance.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function SumoStance:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "SumoStanceVFX"
    self.Folder.Parent = workspace.VFX

    self.stompVFX = OniVFX.SumoStance.Stomp:Clone() :: BasePart
    self.stompVFX.CFrame = self.floorCFrame
    self.stompVFX.Transparency = 1
    self.stompVFX.Parent = self.Folder
end

function SumoStance:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isStomp then
        self:Stomp()
    end
end

function SumoStance:Terminate()
    if self.Folder then
        Debris:AddItem(self.Folder, 1)
    end
end

function SumoStance:Update(deltaTime)
    
end

function SumoStance:Stomp()
    if self.stompVFX then
        for _, obj in pairs(self.stompVFX:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj:Emit(obj:GetAttribute("EmitCount"))
            end
        end
    end
end

return SumoStance