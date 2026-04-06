local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local AngelKnightVFX = VFXAssets:WaitForChild("AngelKnight")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Utils = ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Utils")
local VFX_Utilities = require(Utils:WaitForChild("VFX_Utilities"))

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
    
    task.delay(1, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)

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

    local Center = self.Beam.Center
    local A0 = Center.A0
    local A1 = Center.A1
    local Beam = Center.Beam
    local Beam2 = Center.Beam2

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

    local range = 10
    local attachRange = (4 * range)/3

    A0.Position = Vector3.new(0, A0.Position.Y, 0)
    A1.Position = Vector3.new(0, A1.Position.Y, 0)
    
    Beam.CurveSize0 = 0
    Beam.CurveSize1 = 0
    Beam2.CurveSize0 = 0
    Beam2.CurveSize1 = 1

    Beam.Enabled = true
    Beam2.Enabled = true

    local info1 = TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local info2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    TweenService:Create(self.Beam.A1, info1, {Position = Vector3.new(0, 9, 0)}):Play()
    TweenService:Create(self.Beam.Beam, info2, {Width0 = 0, Width1 = 0}):Play()

    local beamInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    VFX_Utilities:TweenBeams(
        {
            [0] = Beam,
            [1] = Beam2,
        },
        {
            [0] = A0, 
            [1] = A1
        },
        beamInfo,
        {
            [0] = {Width0 = 0, Width1 = 0, CurveSize0 = attachRange, CurveSize1 = -attachRange},
            [1] = {Width0 = 0, Width1 = 0, CurveSize0 = -attachRange, CurveSize1 = attachRange},
        },
        {
            [0] = {
                 Position = A0.Position - Vector3.new(10, A0.Position.Y, 0),
            }, 
            [1] = {
                Position = A1.Position - Vector3.new(-10, A1.Position.Y, 0),
            }
        }
    )

    task.delay(.15, function()
        self.Beam.Particle1.Enabled = false
        self.Beam.Particle2.Enabled = false
    end)
end

return HolyBeam