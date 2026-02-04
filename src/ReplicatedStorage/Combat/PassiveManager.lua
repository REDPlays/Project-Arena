local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Passives = ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Passives")

local passives = {
    HydroStack = require(Passives:WaitForChild("HydroStack")),
}

local PassiveManager = {}

function  PassiveManager:CheckPassive(target: Model, passiveName: string)
    if not passives[passiveName] then
        return
    end

    return passives[passiveName]:CheckPassive(target)
end

if RunService:IsServer() then
    function PassiveManager:AddStack(target: Model, passiveName: string, passiveData: {})
        if not passives[passiveName] then
            return
        end

        passives[passiveName]:AddStack(target, passiveData)
    end

    function PassiveManager:RemoveStack(target: Model, passiveName: string)
        if not passives[passiveName] then
            return
        end

        passives[passiveName]:RemoveStack(target)
    end

    function PassiveManager:ClearStack(target: Model, passiveName: string)
        if not passives[passiveName] then
            return
        end

        passives[passiveName]:ClearStack(target)
    end

    function PassiveManager:ClearAllStacks(target: Model)
        for _, passive in ipairs(passives) do
            if passive:CheckPassive(target) then
                passive:ClearStack(target)
            end
        end
    end

    function PassiveManager:Update(deltaTime)
        for _, passive in ipairs(passives) do
            passive:Update(deltaTime)
        end
    end
end

return PassiveManager