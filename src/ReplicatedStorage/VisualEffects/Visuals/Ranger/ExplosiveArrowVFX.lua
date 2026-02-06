local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local RangerVFX = VFXAssets:WaitForChild("Ranger")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ExplosiveArrow = {}
ExplosiveArrow.__index = ExplosiveArrow

function ExplosiveArrow.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ExplosiveArrow)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ExplosiveArrow:Activate(target, sourceUnit, conditionalData)
    local vfx = ExplosiveArrow.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ExplosiveArrow:DisplayVFX()
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

    self.hitbox = self.conditionalData.hitbox
    if not self.hitbox then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "RangerVFX"
    self.Folder.Parent = workspace.VFX

    self:Arrow()
end

function ExplosiveArrow:RunFunction(target, sourceUnit, conditionalData)
    
end

function ExplosiveArrow:Terminate(target, sourceUnit, conditionalData)
    if self.Arrow then
        self.Arrow.Anchored = true
    end

    self:Explode(conditionalData.spawnCFrame)
end

function ExplosiveArrow:Update(deltaTime)
    if self.Arrow then
        local trail2 = self.Arrow:FindFirstChild("Trail2")
        if trail2 then
            trail2.CFrame *= CFrame.Angles(0, 0, math.rad(-5))
        end
    end
end

function ExplosiveArrow:Arrow()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Spread = RangerVFX.ExplosiveArrow.FireSpread:Clone()
    self.Spread.CFrame = self.Barrel.CFrame
    self.Spread.Transparency = 1
    self.Spread.Parent = self.Folder

    self.Arrow = RangerVFX.ExplosiveArrow.Arrow:Clone()
    self.Arrow.Transparency = 1
    self.Arrow.CFrame = self.hitbox.CFrame
    self.Arrow.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.Arrow
    weld.Part1 = self.hitbox
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
    shootSound.Volume = 0.65
    shootSound._Pitch.Octave = math.random(90,  95) / 100
    shootSound.Parent = self.rootPart
    shootSound:Play()
    Debris:AddItem(shootSound, shootSound.TimeLength)
end

function ExplosiveArrow:Explode(spawnCFrame)
    for _, particle in pairs(self.Arrow:GetDescendants()) do
        if particle:IsA("ParticleEmitter") or particle:IsA("Beam") or particle:IsA("Trail") then
            particle.Enabled = false
        end
    end

    self.Explode = RangerVFX.ExplosiveArrow.Explosion:Clone()
    self.Explode.Transparency = 1
    self.Explode.CFrame = spawnCFrame
    self.Explode.Parent = self.Folder

    self.sfx2 = Sounds.Pyromancer.Eruption:Clone()
    self.sfx2.Volume = .25
    self.sfx2._Pitch.Octave = math.random(95,  105) / 100
    self.sfx2.Parent = self.Explode
    self.sfx2:Play()

    for _, particle in pairs(self.Explode:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end

    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

return ExplosiveArrow