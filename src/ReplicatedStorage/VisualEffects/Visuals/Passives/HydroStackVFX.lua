local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local HydromancerVFX = VFXAssets:WaitForChild("Hydromancer")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local HydroStack = {}
HydroStack.__index = HydroStack

function HydroStack.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, HydroStack)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function HydroStack:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = HydroStack.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function HydroStack:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "HydroStackVFX"
    self.Folder.Parent = workspace.VFX

    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")

    self.distance = 6
    self.rotSpeed = 90
    self.currentRotation = 0
    
    self.stacks = {}

    self:Add(self.target, self.sourceUnit, self.conditionalData)
end

function HydroStack:Terminate()
    if self.Folder then
        for i=1, #self.stacks do
            local currentStack = self.stacks[i]
            currentStack:Destroy()
        end
        self.stacks = {}

        Debris:AddItem(self.Folder, 1)
    end
end

function HydroStack:Update(deltaTime)
    self.currentRotation += self.rotSpeed * deltaTime

    local anglePivot = 360 / #self.stacks

    for i=1, #self.stacks do
        local currentStack = self.stacks[i]

        local angle = anglePivot * i

        currentStack.CFrame = self.rootPart.CFrame * CFrame.Angles(0, math.rad(angle + self.currentRotation), 0) * CFrame.new(0, 0, -self.distance)
    end
end

function HydroStack:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    if conditionalData.add then
        self:Add(target, self.sourceUnit, conditionalData)
    elseif conditionalData.remove then

    end
end

function HydroStack:Add(target: Model, sourceUnit: Model, conditionalData: {})
    local newBubble = HydromancerVFX.BubbleStack:Clone()
    newBubble.Transparency = 1
    newBubble.CFrame = self.rootPart.CFrame
    newBubble.Parent = self.Folder

    table.insert(self.stacks, newBubble)
end

function HydroStack:Remove(target: Model, sourceUnit: Model, conditionalData: {})
    if #self.stacks > 0 then
        local stack = self.stacks[1]
        table.remove(self.stacks, 1)
        stack:Destroy()
    end
end

return HydroStack