local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local ServerGameManager = require(ServerScriptService.ServerFiles.ServerGameManager)
ServerGameManager:Init()

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        ServerGameManager:PlayerJoin(player)

        ServerGameManager:ConfigureCharacter(character)

        Events.Server_Client.PlayerLoaded:FireClient(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    ServerGameManager:PlayerLeave(player)
end)

RunService.Heartbeat:Connect(function(deltaTime)
    ServerGameManager:Update(deltaTime)
end)