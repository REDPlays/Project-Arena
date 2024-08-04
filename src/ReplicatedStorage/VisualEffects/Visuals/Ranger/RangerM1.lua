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
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "RangerVFX"
    self.Folder.Parent = workspace.VFX

    self:Bullet()
end

function Ranger:Terminate(target, sourceUnit, conditionalData)
    self:Hit(conditionalData.spawnCFrame)
end

function Ranger:Update(deltaTime)
    
end

function Ranger:Bullet()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    if not self.conditionalData.projectile then
        return
    end

    local shootSound = Sounds.Ranger.Shot:Clone()
    shootSound.Volume = 0.3
    shootSound._Pitch.Octave = math.random(90,  95) / 100
    shootSound.Parent = self.rootPart
    shootSound:Play()
end

function Ranger:Hit(spawnCFrame)
    local HitVFX = RangerVFX.M1s.Hit:Clone()
    HitVFX.CFrame = spawnCFrame
    HitVFX.Transparency = 1
    HitVFX.Parent = self.Folder

    local hitSound = Sounds.Ranger.Hit:Clone()
    hitSound.Volume = 0.3
    hitSound._Pitch.Octave = math.random(90,  95) / 100
    hitSound.Parent = self.conditionalData.projectile
    hitSound:Play()

    Debris:AddItem(self.Folder, 2.5)
end

return Ranger