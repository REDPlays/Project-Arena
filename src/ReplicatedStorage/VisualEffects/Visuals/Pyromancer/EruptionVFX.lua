local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local PyromancerVFX = VFXAssets:WaitForChild("Pyromancer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Eruption = {}
Eruption.__index = Eruption

function Eruption.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Eruption)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Eruption:Activate(target, sourceUnit, conditionalData)
    local vfx = Eruption.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Eruption:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end
    
    self.range = self.conditionalData.range
    if not self.range then
        return
    end

    self.startupTime = self.conditionalData.startupTime
    if not self.startupTime then
        return
    end

    self.canFollow = true

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "EruptionVFX"
    self.Folder.Parent = workspace.VFX

    self.erupt = PyromancerVFX.Eruption.Eruption3:Clone()
    self.erupt.CFrame = self.sourceUnit:GetPivot() + Vector3.new(0, .1, 0)
    self.erupt.Transparency = 1
    self.erupt.Anchored = true
    self.erupt.Parent = self.Folder

    local newLifetime = NumberRange.new(self.startupTime, self.startupTime)
    self.erupt.Indicator.Floor.Lifetime = newLifetime
    self.erupt.Indicator.Floor2.Lifetime = newLifetime

    self.erupt.Indicator.Floor:Emit(1)
    self.erupt.Indicator.Floor2:Emit(1)

    task.delay(self.startupTime, function()
        self:Explosion()

        if self.weld then
            self.weld:Destroy()
        end

        if self.erupt then
            self.erupt.Anchored = true
        end
    end)
end

function Eruption:Terminate()
    task.delay(1, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function Eruption:Update(deltaTime)
    if self.canFollow and self.erupt and self.sourceUnit then
        local newCFrame = self.sourceUnit:GetPivot() + Vector3.new(0, .1, 0)
        self.erupt.Position = newCFrame.Position
    end
end

function Eruption:Explosion()
    if self.erupt then
        for _, particle in pairs(self.erupt.Explosion:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end

        self.sfx1 = Sounds.Base.MagicSpawn:Clone()
        self.sfx1.Volume = .25
        self.sfx1._Pitch.Octave = math.random(95,  105) / 100
        self.sfx1.Parent = self.erupt
        self.sfx1:Play()

        self.sfx2 = Sounds.Pyromancer.Eruption:Clone()
        self.sfx2.Volume = .25
        self.sfx2._Pitch.Octave = math.random(95,  105) / 100
        self.sfx2.Parent = self.erupt
        self.sfx2:Play()
    end
end

return Eruption