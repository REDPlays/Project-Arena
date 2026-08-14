local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ReaperVFX = VFXAssets:WaitForChild("Reaper")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ReapersBlightVFX = {}
ReapersBlightVFX.__index = ReapersBlightVFX

function ReapersBlightVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, ReapersBlightVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ReapersBlightVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = ReapersBlightVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ReapersBlightVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ReapersBlightVFX"
    self.Folder.Parent = workspace.VFX
    
    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)

    self:Slice()
end

function ReapersBlightVFX:Terminate()
    
end

function ReapersBlightVFX:Update(deltaTime)
    
end

function ReapersBlightVFX:Slice()
    local slice = ReaperVFX.ReapersBlight.Slice:Clone()
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
    TweenService:Create(slice, info, {Orientation = slice.Orientation + Vector3.new(0, -720, 0)}):Play()

    for _, particle in pairs(slice:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount"))
        end
    end
end

function ReapersBlightVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return ReapersBlightVFX