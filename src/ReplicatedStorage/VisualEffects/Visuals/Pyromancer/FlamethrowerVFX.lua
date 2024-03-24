local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local PyromancerVFX = VFXAssets:WaitForChild("Pyromancer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Flamethrower = {}
Flamethrower.__index = Flamethrower

function Flamethrower.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Flamethrower)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Flamethrower:Activate(target, sourceUnit, conditionalData)
    local vfx = Flamethrower.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Flamethrower:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "FlamethrowerVFX"
    self.Folder.Parent = workspace.VFX
    
    Debris:AddItem(self.Folder, 4)

    self:Fire()
end

function Flamethrower:Terminate()
    
end

function Flamethrower:Update(deltaTime)
    
end

function Flamethrower:Fire()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Flame = PyromancerVFX.Flamethrower.Flamethrower2:Clone()
    self.Flame.Transparency = 1
    self.Flame.CFrame = self.rootPart.CFrame * CFrame.new(0, 0, -3)
    self.Flame.Parent = self.Folder

    self.sfx1 = Sounds.Base.MagicSpawn:Clone()
    self.sfx1.Volume = .25
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.Flame
    self.sfx1:Play()

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.Flame
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    self.sfx2 = Sounds.Pyromancer.FireLoop:Clone()
    self.sfx2.Volume = .25
    self.sfx2._Pitch.Octave = math.random(95,  105) / 100
    self.sfx2.Parent = self.Flame
    self.sfx2:Play()

    task.delay(3, function()
        if weld then
            weld:Destroy()
        end

        local info = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(self.sfx2, info, {Volume = 0}):Play()

        self.Flame.Anchored = true
        
        for _, particle in pairs(self.Flame:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    end)
end

return Flamethrower