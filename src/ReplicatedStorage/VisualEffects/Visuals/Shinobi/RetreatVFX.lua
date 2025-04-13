local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ShinobiVFX = VFXAssets:WaitForChild("Shinobi")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Retreat = {}
Retreat.__index = Retreat

function Retreat.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Retreat)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Retreat:Activate(target, sourceUnit, conditionalData)
    local vfx = Retreat.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Retreat:DisplayVFX()
    local floorCFrame = self.conditionalData.floorCFrame

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "RetreatVFX"
    self.Folder.Parent = workspace.VFX

    self.floorVFX = ShinobiVFX.Retreat.Floor:Clone()
    self.floorVFX.CFrame = floorCFrame * CFrame.new(0, self.floorVFX.Size.Y/2, 0)
    self.floorVFX.Transparency = 1
    self.floorVFX.Parent = self.Folder

    self.dagger = ShinobiVFX.Retreat.Dagger:Clone()
    self.dagger.CFrame = floorCFrame * CFrame.new(0, self.dagger.Size.Z, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    self.dagger.Parent = self.Folder

    self.sfx1 = Sounds.Shinobi.Totem:Clone()
    self.sfx1.Volume = 1.5
    self.sfx1._Pitch.Octave = math.random(95,  105) / 100
    self.sfx1.Parent = self.dagger
    self.sfx1:Play()

    local info = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
    self.Tween = TweenService:Create(self.dagger, info, {Position = self.dagger.Position + Vector3.new(0, 1, 0)})
    self.Tween:Play()
end

function Retreat:RunFunction(target, sourceUnit, conditionalData)
    
end

function Retreat:Terminate()
    if self.Tween then
        self.Tween:Cancel()
    end

    if self.dagger then
        self.dagger:Destroy()
    end

    if self.sfx1 then
        self.sfx1:Stop()
    end

    if self.floorVFX then
        for _, object in pairs(self.floorVFX:GetDescendants()) do
            if object:IsA("ParticleEmitter") then
                object.Enabled = false
                object:Emit(object:GetAttribute("EmitCount"))
            end
        end

        self.sfx2 = Sounds.Shinobi.Teleport:Clone()
        self.sfx2.Volume = 1
        self.sfx2._Pitch.Octave = math.random(95,  105) / 100
        self.sfx2.Parent = self.floorVFX
        self.sfx2:Play()
    end

    task.delay(1, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function Retreat:Update(deltaTime)
    
end

return Retreat