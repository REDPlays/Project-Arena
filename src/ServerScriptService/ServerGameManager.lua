local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local AnimationData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Player"):WaitForChild("AnimationData"))

local CharacterSelectServer = require(ServerStorage.ServerFiles.Player.CharacterSelect_Server)
local InputManager = require(ServerStorage.ServerFiles.Player.InputManager)
local HitboxManager = require(ReplicatedStorage.RepFiles.Combat.HitboxManager)
local MoveManager = require(ReplicatedStorage.RepFiles.Combat.MoveManager)
local StateManager = require(ReplicatedStorage.RepFiles.Combat.StateManager)
local PassiveManager = require(ReplicatedStorage.RepFiles.Combat.PassiveManager)
local MoveManager = require(ReplicatedStorage.RepFiles.Combat.MoveManager)
local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local RoundManager = require(ServerStorage.ServerFiles.RoundManager)
local PlayerManager = require(ServerStorage.ServerFiles.Player.PlayerManager)
local LeaderboardManager = require(ServerStorage.ServerFiles.Player.LeaderboardManager)
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local CharacterMoveLibrary = require(ReplicatedStorage.RepFiles.Player.CharacterMoveLibrary)

local Lobby = workspace.Lobby
local Dummies = workspace.Dummies

local ServerGameManager = {}
ServerGameManager.playerList = {}
ServerGameManager.playerCount = 0

function ServerGameManager:Init()
    ServerGameManager.roundManager = RoundManager.new()
    ServerGameManager.roundManager:Init(ServerGameManager)

    ServerGameManager.playerManager = PlayerManager
    ServerGameManager.playerManager:Init(ServerGameManager.roundManager)

    ServerGameManager.characterSelect = CharacterSelectServer
    ServerGameManager.characterSelect:Init(Lobby, ServerGameManager.roundManager, ServerGameManager.playerManager)

    LeaderboardManager:Init(ServerGameManager.playerManager)

    ServerGameManager.dummyTimers = {}
    ServerGameManager:ConfigureDummies()
end

function ServerGameManager:ConfigureDummies()
    local configurations = {
        [Dummies.AllyDummy] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currentMove = "M1",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
            Disabled = true,
            Team = "Ally",
        },

        [Dummies.Dummy1] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currentMove = "M1",
            currTime = 0,
            maxTime = 0.5,
            MoveCount = 0,
            Disabled = false,
            Team = "Dummy",
        },

        [Dummies.Dummy2] = {
            Class = "Pyromancer",
            MoveType = "LMBMove",
            currentMove = "M1",
            currTime = 0,
            maxTime = 0.5,
            MoveCount = 0,
            Disabled = false,
            Team = "Dummy",
        },

        [Dummies.Dummy3] = {
            Class = "Ranger",
            MoveType = "QMove",
            currentMove = "Piercing Arrow",
            currTime = 0,
            maxTime = 3,
            MoveCount = 0,
            Disabled = false,
            Team = "Dummy",
        },

        [Dummies.Dummy4] = {
            Class = "Engineer",
            MoveType = "EMove",
            currentMove = "Turret",
            currTime = 0,
            maxTime = 16,
            MoveCount = 0,
            Disabled = false,
            Team = "Dummy",
        },

        [Dummies.Dummy5] = {
            Class = "Hydromancer",
            MoveType = "EMove",
            currentMove = "Water Bubble",
            currTime = 0,
            maxTime = 8,
            MoveCount = 0,
            Disabled = false,
            Team = "Dummy",
        },
    }
    
    for _, dummy in pairs(Dummies:GetChildren()) do
        CharacterSelectServer:DummyJoined(dummy)

        if dummy.Name == "AllyDummy" then
            dummy:SetAttribute("DummyAlly", true)
        end

        if configurations[dummy] and not configurations[dummy].Disabled then
            ServerGameManager.dummyTimers[dummy] = table.clone(configurations[dummy])
            ServerGameManager.dummyTimers[dummy].dummy = dummy

            dummy:SetAttribute("CurrentClass", configurations[dummy].Class)

            if configurations[dummy].Team == "Dummy" then
                dummy:SetAttribute("Team", configurations[dummy].Team)
            end

            CharacterSelectServer:SetDummy(dummy, configurations[dummy].Class)
        end
    end
end

function ServerGameManager:ConfigureCharacter(player: Player, character: Model)
    local humanoid: Humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CollisionGroup = "Players" 
        end
    end

    local HealthScript = character:FindFirstChild("Health")
    if HealthScript then
        HealthScript.Disabled = false
        Debris:AddItem(HealthScript, 1)
    end

    local isDead
    isDead = humanoid.Died:Connect(function()
        player:SetAttribute("CurrentClass", nil)

        StateManager:RemoveAll(character)

        PassiveManager:ClearAllStacks(character)

        if ServerGameManager.characterSelect.hasClass[player] then
            ServerGameManager.characterSelect.hasClass[player] = nil
        end

        Events.Server_Client.Death:FireClient(player)

        if isDead then
            isDead:Disconnect()
        end
    end)
end

function ServerGameManager:PlayerJoin(player: Player)
    if ServerGameManager.playerList[player.UserId] then
        return
    end

    ServerGameManager.playerList[player.UserId] = player
    ServerGameManager.playerCount += 1

    ServerGameManager.playerManager:PlayerJoin(player)

    CharacterSelectServer:PlayerJoined(player)

    LeaderboardManager:PlayerJoin(player)

    return true
end

function ServerGameManager:PlayerRespawn(player: Player)
    CharacterSelectServer:PlayerJoined(player)
end

function ServerGameManager:PlayerLeave(player: Player)
    if not ServerGameManager.playerList[player.UserId] then
        return
    end

    if ServerGameManager.characterSelect.hasClass[player] then
        ServerGameManager.characterSelect.hasClass[player] = nil
    end

    ServerGameManager.playerList[player.UserId] = nil
    ServerGameManager.playerCount -= 1

    ServerGameManager.playerManager:PlayerRemove(player)

    LeaderboardManager:PlayerLeave(player)
end

local updateRate = 3
local update = 0
function ServerGameManager:UpdateDummies(deltaTime: number)
    update += deltaTime
    if update >= updateRate then
        update = 0
        for dummyId, data in pairs(ServerGameManager.dummyTimers) do
            if not data.dummy then continue end
            Events.Server_Client.UpdateDummyMove:FireAllClients(data.dummy, CharacterMoveLibrary.Movesets[data.dummy])
        end
    end

    for dummyId, data in pairs(ServerGameManager.dummyTimers) do
        if not data.dummy then continue end
        data.currTime += deltaTime

        if data.currTime >= data.maxTime then
            data.currTime = 0

            data.MoveCount += 1
            if data.MoveCount > 3 then
                data.MoveCount = 1
            end

            local class = data.Class
            local moveType = data.MoveType
            local currentMove = data.currentMove

            local anim
            if moveType == "LMBMove" then
                anim = AnimationData[class][moveType][data.MoveCount]
            else
                anim = AnimationData[class][currentMove]
            end

            local moveCount
            if moveType == "LMBMove" then
                moveCount = data.MoveCount
            else
                moveCount = nil
            end

            local currentClassData = ClassData[class]

            local animation: AnimationTrack = data.dummy.Humanoid.Animator:LoadAnimation(anim)

            local hasEvent = ClassData[class].MoveData[currentMove].hasEvent

            if hasEvent or moveType == "LMBMove" then
                animation:GetMarkerReachedSignal("Attack"):Once(function()
                    if moveType == "LMBMove" then
                        Events.Server_Server.DummyHitbox:Fire(data.dummy, class, moveType, moveCount, currentClassData.MoveData[currentMove])
                    else
                        MoveManager:Ability(data.dummy, class, moveType, currentClassData.MoveData[currentMove], currentMove)
                    end
                end)
            else
                MoveManager:Ability(data.dummy, class, moveType, currentClassData.MoveData[currentMove], currentMove)
            end

            animation:Play()
        end
    end
end

function ServerGameManager:Update(deltaTime)
    HitboxManager:Update(deltaTime)
    StateManager:Update(deltaTime)
    MoveManager:Update(deltaTime)
    PassiveManager:Update(deltaTime)
    ServerGameManager.playerManager:Update(deltaTime)
    ServerGameManager.characterSelect:Update(deltaTime)
    ServerGameManager:UpdateDummies(deltaTime)
    LeaderboardManager:Update(deltaTime)

    if ServerGameManager.roundManager then
        ServerGameManager.roundManager:Update(deltaTime)
    end
end

return ServerGameManager