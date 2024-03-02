local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Camera"):WaitForChild("CameraManager"))
local UIController = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("UI"):WaitForChild("UIController"))
local CharacterSelectClient = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Player"):WaitForChild("CharacterSelect_Client"))
local AnimationSystem = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Player"):WaitForChild("AnimationSystem"))

local Lobby = workspace.Lobby

local LocalGameManager = {}

function LocalGameManager:Init(player: Player)
    LocalGameManager.player = player
    LocalGameManager.character = LocalGameManager.player.Character

    LocalGameManager:Setup()
end

function LocalGameManager:Setup()
    LocalGameManager.cameraSystem = CameraManager.new()
    LocalGameManager.cameraSystem:Init(LocalGameManager.player, LocalGameManager.character)

    LocalGameManager.uiController = UIController.new()
    LocalGameManager.uiController:Init(LocalGameManager.player, LocalGameManager.character)

    LocalGameManager.animationSystem = AnimationSystem.new()
    LocalGameManager.animationSystem:Init(LocalGameManager.player, LocalGameManager.character)

    CharacterSelectClient:Init(Lobby)
end

function LocalGameManager:Update(deltaTime)
    if LocalGameManager.cameraSystem then
        LocalGameManager.cameraSystem:Update(deltaTime)
    end

    if LocalGameManager.animationSystem then
        LocalGameManager.animationSystem:Update(deltaTime)
    end
end

return LocalGameManager