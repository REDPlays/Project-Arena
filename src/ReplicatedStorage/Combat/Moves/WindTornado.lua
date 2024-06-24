local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local WindTornado = {}

function WindTornado:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[moveType]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local duration = 2
    local _delay = .5
    local speed = 100

    Stats:SetAttribute("AbilityLocked", true)
    task.delay(_delay, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    local startCFrame = placementCFrame * CFrame.new(0, 0, -5)

    local rayparams = RaycastParams.new()
    rayparams.FilterType = Enum.RaycastFilterType.Exclude

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.CFrame = startCFrame
    Hitbox.Anchored = true
    Hitbox.Parent = IgnoreFolder

    local function hitDetection()

    end

    local function movement(deltaTime)
        local characterList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            local plrChar = plr.Character
            if not plrChar then
                continue
            end
            table.insert(characterList, plrChar)
        end

        rayparams.FilterDescendantsInstances = {workspace.Dummies, workspace.Ignore, workspace.Obstacles, workspace.VFX, characterList}
    
        local newRayCFrame = Hitbox.CFrame * CFrame.new(0, 100, 0)

        local ray = workspace:Raycast(newRayCFrame.Position, newRayCFrame.UpVector * -1000, rayparams)
        if ray then
            local rayPosition = ray.Position

            Hitbox.Position = rayPosition + Vector3.new(0, Hitbox.Size.Y/2, 0)

            Hitbox.CFrame *= CFrame.new(0, 0, -speed * deltaTime)
        end
    end

    local thread = coroutine.create(function()
        while true do
            local dt = task.wait()

            hitDetection()

            Hitbox.CFrame *= CFrame.new(0, 0, -speed * dt)
        end
    end)

    Debris:AddItem(Hitbox, duration)

    task.delay(duration, function()
        if thread then
            task.cancel(thread)
        end
    end)

    coroutine.resume(thread)
end

return WindTornado