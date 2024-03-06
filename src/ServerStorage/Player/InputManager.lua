local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))

local InputManager = {}

InputManager.ServerLMBDebounces = {}
InputManager.ServerQDebounces = {}
InputManager.ServerEDebounces = {}
InputManager.ServerFDebounces = {}

function InputManager:RunInput(player, class, moveType, animInfo, moveCount)
    if not class then
        return
    end

    local currentClassData = ClassData[class]
    if not currentClassData then
        return
    end

    if not moveType then
        return
    end

    if moveType == "LMBMove" then
        if InputManager.ServerLMBDebounces[player.UserId] then
            return
        end

        InputManager.ServerLMBDebounces[player.UserId] = true

        if moveCount and moveCount >= 3 then
            animInfo = currentClassData.Cooldowns.LMBMove
        end

        task.delay(animInfo, function()
            if InputManager.ServerLMBDebounces[player.UserId] then
                InputManager.ServerLMBDebounces[player.UserId] = nil
            end
        end)
    end

    if moveType == "QMove" then
        
    end

    if moveType == "EMove" then
        
    end

    if moveType == "FMove" then
        
    end

    return true
end

local function RunInput(player, class, moveType, animInfo, moveCount)
    return InputManager:RunInput(player, class, moveType, animInfo, moveCount)
end

Events.Client_Server.Input.OnServerInvoke = RunInput

return InputManager