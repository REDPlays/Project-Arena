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

    self.PodiumList = {
        ["FFA"] = self.FFA,
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

function CeremonyUI:CreateCharacters(playerList)
    for place, info in pairs(playerList) do
        local currentPodium = self.PodiumList.FFA[place]
        if not place then
            continue
        end

        local player: Player = Players:FindFirstChild(info[1])
        if player then
            local class = player:GetAttribute("CurrentClass")

            local description: HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(player.UserId)
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
    if enable then
        for name, podium in pairs(self.PodiumList) do
            if name == ceremonyType then
                self:PodiumVisiblity(podium, true)
            else
                self:PodiumVisiblity(podium, false)
            end
        end

        self:CreateCharacters(playerList)
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