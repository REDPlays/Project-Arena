local TeamDeathMatch = {}
TeamDeathMatch.__index = TeamDeathMatch

function TeamDeathMatch.new()
    local newRound = {}
    setmetatable(newRound, TeamDeathMatch)

    newRound.Name = "Team Death Match"

    return newRound
end

function TeamDeathMatch:Init(playerList)
    
end

function TeamDeathMatch:EndRound()
    
end

function TeamDeathMatch:Update(deltaTime)
    
end

return TeamDeathMatch