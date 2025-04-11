local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Indicators = Assets:WaitForChild("Indicators")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local TestState = workspace:GetAttribute("TestState")
local Training = workspace:GetAttribute("Training")
local QuickRounds = workspace:GetAttribute("QuickRounds")

local TeamDeathMatch = {}
TeamDeathMatch.__index = TeamDeathMatch

function TeamDeathMatch.new()
    local newRound = {}
    setmetatable(newRound, TeamDeathMatch)

    newRound.Name = "Team Death Match"

    return newRound
end

function TeamDeathMatch:Init(playerList)
    self.roundMaxDuration = 60 * 4
    self.roundDuration = self.roundMaxDuration

    if TestState then
        self.roundDuration = 60*100
    end

    if QuickRounds then
        self.roundDuration = 30
    end
    
    self.playersInRound = {}
    self.Teams = {
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
                player.Character:SetAttribute("Team", "Red")
                self:SetVisual(player.Character, "Red")
            else
                self.Teams.Blue[player] = {player, 0}
                player.Character:SetAttribute("Team", "Blue")
                self:SetVisual(player.Character, "Blue")
            end
        end
    else
        local _player = playerList

        if self.Teams.Red[_player] then
            warn(_player, "is already in game on team: RED")
            _player.Character:SetAttribute("Team", "Red")
            self:SetVisual(_player.Character, "Red")
            return
        end

        if self.Teams.Blue[_player] then
            warn(_player, "is already in game on team: BLUE")
            _player.Character:SetAttribute("Team", "Blue")
            self:SetVisual(_player.Character, "Blue")
            return
        end

        local teamRed = 0
        local teamBlue = 0

        for _, playerData in pairs(self.Teams.Red) do
            teamRed += 1
        end

        for _, playerData in pairs(self.Teams.Blue) do
            teamBlue += 1
        end

        if teamBlue > teamRed then
            self.Teams.Red[_player] = {_player, 0}
            _player.Character:SetAttribute("Team", "Red")
            self:SetVisual(_player.Character, "Red")
        elseif teamRed > teamBlue then
            self.Teams.Blue[_player] = {_player, 0}
            _player.Character:SetAttribute("Team", "Blue")
            self:SetVisual(_player.Character, "Blue")
        else
            local random = math.random(1, 2)
            if random == 1 then
                self.Teams.Blue[_player] = {_player, 0}
                _player.Character:SetAttribute("Team", "Blue")
                self:SetVisual(_player.Character, "Blue")
            elseif random == 2 then
                self.Teams.Red[_player] = {_player, 0}
                _player.Character:SetAttribute("Team", "Red")
                self:SetVisual(_player.Character, "Red")
            end
        end
    end
end

function TeamDeathMatch:SetVisual(character: Model, team)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local Ring = Indicators:WaitForChild(team.."Ring"):Clone()
    Ring.CFrame = character:GetPivot() * CFrame.new(0, Ring.Size.Y/2, 0)
    Ring.Parent = character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Ring
    weld.Part1 = rootPart
    weld.Parent = weld.Part0
end

function TeamDeathMatch:AddKill(player)
    --warn("Add Kill for:", player)
    --print(debug.traceback())
    if self.roundEnded then
        --can't earn kills when round is over
        return
    end

    for team, playerList in pairs(self.Teams) do
        for playerId, playerData in pairs(playerList) do
            if player == playerId then
                playerData[2] += 1
            end
        end
    end
end

function TeamDeathMatch:EndRound()
    self.roundDuration = 0

    local endScores = {
        ["Red"] = 0,
        ["Blue"] = 0,
    }

    for team, playerList in pairs(self.Teams) do
        for _, playerData in pairs(playerList) do
            --adding up the kills
            endScores[team] += playerData[2]
            playerData[1].Character:SetAttribute("Team", nil)
        end
    end

    if endScores.Red > endScores.Blue then
        --red team wins rewards
        self:RewardPlayers(self.Teams.Red)

        Events.Server_Client.Ceremony:FireAllClients("TDM", true, self.Teams.Red)
    elseif endScores.Blue > endScores.Red then
        --blue team wins rewards
        self:RewardPlayers(self.Teams.Blue)

        Events.Server_Client.Ceremony:FireAllClients("TDM", true, self.Teams.Blue)
    elseif endScores.Red == endScores.Blue then
        --all players will receive rewards but at a reduction since they tied
        self:RewardPlayers(self.Teams.Red, true)
        self:RewardPlayers(self.Teams.Blue, true)
    end
end

function TeamDeathMatch:RewardPlayers(newList, isTie)
    local rewardData = {}
    local rewardCount = 0

    local tokens = 100
    local placement = 1
    if isTie then
        tokens *= 0.5
        placement = 0
    end

    for playerId, playerData in pairs(newList) do
        local player = playerData[1]

        --make ui display victory screen

        Events.Server_Server.RewardPlayers:Fire(player, tokens, placement)
    end
end

function TeamDeathMatch:Update(maxTick, deltaTime)
    self.roundDuration -= maxTick
    Events.Server_Client.CountDown:FireAllClients(self.Name, self.roundDuration)
    
    local scoreData = {
        ["Red"] = 0,
        ["Blue"] = 0,
    }
    for team, playerList in pairs(self.Teams) do
        for _, playerData in pairs(playerList) do
            --adding up the kills
            scoreData[team] += playerData[2]
        end
    end

    Events.Server_Client.ScoreCount:FireAllClients(self.Name, scoreData)

    if self.roundDuration <= 0 then
        self.roundEnded = true
    end
end

return TeamDeathMatch