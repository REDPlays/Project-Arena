local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local TestState = workspace:GetAttribute("TestState")
local Training = workspace:GetAttribute("Training")

local FreeForAll = {}
FreeForAll.__index = FreeForAll

function SortTable(oldTable)
    local sortedTable = table.clone(oldTable)

    table.sort(sortedTable, function(a, b)
        return a[2] > b[2]
    end)

    return sortedTable
end

function FreeForAll.new()
    local newRound = {}
    setmetatable(newRound, FreeForAll)

    newRound.Name = "Free For All"

    return newRound
end

function FreeForAll:Init(playerList)
    self.roundMaxDuration = 60 * 4
    self.roundDuration = self.roundMaxDuration

    if TestState then
        self.roundDuration = 60*100
    end
    
    self.playersInRound = {}

    self.roundEnded = false

    self:Setup(playerList, true)
end

function FreeForAll:Setup(playerList, isList)
    if isList then
        for player, data in pairs(playerList) do
            if not data.character then
                continue
            end
    
            local currentTag = nil
            for _, tag in pairs(self.playersInRound) do
                if tag[1] == player.Name then
                    currentTag = tag
                end
            end
    
            if not currentTag then
                local tag = {player.Name, 0}
                table.insert(self.playersInRound, tag)
            end
        end
    elseif not isList then
        local _player = playerList

        local currentTag = nil
        for _, tag in pairs(self.playersInRound) do
            if tag[1] == _player.Name then
                currentTag = tag
            end
        end

        if not currentTag then
            local tag = {_player.Name, 0}
            table.insert(self.playersInRound, tag)
        end
    end
end

function FreeForAll:AddKill(player)
    for _, tag in pairs(self.playersInRound) do
        if tag[1] == player.Name then
            tag[2] += 1
        end
    end
end

function FreeForAll:EndRound()
    self.roundDuration = 0

    local newList = SortTable(self.playersInRound)
    self:RewardPlayers(newList)
end

function FreeForAll:RewardPlayers(newList)
    local rewardData = {}
    local rewardCount = 0

    for placement, tag in pairs(newList) do
        local player = Players:FindFirstChild(tag[1])
        if player then
            local tokens
            if placement == 1 then
                tokens = 100 + (tag[2] * 10)
            elseif placement == 2 then
                tokens = 75 + (tag[2] * 10)
            elseif placement == 3 then
                tokens = 50 + (tag[2] * 10)
            else
                tokens = 25 + (tag[2] * 10)
            end

            if placement < 4 then
                rewardCount += 1
                player.Character.Archivable = true
                rewardData[placement] = {
                    playerName = player.Name,
                    character = player.Character,
                    kills = tag[2],
                    tokens = tokens,
                }
            end

            Events.Server_Server.RewardPlayers:Fire(player, tokens, placement)
        end
    end

    Events.Server_Client.Rewards:FireAllClients(rewardData, rewardCount)
end

function FreeForAll:Update(maxTick, deltaTime)
    self.roundDuration -= maxTick
    Events.Server_Client.CountDown:FireAllClients(self.Name, self.roundDuration)

    if self.roundDuration <= 0 then
        self.roundEnded = true
    end
end

return FreeForAll