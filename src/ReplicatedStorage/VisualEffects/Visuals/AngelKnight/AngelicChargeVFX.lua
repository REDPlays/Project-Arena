local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local AngelKnightVFX = VFXAssets:WaitForChild("AngelKnight")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local AngelicCharge = {}
AngelicCharge.__index = AngelicCharge

function AngelicCharge.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, AngelicCharge)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function AngelicCharge:Activate(target, sourceUnit, conditionalData)
    local vfx = AngelicCharge.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function AngelicCharge:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "AngelicChargeVFX"
    self.Folder.Parent = workspace.VFX

    self:Dash()
end

function AngelicCharge:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function AngelicCharge:Terminate()
    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function AngelicCharge:Update(deltaTime)
    
end

function AngelicCharge:Dash()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.charge = AngelKnightVFX.AngelicCharge.Charge:Clone()
    self.charge.Transparency = 1
    self.charge.CFrame = self.rootPart.CFrame * CFrame.new(0, 0, -2)
    self.charge.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.charge
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    self.sfx1 = Sounds.AngelKnight.Charge:Clone()
    self.sfx1.Volume = .25
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.charge
    self.sfx1:Play()

    task.delay(.25, function()
        for _, particle in pairs(self.charge:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    end)
end

function AngelicCharge:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local HitVFX = AngelKnightVFX.AngelicCharge.Hit:Clone()
    HitVFX.Transparency = 1
    HitVFX.CFrame = targetRoot.CFrame
    HitVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitVFX
    weld.Part1 = targetRoot
    weld.Parent = weld.Part0

    local sfx2: Sound = Sounds.AngelKnight.Impact:Clone()
    sfx2.Volume = .25
    sfx2._Pitch.Octave = math.random(95,  105) / 100
    sfx2.PlaybackSpeed = 2
    sfx2.Parent = HitVFX
    sfx2:Play()

    for _, particle in pairs(HitVFX:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount"))
        end
    end
end

return AngelicCharge