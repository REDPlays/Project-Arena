local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local EngineerVFX = VFXAssets:WaitForChild("Engineer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local TurretSpawn = {}
TurretSpawn.__index = TurretSpawn

function TurretSpawn.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, TurretSpawn)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function TurretSpawn:Activate(target, sourceUnit, conditionalData)
    local vfx = TurretSpawn.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function TurretSpawn:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.spawnCFrame = self.conditionalData.spawnCFrame
    if not self.spawnCFrame then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "TurretSpawnVFX"
    self.Folder.Parent = workspace.VFX
    Debris:AddItem(self.Folder, 2)

    self:Pulse(self.spawnCFrame)
end

function TurretSpawn:RunFunction(target, sourceUnit, conditionalData)
end

function TurretSpawn:Terminate(target, sourceUnit, conditionalData)
    
end

function TurretSpawn:Update(deltaTime)
    
end

function TurretSpawn:Pulse(spawnCFrame)
    local pulse = EngineerVFX.Turret.Pulse:Clone()
    pulse.CFrame = spawnCFrame
    pulse.Transparency = 1
    pulse.Parent = self.Folder

    for _, particle in pairs(pulse:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end
end

return TurretSpawn