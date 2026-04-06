local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local MapAssets = Assets:WaitForChild("Map")
local Maps = ReplicatedStorage:WaitForChild("Maps")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))
local MapData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Maps"):WaitForChild("MapData"))

local ServerInfo = require(ServerStorage:WaitForChild("ServerFiles"):WaitForChild("ServerInfo"))

local TestState = workspace:GetAttribute("TestState")
local Training = workspace:GetAttribute("Training")

local GamemodesList = {
    --["FreeForAll"] = require(ServerStorage.ServerFiles.gamemodes.FreeForAll),
    ["TeamDeathMatch"] = require(ServerStorage.ServerFiles.gamemodes.TeamDeathMatch),
}

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

    self.intermission = true
    self.inermissionTime = 15
    self.intermissionDuration = self.inermissionTime

    self.ceremonyTime = 10
    self.ceremony = false
    
    self.currentGameMode = nil

    self.startCountDown = false
    self.countDown = 0

    self.roundStart = false
    self.roundDuration = 0
    
    --setting round duration based on gamemode?
    self.roundMaxDuration = 180

    --map selection will be needed later on
    self.availableMaps = {
        Maps:WaitForChild("GreatSkyPlatform"),
        Maps:WaitForChild("ShanghaiShowdown"),
    }

    self.mapPool = table.clone(self.availableMaps)

    self.mapCount = #self.mapPool

    self.MapSelected = false
    self.Map = ""
    self.MapPivot = CFrame.new(Vector3.new(-44505.016, 500, 29.022))

    self.healthPads = {}
end

function RoundManager:ChangeLighting(lightingType)
    local lightingData = MapData[lightingType]
    if not lightingData then
        warn("invalid lighting data")
        return
    end

    local info = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for propertyName, propertyValue in pairs(lightingData) do
        TweenService:Create(Lighting, info, {[propertyName] = propertyValue}):Play()
    end
end

function RoundManager:MapLoader(choice)
    local sudoParent = Instance.new("Model")
    sudoParent:PivotTo(self.MapPivot)

    local parentLocation = {}

    self.Map = self.mapPool[choice]:Clone()
    self.Map:PivotTo(self.MapPivot)

    --local startTime = os.clock()
    for _, groups in pairs(self.Map:GetChildren()) do
        for _, subgroups in pairs(groups:GetChildren()) do
            for _, sub in pairs(subgroups:GetChildren()) do
                parentLocation[sub] = groups
                sub.Parent = sudoParent
            end
        end
    end

    self.Map.Parent = workspace

    for _, sub in pairs(sudoParent:GetChildren()) do
        sub.Parent = parentLocation[sub]
        task.wait(0.1)
    end

    --warn("total time to load map:", os.clock() - startTime)
end

function RoundManager:SelectMap()
    ServerInfo:SendMessage("Selecting Map...")

    self.MapSelected = true

    local choice = math.random(1, self.mapCount)

    self:MapLoader(choice)

    table.remove(self.mapPool, choice)
    self.mapCount = #self.mapPool

    if self.mapCount == 0 then
        self.mapPool = table.clone(self.availableMaps)
        self.mapCount = #self.mapPool
    end

    task.delay(1, function()
        self:ChangeLighting(self.Map.Name)
    end)

    ServerInfo:SendMessage(self.Map.Name.." selected.")
end

function RoundManager:CleanupMap()
    if self.Map then
        self.Map:Destroy()
    end

    self:ChangeLighting("Default")

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
        self.healthPads[pad].cooldown = 20
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
        warn("data.character:", data.character)
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

        data.character:PivotTo(teleporter.CFrame * CFrame.new(xOffset, 0, zOffset))
    end

    return self.serverGameManager.characterSelect.hasClass
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

        humanoid.Health = -humanoid.MaxHealth * 2
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

    if self.currentGameMode then
        self.currentGameMode:Setup(player, false)
    end

    character:PivotTo(teleporter.CFrame * CFrame.new(xOffset, 0, zOffset))
end

function RoundManager:AddKill(player: Player)
    if not player then
        return
    end

    if not self.currentGameMode then
        return
    end

    self.currentGameMode:AddKill(player)
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
                padData.Cube.Burst.Ring:Emit(2)

                HealthManager:Heal(parent, 15)
            end
        end
    end
end

function RoundManager:Update(deltaTime)
    self.currTick += deltaTime

    self:UpdatePickups(deltaTime)

    --every second update tick
    if self.currTick >= self.maxTick then
        self.currTick = 0

        --not enough players
        if self.serverGameManager.playerCount <= self.belowLimit then
            Events.Server_Client.CountDown:FireAllClients("not enough players", 0)
            return
        end
        
        local playerHasClass = 0
        for player, data in pairs(self.serverGameManager.characterSelect.hasClass) do
            playerHasClass += 1
        end

        --count down for intermission in ceremony
        if self.intermission and self.ceremony then

            self.intermissionDuration -= self.maxTick

            Events.Server_Client.CountDown:FireAllClients("Ceremony", self.intermissionDuration)

            --allow players to vote for current gamemode

            if self.intermissionDuration <= 0 then
                self.intermission = false
                self.ceremony = false
                self.intermissionDuration = self.inermissionTime

                Events.Server_Client.Ceremony:FireAllClients("RESET", false)
            end

            return
        end

        --not enough players with a class
        if playerHasClass <= self.belowLimit and not self.roundStart then
            Events.Server_Client.CountDown:FireAllClients("not enough players ready", 0)
            return
        end

        --count down for intermission
        if self.intermission then

            self.intermissionDuration -= self.maxTick

            Events.Server_Client.CountDown:FireAllClients("Intermission", self.intermissionDuration)

            --allow players to vote for current gamemode

            if self.intermissionDuration <= 0 then
                self.intermission = false
                self.intermissionDuration = 0
            end

            return
        end

        if not self.currentGameMode then
            --ServerInfo:SendMessage("No current gamemode selected, choose at random")

            local sudoModeList = {}
            for gamemode, _ in pairs(GamemodesList) do
                table.insert(sudoModeList, gamemode)
            end

            local selection = sudoModeList[math.random(1, #sudoModeList)]
            if not selection then
                selection = "FreeForAll"
            end

            ServerInfo:SendMessage("CurrentGameMode: "..selection)

            self.currentGameMode = GamemodesList[selection].new()
        end

        if not self.roundStart then
            if not self.startCountDown then
                self.startCountDown = true
                
                self.countDown = 15

                --map selection
                if not self.MapSelected then
                    self:SelectMap()
                end

                Events.Server_Client.ToggleUI:FireAllClients(self.currentGameMode.Name)
                Events.Server_Client.CountDown:FireAllClients("CountDown", self.countDown)
            end
            
            if self.startCountDown and self.countDown > 0 then
                self.countDown -= self.maxTick
                Events.Server_Client.CountDown:FireAllClients("CountDown", self.countDown)
    
                if self.countDown <= 0 then
                    self.roundStart = true

                    self.currentGameMode:Init(self.serverGameManager.characterSelect.hasClass)

                    self.startCountDown = false
                    self.countDown = 0

                    self:ConfigurePickups(self.Map.HealthPads)

                    Events.Server_Client.teleportDisable:FireAllClients()

                    Events.Server_Client.CountDown:FireAllClients(self.currentGameMode.Name, self.roundDuration)

                    task.delay(0.25, function()
                        self:TeleportAllPlayers()
                    end)

                    ServerInfo:SendMessage("Start Match!")
                end
            end
        elseif self.roundStart then
            self.currentGameMode:Update(self.maxTick, deltaTime)

            if self.currentGameMode.roundEnded then
                self.roundStart = false
                self.ceremony = true

                self.currentGameMode:EndRound()

                ServerInfo:SendMessage("End Match!")

                self.currentGameMode = nil

                self:CleanupPickups()

                self:ResetAllPlayers()

                self:CleanupMap()

                self.intermission = true
                self.intermissionDuration = self.ceremonyTime

                Events.Server_Client.CountDown:FireAllClients("Intermission", self.intermissionDuration)
            end
        end
    end
end

return RoundManager