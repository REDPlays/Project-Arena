local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local EngineerVFX = VFXAssets:WaitForChild("Engineer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ElectroBall = {}
ElectroBall.__index = ElectroBall

local function TweenScale(model: Model, startScale: number, endScale: number, duration: number)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local numVal = Instance.new("NumberValue")
    numVal.Value = 0

    local connect
    connect = numVal.Changed:Connect(function(value)
        model:ScaleTo(numVal.Value)
    end)

    TweenService:Create(numVal, info, {Value = 1}):Play()

    task.delay(duration, function()
        if connect then
            connect:Disconnect()
        end

        if numVal then
            numVal:Destroy()
        end
    end)
end

function ElectroBall.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ElectroBall)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ElectroBall:Activate(target, sourceUnit, conditionalData)
    local vfx = ElectroBall.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ElectroBall:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.hitbox = self.conditionalData.hitbox
    if not self.hitbox then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ElectroBallVFX"
    self.Folder.Parent = workspace.VFX

    self.canFollow = true

    self:Projectile()
end

function ElectroBall:RunFunction(target, sourceUnit, conditionalData)
    self.canFollow = false

    self.isTerminate = true

    self:Explosion(conditionalData.spawnCFrame)
end

function ElectroBall:Terminate(target, sourceUnit, conditionalData)
    Debris:AddItem(self.Folder, 2)
end

function ElectroBall:Update(deltaTime)
    if not self.hitbox then
        return
    end

    if not self.canFollow then
        return
    end

    self.Projectile.PrimaryPart.CFrame = self.hitbox.CFrame
end

function ElectroBall:Projectile()
    self.Projectile = EngineerVFX.ElectroBall.Projectile2:Clone()
    self.Projectile.PrimaryPart.Transparency = 1
    self.Projectile.PrimaryPart.CFrame = self.hitbox.CFrame
    self.Projectile:ScaleTo(0.1)
    self.Projectile.Parent = self.Folder

    TweenScale(self.Projectile, 0.1, 1, .4)
end

function ElectroBall:Explosion(spawnCFrame)
    for _, particle in pairs(self.Projectile:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle.Enabled = false
        end
    end

    self.Explode = EngineerVFX.ElectroBall.Explosion:Clone()
    self.Explode.Transparency = 1
    self.Explode.CFrame = spawnCFrame
    self.Explode.Parent = self.Folder

    for _, particle in pairs(self.Explode:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end
end

return ElectroBall