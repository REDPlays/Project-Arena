local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Camera"):WaitForChild("CameraManager"))

local LocalGameManager = {}

function LocalGameManager:Init(player: Player)
    LocalGameManager.player = player
    LocalGameManager.character = LocalGameManager.player.Character

    LocalGameManager:Setup()
end

function LocalGameManager:Setup()
    LocalGameManager.cameraSystem = CameraManager.new()
    LocalGameManager.cameraSystem:Init(LocalGameManager.player, LocalGameManager.character)
end

function LocalGameManager:Update(deltaTime)
    if LocalGameManager.cameraSystem then
        LocalGameManager.cameraSystem:Update(deltaTime)
    end
end

return LocalGameManager