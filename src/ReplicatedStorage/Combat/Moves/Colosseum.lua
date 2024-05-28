local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local Colosseum = {}

function Colosseum:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[moveType]

    local duration = 5
    local collideDelay = .25

    local numOfWalls = 12
    local angle = 0
    local maxAngle = 360

    local distance = 30

    local WallSize = Vector3.new(17, 17, 3)

    local startCFrame = placementCFrame

    local wallObjects = {}

    local VFX_ID = HttpService:GenerateGUID(false)

    VisualEffectServer:SpawnEffectsInRange(
        "Colosseum",
        nil,
        character,
        {},
        1000,
        VFX_ID
    )

    for i=1, numOfWalls do
        local newCFrame = startCFrame * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, -WallSize.Y/2, -distance)
        local LastCFrame = newCFrame * CFrame.new(0, WallSize.Y, 0)

        local Wall = Hitboxes.Hitbox:Clone()
        Wall.Size = WallSize
        Wall.Material = Enum.Material.SmoothPlastic
        Wall.CanCollide = false
        Wall.CanTouch = false
        Wall.CanQuery = false
        Wall.CFrame = newCFrame
        Wall.Anchored = true
        Wall.Transparency = 1
        if ShowHitboxes then
            Wall.Transparency = 0.5
        end
        Wall.Parent = workspace.Obstacles

        wallObjects[i] = Wall

        local conditionalData = {
            spawnCFrame = newCFrame,
            collideDelay = collideDelay,
            height = WallSize.Y
        }

        VisualEffectServer:SpawnEffectsInRange(
            "Colosseum",
            nil,
            character,
            conditionalData,
            1000,
            VFX_ID,
            true
        )

        local info1 = TweenInfo.new(collideDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(Wall, info1, {CFrame = LastCFrame}):Play()

        task.delay(collideDelay, function()
            Wall.CanCollide = true
            Wall.CanTouch = true
            Wall.CanQuery = true
        end)

        task.delay(duration, function()
            Wall.CanCollide = false
            Wall.CanTouch = false
            Wall.CanQuery = false

            TweenService:Create(Wall, info1, {CFrame = newCFrame}):Play()
        end)

        angle += maxAngle / numOfWalls
    end

    task.delay(duration, function()
        VisualEffectServer:TerminateVFX(
            "Colosseum",
            nil,
            character,
            {duration = 1},
            VFX_ID
        )

        for _, wall in pairs(wallObjects) do
            Debris:AddItem(wall, 1)
        end
    end)
end

return Colosseum