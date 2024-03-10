local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local AngelKnightVFX = VFXAssets:WaitForChild("AngelKnight")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SunBeam = {}
SunBeam.__index = SunBeam

function SunBeam.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, SunBeam)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function SunBeam:Activate(target, sourceUnit, conditionalData)
    local vfx = SunBeam.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function SunBeam:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "SunBeamVFX"
    self.Folder.Parent = workspace.VFX
    
    Debris:AddItem(self.Folder, 4)

    self:Beam()
end

function SunBeam:Terminate()
    
end

function SunBeam:Update(deltaTime)
    
end

function SunBeam:Beam()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Beam = AngelKnightVFX.SunBeam.Beam:Clone()
    self.Beam.Transparency = 1
    self.Beam.CFrame = self.floorCFrame * CFrame.new(0, 3, -12)
    self.Beam.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.Beam
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    local info1 = TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(self.Beam.Beam, info1, {Width0 = .5, Width1 = .5}):Play()

    task.delay(3, function()
        if weld then
            weld:Destroy()
        end

        self.Beam.Anchored = true
        
        for _, particle in pairs(self.Beam:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end

        local info2 = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(self.Beam.Beam, info2, {Width0 = 0, Width1 = 0}):Play()
    end)
end

return SunBeam