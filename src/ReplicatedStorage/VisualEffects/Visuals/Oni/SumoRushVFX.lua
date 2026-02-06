local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local OniVFX = VFXAssets:WaitForChild("Oni")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SumoRush = {}
SumoRush.__index = SumoRush

function SumoRush.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, SumoRush)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function SumoRush:Activate(target, sourceUnit, conditionalData)
    local vfx = SumoRush.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function SumoRush:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "SumoRushVFX"
    self.Folder.Parent = workspace.VFX

    self:Dash()
end

function SumoRush:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function SumoRush:Terminate()
    if self.charge then
        for _, particle in pairs(self.charge:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    end

    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function SumoRush:Update(deltaTime)
    
end

function SumoRush:Dash()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.charge = OniVFX.SumoRush.Rush:Clone()
    self.charge.Transparency = 1
    self.charge.CFrame = self.rootPart.CFrame * CFrame.new(0, 0, -3)
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
end

function SumoRush:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    
end

return SumoRush