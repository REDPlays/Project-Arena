local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local MoveData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("MoveData"))

local CharacterMoveLibrary = require(ReplicatedStorage.RepFiles.Player.CharacterMoveLibrary)

local MoveManager = {}

function MoveManager:Ability(player: Player | Model, class, moveType, moveData, currentMove)
    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class then
        warn("Wrong Class Equipped")
        return
    end

    local currentClassData = ClassData[class]
    if not currentClassData then
        return
    end

    local currentMoveData = MoveData[class][currentMove]
    if not currentMoveData then
        return
    end

    local character = nil
    if player:IsA("Model") then
        character = player
    else
        character = player.Character
    end
    if not character then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local isAwakened = Stats:GetAttribute("Awakened")

    local placementCFrame = character:GetPivot() * currentClassData.Hitboxes[currentMove].Offset
    currentMoveData:Activate(player, character, rootPart, placementCFrame, class, currentClassData, moveType, currentMove)
end

function MoveManager:ProjectileAbility(player, class, moveType, moveData, currentMove)
    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class then
        warn("Wrong Class Equipped")
        return
    end
end

local function Ability(player, class, moveType, moveData)
    local currentMove: string = CharacterMoveLibrary.Movesets[player][moveType]
    if not currentMove then
        warn("no ability move for:", moveType)
        return
    end

    if moveData.isProjectile and moveType == "LMBMove" then
        MoveManager:ProjectileAbility(player, class, moveType, moveData, currentMove)
    else
        MoveManager:Ability(player, class, moveType, moveData, currentMove)
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