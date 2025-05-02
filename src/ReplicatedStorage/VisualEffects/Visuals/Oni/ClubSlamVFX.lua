local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local OniVFX = VFXAssets:WaitForChild("Oni")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ClubSlam = {}
ClubSlam.__index = ClubSlam

function ClubSlam.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, ClubSlam)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function ClubSlam:Activate(target, sourceUnit, conditionalData)
    local vfx = ClubSlam.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function ClubSlam:DisplayVFX()
    local spawnCFrame = self.conditionalData.spawnCFrame
    local isAwakened = self.conditionalData.isAwakened

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "EngineerVFX"
    self.Folder.Parent = workspace.VFX

    task.delay(2, function()
        self.Folder:Destroy()
    end)

    self:Slam(spawnCFrame, isAwakened)
end

function ClubSlam:Terminate(target, sourceUnit, conditionalData)
    
end

function ClubSlam:Update(deltaTime)
    
end

function ClubSlam:Slam(spawnCFrame, isAwakened)
    local SlamVFX
    if not isAwakened then
        SlamVFX = OniVFX.ClubSlam.NormalSlam:Clone()
    else
        SlamVFX = OniVFX.ClubSlam.AwakenedSlam:Clone()
    end
    SlamVFX.CFrame = spawnCFrame
    SlamVFX.Transparency = 1
    SlamVFX.Parent = self.Folder

    for _, particle in pairs(SlamVFX:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            if particle:GetAttribute("EmitCount") then
                particle:Emit(particle:GetAttribute("EmitCount"))
            end
        end
    end
end

return ClubSlam