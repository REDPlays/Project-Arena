local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local OniVFX = VFXAssets:WaitForChild("Oni")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Enrage = {}
Enrage.__index = Enrage

function Enrage.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, Enrage)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function Enrage:Activate(target, sourceUnit, conditionalData)
    local vfx = Enrage.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function Enrage:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "EnragedVFX"
    self.Folder.Parent = workspace.VFX

    self:Aura()
end

function Enrage:RunFunction(target, sourceUnit, conditionalData)
    
end

function Enrage:Terminate()
    task.delay(0.75, function()
        if self.aura then
            for _, obj in pairs(self.aura:GetDescendants()) do
                if obj:IsA("ParticleEmitter") then
                    obj.Enabled = false
                end
            end
        end

        Debris:AddItem(self.Folder, 1)
    end)
end

function Enrage:Update(deltaTime)
    if self.Folder and self.aura and self.sourceUnit then
        self.aura.CFrame = self.sourceUnit:GetPivot()
    end
end

function Enrage:Aura()
    self.vfx = OniVFX.Enraged.EnrageVFX:Clone()
    self.vfx.Transparency = 1
    self.vfx.CFrame = self.floorCFrame
    self.vfx.Parent = self.Folder

    self.aura = OniVFX.Enraged.Aura:Clone()
    self.aura.Transparency = 1

    for _, obj in pairs(self.aura:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Enabled = false
        end
    end

    self.aura.CFrame = self.sourceUnit:GetPivot()
    self.aura.Parent = self.Folder

    task.delay(0.75, function()
        for _, obj in pairs(self.vfx:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj.Enabled = false
            end
        end
        
        Debris:AddItem(self.vfx, 1)

        for _, obj in pairs(self.aura:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj.Enabled = true
            end
        end
    end)
end

return Enrage