local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local Damage = {}
Damage.__index = Damage

function Damage.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Damage)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Damage:Activate(target, sourceUnit, conditionalData)
    local vfx = Damage.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Damage:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    local prevHighlight: Highlight = self.sourceUnit:FindFirstChild("HL_Indicator")
    if prevHighlight then
        prevHighlight:Destroy()
    end

    local lifeTime = 0.25

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "HL_Indicator"
    Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    Highlight.OutlineTransparency = 0.75
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0
    Highlight.FillColor = Color3.fromRGB(255, 101, 101)
    Highlight.Parent = self.sourceUnit

    local sfx1 = Sounds.Base.Hurt:Clone()
    sfx1.Volume = .1
    sfx1._Pitch.Octave = math.random(95,  105) / 100
    sfx1.Parent = self.rootPart
    sfx1:Play()
    Debris:AddItem(sfx1)

    Debris:AddItem(Highlight, lifeTime)

    local info = TweenInfo.new(lifeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Highlight, info, {FillTransparency = 1, OutlineTransparency = 1}):Play()
end

function Damage:Terminate()
    for _, particle in pairs(self.Fire:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle.Enabled = false
        end
    end

    Debris:AddItem(self.Folder, 1)
end

function Damage:Update(deltaTime)
    
end

return Damage