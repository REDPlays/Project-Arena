local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local TemplateVFX = {}
TemplateVFX.__index = TemplateVFX

function TemplateVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, TemplateVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function TemplateVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = TemplateVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function TemplateVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Stats = self.sourceUnit:FindFirstChild("Stats")
    if not self.Stats then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "TemplateVFX"
    self.Folder.Parent = workspace.VFX

    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
    
end

function TemplateVFX:Terminate()
    
end

function TemplateVFX:Update(deltaTime)
    
end

function TemplateVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return TemplateVFX