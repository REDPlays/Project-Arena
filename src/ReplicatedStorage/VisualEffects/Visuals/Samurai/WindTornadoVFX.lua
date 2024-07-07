local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local SamuraiVFX = VFXAssets:WaitForChild("Samurai")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local LocalPlayer = game:GetService("Players").LocalPlayer

local WindTornado = {}
WindTornado.__index = WindTornado

function WindTornado.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, WindTornado)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function WindTornado:Activate(target, sourceUnit, conditionalData)
    local vfx = WindTornado.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function WindTornado:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "WindTornadoVFX"
    self.Folder.Parent = workspace.VFX

    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.hitbox = self.conditionalData.hitbox

    self.duration = self.conditionalData.duration

    self:Tornado()
end

function WindTornado:Terminate()
    for _, particle in pairs(self.Folder:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle.Enabled = false
        end
    end

    Debris:AddItem(self.Folder, 1)
end

function WindTornado:Update(deltaTime)
    if not self.hitbox then
        return
    end

    if not self.vfx then
        return
    end

    self.vfx.CFrame = self.hitbox.CFrame
end

function WindTornado:RunFunction(target, sourceUnit, conditionalData)
    
end

function WindTornado:Tornado()
    self.vfx = SamuraiVFX.WindTornado.Tornado:Clone()
    self.vfx.CFrame = self.hitbox.CFrame
    self.vfx.Transparency = 1
    self.vfx.Parent = self.Folder

    local sfx1 = Sounds.Samurai.Wind:Clone()
    sfx1.Volume = 4
    sfx1._Pitch.Octave = math.random(95,  105) / 100
    sfx1.Parent = self.vfx
    sfx1:Play()

    task.delay(self.duration, function()
        local info = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(sfx1, info, {Volume = 0}):Play()
    end)
end

return WindTornado