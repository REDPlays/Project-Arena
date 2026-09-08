local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local HydromancerVFX = VFXAssets:WaitForChild("Hydromancer")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local WaterWallVFX = {}
WaterWallVFX.__index = WaterWallVFX

function WaterWallVFX.new(target: Model, sourceUnit: Model, conditionalData: {})
    local newVFX = {}
    setmetatable(newVFX, WaterWallVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function WaterWallVFX:Activate(target: Model, sourceUnit: Model, conditionalData: {})
    local vfx = WaterWallVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function WaterWallVFX:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "WaterWallVFX"
    self.Folder.Parent = workspace.VFX

    self.hitboxes = self.conditionalData.hitboxes

    self.canFollow = true

    self.walls = {}
    self.sounds = {}
    for i=1, #self.hitboxes do
        self:AddWall(i, self.hitboxes[i])
    end
end

function WaterWallVFX:AddWall(order: number, hitbox: BasePart)
    local wall = HydromancerVFX.WaterWall:Clone()
    wall.CFrame = hitbox.CFrame
    wall.Parent = self.Folder

    local sfx2 = Sounds.Hydromancer.WaterLoop:Clone()
    sfx2.Volume = .4
    sfx2._Pitch.Octave = math.random(95,  105) / 100
    sfx2.Parent = wall
    sfx2:Play()

    table.insert(self.walls, order, wall)
    table.insert(self.sounds, order, sfx2)
end

function WaterWallVFX:Terminate()
    if self.walls then
        for i=1, #self.walls do
            local wall = self.walls[i]
            if wall then
                local info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

                for _, obj in pairs(wall:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") then
                        obj.Enabled = false
                    elseif obj:IsA("Beam") then
                        TweenService:Create(obj, info, {Width0 = 0, Width1 = 0}):Play()
                    end
                end
            end

            local sfx: Sound = self.sounds[i]
            if sfx then
                local info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
                TweenService:Create(sfx, info, {Volume = 0}):Play()
            end
        end
    end

    if self.Folder then
        Debris:AddItem(self.Folder, 1)
    end
end

function WaterWallVFX:Update(deltaTime)
    if self.canFollow and self.hitboxes and self.walls then
        for i=1, #self.walls do
            local wall = self.walls[i]
            if not wall then continue end

            local hitbox = self.hitboxes[i]
            if not hitbox then continue end

            wall.CFrame = hitbox.CFrame
        end
    end
end

function WaterWallVFX:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    if conditionalData.action == "Hit" then
        self:Hit(conditionalData.spawnCFrame)
    end
end

function WaterWallVFX:Hit(spawnCFrame)
    local WaterHit = HydromancerVFX.WaterHit:Clone()
    WaterHit.Transparency = 1
    WaterHit.CFrame = spawnCFrame
    WaterHit.Parent = self.Folder

    local sfx3 = Sounds.Hydromancer.WaterHit:Clone()
    sfx3.Volume = 1
    sfx3._Pitch.Octave = math.random(95,  105) / 100
    sfx3.Parent = WaterHit
    sfx3:Play()

    WaterHit.Water:Emit(8)
    WaterHit.Water2:Emit(8)
end

return WaterWallVFX