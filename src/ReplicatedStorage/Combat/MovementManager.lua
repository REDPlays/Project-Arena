local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local IgnoreFolder = workspace:WaitForChild("Ignore")

local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

local MovementManager = {}
MovementManager.dashList = {}
MovementManager.bezierList = {}
MovementManager.knockupList = {}

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

function MovementManager:ShowPath(cframes: table)
    for _, cframe in pairs(cframes) do
        local point = Hitboxes.Point:Clone()
        point.Transparency = 0
        point.Material = Enum.Material.Neon
        point.Anchored = true
        point.CFrame = cframe
        point.Size = Vector3.new(1, 1, 1)
        point.Parent = IgnoreFolder
    end
end

function MovementManager:Bezier(character, bezierData)
    if MovementManager.bezierList[character] then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local startCFrame = bezierData.startCFrame
    local endCFrame = bezierData.endCFrame
    local middleCFrame = bezierData.middleCFrame

    if ShowHitboxes then
        --MovementManager:ShowPath({startCFrame, middleCFrame, endCFrame})
    end

    local numValue = Instance.new("NumberValue")
    numValue.Value = 0

    local info = TweenInfo.new(bezierData.duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
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

function MovementManager:Knockup(character, knockupData)
    if MovementManager.knockupList[character] then
        warn("already knock up")
        return
    end

    local rootPart: BasePart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    for _, velocity in pairs(rootPart:GetChildren()) do
        if velocity:IsA("BodyVelocity") or velocity:IsA("LinearVelocity") then
            velocity:Destroy()
        end
    end

    --[==[local upwardVelocity = Instance.new("BodyVelocity")
    upwardVelocity.Name = "upwardVelocity"
    upwardVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    upwardVelocity.Velocity = Vector3.new(0, knockupData.Force, 0)
    upwardVelocity.Parent = rootPart]==]

    local attach = Instance.new("Attachment")
    attach.Name = "upwardAttach"
    attach.Parent = rootPart

    local linearVel = Instance.new("LinearVelocity")
    linearVel.Attachment0 = attach
    linearVel.MaxForce = math.huge
    linearVel.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    linearVel.Parent = rootPart
    linearVel.Enabled = true
    linearVel.VectorVelocity = Vector3.new(0, knockupData.Force, 0)

    MovementManager.knockupList[character] = {
        duration = knockupData.duration,
        currTime = 0,
        character = character,
        --upwardVelocity = upwardVelocity,
        attach = attach,
        linearVel = linearVel,
    }
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

function MovementManager:CleanupKnockup(character)
    local knockupData = MovementManager.knockupList[character]
    if knockupData then
        if knockupData.upwardVelocity then
            knockupData.upwardVelocity:Destroy()
        end

        if knockupData.attach then
            knockupData.attach:Destroy()
        end

        if knockupData.linearVel then
            knockupData.linearVel:Destroy()
        end

        MovementManager.knockupList[character] = nil
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

    if moveData.isKnockup then
        MovementManager:Knockup(character, moveData)
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

    for id, knockupData in pairs(MovementManager.knockupList) do
        local humanoid = knockupData.character:FindFirstChild("Humanoid")
        if not humanoid then
            MovementManager:CleanupKnockup(knockupData.character)

            continue
        end

        local rootPart = knockupData.character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            MovementManager:CleanupKnockup(knockupData.character)
            continue
        end

        if knockupData.currTime >= knockupData.duration then
            MovementManager:CleanupKnockup(knockupData.character)
            continue
        end

        if humanoid and humanoid.Health <= 0 then
            MovementManager:CleanupKnockup(knockupData.character)
            
            continue
        end

        knockupData.currTime += deltaTime
    end
end)

Events.Server_Client.Movement.OnClientEvent:Connect(movement)

return MovementManager