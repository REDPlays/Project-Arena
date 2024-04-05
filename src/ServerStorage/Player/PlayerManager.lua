local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerStorage = game:GetService("ServerStorage")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local PlayerDataManager = require(ServerStorage.ServerFiles.Player.PlayerDataManager)

local PlayerManager = {}
PlayerManager.playerDatas = {}

function PlayerManager:Init(roundManager)
    PlayerManager.roundManager = roundManager
end

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

    PlayerManager.roundManager:AddKill(player)

    --10 tokens a kill
    PlayerDataManager:AddToken(player, 10)
end

function PlayerManager:AddWin(player: Player)
    PlayerDataManager:AddWin(player)
end

function PlayerManager:GetData(player: Player)
    return PlayerDataManager:Get(player)
end

function PlayerManager:Update(deltaTime)
    
end

local function RewardPlayers(player: Player, tokenAmount: number, placement: number)
    PlayerManager:AddToken(player, tokenAmount)

    if placement == 1 then
        PlayerManager:AddWin(player)
    end
end

Events.Server_Server.RewardPlayers.Event:Connect(RewardPlayers)

return PlayerManager