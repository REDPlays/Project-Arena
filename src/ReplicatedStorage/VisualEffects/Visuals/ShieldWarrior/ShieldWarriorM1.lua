local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ShieldWarriorVFX = VFXAssets:WaitForChild("ShieldWarrior")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ShieldWarriorM1 = {}
ShieldWarriorM1.__index = ShieldWarriorM1

function ShieldWarriorM1.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ShieldWarriorM1)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ShieldWarriorM1:Activate(target, sourceUnit, conditionalData)
    local vfx = ShieldWarriorM1.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ShieldWarriorM1:DisplayVFX()
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
    self.Folder.Name = "ShieldWarriorM1VFX"
    self.Folder.Parent = workspace.VFX
    
    Debris:AddItem(self.Folder, 2)

    self:Swing()
end

function ShieldWarriorM1:Terminate()
    
end

function ShieldWarriorM1:Update(deltaTime)
    
end

function ShieldWarriorM1:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function ShieldWarriorM1:Swing()
    self.slash = ShieldWarriorVFX.M1s.Swing:Clone()
    self.slash.Transparency = 1
    self.slash.CFrame = self.rootPart.CFrame
    self.slash.Parent = self.Folder

    if self.conditionalData.moveCount == 1 or self.conditionalData.moveCount == 3 then
        self.slash.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0, math.rad(30))
    elseif self.conditionalData.moveCount == 2 then
        self.slash.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0, math.rad(15))
    end

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.slash
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    self.sfx1 = Sounds.ShieldWarrior.ShieldSwipe:Clone()
    self.sfx1.Volume = .25
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.slash
    self.sfx1:Play()

    local timing1 = .15
    local info = TweenInfo.new(timing1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(self.slash, info, {CFrame = self.slash.CFrame * CFrame.new(0, 0, -2)}):Play()

    task.delay(timing1, function()
        local numVal = Instance.new("NumberValue")
        numVal.Value = 0

        local connect
        connect = numVal.Changed:Connect(function()
            self.slash.Beam.Transparency = NumberSequence.new(numVal.Value, 1)
        end)

        local timing2 = .5
        local info2 = TweenInfo.new(timing2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        TweenService:Create(numVal, info2, {Value = 1}):Play()

        task.delay(timing2, function()
            if connect then
                connect:Disconnect()
            end

            if numVal then
                numVal:Destroy()
            end
        end)
    end)
end

function ShieldWarriorM1:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    self.HitVFX = ShieldWarriorVFX.M1s.Hit:Clone()
    self.HitVFX.Transparency = 1
    self.HitVFX.CFrame = targetRoot.CFrame
    self.HitVFX.Parent = self.Folder

    self.sfx2 = Sounds.ShieldWarrior.ShieldHit:Clone()
    self.sfx2.Volume = .5
    self.sfx2._Pitch.Octave = math.random(90,  95) / 100
    self.sfx2.Parent = self.slash
    self.sfx2:Play()

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.HitVFX
    weld.Part1 = targetRoot 
    weld.Parent = weld.Part0

    self.HitVFX.Attachment.Particle1:Emit(32)
    self.HitVFX.Attachment.Particle1.Enabled = true
    task.delay(.15, function()
        self.HitVFX.Attachment.Particle1.Enabled = false
    end)
end

return ShieldWarriorM1