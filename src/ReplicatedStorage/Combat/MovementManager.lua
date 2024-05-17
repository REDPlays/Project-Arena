local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local MovementManager = {}
MovementManager.dashList = {}
MovementManager.bezierList = {}

local function quadratic(t, p0, p1, p2)
	return (1 - t) ^ 2 * p0 + 2 * (1 - t) * t * p1 + t ^ 2 * p2
end

function MovementManager:Dash(character, dashData)
    if MovementManager.dashList[character] then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end
    
   if dashData.facingCFrame then
        rootPart.CFrame = dashData.facingCFrame
   end

    local detector = Hitboxes.Hitbox:Clone()
    detector.Size = Vector3.new(5, 5, 5)
    detector.Color = Color3.fromRGB(82, 180, 173)
    detector.Transparency = .5
    detector.Anchored = true
    detector.CFrame = character.HumanoidRootPart.CFrame
    detector.Parent = workspace.Ignore

    MovementManager.dashList[character] = {
        character = character,
        duration = dashData.duration,
        currTime = 0,
        speed = dashData.speed,
        allowPass = dashData.allowPass,
        detector = detector
    }
end

function MovementManager:Bezier(character, bezierData)
    if MovementManager.bezierList[character] then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local startCFrame = rootPart.CFrame
    local endCFrame = startCFrame * CFrame.new(0, 0, -bezierData.distance)
    local middleCFrame = startCFrame:Lerp(endCFrame, 0.5) * CFrame.new(0, 20, 0)

    local numValue = Instance.new("NumberValue")
    numValue.Value = 0

    local info = TweenInfo.new(bezierData.duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(numValue, info, {Value = 1})

    local thread = task.spawn(function()
        while true do
            local position = quadratic(numValue.Value, startCFrame.Position, middleCFrame.Position, endCFrame.Position)
            
            local endLookVector = endCFrame.LookVector
            local lookAt = Vector3.new(endLookVector.X, 0, endLookVector.Z)

            rootPart.CFrame = CFrame.lookAt(position, position + lookAt, Vector3.new(0, 1, 0))
            
            task.wait()
        end
    end)

    MovementManager.bezierList[character] = {
        duration = bezierData.duration,
        currTime = 0,
        character = character,
        numValue = numValue,
        tween = tween,
        thread = thread
    }

    tween:Play()
end

function MovementManager:Cleanup(character)
    if MovementManager.dashList[character] then
        MovementManager.dashList[character].detector:Destroy()
        MovementManager.dashList[character] = nil
    end
end

function MovementManager:CleanupBezier(character)
    local bezierData = MovementManager.bezierList[character]
    if bezierData then
        if bezierData.thread then
            task.cancel(bezierData.thread)
        end

        if bezierData.tween then
            bezierData.tween:Cancel()
        end

        if bezierData.numValue then
            bezierData.numValue:Destroy()
        end

        MovementManager.bezierList[character] = nil
    end
end

function MovementManager:GetDetection(detector: BasePart, character, allowPass)
    local playerList = {}
    for _, plr in pairs(game.Players:GetChildren()) do
        local char = plr.Character
        table.insert(playerList, char)
    end

    local Overlap = OverlapParams.new()
    Overlap.FilterType =Enum.RaycastFilterType.Exclude

    if allowPass then
        Overlap.FilterDescendantsInstances = {workspace.Ignore, workspace.VFX, workspace.Dummies, character, playerList}
    elseif not allowPass then
        Overlap.FilterDescendantsInstances = {workspace.Ignore, workspace.VFX, character}
    end
    
    local wall = false

    local partsInDetector = workspace:GetPartsInPart(detector, Overlap)
    for _, object in pairs(partsInDetector) do
        wall = true
        break
    end

    return wall
end

local function movement(character, moveData, cancel)
    if not character then
        return
    end

    if not moveData then
        return
    end

    if cancel then
        MovementManager:Cleanup(character)
        return
    end

    if moveData.isDash then
        MovementManager:Dash(character, moveData)
    end

    if moveData.isBezier then
        MovementManager:Bezier(character, moveData)
    end
end

RunService.Heartbeat:Connect(function(deltaTime)
    for id, dashData in pairs(MovementManager.dashList) do
        local rootPart = dashData.character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            continue
        end
        
        if dashData.currTime >= dashData.duration then
            MovementManager:Cleanup(dashData.character)
            continue
        end
        
        local detector = dashData.detector
        if not detector then
            MovementManager:Cleanup(dashData.character)
            continue
        end
        
        dashData.currTime += deltaTime

        detector.CFrame = rootPart.CFrame

        local wall = MovementManager:GetDetection(detector, dashData.character, dashData.allowPass)
        if wall then
            continue
        end

        rootPart.CFrame *= CFrame.new(0, 0, -dashData.speed * deltaTime)
    end

    for id, bezierData in pairs(MovementManager.bezierList) do
        local humanoid = bezierData.character:FindFirstChild("Humanoid")
        if not humanoid then
            MovementManager:CleanupBezier(bezierData.character)

            continue
        end

        if bezierData.currTime >= bezierData.duration then
            MovementManager:CleanupBezier(bezierData.character)
            continue
        end

        if humanoid and humanoid.Health <= 0 then
            MovementManager:CleanupBezier(bezierData.character)
            
            continue
        end

        bezierData.currTime += deltaTime
    end
end)

Events.Server_Client.Movement.OnClientEvent:Connect(movement)

return MovementManager