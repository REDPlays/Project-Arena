local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ReaperVFX = VFXAssets:WaitForChild("Reaper")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ReapersCallingVFX = {}
ReapersCallingVFX.__index = ReapersCallingVFX

function ReapersCallingVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, ReapersCallingVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ReapersCallingVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = ReapersCallingVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ReapersCallingVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Stats = self.sourceUnit:FindFirstChild("Stats")
    if not self.Stats then
        return
    end

    self.companion = self.conditionalData.companion
    if not self.companion then return end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ReapersCallingVFX"
    self.Folder.Parent = workspace.VFX

    local energy = ReaperVFX.ReapersCalling.Energy:Clone()
    energy.Transparency = 1
    energy.CFrame = self.sourceUnit:GetPivot()
    energy.Parent = self.Folder

    for _, particle in pairs(energy:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            local EmitDuration = particle:GetAttribute("EmitDuration") or 0
            if EmitDuration > 0 then
                particle.Enabled = true
                task.delay(EmitDuration, function()
                    particle.Enabled = false
                end)
            end
        end
    end

    local whiteList = {"Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

    for _, obj in ipairs(self.companion:GetChildren()) do
        if obj:IsA("BasePart") and table.find(whiteList, obj.Name) then
            local Particles = ReaperVFX.ReapersCalling.Particles:Clone()
            Particles.Size = obj.Size
            Particles.CFrame = obj.CFrame
            Particles.Parent = self.Folder

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = Particles
            weld.Part1 = obj
            weld.Parent = weld.Part0

            task.delay(0.25, function()
                for _, particle in pairs(Particles:GetDescendants()) do
                    if particle:IsA("ParticleEmitter") then
                        particle.Enabled = false
                    end
                end
            end)

            Debris:AddItem(Particles, 1)
        end
    end

    task.delay(1, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function ReapersCallingVFX:Terminate()
    
end

function ReapersCallingVFX:Update(deltaTime)
    
end

function ReapersCallingVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    
end

return ReapersCallingVFX