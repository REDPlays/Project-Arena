local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local AngelKnightVFX = VFXAssets:WaitForChild("AngelKnight")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local HolyBeam = {}
HolyBeam.__index = HolyBeam

function HolyBeam.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, HolyBeam)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function HolyBeam:Activate(target, sourceUnit, conditionalData)
    local vfx = HolyBeam.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function HolyBeam:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "HolyBeamVFX"
    self.Folder.Parent = workspace.VFX
    
    Debris:AddItem(self.Folder, 1)

    self:Beam()
end

function HolyBeam:Terminate()
    
end

function HolyBeam:Update(deltaTime)
    
end

function HolyBeam:Beam()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Beam = AngelKnightVFX.HolyBeam.HolyBeam:Clone()
    self.Beam.Transparency = 1
    self.Beam.CFrame = self.floorCFrame
    self.Beam.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.Beam
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    self.sfx1 = Sounds.AngelKnight.Heal:Clone()
    self.sfx1.Volume = .25
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.Beam
    self.sfx1:Play()

    self.Beam.Attachment.Ring:Emit(1)
    self.Beam.Particle1.Enabled = true
    self.Beam.Particle2.Enabled = true

    local info1 = TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local info2 = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    TweenService:Create(self.Beam.A1, info1, {Position = Vector3.new(0, 9, 0)}):Play()
    TweenService:Create(self.Beam.Beam, info2, {Width0 = 0, Width1 = 0}):Play()

    task.delay(.15, function()
        self.Beam.Particle1.Enabled = false
        self.Beam.Particle2.Enabled = false
    end)
end

return HolyBeam