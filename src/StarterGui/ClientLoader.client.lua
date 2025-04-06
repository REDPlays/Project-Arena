local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local LocalGameManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("LocalGameManager"))

local Channels = TextChatService:WaitForChild("TextChannels")
local RBXSystem: TextChannel = Channels:WaitForChild("RBXSystem")

local function PlayerAdded()
    LocalGameManager:Init(Players.LocalPlayer)

    RunService.Heartbeat:Connect(function(deltaTime)
        LocalGameManager:Update(deltaTime)
    end)
end

local function Respawn()
    LocalGameManager:Disconnect(Players.LocalPlayer)
end

local function ServerMessage(message: string)
    local newMessage = "[SERVER] "..message
	local color = "#ffc600"

	RBXSystem:DisplaySystemMessage(`<font color = "{color}">{newMessage}</font>`)
end

Events.Server_Client.PlayerLoaded.OnClientEvent:Connect(PlayerAdded)
Events.Server_Client.Death.OnClientEvent:Connect(Respawn)
Events.Server_Client.ReceiveMessage.OnClientEvent:Connect(ServerMessage)