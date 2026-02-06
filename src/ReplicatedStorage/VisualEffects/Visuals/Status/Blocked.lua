local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local Blocked = {}
Blocked.__index = Blocked

function Blocked.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Blocked)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Blocked:Activate(target, sourceUnit, conditionalData)
    local vfx = Blocked.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Blocked:DisplayVFX()
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
    Highlight.FillColor = Color3.fromRGB(134, 255, 255)
    Highlight.Parent = self.sourceUnit

    local sfx1 = Sounds.Base.Block:Clone()
    sfx1.Volume = .1
    sfx1._Pitch.Octave = math.random(95,  105) / 100
    sfx1.Parent = self.rootPart
    sfx1:Play()
    Debris:AddItem(sfx1)

    Debris:AddItem(Highlight, lifeTime)

    local info = TweenInfo.new(lifeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Highlight, info, {FillTransparency = 1, OutlineTransparency = 1}):Play()
end

function Blocked:Terminate()
    for _, particle in pairs(self.Fire:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle.Enabled = false
        end
    end

    Debris:AddItem(self.Folder, 1)
end

function Blocked:Update(deltaTime)
    
end

return Blocked