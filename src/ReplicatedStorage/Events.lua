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
    ProjectileTarget = Client_Server:WaitForChild("ProjectileTarget")
}

Events.Server_Client = {
    PlayerLoaded = Server_Client:WaitForChild("PlayerLoaded"),
    Cooldown = Server_Client:WaitForChild("Cooldown"),
    Death = Server_Client:WaitForChild("Death"),
    Movement = Server_Client:WaitForChild("Movement"),
    VisualEffects = Server_Client:WaitForChild("VisualEffects"),
    TerminateVFX = Server_Client:WaitForChild("TerminateVFX"),
    Hitbox = Server_Client:WaitForChild("Hitbox"),
    CountDown = Server_Client:WaitForChild("CountDown"),
    UpdateStatue = Server_Client:WaitForChild("UpdateStatue"),
    Leaderboard = Server_Client:WaitForChild("Leaderboard")
}

Events.Server_Server = {
    Hitbox = Server_Server:WaitForChild("Hitbox"),
}

return Events