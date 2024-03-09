local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local MovementManager = {}
MovementManager.dashList = {}

function MovementManager:Dash(character, dashData)
    if MovementManager.dashList[character] then
        return
    end

    MovementManager.dashList[character] = {
        character = character,
        duration = dashData.duration,
        currTime = 0,
        speed = dashData.speed
    }
end

local function movement(character, moveData)
    if not character then
        return
    end

    if not moveData then
        return
    end

    if moveData.isDash then
        MovementManager:Dash(character, moveData)
    end
end

RunService.Heartbeat:Connect(function(deltaTime)
    for id, dashData in pairs(MovementManager.dashList) do
        local rootPart = dashData.character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            continue
        end

        if dashData.currTime >= dashData.duration then
            MovementManager.dashList[id] = nil
            continue
        end

        dashData.currTime += deltaTime

        rootPart.CFrame *= CFrame.new(0, 0, -dashData.speed * deltaTime)
    end
end)

Events.Server_Client.Movement.OnClientEvent:Connect(movement)

return MovementManager