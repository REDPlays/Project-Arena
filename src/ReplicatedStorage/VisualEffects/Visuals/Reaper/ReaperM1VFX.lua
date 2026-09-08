local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ReaperVFX = VFXAssets:WaitForChild("Reaper")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ReaperM1 = {}
ReaperM1.__index = ReaperM1

function ReaperM1.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, ReaperM1)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ReaperM1:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = ReaperM1.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ReaperM1:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Stats = self.sourceUnit:FindFirstChild("Stats")
    if not self.Stats then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ReaperM1"
    self.Folder.Parent = workspace.VFX

    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)

    self:Swing()
end

function ReaperM1:Terminate()
    
end

function ReaperM1:Update(deltaTime)
    
end

function ReaperM1:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function ReaperM1:Swing()
    local isAwakened = self.Stats:GetAttribute("Awakened")

    self.swing1 = ReaperVFX.M1s.Swing:Clone() :: Model
    self.swing1.Swing.Transparency = 1
    self.swing1:PivotTo(self.rootPart.CFrame)
    self.swing1.Parent = self.Folder
    self.swing1:ScaleTo(not isAwakened and 1 or 1.5)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.swing1.Swing
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    local container = self.swing1.Swing["Swing"..self.conditionalData.moveCount]
    container.Layer1:Emit(1)
    container.Layer2:Emit(3)

    task.delay(0.2, function()
        container.Layer1.LockedToPart = false
        container.Layer2.LockedToPart = false
    end)

    self.sfx1 = Sounds.Base.LargeWeaponSwipe:Clone()
    self.sfx1.Volume = .35
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.swing1.Swing
    self.sfx1:Play()
end

function ReaperM1:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local HitVFX = ReaperVFX.M1s.Hit:Clone()
    HitVFX.Transparency = 1
    HitVFX.CFrame = CFrame.lookAt(targetRoot.Position, self.rootPart.Position, Vector3.new(0, 1, 0)) * CFrame.Angles(0, math.rad(180), 0)
    HitVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitVFX
    weld.Part1 = targetRoot
    weld.Parent = weld.Part0

    local sfx2 = Sounds.Base.LargeWeaponHit:Clone()
    sfx2.Volume = .25
    sfx2._Pitch.Octave = math.random(95,  105) / 100
    sfx2.Parent = HitVFX
    sfx2:Play()

    for _, particle in pairs(HitVFX:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount"))
        end
    end
end

return ReaperM1