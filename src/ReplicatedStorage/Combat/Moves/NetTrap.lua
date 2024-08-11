local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local NetTrap = {}

local function quadratic(t, p0, p1, p2)
	return (1 - t) ^ 2 * p0 + 2 * (1 - t) * t * p1 + t ^ 2 * p2
end

local function predictPosition(part: BasePart, timeInterval)
    return part.Position + part.AssemblyLinearVelocity * timeInterval
end

function NetTrap:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[moveType]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local distance = 15
    local height = 10

    local startPosition = predictPosition(rootPart, 0.25)

    local startCFrame = CFrame.new(startPosition, rootPart.CFrame.LookVector + startPosition) * CFrame.new(0, 0, -3)
    local endCFrame = startCFrame * CFrame.new(0, 0, -distance)
    local middleCFrame = startCFrame:Lerp(endCFrame, 0.5) * CFrame.new(0, height, 0)

    local listOfChars = {}
    for _, plr in pairs(game.Players:GetPlayers()) do
        local _chr = plr.Character
        if _chr then
            table.insert(listOfChars, _chr)
        end
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {listOfChars, IgnoreFolder, workspace.VFX, workspace.Dummies}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local endRay = workspace:Raycast(endCFrame.Position, endCFrame.UpVector * -1000, raycastParams) 
    if endRay then
        local rayPosition = endRay.Position
        endCFrame = CFrame.lookAt(rayPosition, rayPosition + endCFrame.LookVector, Vector3.new(0, 1, 0))
        middleCFrame = startCFrame:Lerp(endCFrame, 0.5) * CFrame.new(0, height, 0)
    end

    local pointsList = {}
    for i=0, 1.05, 0.05 do
        local newPosition = quadratic(i, startCFrame.Position, middleCFrame.Position, endCFrame.Position)
        local lookVector = endCFrame.LookVector

        local point = Instance.new("Part")
        point.Size = Vector3.new(.5, .5, .5)
        point.Material = Enum.Material.Neon
        point.Anchored = true
        point.CFrame = CFrame.new(newPosition, newPosition + lookVector)
        point.CanCollide = false
        point.CanQuery = false
        point.CanTouch = false
        point.Parent = IgnoreFolder

        table.insert(pointsList, point)
    end

    local function checkCollision(hitbox: BasePart)
        local overlapParams = OverlapParams.new()
        overlapParams.FilterDescendantsInstances = {listOfChars, IgnoreFolder, workspace.VFX, workspace.Dummies}
        overlapParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local collided = false
        local parts = workspace:GetPartsInPart(hitbox, overlapParams)

        for _, obj in parts do
            if obj then
                collided = true
                break
            end
        end

        return collided
    end

    local function Explode(spawnCFrame: CFrame)
        local BombHitbox: BasePart = Hitboxes.CircleHitbox:Clone()
        BombHitbox.Transparency = 1
        if ShowHitboxes then
            BombHitbox.Transparency = .5
        end
        BombHitbox.Anchored = true
        BombHitbox.Size = classData.Hitboxes[moveType].Size2
        BombHitbox.CFrame = spawnCFrame
        BombHitbox.Parent = IgnoreFolder
        Debris:AddItem(BombHitbox, 1)

        local overlapParams = OverlapParams.new()
        overlapParams.FilterDescendantsInstances = {listOfChars, workspace.Dummies}
        overlapParams.FilterType = Enum.RaycastFilterType.Include

        local alreadyHit = {}

        local parts = workspace:GetPartsInPart(BombHitbox, overlapParams)
        for _, object in parts do
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

            if CollectionService:HasTag(parent, "Invulnerable") then
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
                HealthManager:Block(parent, damage, character)
                continue
            end

            --apply burn
            if classData.MoveData[moveType].Burn then
                StateManager:AddTarget(parent, "Burn", 3)
            end

            --apply stun
            if classData.MoveData[moveType].Stunned then
                StateManager:AddTarget(parent, "Stunned", 2)
            end

            --apply slow
            if classData.MoveData[moveType].Slow then
                StateManager:AddTarget(parent, "Slow", 1)
            end

            --apply silence
            if classData.MoveData[moveType].Silenced then
                StateManager:AddTarget(parent, "Silenced", 2)
            end

            StateManager:AddTarget(parent, "Attacked", 1)

            HealthManager:Damage(parent, damage, character)
        end
    end

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end
    Hitbox.Anchored = true
    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.CFrame = startCFrame
    Hitbox.Parent = IgnoreFolder

    local speed = 50

    local totalDistance = (startCFrame.Position - middleCFrame.Position).Magnitude + (middleCFrame.Position - endCFrame.Position).Magnitude

    local totalTime = totalDistance / speed

    local startTime = tick()
    local RunConnect
    RunConnect = RunService.Heartbeat:Connect(function(deltaTime)
        local _elapsedTime = tick() - startTime
        local t = _elapsedTime / totalTime

        if t > 1 then
            t = 1
        end

        local newPosition = quadratic(t, startCFrame.Position, middleCFrame.Position, endCFrame.Position)
        local lookVector = endCFrame.LookVector

        Hitbox.CFrame = CFrame.new(newPosition, newPosition + lookVector)

        local collided = checkCollision(Hitbox)
        if collided then
            Explode(Hitbox.CFrame)

            Debris:AddItem(Hitbox, 1)

            for _, obj in pointsList do
                Debris:AddItem(obj, 1)
            end

            if RunConnect then
                RunConnect:Disconnect()
            end
        end

        if t == 1 then
            if RunConnect then
                RunConnect:Disconnect()
            end
        end
    end)
end

return NetTrap