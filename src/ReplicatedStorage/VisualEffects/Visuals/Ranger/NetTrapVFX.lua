local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local RangerVFX = VFXAssets:WaitForChild("Ranger")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local NetTrap = {}
NetTrap.__index = NetTrap

function NetTrap.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, NetTrap)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function NetTrap:Activate(target, sourceUnit, conditionalData)
    local vfx = NetTrap.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function NetTrap:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.hitbox = self.conditionalData.hitbox
    if not self.hitbox then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "NetTrapVFX"
    self.Folder.Parent = workspace.VFX

    self.canFollow = true
    self.angle = 5
    self.count = 1

    self:Bomb()
end

function NetTrap:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.action == "Trap" then
        self:Trap(target, conditionalData.duration)
    elseif conditionalData.action == "Explosion" then
        self.canFollow = false

        self.isTerminate = true
    
        self:Explosion(conditionalData.spawnCFrame)
    end
end

function NetTrap:Terminate(target, sourceUnit, conditionalData)
    task.delay(3, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function NetTrap:Update(deltaTime)
    if not self.hitbox then
        return
    end

    if not self.canFollow then
        return
    end

    self.Bomb.PrimaryPart.CFrame = CFrame.new(self.hitbox.Position) * CFrame.Angles(math.rad(self.angle * self.count), 0, 0)
    self.count += 1
end

function NetTrap:Bomb()
    self.Bomb = RangerVFX.NetTrap.Bomb:Clone()
    self.Bomb.PrimaryPart.CFrame = self.hitbox.CFrame
    self.Bomb.Parent = self.Folder

    local throwSound: Sound = Sounds.Engineer.GrenadeThrow:Clone()
    throwSound.Volume = 0.75
    throwSound._Pitch.Octave = math.random(90,  95) / 100
    throwSound.Parent = self.Bomb
    throwSound:Play()
    Debris:AddItem(throwSound, throwSound.TimeLength)
end

function NetTrap:Explosion(spawnCFrame)
    for _, obj in pairs(self.Bomb:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") then
            obj.Enabled = false
        end
    end

    for _, particle in pairs(self.Bomb.PrimaryPart.Explosion:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end
    
    self.BombExplosion = RangerVFX.NetTrap.BombExplosion:Clone()
    self.BombExplosion.CFrame = spawnCFrame * CFrame.new(0, -0.75, 0)
    self.BombExplosion.Transparency = 1
    self.BombExplosion.Parent = self.Folder

    for _, particle in pairs(self.BombExplosion:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end

    local explodeSound: Sound = Sounds.Engineer.Grenade:Clone()
    explodeSound.Volume = .5
    explodeSound._Pitch.Octave = math.random(90,  95) / 100
    explodeSound.Parent = self.BombExplosion
    explodeSound:Play()
    Debris:AddItem(explodeSound, explodeSound.TimeLength)
end

function NetTrap:Trap(target, duration)
    local enemyRoot = target:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then
        return
    end

    local trapVFX = RangerVFX.NetTrap.Trap:Clone()
    trapVFX.CFrame = enemyRoot.CFrame * CFrame.new(0, -3, 0)
    trapVFX.Transparency = 1
    trapVFX.Anchored = true
    trapVFX.Parent = self.Folder

    task.delay(duration, function()
        for _, particle in pairs(trapVFX:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            elseif particle:IsA("Beam") then
                local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(particle, info, {Width0 = 0, Width1 = 0}):Play()
            end
        end
    end)
end

return NetTrap