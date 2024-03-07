local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local LocalGameManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("LocalGameManager"))

local function PlayerAdded()
    LocalGameManager:Init(Players.LocalPlayer)

    RunService.Heartbeat:Connect(function(deltaTime)
        LocalGameManager:Update(deltaTime)
    end)
end

local function Respawn()
    LocalGameManager:Disconnect(Players.LocalPlayer)
end

Events.Server_Client.PlayerLoaded.OnClientEvent:Connect(PlayerAdded)

Events.Server_Client.Death.OnClientEvent:Connect(Respawn)