local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ShieldWarriorVFX = VFXAssets:WaitForChild("ShieldWarrior")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ColosseumVFX = {}
ColosseumVFX.__index = ColosseumVFX

function ColosseumVFX.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ColosseumVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ColosseumVFX:Activate(target, sourceUnit, conditionalData)
    local vfx = ColosseumVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ColosseumVFX:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.Gear = self.sourceUnit:FindFirstChild("Gear")
    if not self.Gear then
        return
    end

    self.Wepaon = self.Gear:FindFirstChild("Weapon")
    if not self.Wepaon then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "ColosseumVFX"
    self.Folder.Parent = workspace.VFX

    self.floors = {}
    self.walls = {}
    self.wallCount = 0

    self:Sound()
end

function ColosseumVFX:RunFunction(target, sourceUnit, conditionalData)
    self:Wall(conditionalData.spawnCFrame, conditionalData.collideDelay, conditionalData.height)
end

function ColosseumVFX:Terminate(target, sourceUnit, conditionalData)
    local duration = conditionalData.duration

    task.delay(duration, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)

    for _, wall in self.walls do
        local info2 = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(wall, info2, {CFrame = wall.CFrame * CFrame.new(0, -wall.Size.Y, 0)}):Play()
        Debris:AddItem(wall, 1)
    end

    for _, floor in self.floors do
        for _, particle in pairs(floor:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    end
end

function ColosseumVFX:Update(deltaTime)
    
end

function ColosseumVFX:Sound()
    local soundPart = ShieldWarriorVFX.Colosseum.SoundPart:Clone()
    soundPart.CFrame = self.rootPart.CFrame
    soundPart.Transparency = 1
    soundPart.Parent = self.Folder

    local sfx1: Sound = Sounds.ShieldWarrior.GroundSpawn:Clone()
    sfx1.Volume = .5
    sfx1._Pitch.Octave = 0.5
    sfx1.Parent = soundPart
    sfx1:Play()
end

function ColosseumVFX:Wall(spawnCFrame, collideDelay, height)
    self.wallCount += 1

    local floorCFrame = spawnCFrame * CFrame.new(0, height/2, 0)
    spawnCFrame *= CFrame.new(0, -height/2, 0)

    local wall: BasePart = ShieldWarriorVFX.Colosseum.WallObject:Clone()
    if self.wallCount % 2 ~= 0 then
        wall:PivotTo(spawnCFrame)
    else
        wall:PivotTo(spawnCFrame * CFrame.Angles(0, math.rad(180), 0))
    end
    wall.Parent = self.Folder

    local floor: BasePart = ShieldWarriorVFX.Colosseum.Floor:Clone()
    floor.Transparency = 1
    floor.CFrame = floorCFrame
    floor.Parent = self.Folder

    table.insert(self.walls, wall)
    table.insert(self.floors, floor)

    local info1 = TweenInfo.new(collideDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(wall, info1, {CFrame = wall.CFrame * CFrame.new(0, height, 0)}):Play()
end

return ColosseumVFX