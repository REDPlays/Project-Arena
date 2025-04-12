local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ShinobiVFX = VFXAssets:WaitForChild("Shinobi")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ShurikenThrow = {}
ShurikenThrow.__index = ShurikenThrow

function ShurikenThrow.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ShurikenThrow)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ShurikenThrow:Activate(target, sourceUnit, conditionalData)
    local vfx = ShurikenThrow.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ShurikenThrow:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ShurikenThrowVFX"
    self.Folder.Parent = workspace.VFX

    local startCFrame = self.conditionalData.startCFrame
    local endCFrame = self.conditionalData.endCFrame
    local size = self.conditionalData.Size

    self:Throw(startCFrame, endCFrame, size)
end

function ShurikenThrow:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function ShurikenThrow:Terminate()
    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function ShurikenThrow:Update(deltaTime)
    
end

function ShurikenThrow:Throw(startCFrame, endCFrame, size)
    startCFrame *= CFrame.new(0, 2, 0)
end

function ShurikenThrow:Hit(target)
    
end

return ShurikenThrow