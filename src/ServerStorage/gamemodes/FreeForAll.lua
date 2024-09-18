local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local FreeForAll = {}
FreeForAll.__index = FreeForAll

function FreeForAll.new()
    local newRound = {}
    setmetatable(newRound, FreeForAll)

    newRound.Name = "Free For All"

    return newRound
end

function FreeForAll:Init(playerList)
    self.roundMaxDuration = 180
    self.roundDuration = self.roundMaxDuration
    
    self.playerList = playerList

    self.roundEnded = false
end

function FreeForAll:EndRound()
    self.roundDuration = 0
end

function FreeForAll:Update(maxTick, deltaTime)
    self.roundDuration -= maxTick
    Events.Server_Client.CountDown:FireAllClients(self.Name, self.roundDuration)

    if self.roundDuration <= 0 then
        self.roundEnded = true
    end
end

return FreeForAll