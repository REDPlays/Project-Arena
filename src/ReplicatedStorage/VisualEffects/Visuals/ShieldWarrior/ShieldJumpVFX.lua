local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local ShieldWarriorVFX = VFXAssets:WaitForChild("ShieldWarrior")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ShieldJumpVFX = {}
ShieldJumpVFX.__index = ShieldJumpVFX

function ShieldJumpVFX.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ShieldJumpVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ShieldJumpVFX:Activate(target, sourceUnit, conditionalData)
    local vfx = ShieldJumpVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ShieldJumpVFX:DisplayVFX()
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
    self.Folder.Name = "ShieldJumpVFX"
    self.Folder.Parent = workspace.VFX
    Debris:AddItem(self.Folder, 3)

    self:Burst(self.conditionalData.spawnCFrame)
end

function ShieldJumpVFX:RunFunction(target, sourceUnit, conditionalData)
    
end

function ShieldJumpVFX:Terminate()
    
end

function ShieldJumpVFX:Update(deltaTime)
    
end

function ShieldJumpVFX:Burst(spawnCFrame)
    local characterList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            local plrChar = plr.Character
            if not plrChar then
                continue
            end
            table.insert(characterList, plrChar)
        end

        local rayparams = RaycastParams.new()
        rayparams.FilterDescendantsInstances = {workspace.Dummies, workspace.Ignore, workspace.Obstacles, workspace.VFX, characterList}
        rayparams.FilterType = Enum.RaycastFilterType.Exclude

        local ray = workspace:Raycast(spawnCFrame.Position, spawnCFrame.UpVector * -100, rayparams)
        if ray then
            local floorPosition = ray.Position

            local burstParticles = ShieldWarriorVFX.ShieldJump.Burst:Clone()
            burstParticles.Position = floorPosition + Vector3.new(0, 0.05, 0)
            burstParticles.Transparency = 1
            burstParticles.Parent = self.Folder

            self.sfx1 = Sounds.ShieldWarrior.GroundSlam:Clone()
            self.sfx1.Volume = .25
            self.sfx1._Pitch.Octave = math.random(95,  105) / 100
            self.sfx1.Parent = burstParticles
            self.sfx1:Play()

            for _, particle in pairs(burstParticles:GetDescendants()) do
                if particle:IsA("ParticleEmitter") then
                    particle:Emit(particle:GetAttribute("EmitCount") or 5)
                end
            end
        end
end

return ShieldJumpVFX