local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local TeamDeathMatch = {}
TeamDeathMatch.__index = TeamDeathMatch

function TeamDeathMatch.new()
    local newRound = {}
    setmetatable(newRound, TeamDeathMatch)

    newRound.Name = "Team Death Match"

    return newRound
end

function TeamDeathMatch:Init(playerList)
    self.roundMaxDuration = 60 * 8
    self.roundDuration = self.roundMaxDuration
    
    self.playersInRound = {}
    self.Teams ={
        ["Red"] = {},
        ["Blue"] = {},
    }

    self.roundEnded = false

    self:Setup(playerList, true)
end

function TeamDeathMatch:Setup(playerList, isList)
    if isList then
        local listCopy = {}
        for player, _ in playerList do
            table.insert(listCopy, player)
        end

        local randomTable = {}
        local RandomChosenValue
        for _ = 1, #listCopy, 1 do
            repeat
                RandomChosenValue = listCopy[math.random(1, #listCopy)]
            until not table.find(randomTable, RandomChosenValue)
            table.insert(randomTable, RandomChosenValue)
        end

        for i, player in pairs(randomTable) do
            if i%2 == 0 then
                self.Teams.Red[player] = {player, 0}
            else
                self.Teams.Blue[player] = {player, 0}
            end
        end
    else
        local teamRed = 0
        local teamBlue = 0

        for _, playerData in pairs(self.Teams.Red) do
            teamRed += 1
        end

        for _, playerData in pairs(self.Teams.Blue) do
            teamBlue += 1
        end
    end
end

function TeamDeathMatch:AddKill(player)

end

function TeamDeathMatch:EndRound()
    self.roundDuration = 0

end

function TeamDeathMatch:RewardPlayers(newList)

end

function TeamDeathMatch:Update(maxTick, deltaTime)
    self.roundDuration -= maxTick
    Events.Server_Client.CountDown:FireAllClients(self.Name, self.roundDuration)

    if self.roundDuration <= 0 then
        self.roundEnded = true
    end
end

return TeamDeathMatch