local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local HealthVFX = VFXAssets:WaitForChild("HealthRegen")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local HealthRegen = {}
HealthRegen.__index = HealthRegen

function HealthRegen.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, HealthRegen)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function HealthRegen:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = HealthRegen.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function HealthRegen:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "HealthRegen"
    self.Folder.Parent = workspace.VFX
    Debris:AddItem(self.Folder, 1)

    self.healing = HealthVFX.Healing:Clone()
    self.healing.Transparency = 1
    self.healing.CFrame = self.rootPart.CFrame
    self.healing.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.healing
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    self.healing.Health:Emit(5)
    self.healing.Attachment.Flat:Emit(1)
end

function HealthRegen:Terminate()
    
end

function HealthRegen:Update(deltaTime)
    
end

function HealthRegen:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return HealthRegen