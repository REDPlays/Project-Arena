local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local CharacterSelectServer = require(ServerStorage.ServerFiles.Player.CharacterSelect_Server)

local Lobby = workspace.Lobby

local ServerGameManager = {}
ServerGameManager.playerList = {}
ServerGameManager.playerCount = 0

function ServerGameManager:Init()
    CharacterSelectServer:Init(Lobby)
end

function ServerGameManager:ConfigureCharacter(character: Model)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CollisionGroup = "Players" 
        end
    end
end

function ServerGameManager:PlayerJoin(player: Player)
    if ServerGameManager.playerList[player.UserId] then
        return
    end

    ServerGameManager.playerList[player.UserId] = player
    ServerGameManager.playerCount += 1

    CharacterSelectServer:PlayerJoined(player)
end

function ServerGameManager:PlayerLeave(player: Player)
    if not ServerGameManager.playerList[player.UserId] then
        return
    end

    ServerGameManager.playerList[player.UserId] = nil
    ServerGameManager.playerCount -= 1
end

function ServerGameManager:Update(deltaTime)
    
end

return ServerGameManager