local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ShieldWarriorVFX = VFXAssets:WaitForChild("ShieldWarrior")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ShieldBashVFX = {}
ShieldBashVFX.__index = ShieldBashVFX

function ShieldBashVFX.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ShieldBashVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ShieldBashVFX:Activate(target, sourceUnit, conditionalData)
    local vfx = ShieldBashVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ShieldBashVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Gear = self.sourceUnit:FindFirstChild("Gear")
    if not self.Gear then
        return
    end

    self.Wepaon = self.Gear:FindFirstChild("Weapon")
    if not self.Wepaon then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ShieldBashVFX"
    self.Folder.Parent = workspace.VFX
    Debris:AddItem(self.Folder, 2)

    self:Bash()
end

function ShieldBashVFX:Terminate()
    
end

function ShieldBashVFX:Update(deltaTime)
    
end

function ShieldBashVFX:Bash()
    self.Burst = ShieldWarriorVFX.ShieldBash.Burst:Clone()
    self.Burst.CFrame = self.rootPart.CFrame * CFrame.new(0, 0, -2)
    self.Burst.Transparency = 1
    self.Burst.Anchored = true
    self.Burst.Parent = self.Folder

    self.Burst.Attachment.Ring1:Emit(1)
    self.Burst.Attachment.Center:Emit(3)
    self.Burst.Attachment.Ring2.Enabled = true
    self.Burst.Attachment.Squares.Enabled = true

    task.delay(.25, function()
        self.Burst.Attachment.Ring2.Enabled = false
        self.Burst.Attachment.Squares.Enabled = false
    end)
end

return ShieldBashVFX