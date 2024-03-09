local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local IgnoreFolder = workspace.Ignore

local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

local HitboxManager = {}

function HitboxManager:HitboxDebugger(character, isStun, isBurn)
    local currentClassData = ClassData["Base"]
    if not currentClassData then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local damage = 2
    if character.Name == "DummyAttacker" then
        damage = 10
    end

    local placementCFrame = character:GetPivot() * currentClassData.Hitboxes["LMBMove"].Offset

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = currentClassData.Hitboxes["LMBMove"].Size
    Hitbox.CFrame = placementCFrame
    Hitbox.Parent = IgnoreFolder
    Debris:AddItem(Hitbox, .25)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    local touched = Hitbox.Touched:Connect(function() end)
    local touchedObjects = Hitbox:GetTouchingParts()

    if touched then
        touched:Disconnect()
    end

    local alreadyHit = {}
    for i=1, #touchedObjects do
        local object = touchedObjects[i]
        local parent = object.Parent

        if not parent:IsA("Model") then
            continue
        end

        if parent == character then
            continue
        end

        --ignoreTargets
        if CollectionService:HasTag(parent, "Ignore") or CollectionService:HasTag(parent, "Dummies") then
            continue
        end

        local enemyHum = parent:FindFirstChild("Humanoid")
        if not enemyHum then
            continue
        end

        local enemyRoot = parent:FindFirstChild("HumanoidRootPart")
        if not enemyRoot then
            continue
        end

        if alreadyHit[parent.Name] then
            continue
        end

        local Stats = parent:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        local isUserStun = StateManager:CheckState(character, "Stunned")
        if isUserStun then
            return
        end

        alreadyHit[parent.Name] = true

        local isBlocking = StateManager:CheckState(parent, "Blocking")
        if isBlocking then
            --Block Indication
            continue
        end

        if isStun then
            StateManager:AddTarget(parent, "Stunned", 1)
        end

        if isBurn then
            StateManager:AddTarget(parent, "Burn", 3)
        end

        StateManager:AddTarget(parent, "Attacked", 1)

        HealthManager:Damage(parent, damage)
    end
end

function HitboxManager:HitboxCreateMove(player, class, moveType, moveCount)
    local currentClass = player:GetAttribute("CurrentClass")
    if currentClass ~= class then
        warn("Wrong Class Equipped")
        return
    end

    local currentClassData = ClassData[class]
    if not currentClassData then
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

    local damage = 1
    if not moveCount then
        damage = currentClassData.DamageList[moveType]
    else
        damage = currentClassData.DamageList[moveType][moveCount]
    end

    local placementCFrame = character:GetPivot() * currentClassData.Hitboxes[moveType].Offset

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = currentClassData.Hitboxes[moveType].Size
    Hitbox.CFrame = placementCFrame
    Hitbox.Parent = IgnoreFolder
    Debris:AddItem(Hitbox, .25)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = rootPart
    weld.Parent = weld.Part0

    local touched = Hitbox.Touched:Connect(function() end)
    local touchedObjects = Hitbox:GetTouchingParts()

    if touched then
        touched:Disconnect()
    end

    local alreadyHit = {}
    for i=1, #touchedObjects do
        local object = touchedObjects[i]
        local parent = object.Parent

        if not parent:IsA("Model") then
            continue
        end

        if parent == character then
            continue
        end

        --ignoreTargets
        if CollectionService:HasTag(parent, "Ignore") then
            continue
        end

        local enemyHum = parent:FindFirstChild("Humanoid")
        if not enemyHum then
            continue
        end

        local enemyRoot = parent:FindFirstChild("HumanoidRootPart")
        if not enemyRoot then
            continue
        end

        if alreadyHit[parent.Name] then
            continue
        end

        local Stats = parent:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        local isUserStun = StateManager:CheckState(character, "Stunned")
        if isUserStun then
            return
        end

        alreadyHit[parent.Name] = true

        local isBlocking = StateManager:CheckState(parent, "Blocking")
        if isBlocking then
            --Block Indication

            continue
        end

        --apply burn
        if currentClassData.MoveData[moveType].Burn then
            StateManager:AddTarget(parent, "Burn", 3)
        end

        StateManager:AddTarget(parent, "Attacked", 1)

        HealthManager:Damage(parent, damage)
    end
end

function HitboxManager:HitboxProjectile(player, class, moveType, moveCount)
    warn(" hehe i'm a projectile >:3 ")
end

local function HitboxCreateMove(player, class, moveType, moveCount, isProjectile)
    if not isProjectile then
        HitboxManager:HitboxCreateMove(player, class, moveType, moveCount)
    else
        HitboxManager:HitboxProjectile(player, class, moveType, moveCount)
    end
end

function HitboxManager:Update(deltaTime)
    ShowHitboxes = workspace:GetAttribute("ShowHitboxes")
end

Events.Client_Server.Hitbox.OnServerEvent:Connect(HitboxCreateMove)

return HitboxManager