local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ReaperVFX = VFXAssets:WaitForChild("Reaper")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local EnshroudVFX = {}
EnshroudVFX.__index = EnshroudVFX

function EnshroudVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, EnshroudVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function EnshroudVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = EnshroudVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function EnshroudVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Stats = self.sourceUnit:FindFirstChild("Stats")
    if not self.Stats then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "EnshroudVFX"
    self.Folder.Parent = workspace.VFX

    local whiteList = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

    self.auraParts = {}

    for _, obj in ipairs(self.sourceUnit:GetChildren()) do
        if table.find(whiteList, obj.Name) then
            local aura = ReaperVFX.Enshroud.Aura:Clone()
            aura.Size = obj.Size
            aura.CFrame = obj.CFrame
            aura.Transparency = 1
            aura.Parent = self.Folder

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = aura
            weld.Part1 = obj
            weld.Parent = weld.Part0

            self.auraParts[obj.Name] = aura
        end
    end
end

function EnshroudVFX:Terminate()
    if self.Folder then
        Debris:AddItem(self.Folder, 1)
    end
    
    if self.auraParts then
        for _, aura: BasePart in pairs(self.auraParts) do
            for _, particle in pairs(aura:GetDescendants()) do
                if particle:IsA("ParticleEmitter") then
                    particle.Enabled = false
                end
            end
            Debris:AddItem(aura, 1)
        end

        self.auraParts = {}
    end
end

function EnshroudVFX:Update(deltaTime)
    
end

function EnshroudVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return EnshroudVFX