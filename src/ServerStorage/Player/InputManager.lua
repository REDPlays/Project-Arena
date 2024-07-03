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

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    --check if they can attack
    if Stats:GetAttribute("Stunned") and Stats:GetAttribute("Stunned") == true then
        warn("Ability is locked due to stun")
        return
    end

    if Stats:GetAttribute("AbilityLocked") and Stats:GetAttribute("AbilityLocked") == true then
        warn("Ability is locked due to using an ability")
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

        local cooldown = currentClassData.Cooldowns.LMBMove

        if moveCount and moveCount >= 3 then
            animInfo = currentClassData.Cooldowns.LMBMove
            cooldown = 1
        end

        task.delay(cooldown, function()
            if InputManager.ServerLMBDebounces[player.UserId] then
                InputManager.ServerLMBDebounces[player.UserId] = nil
            end

            Events.Server_Client.Cooldown:FireClient(player, "LMBMove")
        end)
    end

    if moveType == "QMove" then
        if InputManager.ServerQDebounces[player.UserId] then
            return
        end

        InputManager.ServerQDebounces[player.UserId] = true

        local cooldown = currentClassData.Cooldowns.QMove

        task.delay(cooldown, function()
            if InputManager.ServerQDebounces[player.UserId] then
                InputManager.ServerQDebounces[player.UserId] = nil
            end

            Events.Server_Client.Cooldown:FireClient(player, "QMove")
        end)
    end

    if moveType == "EMove" then
        if InputManager.ServerEDebounces[player.UserId] then
            return
        end

        InputManager.ServerEDebounces[player.UserId] = true

        local cooldown = currentClassData.Cooldowns.EMove

        task.delay(cooldown, function()
            if InputManager.ServerEDebounces[player.UserId] then
                InputManager.ServerEDebounces[player.UserId] = nil
            end

            Events.Server_Client.Cooldown:FireClient(player, "EMove")
        end)
    end

    if moveType == "FMove" then
        if InputManager.ServerFDebounces[player.UserId] then
            return
        end

        InputManager.ServerFDebounces[player.UserId] = true

        local cooldown = currentClassData.Cooldowns.FMove

        task.delay(cooldown, function()
            if InputManager.ServerFDebounces[player.UserId] then
                InputManager.ServerFDebounces[player.UserId] = nil
            end

            Events.Server_Client.Cooldown:FireClient(player, "FMove")
        end)
    end

    return true
end

local function RunInput(player, class, moveType, animInfo, moveCount)
    return InputManager:RunInput(player, class, moveType, animInfo, moveCount)
end

Events.Client_Server.Input.OnServerInvoke = RunInput

return InputManager