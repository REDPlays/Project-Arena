local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerStorage = game:GetService("ServerStorage")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local PlayerDataManager = require(ServerStorage.ServerFiles.Player.PlayerDataManager)

local ValidIds = {
    ["126372777"] = "OwnerID",
    ["-1"] = "player1",
    ["-2"] = "player2",
    ["-3"] = "player3",
}

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

local function DebuggerTool(player: Player, debugType)
    local userId = player.UserId

    if not ValidIds[userId] then
        return "Not Owner | WARNED!!!"
    end

    if not debugType then
        return "No Debug Type!!!"
    end

    if debugType == "Tokens" then
        PlayerManager:AddToken(player, 100)
    elseif debugType == "Kills" then
        PlayerManager:AddKill(player)
    elseif debugType == "Wins" then
        PlayerManager:AddWin(player)
    end

    return "Successful!!!"
end

Events.Server_Server.RewardPlayers.Event:Connect(RewardPlayers)
Events.Client_Server.Debugger.OnServerInvoke = DebuggerTool

return PlayerManager