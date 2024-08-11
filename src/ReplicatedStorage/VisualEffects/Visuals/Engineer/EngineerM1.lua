local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local EngineerVFX = VFXAssets:WaitForChild("Engineer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Engineer = {}
Engineer.__index = Engineer

function Engineer.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Engineer)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Engineer:Activate(target, sourceUnit, conditionalData)
    local vfx = Engineer.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Engineer:DisplayVFX()
    self.gear = self.sourceUnit:FindFirstChild("Gear")
    if not self.gear then
        return
    end

    self.weapon = self.gear:FindFirstChild("Weapon")
    if not self.weapon then
        return
    end

    self.Barrel = self.weapon.PrimaryPart
    if not self.Barrel then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "EngineerVFX"
    self.Folder.Parent = workspace.VFX

    self:Bullet()
end

function Engineer:Terminate(target, sourceUnit, conditionalData)
    self:Hit(target)
end

function Engineer:Update(deltaTime)
    
end

function Engineer:Bullet()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    if not self.conditionalData.projectile then
        return
    end

    self.Spread = EngineerVFX.M1s.FireSpread:Clone()
    self.Spread.CFrame = self.Barrel.CFrame
    self.Spread.Transparency = 1
    self.Spread.Parent = self.Folder

    self.Bullet = EngineerVFX.M1s.Bullet:Clone()
    self.Bullet.Transparency = 1
    self.Bullet.CFrame = self.conditionalData.projectile.CFrame
    self.Bullet.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.Bullet
    weld.Part1 = self.conditionalData.projectile
    weld.Parent = weld.Part0

    local weld2 = Instance.new("WeldConstraint")
    weld2.Part0 = self.Spread
    weld2.Part1 = self.Barrel
    weld2.Parent = weld.Part0

    for _, particle in pairs(self.Spread:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end

    local shootSound = Sounds.Engineer.Shot:Clone()
    shootSound.Volume = 0.3
    shootSound._Pitch.Octave = math.random(90,  95) / 100
    shootSound.Parent = self.rootPart
    shootSound:Play()
    Debris:AddItem(shootSound, shootSound.TimeLength)
end

function Engineer:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    self.Bullet.Anchored = true

    for _, particle in pairs(self.Bullet:GetDescendants()) do
        if particle:IsA("ParticleEmitter") or particle:IsA("Beam") or particle:IsA("Trail") then
            particle.Enabled = false
        end
    end

    local HitVFX = EngineerVFX.M1s.Hit:Clone()
    HitVFX.CFrame = targetRoot.CFrame
    HitVFX.Transparency = 1
    HitVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitVFX
    weld.Part1 = targetRoot 
    weld.Parent = weld.Part0

    HitVFX.Attachment.Ring:Emit(3)
    HitVFX.Attachment.Squares:Emit(24)
    HitVFX.Attachment.Center:Emit(3)

    Debris:AddItem(self.Folder, 2.5)
end

return Engineer