local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local BaseVFX = VFXAssets:WaitForChild("Base")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local IndicatorNumbers = require(ReplicatedStorage.RepFiles.Combat.Constants.IndicatorNumbers)

function round(n)
    return math.floor(n * 10) / 10
end

local IndicatorNumberVFX = {}
IndicatorNumberVFX.__index = IndicatorNumberVFX

function IndicatorNumberVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, IndicatorNumberVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function IndicatorNumberVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = IndicatorNumberVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function IndicatorNumberVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Stats = self.sourceUnit:FindFirstChild("Stats")
    if not self.Stats then
        return
    end

    self.lifetime = 1
    self.amount = self.conditionalData.amount

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "IndicatorNumberVFX"
    self.Folder.Parent = workspace.VFX

    self:CreateNumber()

    task.delay(self.lifetime, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function IndicatorNumberVFX:CreateNumber()
    local centerCFrame = CFrame.new(self.rootPart.Position)

    local xOffset = math.random(25, 125)/100
    local yOffset = math.random(25, 125)/100
    local zOffset = math.random(25, 125)/100

    local upVelocity = math.random(5, 35)/10
    local forVelocity = math.random(5, 35)/10

    local indicatorColor
    if self.conditionalData.isDamage then
        indicatorColor = IndicatorNumbers.Damage
    end

    if self.conditionalData.isHeal then
        indicatorColor = IndicatorNumbers.Heal
    end
    
    if self.conditionalData.isBurn then
        indicatorColor = IndicatorNumbers.Burn
    end

    local display: BasePart = BaseVFX.DisplayNumbers.NumPart:Clone()
    display.CFrame = centerCFrame * CFrame.new(xOffset, yOffset, zOffset)
    display.Orientation = Vector3.new(0, math.random(-180, 180), 0)
    display.Numbers.Indicator.TextColor3 = indicatorColor
    display.Numbers.Indicator.Text = tostring(round(self.amount))
    display.Parent = self.Folder

    local velocity = display.CFrame.LookVector * forVelocity + Vector3.new(0, upVelocity, 0)

    local lineVel = Instance.new("LinearVelocity")
    lineVel.Attachment0 = display.Attachment
    lineVel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    lineVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lineVel.ForceLimitsEnabled = true
    lineVel.VectorVelocity = velocity
    lineVel.Parent = display
    Debris:AddItem(lineVel, 0.1)

    local info = TweenInfo.new(self.lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(display.Numbers.Indicator, info, {TextTransparency = 1}):Play()
end

function IndicatorNumberVFX:Terminate()
    
end

function IndicatorNumberVFX:Update(deltaTime)
    
end

function IndicatorNumberVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return IndicatorNumberVFX