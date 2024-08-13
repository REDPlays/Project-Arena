local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local EngineerVFX = VFXAssets:WaitForChild("Engineer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local TurretShot = {}
TurretShot.__index = TurretShot

function TurretShot.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, TurretShot)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    if conditionalData.sourceUnit then
        newVFX.sourceUnit = conditionalData.sourceUnit
    end

    newVFX.isTerminate = false

    return newVFX
end

function TurretShot:Activate(target, sourceUnit, conditionalData)
    local vfx = TurretShot.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function TurretShot:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "EngineerVFX"
    self.Folder.Parent = workspace.VFX

    self:Bullet()
end

function TurretShot:Terminate(target, sourceUnit, conditionalData)
    if self.Bullet then
        self.Bullet.Anchored = true
    end

    self:Hit(conditionalData.spawnCFrame)
end

function TurretShot:Update(deltaTime)
    
end

function TurretShot:Bullet()
    self.primaryPart = self.sourceUnit.PrimaryPart
    if not self.primaryPart then
        return
    end

    if not self.conditionalData.projectile then
        return
    end

    self.Spread = EngineerVFX.Turret.FireSpread:Clone()
    self.Spread.CFrame = self.primaryPart.CFrame
    self.Spread.Transparency = 1
    self.Spread.Parent = self.Folder

    self.Bullet = EngineerVFX.Turret.Bullet:Clone()
    self.Bullet.Transparency = 1
    self.Bullet.CFrame = self.conditionalData.projectile.CFrame
    self.Bullet.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.Bullet
    weld.Part1 = self.conditionalData.projectile
    weld.Parent = weld.Part0

    local weld2 = Instance.new("WeldConstraint")
    weld2.Part0 = self.Spread
    weld2.Part1 = self.primaryPart
    weld2.Parent = weld.Part0

    for _, particle in pairs(self.Spread:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end

    local shootSound: Sound = Sounds.Engineer.Shot:Clone()
    shootSound.Volume = 0.3
    shootSound._Pitch.Octave = math.random(90,  95) / 100
    shootSound.Parent = self.primaryPart
    shootSound:Play()
    Debris:AddItem(shootSound, shootSound.TimeLength)
end

function TurretShot:Hit(spawnCFrame)
    for _, particle in pairs(self.Bullet:GetDescendants()) do
        if particle:IsA("ParticleEmitter") or particle:IsA("Beam") or particle:IsA("Trail") then
            particle.Enabled = false
        end
    end

    local HitVFX = EngineerVFX.M1s.Hit:Clone()
    HitVFX.CFrame = spawnCFrame
    HitVFX.Anchored = true
    HitVFX.Transparency = 1
    HitVFX.Parent = self.Folder

    HitVFX.Attachment.Ring:Emit(3)
    HitVFX.Attachment.Squares:Emit(24)
    HitVFX.Attachment.Center:Emit(3)

    Debris:AddItem(self.Folder, 2.5)
end

return TurretShot