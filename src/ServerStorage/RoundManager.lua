local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local MapAssets = Assets:WaitForChild("Map")
local Maps = ServerStorage:WaitForChild("Maps")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local TestState = workspace:GetAttribute("TestState")

local RoundManager = {}
RoundManager.__index = RoundManager

function SortTable(oldTable)
    local sortedTable = table.clone(oldTable)

    table.sort(sortedTable, function(a, b)
        return a[2] > b[2]
    end)

    return sortedTable
end

function RoundManager.new()
    local newRound = {}
    setmetatable(newRound, RoundManager)

    return newRound
end

function RoundManager:Init(ServerGameManager)
    self.serverGameManager = ServerGameManager

    self.belowLimit = 1

    if TestState then
        self.belowLimit = 0
    end

    self.maxTick = 1
    self.currTick = 0

    self.intermission = false
    self.intermissionDuration = 0

    self.startCountDown = false
    self.countDown = 0

    self.roundStart = false
    self.roundDuration = 0

    self.playersInRound = {}
    
    --setting round duration based on gamemode?
    self.roundMaxDuration = 120

    --map selection will be needed later on
    self.availableMaps = {
        Maps:WaitForChild("GreatSkyPlatform")
    }

    self.mapCount = 1

    self.MapSelected = false
    self.Map = workspace.Map

    self.healthPads = {}
end

function RoundManager:SelectMap()
    warn("selecting map...")
    self.MapSelected = true

    local choice = math.random(1, self.mapCount)
    
    self.Map = self.availableMaps[choice]:Clone()
    self.Map.Parent = workspace

    warn(self.Map.Name, "selected!!!")
end

function RoundManager:CleanupMap()
    if self.Map then
        self.Map:Destroy()
    end

    self.Map = nil
    self.MapSelected = false
end

function RoundManager:ConfigurePickups(pickupFolder)
    for _, pad in pairs(pickupFolder:GetChildren()) do
        local pickup = MapAssets.Pickups.HealthPickup:Clone()
        pickup.PrimaryPart.Position = pad.Position
        pickup.Parent = workspace.Ignore

        self.healthPads[pad] = {}
        self.healthPads[pad].pad = pickup
        self.healthPads[pad].isActive = true
        self.healthPads[pad].hitbox = pickup.Hitbox
        self.healthPads[pad].Cube = pickup.Cube
        self.healthPads[pad].cooldown = 10
        self.healthPads[pad].currTime = 0
        self.healthPads[pad].UI = pickup.PrimaryPart.Cooldown
        self.healthPads[pad].Timer = pickup.PrimaryPart.Cooldown.Timer

        pad.Transparency = 1
    end
end

function RoundManager:CleanupPickups()
    for padId, padData in pairs(self.healthPads) do
        if padData.pad then
            padData.pad:Destroy()
        end

        self.healthPads[padId] = nil
    end

    self.healthPads = {}
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

        local xRange = teleporter.Size.X/2
        local zRange = teleporter.Size.Z/2

        local xOffset = math.random(-xRange, xRange)
        local zOffset = math.random(-zRange, zRange)

        if CollectionService:HasTag(data.character, "Invulnerable") then
            CollectionService:RemoveTag(data.character, "Invulnerable")
        end

        local currentTag = nil
        for i, tag in pairs(self.playersInRound) do
            if tag[1] == player.Name then
                currentTag = tag
            end
        end

        if not currentTag then
            local tag = {player.Name, 0}
            table.insert(self.playersInRound, tag)
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

    local xRange = teleporter.Size.X/2
    local zRange = teleporter.Size.Z/2

    local xOffset = math.random(-xRange, xRange)
    local zOffset = math.random(-zRange, zRange)

    if CollectionService:HasTag(character, "Invulnerable") then
        CollectionService:RemoveTag(character, "Invulnerable")
    end

    local currentTag = nil
    for i, tag in pairs(self.playersInRound) do
        if tag[1] == player.Name then
            currentTag = tag
        end
    end

    if not currentTag then
        local tag = {player.Name, 0}
        table.insert(self.playersInRound, tag)
    end

    character:PivotTo(teleporter.CFrame * CFrame.new(xOffset, 0, zOffset))
end

function RoundManager:AddKill(player: Player)
    if not player then
        return
    end
    
    for i, tag in pairs(self.playersInRound) do
        if tag[1] == player.Name then
            tag[2] += 1
        end
    end
end

function RoundManager:UpdatePickups(deltaTime)
    if self.roundStart then
        for _, padData in pairs(self.healthPads) do
            padData.Cube.Orientation += Vector3.new(1, 1, 0)

            if not padData.isActive then
                if padData.currTime <= 0 then
                    padData.isActive = true
                    padData.UI.Enabled = false
                    padData.currTime = padData.cooldown
    
                    padData.Cube.Transparency = 0
                end
    
                padData.currTime -= deltaTime
                padData.currTime = math.clamp(padData.currTime, 0, padData.cooldown)
                local durationText = string.format("%0.2f", padData.currTime)
                padData.Timer.Text = "["..durationText.."]"

                continue
            end

            local playerList = {}
            for _, plr in pairs(game.Players:GetChildren()) do
                local char = plr.Character
                table.insert(playerList, char)
            end

            local overlap = OverlapParams.new()
            overlap.FilterDescendantsInstances = {playerList}
            overlap.FilterType = Enum.RaycastFilterType.Include

            local touchedObjects = workspace:GetPartsInPart(padData.hitbox, overlap)

            for i=1, #touchedObjects do
                local object = touchedObjects[i]
                local parent = object.Parent

                local humanoid = parent:FindFirstChild("Humanoid")
                if not humanoid then
                    continue
                end

                if humanoid.Health <= 0 then
                    continue
                end

                if not padData.isActive then
                    continue
                end

                padData.isActive = false
                padData.Cube.Transparency = 1
                padData.Cube.Idle.Health.Enabled = false
                padData.UI.Enabled = true

                padData.Cube.Burst.Health:Emit(8)
                padData.Cube.Burst.Ring:Emit(3)

                HealthManager:Heal(parent, 25)
            end
        end
    end
end

function RoundManager:RewardPlayers(newList)
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

function RoundManager:Update(deltaTime)
    self.currTick += deltaTime

    self:UpdatePickups(deltaTime)

    if self.currTick >= self.maxTick then
        self.currTick = 0

        --not enough players
        if self.serverGameManager.playerCount <= self.belowLimit then
            Events.Server_Client.CountDown:FireAllClients("not enough players", 0)
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
        if playerHasClass <= self.belowLimit and not self.roundStart then
            Events.Server_Client.CountDown:FireAllClients("not enough players ready", 0)
            return
        end

        if not self.roundStart then
            if not self.startCountDown then
                self.startCountDown = true
                
                self.countDown = 15
                if TestState then
                    --self.countDown = 1000
                end

                --map selection
            if not self.MapSelected then
                self:SelectMap()
            end

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

                    self:ConfigurePickups(self.Map.HealthPads)

                    Events.Server_Client.CountDown:FireAllClients("Round", self.roundDuration)

                    self:TeleportAllPlayers()

                    --warn("Start Round!!!")
                end
            end
        elseif self.roundStart then
            self.roundDuration -= self.maxTick
            Events.Server_Client.CountDown:FireAllClients("Round", self.roundDuration)

            if self.roundDuration <= 0 then
                self.roundStart = false
                self.roundDuration = 0

                local newList = SortTable(self.playersInRound)
                self:RewardPlayers(newList)

                self.playersInRound = {}

                self:CleanupPickups()

                self:ResetAllPlayers()

                self:CleanupMap()

                self.intermission = true
                self.intermissionDuration = 20

                Events.Server_Client.CountDown:FireAllClients("Intermission", self.intermissionDuration)

                --warn("ROUND OVER!!!")
            end
        end
    end
end

return RoundManager