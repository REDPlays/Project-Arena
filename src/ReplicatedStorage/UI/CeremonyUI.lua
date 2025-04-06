local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Podiums = workspace:WaitForChild("Podiums")

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

function CeremonyUI:ToggleCeremony(ceremonyType, enable, playerList)
    if enable then
        for name, podium in pairs(self.PodiumList) do
            if name == ceremonyType then
                self:PodiumVisiblity(podium, true)
            else
                self:PodiumVisiblity(podium, false)
            end
        end
    else
        for name, podium in pairs(self.PodiumList) do
            self:PodiumVisiblity(podium, false)
        end
    end

    self.cameraSystem:SetCeremony(enable)
end

function CeremonyUI:Update(deltaTime)
    
end

return CeremonyUI