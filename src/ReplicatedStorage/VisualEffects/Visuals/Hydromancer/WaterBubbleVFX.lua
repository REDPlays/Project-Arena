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
    self.bubble.Position = (self.sourceUnit:GetPivot() * CFrame.new(0, 2, 0)).Position
    self.bubble.Anchored = true
    self.bubble.Parent = self.Folder

    self.floor = HydromancerVFX.BubbleFloor:Clone()
    self.floor.Position = self.sourceUnit:GetPivot().Position
    self.floor.Anchored = true
    self.floor.Parent = self.Folder

    self.sfx2 = Sounds.Hydromancer.UnderWater:Clone()
    self.sfx2.Volume = .75
    self.sfx2._Pitch.Octave = math.random(95,  105) / 100
    self.sfx2.Parent = self.bubble
    self.sfx2:Play()

    if self.conditionalData.maxStacks then
        self.floor.Attachment.Floor.Rate = 3
        self.floor.Attachment.Floor.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 16),
            NumberSequenceKeypoint.new(1, 16)
        })
    end
end

function WaterBubbleVFX:Terminate()
    local spinInfo = TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    if self.bubble then
        for _, obj in pairs(self.bubble:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj.Enabled = false
            end
        end

        TweenService:Create(self.bubble, spinInfo, {
            Orientation = self.bubble.Orientation + Vector3.new(0, 180, 0)
        }):Play()
    end

    if self.floor then
        for _, obj in pairs(self.floor:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj.Enabled = false
            end
        end

        TweenService:Create(self.floor, spinInfo, {
            Orientation = self.floor.Orientation + Vector3.new(0, 180, 0)
        }):Play()
    end

    if self.sfx2 then
        local info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        TweenService:Create(self.sfx2, info, {Volume = 0}):Play()
    end

    if self.Folder then
        Debris:AddItem(self.Folder, 2)
    end
end

function WaterBubbleVFX:Update(deltaTime)
    if self.bubble then
        self.bubble.Position = (self.sourceUnit:GetPivot() * CFrame.new(0, 2, 0)).Position
        self.bubble.Orientation += Vector3.new(0, 1, 0)
    end

    if self.floor then
        self.floor.Position = self.sourceUnit:GetPivot().Position
        self.floor.Orientation += Vector3.new(0, 1, 0)
    end
end

function WaterBubbleVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return WaterBubbleVFX