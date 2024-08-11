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

    local shootSound: Sound = Sounds.Engineer.Shot:Clone()
    shootSound.Volume = 0.3
    shootSound._Pitch.Octave = math.random(90,  95) / 100
    shootSound.Parent = self.primaryPart
    shootSound:Play()
    Debris:AddItem(shootSound, shootSound.TimeLength)
end

function TurretShot:Hit(spawnCFrame)
    local HitVFX = EngineerVFX.M1s.Hit:Clone()
    HitVFX.CFrame = spawnCFrame
    HitVFX.Transparency = 1
    HitVFX.Parent = self.Folder

    Debris:AddItem(self.Folder, 2.5)
end

return TurretShot