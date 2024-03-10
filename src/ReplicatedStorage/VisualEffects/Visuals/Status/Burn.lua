local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local BurnVFX = VFXAssets:WaitForChild("Burn")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Burn = {}
Burn.__index = Burn

function Burn.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Burn)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Burn:Activate(target, sourceUnit, conditionalData)
    local vfx = Burn.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Burn:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "BurnVFX"
    self.Folder.Parent = workspace.VFX

    self:Fire()
end

function Burn:Terminate()
    for _, particle in pairs(self.Fire:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle.Enabled = false
        end
    end

    Debris:AddItem(self.Folder, 1)
end

function Burn:Update(deltaTime)
    
end

function Burn:Fire()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Fire = BurnVFX.Fire:Clone()
    self.Fire.Transparency = 1
    self.Fire.CFrame = self.rootPart.CFrame
    self.Fire.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.Fire
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0
end

return Burn