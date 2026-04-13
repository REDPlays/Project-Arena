local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local HydromancerVFX = VFXAssets:WaitForChild("Hydromancer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Utils = ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Utils")
local VFX_Utilities = require(Utils:WaitForChild("VFX_Utilities"))

local WhirlpoolVFX = {}
WhirlpoolVFX.__index = WhirlpoolVFX

function WhirlpoolVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, WhirlpoolVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function WhirlpoolVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = WhirlpoolVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function WhirlpoolVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end
    
    self.range = self.conditionalData.range
    if not self.range then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "WhirlpoolVFX"
    self.Folder.Parent = workspace.VFX

    self.canFollow = true

    self.pool = HydromancerVFX.Whirlpool:Clone()
    self.pool.CFrame = self.sourceUnit:GetPivot() + Vector3.new(0, .1, 0)
    self.pool.Transparency = 1
    self.pool.Parent = self.Folder
end

function WhirlpoolVFX:Terminate()
    self.canFollow = false

    if self.pool then
        for _, particle: ParticleEmitter in pairs(self.pool:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    end

    task.delay(2, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function WhirlpoolVFX:Update(deltaTime)
    if self.canFollow and self.pool and self.sourceUnit then
        local newCFrame = self.sourceUnit:GetPivot() + Vector3.new(0, .1, 0)
        self.pool.Position = newCFrame.Position
    end
end

function WhirlpoolVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function WhirlpoolVFX:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local HitVFX = HydromancerVFX.WhirlHit:Clone()
    HitVFX.Transparency = 1
    HitVFX.CFrame = CFrame.lookAt(targetRoot.Position, self.rootPart.Position, Vector3.new(0, 1, 0)) * CFrame.Angles(0, math.rad(180), 0)
    HitVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitVFX
    weld.Part1 = targetRoot
    weld.Parent = weld.Part0

    for _, particle in pairs(HitVFX:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount"))
        end
    end
end

return WhirlpoolVFX