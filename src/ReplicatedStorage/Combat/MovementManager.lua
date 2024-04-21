local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local MovementManager = {}
MovementManager.dashList = {}

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

function MovementManager:Cleanup(character)
    if MovementManager.dashList[character] then
        MovementManager.dashList[character].detector:Destroy()
        MovementManager.dashList[character] = nil
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
end)

Events.Server_Client.Movement.OnClientEvent:Connect(movement)

return MovementManager