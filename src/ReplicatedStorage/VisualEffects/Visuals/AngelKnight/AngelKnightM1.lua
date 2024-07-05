local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local AngelKnightVFX = VFXAssets:WaitForChild("AngelKnight")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local AngelKnightM1 = {}
AngelKnightM1.__index = AngelKnightM1

function AngelKnightM1.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, AngelKnightM1)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function AngelKnightM1:Activate(target, sourceUnit, conditionalData)
    local vfx = AngelKnightM1.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function AngelKnightM1:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "AngelKnightM1VFX"
    self.Folder.Parent = workspace.VFX
    
    Debris:AddItem(self.Folder, 2)

    self:Slash()
end

function AngelKnightM1:Terminate()
    
end

function AngelKnightM1:Update(deltaTime)

end

function AngelKnightM1:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function AngelKnightM1:Slash()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.slash = AngelKnightVFX.M1s.Slash:Clone()
    self.slash.Transparency = 1
    self.slash.CFrame = self.rootPart.CFrame
    self.slash.Parent = self.Folder

    if self.conditionalData.moveCount == 1 then
        self.slash.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0, math.rad(-30))
    elseif self.conditionalData.moveCount == 2 then
        self.slash.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0, math.rad(30))
    end

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.slash
    weld.Part1 = self.rootPart
    weld.Parent = weld.Part0

    self.sfx1 = Sounds.Base.SwordSwipe:Clone()
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

function AngelKnightM1:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local HitVFX = AngelKnightVFX.M1s.Hit:Clone()
    HitVFX.Transparency = 1
    HitVFX.CFrame = targetRoot.CFrame
    HitVFX.Parent = self.Folder

    self.sfx2 = Sounds.Base.SwordHit:Clone()
    self.sfx2.Volume = .25
    self.sfx2._Pitch.Octave = math.random(95,  105) / 100
    self.sfx2.Parent = HitVFX
    self.sfx2:Play()

    if self.conditionalData.moveCount == 1 then
        HitVFX.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0, math.rad(30))
    elseif self.conditionalData.moveCount == 2 then
        HitVFX.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0, math.rad(-30))
    end

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitVFX
    weld.Part1 = targetRoot
    weld.Parent = weld.Part0

    local timing = .25
    local info = TweenInfo.new(timing, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    local info2 = TweenInfo.new(timing, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, .25)

    TweenService:Create(HitVFX.A0, info, {Position = Vector3.new(4, 0, 0)}):Play()
    TweenService:Create(HitVFX.A1, info, {Position = Vector3.new(-4, 0, 0)}):Play()
    TweenService:Create(HitVFX.Beam, info2, {Width0 = 0, Width1 = 0}):Play()

    HitVFX.Attachment.Particle1.Enabled = true
    task.delay(.15, function()
        HitVFX.Attachment.Particle1.Enabled = false
    end)
end

return AngelKnightM1