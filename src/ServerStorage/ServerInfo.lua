local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local ServerInfo = {}

function ServerInfo:SendMessage(message: string)
    Events.Server_Client.ReceiveMessage:FireAllClients(message)
end

return ServerInfo