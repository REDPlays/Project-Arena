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

    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function ShurikenThrow:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function ShurikenThrow:Terminate()
    
end

function ShurikenThrow:Update(deltaTime)
    
end

function ShurikenThrow:Throw(startCFrame, endCFrame, size)
    startCFrame *= CFrame.new(0, 2, 0)

    local xSize = size.X/2
    local zSize = size.Z/2

    local count = 10
    local angle = 0
    for i=1, count do
        local newCFrame = startCFrame * CFrame.Angles(0, 0, math.rad(angle))
        local newEnd = endCFrame * CFrame.new(0, 0, math.random(-zSize, zSize)) * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, 0, -math.random(-xSize, xSize))

        local shuriken = ShinobiVFX.ShurikenThrow.Shuriken:Clone()
        shuriken.CFrame = newCFrame
        shuriken.Parent = self.Folder

        if i==1 then
            self.sfx1 = Sounds.Shinobi.Shuriken:Clone()
            self.sfx1.Volume = .5
            self.sfx1._Pitch.Octave = math.random(95,  105) / 100
            self.sfx1.Parent = shuriken
            self.sfx1:Play()
        end

        local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(shuriken, info, {Position = newEnd.Position}):Play()

        angle += 360/count
    end
end

function ShurikenThrow:Hit(target)
    
end

return ShurikenThrow