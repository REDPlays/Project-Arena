local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local EngineerVFX = VFXAssets:WaitForChild("Engineer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ConcussiveBomb = {}
ConcussiveBomb.__index = ConcussiveBomb

function ConcussiveBomb.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ConcussiveBomb)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ConcussiveBomb:Activate(target, sourceUnit, conditionalData)
    local vfx = ConcussiveBomb.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ConcussiveBomb:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.hitbox = self.conditionalData.hitbox
    if not self.hitbox then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ConcussiveBombVFX"
    self.Folder.Parent = workspace.VFX

    self.canFollow = true
    self.angle = 15
    self.count = 1

    self:Bomb()
end

function ConcussiveBomb:RunFunction(target, sourceUnit, conditionalData)
    self.canFollow = false

    self.isTerminate = true

    self:Explosion(conditionalData.spawnCFrame)
end

function ConcussiveBomb:Terminate(target, sourceUnit, conditionalData)
    Debris:AddItem(self.Folder, 2)
end

function ConcussiveBomb:Update(deltaTime)
    if not self.hitbox then
        return
    end

    if not self.canFollow then
        return
    end

    self.Bomb.PrimaryPart.CFrame = CFrame.new(self.hitbox.Position) * CFrame.Angles(math.rad(self.angle * self.count), 0, 0)
    self.count += 1
end

function ConcussiveBomb:Bomb()
    self.Bomb = EngineerVFX.ConcussiveBomb.Bomb:Clone()
    self.Bomb.PrimaryPart.CFrame = self.hitbox.CFrame
    self.Bomb.Parent = self.Folder
end

function ConcussiveBomb:Explosion(spawnCFrame)
    for _, obj in pairs(self.Bomb:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = 1
        end
    end

    for _, particle in pairs(self.Bomb.PrimaryPart.Explosion:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end
    

    self.BombExplosion = EngineerVFX.ConcussiveBomb.BombExplosion:Clone()
    self.BombExplosion.CFrame = spawnCFrame
    self.BombExplosion.Transparency = 1
    self.BombExplosion.Parent = self.Folder

    for _, particle in pairs(self.BombExplosion:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end
end

return ConcussiveBomb