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

    ServerGameManager:ConfigureDummies()
end

function ServerGameManager:ConfigureDummies()
    ServerGameManager.dummyTimers = {}

    local configurations = {
        [Dummies.Dummy1] = {
            Class = "Engineer",
            MoveType = "EMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy2] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy3] = {
            Class = "Pyromancer",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy4] = {
            Class = "Samurai",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy5] = {
            Class = "Engineer",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy6] = {
            Class = "ShieldWarrior",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy7] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy8] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy9] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy10] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy11] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy12] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy13] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy14] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
        [Dummies.Dummy15] = {
            Class = "AngelKnight",
            MoveType = "LMBMove",
            currTime = 0,
            maxTime = 1,
            MoveCount = 0,
        },
    }
    
    for _, dummy in pairs(Dummies:GetChildren()) do
        CharacterSelectServer:DummyJoined(dummy)

        if configurations[dummy] then
            ServerGameManager.dummyTimers[dummy] = table.clone(configurations[dummy])
            ServerGameManager.dummyTimers[dummy].dummy = dummy

            dummy:SetAttribute("CurrentClass", configurations[dummy].Class)

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

    CharacterSelectServer:PlayerJoined(player)

    ServerGameManager.playerManager:PlayerJoin(player)

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

function ServerGameManager:Update(deltaTime)
    HitboxManager:Update(deltaTime)
    StateManager:Update(deltaTime)
    MoveManager:Update(deltaTime)
    PassiveManager:Update(deltaTime)
    ServerGameManager.playerManager:Update(deltaTime)
    ServerGameManager.characterSelect:Update(deltaTime)
    LeaderboardManager:Update(deltaTime)

    if ServerGameManager.roundManager then
        ServerGameManager.roundManager:Update(deltaTime)
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

            local anim = AnimationData[data.Class][data.MoveType]
            if type(anim) == "table" and data.MoveType == "LMBMove" then
                anim = anim[data.MoveCount]
            end

            local moveCount
            if data.MoveType == "LMBMove" then
                moveCount = data.MoveCount
            else
                moveCount = nil
            end

            local currentClassData = ClassData[data.Class]

            local animation: AnimationTrack = data.dummy.Humanoid.Animator:LoadAnimation(anim)

            local hasEvent = ClassData[data.Class].MoveData[data.MoveType].hasEvent
            if hasEvent then
                local event
                event = animation:GetMarkerReachedSignal("Attack"):Connect(function()
                    if event then
                        event:Disconnect()
                    end

                    if data.MoveType == "LMBMove" then
                        Events.Server_Server.DummyHitbox:Fire(data.dummy, data.Class, data.MoveType, moveCount, currentClassData.MoveData[data.MoveType])
                    else
                        MoveManager:Ability(data.dummy, data.Class, data.MoveType, currentClassData.MoveData[data.MoveType])
                    end
                end)
            else
                if data.MoveType == "LMBMove" then
                    Events.Server_Server.DummyHitbox:Fire(data.dummy, data.Class, data.MoveType, moveCount, currentClassData.MoveData[data.MoveType])
                else
                    MoveManager:Ability(data.dummy, data.Class, data.MoveType, currentClassData.MoveData[data.MoveType])
                end
            end

            animation:Play()
        end
    end
end

return ServerGameManager