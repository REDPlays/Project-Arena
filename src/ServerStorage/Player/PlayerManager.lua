local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerStorage = game:GetService("ServerStorage")

local PlayerDataManager = require(ServerStorage.ServerFiles.Player.PlayerDataManager)

local PlayerManager = {}
PlayerManager.playerDatas = {}

function PlayerManager:PlayerJoin(player: Player)
    PlayerDataManager:onPlayerAdded(player)
end

function PlayerManager:PlayerRemove(player: Player)
    PlayerDataManager:onPlayerRemoving(player)
end

function PlayerManager:AddToken(player: Player, tokenAmount: number)
    PlayerDataManager:AddToken(player, tokenAmount)
end

function PlayerManager:RemoveToken(player: Player, tokenAmount: number)
    PlayerDataManager:RemoveToken(player, tokenAmount)
end

function PlayerManager:AddClass(player: Player, class)
    return PlayerDataManager:AddClass(player, class)
end

function PlayerManager:CheckClass(player: Player, class)
    return PlayerDataManager:CheckClass(player, class)
end

function PlayerManager:AddKill(player: Player)
    PlayerDataManager:AddKill(player)
end

function PlayerManager:GetData(player: Player)
    return PlayerDataManager:Get(player)
end

function PlayerManager:Update(deltaTime)
    
end

return PlayerManager