local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local SamuraiVFX = VFXAssets:WaitForChild("Samurai")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local LocalPlayer = game:GetService("Players").LocalPlayer

local ShadowStep = {}
ShadowStep.__index = ShadowStep

function ShadowStep.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ShadowStep)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ShadowStep:Activate(target, sourceUnit, conditionalData)
    local vfx = ShadowStep.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ShadowStep:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ShadowStepVFX"
    self.Folder.Parent = workspace.VFX

    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.overhead = self.sourceUnit:FindFirstChild("Overhead")
    if not self.overhead then
        return
    end
    
    self.statusUI = self.sourceUnit:FindFirstChild("StatusUI")
    if not self.statusUI then
        return
    end

    self.prevTransparency = {}
    self.particleList = {}
    
    local LocalCharacter = LocalPlayer.Character
    if not LocalCharacter then
        return
    end

    self.isSource = true
    if LocalCharacter ~= self.sourceUnit then
        self.isSource = false
    end

    self.spawnRate = 0.2
    self.currTime = 0

    self:Shadow()
end

function ShadowStep:Terminate()
    self:Show()

    Debris:AddItem(self.Folder, 2)
end

function ShadowStep:Update(deltaTime)
    self.currTime += deltaTime
    if self.currTime >= self.spawnRate then
        self.currTime = 0
        self:CopyCharacter()
    end
end

function ShadowStep:RunFunction(target, sourceUnit, conditionalData)
    
end

function ShadowStep:Shadow()
    self.overhead.Enabled = false
    self.statusUI.Enabled = false

    for _, obj in pairs(self.sourceUnit:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            self.prevTransparency[obj] = obj.Transparency

            if self.isSource then
                obj.Transparency = 0.8
            else
                obj.Transparency = 1
            end
        end
    end

    for _, obj in pairs(self.sourceUnit:GetChildren()) do
        if obj:IsA("BasePart") then
            local particlePart = SamuraiVFX.ShadowStep.Particles:Clone()
            particlePart.Size = obj.Size
            particlePart.Massless = true
            particlePart.CFrame = obj.CFrame
            particlePart.Transparency = 1
            particlePart.Parent = self.Folder

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = particlePart
            weld.Part1 = obj
            weld.Parent = weld.Part0

            self.particleList[particlePart] = particlePart
        end
    end
end

function ShadowStep:CopyCharacter()
    self.sourceUnit.Archivable = true

    local copyChar = self.sourceUnit:Clone()

    local info = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for _, obj in pairs(copyChar:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = false
            obj.Anchored = true
            obj.Color = Color3.fromRGB(65, 65, 65)
            obj.Material = Enum.Material.Neon
            obj.Transparency = 0.25

            TweenService:Create(obj, info, {Transparency = 1}):Play()
        elseif obj:IsA("BillboardGui") or obj:IsA("Folder") then
            obj:Destroy()
        end
    end

    copyChar.Parent = self.Folder
end

function ShadowStep:Show()
    self.overhead.Enabled = true
    self.statusUI.Enabled = true

    for _, obj in pairs(self.sourceUnit:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            if self.prevTransparency[obj] then
                obj.Transparency = self.prevTransparency[obj]
            end
        end
    end

    for _, particlePart in pairs(self.particleList) do
        for _, particle in pairs(particlePart:GetChildren()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    end
end

return ShadowStep