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

function Enraged:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
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

    Stats:SetAttribute("AbilityLocked", true)
    Stats:SetAttribute("Awakened", true)

    local duration = 1
    local lifeTime = 15
    local scale = 1.5

    TweenScale(character, 1, scale, duration)

    task.delay(duration, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    task.delay(lifeTime, function()
        Stats:SetAttribute("Awakened", nil)
        TweenScale(character, scale, 1, duration)
    end)
end

return Enraged