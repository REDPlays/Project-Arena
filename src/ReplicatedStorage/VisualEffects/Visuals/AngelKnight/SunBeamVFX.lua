local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local AngelKnightVFX = VFXAssets:WaitForChild("AngelKnight")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

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

    self:Beam()
end

function SunBeam:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function SunBeam:Terminate()
    Debris:AddItem(self.Folder, 2)
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

    self.sfx1 = Sounds.AngelKnight.Beam:Clone()
    self.sfx1.Volume = .25
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.Beam
    self.sfx1:Play()

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

function SunBeam:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local HitVFX = AngelKnightVFX.AngelicCharge.Hit:Clone()
    HitVFX.Transparency = 1
    HitVFX.CFrame = targetRoot.CFrame
    HitVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitVFX
    weld.Part1 = targetRoot
    weld.Parent = weld.Part0

    local sfx2: Sound = Sounds.AngelKnight.Impact:Clone()
    sfx2.Volume = .25
    sfx2._Pitch.Octave = math.random(95,  105) / 100
    sfx2.PlaybackSpeed = 2
    sfx2.Parent = HitVFX
    sfx2:Play()

    for _, particle in pairs(HitVFX:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount"))
        end
    end
end

return SunBeam