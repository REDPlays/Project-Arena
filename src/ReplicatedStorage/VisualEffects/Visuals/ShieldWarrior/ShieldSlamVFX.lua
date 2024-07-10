local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ShieldWarriorVFX = VFXAssets:WaitForChild("ShieldWarrior")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ShieldSlamVFX = {}
ShieldSlamVFX.__index = ShieldSlamVFX

function ShieldSlamVFX.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ShieldSlamVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ShieldSlamVFX:Activate(target, sourceUnit, conditionalData)
    local vfx = ShieldSlamVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ShieldSlamVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Gear = self.sourceUnit:FindFirstChild("Gear")
    if not self.Gear then
        return
    end

    self.Wepaon = self.Gear:FindFirstChild("Weapon")
    if not self.Wepaon then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ShieldSlamVFX"
    self.Folder.Parent = workspace.VFX
end

function ShieldSlamVFX:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    elseif conditionalData.isSlam then
        self:Burst(conditionalData.spawnPosition)
    end
end

function ShieldSlamVFX:Terminate()
    Debris:AddItem(self.Folder, 3)
end

function ShieldSlamVFX:Update(deltaTime)
    
end

function ShieldSlamVFX:Burst(spawnPosition)
    local burstParticles = ShieldWarriorVFX.ShieldSlam.Burst:Clone()
    burstParticles.Position = spawnPosition
    burstParticles.Transparency = 1
    burstParticles.Parent = self.Folder

    self.sfx1 = Sounds.ShieldWarrior.SmallRupture:Clone()
    self.sfx1.Volume = .5
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = burstParticles
    self.sfx1:Play()

    for _, particle in pairs(burstParticles:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount") or 5)
        end
    end

    local info1 = TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local info2 = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    TweenService:Create(burstParticles.A1, info1, {Position = Vector3.new(0, 9, 0)}):Play()
    TweenService:Create(burstParticles.Beam, info2, {Width0 = 0, Width1 = 0}):Play()
end

function ShieldSlamVFX:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local HitVFX = ShieldWarriorVFX.ShieldSlam.Hit:Clone()
    HitVFX.Transparency = 1
    HitVFX.CFrame = targetRoot.CFrame
    HitVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitVFX
    weld.Part1 = targetRoot
    weld.Parent = weld.Part0

    local sfx2: Sound = Sounds.ShieldWarrior.SmallRupture:Clone()
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

return ShieldSlamVFX