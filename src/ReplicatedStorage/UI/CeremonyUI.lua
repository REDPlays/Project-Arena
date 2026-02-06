local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Podiums = workspace:WaitForChild("Podiums")

local CeremonyHelper = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("UI"):WaitForChild("CeremonyHelper"))

local CeremonyUI = {}
CeremonyUI.__index = CeremonyUI

function CeremonyUI.new()
    local newCeremony = {}
    setmetatable(newCeremony, CeremonyUI)

    return newCeremony
end

function CeremonyUI:Init(player, character, animationSystem, cameraSystem)
    self.player = player
    self.character = character
    self.humanoid = character:WaitForChild("Humanoid")
    self.rootPart = character:WaitForChild("HumanoidRootPart")

    self.animationSystem = animationSystem
    self.cameraSystem = cameraSystem

    self.FFA = Podiums:WaitForChild("FFA")
    self.TDM = Podiums:WaitForChild("TDM")

    self.HUD = self.player:WaitForChild("PlayerGui"):WaitForChild("HUD")
    self.BlackFrame = self.HUD:WaitForChild("BlackFrame")
    self.BlackFrame.Visible = false

    self.Gameplay = self.HUD:WaitForChild("Gameplay")

    self.PodiumList = {
        ["FFA"] = self.FFA,
        ["TDM"] = self.TDM,
    }
end

function CeremonyUI:PodiumVisiblity(Podium: Model, isVisible)
    local Transparency = if isVisible then 0 else 1

    for _, object in pairs(Podium:GetDescendants()) do
        if object:IsA("BasePart") or object:IsA("Decal") then
            object.Transparency = Transparency
        end
    end
end

function CeremonyUI:CreateCharacters(podiumType, playerList)
    for place, info in pairs(playerList) do
        local currentPodium = self.PodiumList[podiumType][place]
        if not place then
            continue
        end

        local player: Player = Players:FindFirstChild(info[1])
        if player then
            local class = player:GetAttribute("ClassDisplay")

            local userID = player.UserId
            if userID < 0 then
                userID = 126372777
            end

            local description: HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(userID)
            local bodyDouble = Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R6)
            bodyDouble.HumanoidRootPart.Anchored = true
            bodyDouble.PrimaryPart = bodyDouble.HumanoidRootPart
            bodyDouble.PrimaryPart.PivotOffset = CFrame.new(0, -3, 0)
            bodyDouble:PivotTo(currentPodium:GetPivot())

            if class then
                CeremonyHelper:ApplyClass(class, bodyDouble, player)
            end

            bodyDouble.Parent = workspace.Ignore
            CollectionService:AddTag(bodyDouble, "Ceremony")

            CeremonyHelper:Emote(bodyDouble, "Emote"..place)
        end
    end
end

function CeremonyUI:RemoveCharacters()
    local ceremonyObjects = CollectionService:GetTagged("Ceremony")

    for _, obj in pairs(ceremonyObjects) do
        obj:Destroy()
    end
end

function CeremonyUI:ToggleCeremony(ceremonyType, enable, playerList)
    self.Gameplay.Visible = false

    self.BlackFrame.BackgroundTransparency = 0
    self.BlackFrame.Visible = true

    local tweenTime = 0.5
    local info = TweenInfo.new(
        tweenTime, 
        Enum.EasingStyle.Linear, 
        Enum.EasingDirection.Out,
        0,
        false,
        0.5
    )
    TweenService:Create(self.BlackFrame, info, {BackgroundTransparency = 1}):Play()

    if ceremonyType == "TDM" then
        local newList = {}
        local count = 0
        for _, data in pairs(playerList) do
            count += 1
            data[1] = data[1].Name
            newList[count] = data
        end
        playerList = newList
    end

    task.delay(tweenTime, function()
        self.BlackFrame.Visible = false
        self.BlackFrame.BackgroundTransparency = 0
    end)

    if enable then
        for name, podium in pairs(self.PodiumList) do
            if name == ceremonyType then
                self:PodiumVisiblity(podium, true)
            else
                self:PodiumVisiblity(podium, false)
            end
        end

        self:CreateCharacters(ceremonyType, playerList)
    else
        for name, podium in pairs(self.PodiumList) do
            self:PodiumVisiblity(podium, false)
        end

        self:RemoveCharacters()
    end

    self.cameraSystem:SetCeremony(enable)
end

function CeremonyUI:Update(deltaTime)
    
end

return CeremonyUI