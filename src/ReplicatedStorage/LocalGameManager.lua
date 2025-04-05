local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Camera"):WaitForChild("CameraManager"))
local UIController = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("UI"):WaitForChild("UIController"))
local CharacterSelectClient = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Player"):WaitForChild("CharacterSelect_Client"))
local AnimationSystem = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Player"):WaitForChild("AnimationSystem"))
local MovementManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("MovementManager"))
local VisualEffectClient = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("VisualEffectClient"))
local ClientHitboxManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("ClientHitboxManager"))

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

    LocalGameManager.animationSystem = AnimationSystem.new()
    LocalGameManager.animationSystem:Init(LocalGameManager.player, LocalGameManager.character)

    LocalGameManager.uiController = UIController.new()
    LocalGameManager.uiController:Init(LocalGameManager.player, LocalGameManager.character, LocalGameManager.animationSystem, LocalGameManager.cameraSystem)

    CharacterSelectClient:Init(LocalGameManager.character, Lobby, LocalGameManager.uiController, LocalGameManager.animationSystem)
end

function LocalGameManager:Disconnect(player: Player)
    if LocalGameManager.cameraSystem then
        LocalGameManager.cameraSystem:Disconnect()
        LocalGameManager.cameraSystem = nil
    end

    if LocalGameManager.animationSystem then
        LocalGameManager.animationSystem:Disconnect()
        LocalGameManager.animationSystem = nil
    end

    if LocalGameManager.uiController then
        LocalGameManager.uiController:Disconnect()
        LocalGameManager.uiController = nil
    end

    CharacterSelectClient:Disconnect()
end

function LocalGameManager:Update(deltaTime)
    if LocalGameManager.cameraSystem then
        LocalGameManager.cameraSystem:Update(deltaTime)
    end

    if LocalGameManager.animationSystem then
        LocalGameManager.animationSystem:Update(deltaTime)
    end

    if LocalGameManager.uiController then
        LocalGameManager.uiController:Update(deltaTime)
    end

    ClientHitboxManager:Update(deltaTime)

    VisualEffectClient:Update(deltaTime)

    Lobby.Misc.RunicCircle.CFrame *= CFrame.Angles(0, math.rad(15) * deltaTime, 0)
end

return LocalGameManager