local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ReaperVFX = VFXAssets:WaitForChild("Reaper")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local GrimReapingVFX = {}
GrimReapingVFX.__index = GrimReapingVFX

function GrimReapingVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, GrimReapingVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function GrimReapingVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = GrimReapingVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function GrimReapingVFX:DisplayVFX()
    self.dashDuration = self.conditionalData.dashDuration

    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Stats = self.sourceUnit:FindFirstChild("Stats")
    if not self.Stats then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "GrimReapingVFX"
    self.Folder.Parent = workspace.VFX

    self:Dash()
    task.delay(self.dashDuration, function()
        self:Slice()
    end)

    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function GrimReapingVFX:Terminate()
    
end

function GrimReapingVFX:Dash()
    self.dashVFX = ReaperVFX.GrimReaping.Dash:Clone()
    self.dashVFX.CFrame = self.rootPart.CFrame * CFrame.new(0, 0, -2)
    self.dashVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.dashVFX
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    task.delay(self.dashDuration, function()
        for _, particle in pairs(self.dashVFX:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    end)
end

function GrimReapingVFX:Slice()
    self.sliceVFX = ReaperVFX.GrimReaping.Slice:Clone()
    self.sliceVFX.CFrame = self.rootPart.CFrame
    self.sliceVFX.Parent = self.Folder

    for _, particle in pairs(self.sliceVFX:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount"))
        end
    end
end

function GrimReapingVFX:Update(deltaTime)
    
end

function GrimReapingVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return GrimReapingVFX