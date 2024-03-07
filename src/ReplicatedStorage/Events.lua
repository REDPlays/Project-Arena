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
}

Events.Server_Client = {
    PlayerLoaded = Server_Client:WaitForChild("PlayerLoaded"),
    Cooldown = Server_Client:WaitForChild("Cooldown"),
}

Events.Server_Server = {
    
}

return Events