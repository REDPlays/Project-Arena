local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local AnimationData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Player"):WaitForChild("AnimationData"))

local CharacterSelectServer = require(ServerStorage.ServerFiles.Player.CharacterSelect_Server)
local InputManager = require(ServerStorage.ServerFiles.Player.InputManager)
local HitboxManager = require(ReplicatedStorage.RepFiles.Combat.HitboxManager)
local StateManager = require(ReplicatedStorage.RepFiles.Combat.StateManager)
local MoveManager = require(ReplicatedStorage.RepFiles.Combat.MoveManager)
local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)
local RoundManager = require(ServerStorage.ServerFiles.RoundManager)
local PlayerManager = require(ServerStorage.ServerFiles.Player.PlayerManager)
local LeaderboardManager = require(ServerStorage.ServerFiles.Player.LeaderboardManager)

local Lobby = workspace.Lobby
local Dummies = workspace.Dummies

local ServerGameManager = {}
ServerGameManager.playerList = {}
ServerGameManager.playerCount = 0

function ServerGameManager:Init()
    ServerGameManager.roundManager = RoundManager.new()
    ServerGameManager.roundManager:Init(ServerGameManager)

    ServerGameManager.playerManager = PlayerManager

    ServerGameManager.characterSelect = CharacterSelectServer
    ServerGameManager.characterSelect:Init(Lobby, ServerGameManager.roundManager, ServerGameManager.playerManager)

    LeaderboardManager:Init(ServerGameManager.playerManager)

    ServerGameManager:ConfigureDummies()
end

function ServerGameManager:ConfigureDummies()
    ServerGameManager.dummyTimers = {}
    
    for _, dummy in pairs(Dummies:GetChildren()) do
        CharacterSelectServer:DummyJoined(dummy)
    end

    StateManager:AddTarget(Dummies.DummyBlocker, "Blocking")

    ServerGameManager.dummyTimers[Dummies.DummyAttacker] = {
        dummy = Dummies.DummyAttacker,
        currTime = 0,
        maxTime = 1,
    }

    ServerGameManager.dummyTimers[Dummies.DummyStunner] = {
        dummy = Dummies.DummyStunner,
        currTime = 0,
        maxTime = 3,
    }

    ServerGameManager.dummyTimers[Dummies.DummyBurn] = {
        dummy = Dummies.DummyBurn,
        currTime = 0,
        maxTime = 1,
    }

    ServerGameManager.dummyTimers[Dummies.DummySlow] = {
        dummy = Dummies.DummySlow,
        currTime = 0,
        maxTime = 3,
    }
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
    ServerGameManager.playerManager:Update(deltaTime)
    ServerGameManager.characterSelect:Update(deltaTime)
    LeaderboardManager:Update(deltaTime)

    if ServerGameManager.roundManager then
        ServerGameManager.roundManager:Update(deltaTime)
    end

    for dummyId, data in pairs(ServerGameManager.dummyTimers) do
        data.currTime += deltaTime

        local isStun = false
        if data.dummy.Name == "DummyStunner" then
            isStun = true
        end

        local isBurn = false
        if data.dummy.Name == "DummyBurn" then
            isBurn = true
        end

        local isSlow = false
        if data.dummy.Name == "DummySlow" then
            isSlow = true
        end

        if data.currTime >= data.maxTime then
            data.currTime = 0

            local animation = data.dummy.Humanoid.Animator:LoadAnimation(AnimationData.Base.DummyAttack)
            animation:Play()

            HitboxManager:HitboxDebugger(data.dummy, isStun, isBurn, isSlow)
        end
    end
end

return ServerGameManager