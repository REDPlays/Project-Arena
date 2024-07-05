local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local SamuraiVFX = VFXAssets:WaitForChild("Samurai")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SamuraM1 = {}
SamuraM1.__index = SamuraM1

function SamuraM1.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, SamuraM1)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function SamuraM1:Activate(target, sourceUnit, conditionalData)
    local vfx = SamuraM1.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function SamuraM1:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "SamuraM1VFX"
    self.Folder.Parent = workspace.VFX
    
    Debris:AddItem(self.Folder, 2)

    self:Slash()
end

function SamuraM1:Terminate()
    
end

function SamuraM1:Update(deltaTime)

end

function SamuraM1:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function SamuraM1:Slash()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.slash = SamuraiVFX.M1s.Slash:Clone()
    self.slash.Transparency = 1
    self.slash.CFrame = self.rootPart.CFrame
    self.slash.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.slash
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    if self.conditionalData.moveCount == 2 then
        self.slash.Slash2.Particle:Emit(1)
    else
        self.slash.Slash1.Particle:Emit(1)
    end

    self.sfx1 = Sounds.Base.SwordSwipe:Clone()
    self.sfx1.Volume = .25
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.slash
    self.sfx1:Play()
end

function SamuraM1:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local HitVFX = SamuraiVFX.M1s.Hit:Clone()
    HitVFX.Transparency = 1
    HitVFX.CFrame = CFrame.lookAt(targetRoot.Position, self.rootPart.Position, Vector3.new(0, 1, 0)) * CFrame.Angles(0, math.rad(180), 0)
    HitVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitVFX
    weld.Part1 = targetRoot
    weld.Parent = weld.Part0

    self.sfx2 = Sounds.Base.SwordHit:Clone()
    self.sfx2.Volume = .25
    self.sfx2._Pitch.Octave = math.random(95,  105) / 100
    self.sfx2.Parent = HitVFX
    self.sfx2:Play()

    for _, particle in pairs(HitVFX:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount"))
        end
    end

    local timing = .25
    local info = TweenInfo.new(timing, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    local info2 = TweenInfo.new(timing, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, .25)

    TweenService:Create(HitVFX.A0, info, {Position = Vector3.new(4, 0, 0)}):Play()
    TweenService:Create(HitVFX.A1, info, {Position = Vector3.new(-4, 0, 0)}):Play()
    TweenService:Create(HitVFX.Beam, info2, {Width0 = 0, Width1 = 0}):Play()
end

return SamuraM1