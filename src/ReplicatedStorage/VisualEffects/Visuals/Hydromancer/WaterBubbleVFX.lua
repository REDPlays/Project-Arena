local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local HydromancerVFX = VFXAssets:WaitForChild("Hydromancer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local WaterBubbleVFX = {}
WaterBubbleVFX.__index = WaterBubbleVFX

function WaterBubbleVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, WaterBubbleVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function WaterBubbleVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = WaterBubbleVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function WaterBubbleVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then return end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "WaterBubbleVFX"
    self.Folder.Parent = workspace.VFX

    self:AddBubble()
end

function WaterBubbleVFX:AddBubble()
    self.bubble = HydromancerVFX.WaterBubble:Clone()
    self.bubble.CFrame = self.floorCFrame * CFrame.new(0, 3, 0)
    self.bubble.Parent = self.Folder

    self.weld = Instance.new("WeldConstraint")
    self.weld.Part0 = self.bubble
    self.weld.Part1 = self.rootPart
    self.weld.Parent = self.weld.Part0

    if self.conditionalData.maxStacks then
        self.healRange = HydromancerVFX.HealRange:Clone()
        self.healRange.CFrame = self.floorCFrame
        self.healRange.Parent = self.Folder

        self.weld2 = Instance.new("WeldConstraint")
        self.weld2.Part0 = self.healRange
        self.weld2.Part1 = self.rootPart
        self.weld2.Parent = self.weld2.Part0
    end
end

function WaterBubbleVFX:Terminate()
    if self.bubble then
        for _, obj in pairs(self.bubble:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj.Enabled = false
            end
        end

        local info = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(self.bubble, info, {Transparency = 1}):Play()
    end
    
    if self.healRange then
        
    end

    if self.Folder then
        Debris:AddItem(self.Folder, 2)
    end
end

function WaterBubbleVFX:Update(deltaTime)
    
end

function WaterBubbleVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return WaterBubbleVFX