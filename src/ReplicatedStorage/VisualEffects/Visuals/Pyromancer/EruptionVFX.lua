local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local PyromancerVFX = VFXAssets:WaitForChild("Pyromancer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Eruption = {}
Eruption.__index = Eruption

function Eruption.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Eruption)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Eruption:Activate(target, sourceUnit, conditionalData)
    local vfx = Eruption.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Eruption:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "EruptionVFX"
    self.Folder.Parent = workspace.VFX
    
    Debris:AddItem(self.Folder, 2)

    self:Explosion()
end

function Eruption:Terminate()
    
end

function Eruption:Update(deltaTime)
    
end

function Eruption:Explosion()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    if not self.conditionalData.spawnCFrame then
        return
    end

    self.size = self.conditionalData.size
    if not self.size then
        return
    end

    self.Bubble = PyromancerVFX.Eruption.Bubble:Clone()
    self.Bubble.CFrame = self.conditionalData.spawnCFrame
    self.Bubble.Size = Vector3.new(.1, .1, .1)
    self.Bubble.Parent = self.Folder

    self.Fire = PyromancerVFX.Eruption.Eruption2:Clone()
    self.Fire.CFrame = self.conditionalData.spawnCFrame
    self.Fire.Transparency = 1
    self.Fire.Parent = self.Folder

    self.sfx1 = Sounds.Base.MagicSpawn:Clone()
    self.sfx1.Volume = .25
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.Bubble
    self.sfx1:Play()

    self.sfx2 = Sounds.Pyromancer.Eruption:Clone()
    self.sfx2.Volume = .25
    self.sfx2._Pitch.Octave = math.random(95,  105) / 100
    self.sfx2.Parent = self.Bubble
    self.sfx2:Play()

    self.Fire.Attachment.Fire:Emit(50)
    self.Fire.Attachment.Fire2:Emit(50)
    self.Fire.Attachment.Ring:Emit(1)

    local info = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local info2 = TweenInfo.new(.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, .125)
    TweenService:Create(self.Bubble, info, {Size = self.size}):Play()
    TweenService:Create(self.Bubble, info2, {Transparency = 1}):Play()
end

return Eruption