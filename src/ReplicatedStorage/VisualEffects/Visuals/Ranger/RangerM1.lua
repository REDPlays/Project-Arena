local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local RangerVFX = VFXAssets:WaitForChild("Ranger")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Ranger = {}
Ranger.__index = Ranger

function Ranger.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Ranger)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Ranger:Activate(target, sourceUnit, conditionalData)
    local vfx = Ranger.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Ranger:DisplayVFX()
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
    self.Folder.Name = "RangerVFX"
    self.Folder.Parent = workspace.VFX

    self:Arrow()
end

function Ranger:Terminate(target, sourceUnit, conditionalData)
    if self.Arrow then
        self.Arrow.Anchored = true
    end

    self:Hit(conditionalData.spawnCFrame)
end

function Ranger:Update(deltaTime)
    if self.Arrow then
        local trail2 = self.Arrow:FindFirstChild("Trail2")
        if trail2 then
            trail2.CFrame *= CFrame.Angles(0, 0, math.rad(-10))
        end
    end
end

function Ranger:Arrow()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    if not self.conditionalData.projectile then
        return
    end

    self.Spread = RangerVFX.M1s.FireSpread:Clone()
    self.Spread.CFrame = self.Barrel.CFrame
    self.Spread.Transparency = 1
    self.Spread.Parent = self.Folder

    self.Arrow = RangerVFX.M1s.Arrow:Clone()
    self.Arrow.Transparency = 1
    self.Arrow.CFrame = self.conditionalData.projectile.CFrame
    self.Arrow.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.Arrow
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

    local shootSound = Sounds.Ranger.Shot:Clone()
    shootSound.Volume = 0.3
    shootSound._Pitch.Octave = math.random(90,  95) / 100
    shootSound.Parent = self.rootPart
    shootSound:Play()
    Debris:AddItem(shootSound, shootSound.TimeLength)
end

function Ranger:Hit(spawnCFrame)
    for _, particle in pairs(self.Arrow:GetDescendants()) do
        if particle:IsA("ParticleEmitter") or particle:IsA("Beam") or particle:IsA("Trail") then
            particle.Enabled = false
        end
    end

    local HitVFX = RangerVFX.M1s.Hit:Clone()
    HitVFX.CFrame = spawnCFrame
    HitVFX.Anchored = true
    HitVFX.Transparency = 1
    HitVFX.Parent = self.Folder

    HitVFX.Attachment.Ring:Emit(3)
    HitVFX.Attachment.Triangles:Emit(24)
    HitVFX.Attachment.Center:Emit(3)

    local hitSound = Sounds.Ranger.Hit:Clone()
    hitSound.Volume = 0.3
    hitSound._Pitch.Octave = math.random(90,  95) / 100
    hitSound.Parent = self.conditionalData.projectile
    hitSound:Play()

    task.delay(2.5, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

return Ranger