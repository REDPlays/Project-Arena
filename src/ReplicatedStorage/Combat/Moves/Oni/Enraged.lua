local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
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
local CharacterMoveLibrary = require(ReplicatedStorage.RepFiles.Player.CharacterMoveLibrary)

local IgnoreFolder = workspace.Ignore

local Enraged = {}

local function TweenScale(model: Model, startScale: number, endScale: number, duration: number)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local numVal = Instance.new("NumberValue")
    numVal.Value = startScale

    local connect
    connect = numVal.Changed:Connect(function(value)
        model:ScaleTo(numVal.Value)
    end)

    TweenService:Create(numVal, info, {Value = endScale}):Play()

    task.delay(duration, function()
        if connect then
            connect:Disconnect()
        end

        if numVal then
            numVal:Destroy()
        end
    end)
end

function Enraged:Activate(player, character, rootPart, placementCFrame, class, classData, moveType, currentMove)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[currentMove]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local VFX_ID = "Enraged"..HttpService:GenerateGUID(false)

    Stats:SetAttribute("AbilityLocked", true)
    Stats:SetAttribute("Awakened", true)

    CharacterMoveLibrary.Movesets[player] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Club Slam",
        ["EMove"] = "Sumo Stance",
        ["FMove"] = "Enraged",
    }
    Events.Server_Client.UpdateMoveNumber:FireClient(player, CharacterMoveLibrary.Movesets[player])

    local resetList = {
        "QMove",
        "EMove",
    }
    Events.Server_Server.ResetCooldowns:Fire(player, resetList)

    VisualEffectServer:SpawnEffectsInRange(
        "Enraged",
        nil,
        character,
        {},
        1000,
        VFX_ID
    )

    local duration = 1
    local lifeTime = 15
    local scale = 1.5

    TweenScale(character, 1, scale, duration)

    task.delay(duration, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    task.delay(lifeTime, function()
        Stats:SetAttribute("AbilityLocked", true)
        Stats:SetAttribute("Awakened", nil)

        CharacterMoveLibrary.Movesets[player] = {
            ["LMBMove"] = "M1",
            ["QMove"] = "Club Slam",
            ["EMove"] = "Sumo Rush",
            ["FMove"] = "Enraged",
        }
        Events.Server_Client.UpdateMoveNumber:FireClient(player, CharacterMoveLibrary.Movesets[player])

        Events.Server_Server.ResetCooldowns:Fire(player, resetList)

        VisualEffectServer:TerminateVFX(
            "Enraged",
            nil,
            character,
            {},
            VFX_ID
        )

        TweenScale(character, scale, 1, duration)

        task.delay(1, function()
            Stats:SetAttribute("AbilityLocked", false)
        end)
    end)
end

return Enraged