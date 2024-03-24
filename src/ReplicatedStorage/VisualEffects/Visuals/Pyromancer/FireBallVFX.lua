local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local PyromancerVFX = VFXAssets:WaitForChild("Pyromancer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local FireBall = {}
FireBall.__index = FireBall

function FireBall.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, FireBall)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function FireBall:Activate(target, sourceUnit, conditionalData)
    local vfx = FireBall.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function FireBall:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "FireBallVFX"
    self.Folder.Parent = workspace.VFX

    self:Ball()
end

function FireBall:Terminate(target, sourceUnit, conditionalData)
    if self.weld then
        self.weld:Destroy()
    end

    if self.FireBall  then
        self.FireBall .Anchored = true
        for _, particle in pairs(self.FireBall:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    end

    self:Explode(conditionalData.spawnCFrame)
end

function FireBall:Update(deltaTime)
    
end

function FireBall:Ball()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    if not self.conditionalData.projectile then
        return
    end

    self.FireStart = PyromancerVFX.FireStart:Clone()
    self.FireStart.Transparency = 1
    self.FireStart.CFrame = self.rootPart.CFrame * CFrame.new(0, 0, -2)
    self.FireStart.Parent = self.Folder

    self.sfx1 = Sounds.Base.MagicSpawn:Clone()
    self.sfx1.Volume = .25
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.FireStart
    self.sfx1:Play()

    self.FireStart.Attachment.Ring:Emit(1)
    self.FireStart.Fire:Emit(12)
    self.FireStart.Fire2:Emit(12)
    
    self.FireBall = PyromancerVFX.FireBall:Clone()
    self.FireBall.Transparency = 1
    self.FireBall.CFrame = self.conditionalData.projectile.CFrame
    self.FireBall.Parent = self.Folder

    self.sfx2 = Sounds.Pyromancer.FireLoop:Clone()
    self.sfx2.Volume = .25
    self.sfx2._Pitch.Octave = math.random(95,  105) / 100
    self.sfx2.Parent = self.FireBall
    self.sfx2:Play()

    self.weld = Instance.new("WeldConstraint")
    self.weld.Part0 = self.FireBall
    self.weld.Part1 = self.conditionalData.projectile
    self.weld.Parent = self.weld.Part0

    task.delay(self.conditionalData.duration * .75, function()
        local info = TweenInfo.new(self.conditionalData.duration * .25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(self.sfx2, info, {Volume = 0}):Play()
    end)
end

function FireBall:Explode(spawnCFrame)
    self.FireHit = PyromancerVFX.FireHit:Clone()
    self.FireHit.Transparency = 1
    self.FireHit.CFrame = spawnCFrame
    self.FireHit.Parent = self.Folder

    self.sfx3 = Sounds.Pyromancer.FireHit:Clone()
    self.sfx3.Volume = .25
    self.sfx3._Pitch.Octave = math.random(95,  105) / 100
    self.sfx3.Parent = self.FireHit
    self.sfx3:Play()

    self.FireHit.Attachment.Ring:Emit(2)
    self.FireHit.Fire:Emit(8)
    self.FireHit.Fire2:Emit(8)

    Debris:AddItem(self.Folder, 1)
end

return FireBall