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
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "EngineerVFX"
    self.Folder.Parent = workspace.VFX

    self:Bullet()
end

function Engineer:Terminate(target, sourceUnit, conditionalData)
    self:Hit(conditionalData.spawnCFrame)
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

    local shootSound = Sounds.Engineer.Shot:Clone()
    shootSound.Volume = 0.3
    shootSound._Pitch.Octave = math.random(90,  95) / 100
    shootSound.Parent = self.rootPart
    shootSound:Play()
end

function Engineer:Hit(spawnCFrame)
    local HitVFX = EngineerVFX.M1s.Hit:Clone()
    HitVFX.CFrame = spawnCFrame
    HitVFX.Transparency = 1
    HitVFX.Parent = self.Folder

    Debris:AddItem(self.Folder, 2.5)
end

return Engineer