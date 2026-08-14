local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:WaitForChild("Events")

local Client_Client = EventsFolder:WaitForChild("Client_Client")
local Client_Server = EventsFolder:WaitForChild("Client_Server")
local Server_Client = EventsFolder:WaitForChild("Server_Client")
local Server_Server = EventsFolder:WaitForChild("Server_Server")

local Events = {}

Events.Client_Client = {

}

Events.Client_Server = {
    CharacterSelect = Client_Server:WaitForChild("CharacterSelect"),
    Input = Client_Server:WaitForChild("Input"),
    Hitbox = Client_Server:WaitForChild("Hitbox"),
    Moves = Client_Server:WaitForChild("Moves"),
    ProjectileTarget = Client_Server:WaitForChild("ProjectileTarget"),
    Debugger = Client_Server:WaitForChild("Debugger"),
    SelectColor = Client_Server:WaitForChild("SelectColor"),
    SetUI = Client_Server:WaitForChild("SetUI") :: RemoteEvent,
    GetUI = Client_Server:WaitForChild("GetUI") :: RemoteFunction,
}

Events.Server_Client = {
    PlayerLoaded = Server_Client:WaitForChild("PlayerLoaded") :: RemoteEvent,
    Cooldown = Server_Client:WaitForChild("Cooldown") :: RemoteEvent,
    Death = Server_Client:WaitForChild("Death") :: RemoteEvent,
    Movement = Server_Client:WaitForChild("Movement") :: RemoteEvent,
    VisualEffects = Server_Client:WaitForChild("VisualEffects") :: RemoteEvent,
    TerminateVFX = Server_Client:WaitForChild("TerminateVFX") :: RemoteEvent,
    Hitbox = Server_Client:WaitForChild("Hitbox") :: RemoteEvent,
    CountDown = Server_Client:WaitForChild("CountDown") :: RemoteEvent,
    UpdateStatue = Server_Client:WaitForChild("UpdateStatue") :: RemoteEvent,
    Leaderboard = Server_Client:WaitForChild("Leaderboard") :: RemoteEvent,
    Rewards = Server_Client:WaitForChild("Rewards") :: RemoteEvent,
    AnimationSystem = Server_Client:WaitForChild("AnimationSystem") :: RemoteEvent,
    ScoreCount = Server_Client:WaitForChild("ScoreCount") :: RemoteEvent,
    ToggleUI = Server_Client:WaitForChild("ToggleUI") :: RemoteEvent,
    teleportDisable = Server_Client:WaitForChild("teleportDisable") :: RemoteEvent,
    Ceremony = Server_Client:WaitForChild("Ceremony") :: RemoteEvent,
    ReceiveMessage = Server_Client:WaitForChild("ReceiveMessage") :: RemoteEvent,
    GetTarget = Server_Client:WaitForChild("GetTarget") :: RemoteFunction,
}

Events.Server_Server = {
    Hitbox = Server_Server:WaitForChild("Hitbox") :: BindableEvent,
    RewardPlayers = Server_Server:WaitForChild("RewardPlayers") :: BindableEvent,
    ResetCooldowns = Server_Server:WaitForChild("ResetCooldowns") :: BindableEvent,
    DummyHitbox = Server_Server:WaitForChild("DummyHitbox") :: BindableEvent,
}

return Events