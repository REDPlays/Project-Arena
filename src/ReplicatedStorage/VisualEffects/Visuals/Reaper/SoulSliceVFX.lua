local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ReaperVFX = VFXAssets:WaitForChild("Reaper")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SoulSliceVFX = {}
SoulSliceVFX.__index = SoulSliceVFX

function SoulSliceVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, SoulSliceVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function SoulSliceVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = SoulSliceVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function SoulSliceVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "SoulSliceVFX"
    self.Folder.Parent = workspace.VFX
    
    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)

    self:Slice()
end

function SoulSliceVFX:Terminate()
    
end

function SoulSliceVFX:Update(deltaTime)
    
end

function SoulSliceVFX:Slice()
    local slice = ReaperVFX.SoulSlice.Slice:Clone()
    slice.CFrame = self.rootPart.CFrame
    slice.Parent = self.Folder

    local sfx1 = Sounds.Reaper.Slice:Clone()
    sfx1.Volume = .25
    sfx1._Pitch.Octave = math.random(95,  105) / 100
    sfx1.Parent = slice
    sfx1:Play()

    local sfx2 = Sounds.Reaper["Slice Blood"]:Clone()
    sfx2.Volume = .25
    sfx2._Pitch.Octave = math.random(95,  105) / 100
    sfx2.Parent = slice
    sfx2:Play()

    local info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    TweenService:Create(slice, info, {Orientation = slice.Orientation + Vector3.new(0, 720, 0)}):Play()

    for _, particle in pairs(slice:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount"))
        end
    end
end

function SoulSliceVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return SoulSliceVFX