local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local ServerGameManager = require(ServerScriptService.ServerFiles.ServerGameManager)
ServerGameManager:Init()

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local isNew = ServerGameManager:PlayerJoin(player)
        
        if not isNew then
            ServerGameManager:PlayerRespawn(player)

            task.delay(1, function()
                ServerGameManager:ConfigureCharacter(player, character)
                
                Events.Server_Client.PlayerLoaded:FireClient(player)
            end)
        else
            ServerGameManager:ConfigureCharacter(player, character)

            Events.Server_Client.PlayerLoaded:FireClient(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    ServerGameManager:PlayerLeave(player)
end)

RunService.Heartbeat:Connect(function(deltaTime)
    ServerGameManager:Update(deltaTime)
end)