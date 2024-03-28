local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local RoundManager = {}
RoundManager.__index = RoundManager

function RoundManager.new()
    local newRound = {}
    setmetatable(newRound, RoundManager)

    return newRound
end

function RoundManager:Init(ServerGameManager)
    self.serverGameManager = ServerGameManager

    self.belowLimit = 1
    self.maxTick = 1
    self.currTick = 0

    self.intermission = false
    self.intermissionDuration = 0

    self.startCountDown = false
    self.countDown = 0

    self.roundStart = false
    self.roundDuration = 0
    
    --setting round duration based on gamemode?
    self.roundMaxDuration = 120

    --map selection will be needed later on
    self.Map = workspace.Map
end

function RoundManager:TeleportAllPlayers()
    local teleporter = self.Map:FindFirstChild("Teleporter")
    if not teleporter then
        return
    end

    for player, data in pairs(self.serverGameManager.characterSelect.hasClass) do
        if not data.character then
            continue
        end

        local xRange = teleporter.Size.X
        local zRange = teleporter.Size.Z

        local xOffset = math.random(-xRange, xRange)
        local zOffset = math.random(-zRange, zRange)

        if CollectionService:HasTag(data.character, "Invulnerable") then
            CollectionService:RemoveTag(data.character, "Invulnerable")
        end

        data.character:PivotTo(teleporter.CFrame * CFrame.new(xOffset, 0, zOffset))
    end
end

function RoundManager:ResetAllPlayers()
    for player, data in pairs(self.serverGameManager.characterSelect.hasClass) do
        if not data.character then
            continue
        end

        local humanoid = data.character:FindFirstChild("Humanoid")
        if not humanoid then
            continue
        end

        humanoid.Health = -100
    end
end

function RoundManager:TeleportPlayer(player: Player)
    local character = player.Character
    if not character then
        return
    end

    local teleporter = self.Map:FindFirstChild("Teleporter")
    if not teleporter then
        return
    end

    local xRange = teleporter.Size.X
    local zRange = teleporter.Size.Z

    local xOffset = math.random(-xRange, xRange)
    local zOffset = math.random(-zRange, zRange)

    if CollectionService:HasTag(character, "Invulnerable") then
        CollectionService:RemoveTag(character, "Invulnerable")
    end

    character:PivotTo(teleporter.CFrame * CFrame.new(xOffset, 0, zOffset))
end

function RoundManager:Update(deltaTime)
    self.currTick += deltaTime

    if self.currTick >= self.maxTick then
        self.currTick = 0

        --not enough players
        if self.serverGameManager.playerCount <= self.belowLimit then
            warn("not enough players")
            return
        end

        if self.intermission then
            self.intermissionDuration -= self.maxTick
            Events.Server_Client.CountDown:FireAllClients("Intermission", self.intermissionDuration)

            if self.intermissionDuration <= 0 then
                self.intermission = false
                self.intermissionDuration = 0
            end

            return
        end
        
        local playerHasClass = 0
        for player, data in pairs(self.serverGameManager.characterSelect.hasClass) do
            playerHasClass += 1
        end

        --not enough players with a class
        if playerHasClass <= self.belowLimit then
            warn("not enough players ready")
            return
        end

        if not self.roundStart then
            if not self.startCountDown then
                self.startCountDown = true
                self.countDown = 15

                Events.Server_Client.CountDown:FireAllClients("CountDown", self.countDown)
            end
            
            if self.startCountDown and self.countDown > 0 then
                self.countDown -= self.maxTick
                Events.Server_Client.CountDown:FireAllClients("CountDown", self.countDown)
    
                if self.countDown <= 0 then
                    self.roundStart = true
                    self.roundDuration = self.roundMaxDuration

                    self.startCountDown = false
                    self.countDown = 0

                    Events.Server_Client.CountDown:FireAllClients("Round", self.roundDuration)

                    self:TeleportAllPlayers()

                    warn("Start Round!!!")
                end
            end
        elseif self.roundStart then
            self.roundDuration -= self.maxTick
            Events.Server_Client.CountDown:FireAllClients("Round", self.roundDuration)

            if self.roundDuration <= 0 then
                self.roundStart = false
                self.roundDuration = 0

                self:ResetAllPlayers()

                self.intermission = true
                self.intermissionDuration = 20

                Events.Server_Client.CountDown:FireAllClients("Intermission", self.intermissionDuration)

                warn("ROUND OVER!!!")
            end
        end
    end
end

return RoundManager