local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local MoveData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("MoveData"))

local MoveManager = {}

function MoveManager:Ability(player, class, moveType, moveData)
    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class then
        warn("Wrong Class Equipped")
        return
    end

    local currentClassData = ClassData[class]
    if not currentClassData then
        return
    end

    local currentMoveData = MoveData[class][moveType]
    if not currentMoveData then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local placementCFrame = character:GetPivot() * currentClassData.Hitboxes[moveType].Offset
    MoveData[class][moveType]:Activate(player, character, rootPart, placementCFrame, class, currentClassData, moveType)
end

function MoveManager:AbilityNonPlayer(character, class, moveType, moveData)
    local currentClassData = ClassData[class]
    if not currentClassData then
        return
    end

    local currentMoveData = MoveData[class][moveType]
    if not currentMoveData then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local placementCFrame = character:GetPivot() * currentClassData.Hitboxes[moveType].Offset
    MoveData[class][moveType]:Activate(character, character, rootPart, placementCFrame, class, currentClassData, moveType)
end

function MoveManager:ProjectileAbility(player, class, moveType, moveData)
    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class then
        warn("Wrong Class Equipped")
        return
    end
end

function MoveManager:AOEAbility(player, class, moveType, moveData)
    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class then
        warn("Wrong Class Equipped")
        return
    end
end

local function Ability(player, class, moveType, moveData)
    if moveData.isProjectile then
        MoveManager:ProjectileAbility(player, class, moveType, moveData)
    elseif moveData.isAOE then
        MoveManager:AOEAbility(player, class, moveType, moveData)
    else
        MoveManager:Ability(player, class, moveType, moveData)
    end
end

function MoveManager:Update(deltaTime)
    for className, moveList in pairs(MoveData) do
        for moveType, module in pairs(moveList) do
            if module.Update then
                module:Update(deltaTime)
            end
        end
    end
end

Events.Client_Server.Moves.OnServerEvent:Connect(Ability)

return MoveManager