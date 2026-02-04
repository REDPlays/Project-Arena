local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local HydromancerVFX = VFXAssets:WaitForChild("Hydromancer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local WaterBall = {}
WaterBall.__index = WaterBall

function WaterBall.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, WaterBall)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function WaterBall:Activate(target, sourceUnit, conditionalData)
    local vfx = WaterBall.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function WaterBall:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "WaterBalllVFX"
    self.Folder.Parent = workspace.VFX

    self:Ball()
end

function WaterBall:Terminate(target, sourceUnit, conditionalData)
    if self.weld then
        self.weld:Destroy()
    end

    if self.waterBall  then
        self.waterBall .Anchored = true
        for _, particle in pairs(self.waterBall:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    end

    self:Explode(conditionalData.spawnCFrame)
end

function WaterBall:Update(deltaTime)
    
end

function WaterBall:Ball()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    if not self.conditionalData.projectile then
        return
    end

    self.WaterStart = HydromancerVFX.WaterStart:Clone()
    self.WaterStart.Transparency = 1
    self.WaterStart.CFrame = self.rootPart.CFrame * CFrame.new(0, 0, -2)
    self.WaterStart.Parent = self.Folder

    self.WaterStart.Attachment.Ring:Emit(1)
    self.WaterStart.Attachment.Water:Emit(12)
    self.WaterStart.Attachment.Water2:Emit(12)
    
    self.waterBall = HydromancerVFX.WaterBall:Clone()
    self.waterBall.Transparency = 1
    self.waterBall.CFrame = self.conditionalData.projectile.CFrame
    self.waterBall.Parent = self.Folder

    self.sfx2 = Sounds.Hydromancer.WaterLoop:Clone()
    self.sfx2.Volume = .4
    self.sfx2._Pitch.Octave = math.random(95,  105) / 100
    self.sfx2.Parent = self.waterBall
    self.sfx2:Play()

    self.weld = Instance.new("WeldConstraint")
    self.weld.Part0 = self.waterBall
    self.weld.Part1 = self.conditionalData.projectile
    self.weld.Parent = self.weld.Part0

    task.delay(self.conditionalData.duration * .75, function()
        local info = TweenInfo.new(self.conditionalData.duration * .25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(self.sfx2, info, {Volume = 0}):Play()
    end)
end

function WaterBall:Explode(spawnCFrame)
    self.WaterHit = HydromancerVFX.WaterHit:Clone()
    self.WaterHit.Transparency = 1
    self.WaterHit.CFrame = spawnCFrame
    self.WaterHit.Parent = self.Folder

    self.sfx3 = Sounds.Hydromancer.WaterHit:Clone()
    self.sfx3.Volume = .65
    self.sfx3._Pitch.Octave = math.random(95,  105) / 100
    self.sfx3.Parent = self.WaterHit
    self.sfx3:Play()

    self.WaterHit.Water:Emit(8)
    self.WaterHit.Water2:Emit(8)

    task.delay(1, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

return WaterBall