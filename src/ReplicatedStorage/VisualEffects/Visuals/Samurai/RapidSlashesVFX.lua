local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local SamuraiVFX = VFXAssets:WaitForChild("Samurai")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local LocalPlayer = game:GetService("Players").LocalPlayer

local RapidSlashes = {}
RapidSlashes.__index = RapidSlashes

function RapidSlashes.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, RapidSlashes)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function RapidSlashes:Activate(target, sourceUnit, conditionalData)
    local vfx = RapidSlashes.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function RapidSlashes:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "RapidSlashesVFX"
    self.Folder.Parent = workspace.VFX

    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.spawnRate = 0.1
    self.currTime = 0

    self.hitbox = self.conditionalData.hitbox

    self:Slashes()
end

function RapidSlashes:Terminate()
    for _, particle in pairs(self.Folder:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle.Enabled = false
        end
    end

    task.delay(1, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function RapidSlashes:Update(deltaTime)
    self.currTime += deltaTime
    if self.currTime >= self.spawnRate then
        self.currTime = 0

        self:SlashSound()
    end
end

function RapidSlashes:RunFunction(target, sourceUnit, conditionalData)
    if conditionalData.isHit then
        self:Hit(target)
    end
end

function RapidSlashes:Slashes()
    self.slashesVFX = SamuraiVFX.RapidSlashes.Slashes:Clone()
    self.slashesVFX.CFrame = self.hitbox.CFrame
    self.slashesVFX.Transparency = 1
    self.slashesVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = self.slashesVFX
    weld.Part1 = self.hitbox
    weld.Parent = weld.Part0

    self:SlashSound()
end

function RapidSlashes:SlashSound()
    local sfx1 = Sounds.Base.SwordHit:Clone()
    sfx1.Volume = .25
    sfx1._Pitch.Octave = math.random(95,  105) / 100
    sfx1.Parent = self.slashesVFX
    sfx1:Play()
end

function RapidSlashes:Hit(target)
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local HitVFX = SamuraiVFX.RapidSlashes.Hit:Clone()
    HitVFX.Transparency = 1
    HitVFX.CFrame = CFrame.lookAt(targetRoot.Position, self.rootPart.Position, Vector3.new(0, 1, 0)) * CFrame.Angles(0, math.rad(180), 0)
    HitVFX.CFrame *= CFrame.Angles(0, 0, math.rad(math.random(-180, 180)))
    HitVFX.Parent = self.Folder

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HitVFX
    weld.Part1 = targetRoot
    weld.Parent = weld.Part0

    local sfx2 = Sounds.Base.SwordHit:Clone()
    sfx2.Volume = .15
    sfx2._Pitch.Octave = math.random(95,  105) / 100
    sfx2.Parent = HitVFX
    sfx2:Play()

    for _, particle in pairs(HitVFX:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle:Emit(particle:GetAttribute("EmitCount"))
        end
    end

    local timing = .25
    local info = TweenInfo.new(timing, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    local info2 = TweenInfo.new(timing, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, .25)

    TweenService:Create(HitVFX.A0, info, {Position = Vector3.new(3, 0, 0)}):Play()
    TweenService:Create(HitVFX.A1, info, {Position = Vector3.new(-3, 0, 0)}):Play()
    TweenService:Create(HitVFX.Beam, info2, {Width0 = 0, Width1 = 0}):Play()
end

return RapidSlashes