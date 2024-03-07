local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))

local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))

local InputManager = {}

InputManager.ServerBlockDebounces = {}
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

    local character = player.Character
    if not character then
        return
    end

    if moveType == "Block" then
        if InputManager.ServerBlockDebounces[player.UserId] then
            InputManager.ServerBlockDebounces[player.UserId] = nil

            StateManager:RemoveTarget(character, "Blocking")
        elseif not InputManager.ServerBlockDebounces[player.UserId] then
            InputManager.ServerBlockDebounces[player.UserId] = true

            StateManager:AddTarget(character, "Blocking")
        end
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

            Events.Server_Client.Cooldown:FireClient(player, "LMBMove")
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