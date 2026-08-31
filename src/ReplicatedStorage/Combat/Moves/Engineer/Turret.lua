local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")
local CharacterModels = Assets:WaitForChild("CharacterModels")
local EngineerFolder = CharacterModels:WaitForChild("Engineer")
local UI = Assets.UI

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local Turret = {}

Turret.currentPlayers = {}
local maxTurrets = 1

local function predictPosition(part: BasePart, timeInterval)
    return part.Position + part.AssemblyLinearVelocity * timeInterval
end

local function TweenPivot(model: Model, startCFrame: CFrame, endCFrame: CFrame, duration: number)
    local duration = duration
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local numVal = Instance.new("NumberValue")
    numVal.Value = 0

    local connect
    connect = numVal.Changed:Connect(function(value)
        model:PivotTo(startCFrame:Lerp(endCFrame, numVal.Value))
    end)

    TweenService:Create(numVal, info, {Value = 1}):Play()

    task.delay(duration, function()
        if connect then
            connect:Disconnect()
        end

        if numVal then
            numVal:Destroy()
        end
    end)
end

function Turret:Activate(player, character, rootPart, placementCFrame, class, classData, moveType, currentMove)
    if not Turret.currentPlayers[player] then
        Turret.currentPlayers[player] = {
            currCount = 0,
            Turrets = {}
        }
    end

    if Turret.currentPlayers[player].currCount >= maxTurrets then
        return
    end

    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[currentMove]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local spawnDelay = 1
    Stats:SetAttribute("AbilityLocked", true)
    
    task.delay(spawnDelay, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    local positioning = predictPosition(rootPart, .25)

    local startCFrame = CFrame.new(positioning, positioning + rootPart.CFrame.LookVector) * CFrame.new(0, 0, -3)

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

    local ray = workspace:Raycast(startCFrame.Position, startCFrame.UpVector * -1000, raycastParams)
    if ray then
        local floorPosition = ray.Position
        local lookVector = startCFrame.LookVector

        local spawnCFrame = CFrame.new(floorPosition, floorPosition + lookVector)

        VisualEffectServer:SpawnEffectsInRange(
            "TurretSpawn",
            nil,
            character,
            {spawnCFrame = spawnCFrame},
            1000
        )

        local TurretModel = EngineerFolder.Turret:Clone()

        local finalCFrame = spawnCFrame * CFrame.new(0, TurretModel.PrimaryPart.Size.Y/2, 0)
        local underCFrame = finalCFrame * CFrame.new(0, -3, 0)

        TurretModel:PivotTo(underCFrame)
        TurretModel.Parent = IgnoreFolder

        Turret.currentPlayers[player].currCount += 1
        Turret.currentPlayers[player].Turrets[TurretModel] = TurretModel

        TweenPivot(TurretModel, underCFrame, finalCFrame, spawnDelay)

        task.delay(spawnDelay, function()
            local lifeTime = 15
            local MaxDistance = 50
            local fireRate = 1.5
            local currentRate = 0
            local burstDelay = 0.15
            local numShots = 2
            local predictionValue = 0.25

            local Turret_Head = TurretModel.Head
            local Turret_Barrel = TurretModel.Barrel
            local TimerUI = TurretModel.Timer
            local Timer_Bar = TimerUI.Bar
            
            Timer_Bar.Size = UDim2.new(1, 0, 1, 0)
            local info = TweenInfo.new(lifeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            TweenService:Create(Timer_Bar, info, {Size = UDim2.new(0, 0, 1, 0)}):Play()

            local target = nil

            local function applyUI(victim)
                if not victim then
                    return
                end

                local victimRoot = victim:FindFirstChild("HumanoidRootPart")
                if not victimRoot then
                    return
                end

                local UIAttach = victimRoot:FindFirstChild("UI")
                if not UIAttach then
                    return
                end

                local oldtargetUI = victimRoot:FindFirstChild("TargetUI")
                if oldtargetUI then
                    oldtargetUI:Destroy()
                end

                local targetUI = UI.TargetUI:Clone()
                targetUI.Adornee = UIAttach
                targetUI.Parent = victim
            end

            local function removeUI(victim)
                if not victim then
                    return
                end

                local oldtargetUI = victim:FindFirstChild("TargetUI")
                if oldtargetUI then
                    oldtargetUI:Destroy()
                end
            end

            local function findTarget()
                local victim = nil

                local potentialList = {}
                for _, _plr in pairs(Players:GetPlayers()) do
                    local _chr = _plr.Character
                    if not _chr then
                        continue
                    end

                    if _chr == character then
                        continue
                    end

                    table.insert(potentialList, _chr)
                end

                for _, ene in pairs(workspace.Dummies:GetChildren()) do
                    if ene == character then
                        continue
                    end

                    table.insert(potentialList, ene)
                end

                local distance = nil
                for _, potentialVictim in pairs(potentialList) do
                    local myTeam = character:GetAttribute("Team")
                    local theirTeam = potentialVictim:GetAttribute("Team")

                    if (myTeam and theirTeam) and myTeam == theirTeam then
                        continue
                    end

                    local victimRoot = potentialVictim:FindFirstChild("HumanoidRootPart")
                    if not victimRoot then
                        continue
                    end

                    local currDist = (victimRoot.Position - Turret_Head:GetPivot().Position).Magnitude

                    if currDist > MaxDistance then
                        continue
                    end

                    if not distance or currDist < distance then
                        distance = currDist
                        victim = potentialVictim
                    end
                end

                if victim then
                    applyUI(victim)
                end

                return victim
            end

            local thread = task.spawn(function()
                local currentPosition = Turret_Head:GetPivot().Position

                while true do
                    local deltaTime = task.wait()

                    if not target then
                        target = findTarget()
                        continue
                    end
                    
                    local targetRoot = target:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then
                        removeUI(target)
                        target = nil
                        continue
                    end
                    
                    local targetHum = target:FindFirstChild("Humanoid")
                    if not targetHum then
                        removeUI(target)
                        target = nil
                        continue
                    end
                    
                    local targetRootPosition = predictPosition(targetRoot, predictionValue)
                    
                    if (targetRootPosition - currentPosition).Magnitude > MaxDistance then
                        removeUI(target)
                        target = nil
                        continue
                    end

                    if targetHum.Health <= 0 then
                        removeUI(target)
                        target = nil
                        continue
                    end
                    
                    local lookAt = Vector3.new(targetRootPosition.X, currentPosition.Y, targetRootPosition.Z)
                    local newLookCFrame = CFrame.new(currentPosition, lookAt)

                    Turret_Head:PivotTo(newLookCFrame)

                    currentRate += deltaTime
                    if currentRate >= fireRate then
                        currentRate = 0

                        for i=1, numShots do
                            Events.Server_Server.Hitbox:Fire(player, class, moveType, nil, nil, 
                            {rootPart = Turret_Barrel.PrimaryPart, sourceUnit = Turret_Barrel}
                        )

                            task.wait(burstDelay)
                        end

                    end
                end
            end)

            task.delay(lifeTime, function()
                if thread then
                    task.cancel(thread)
                end

                removeUI(target)

                Turret.currentPlayers[player].currCount -= 1
                Turret.currentPlayers[player].Turrets[TurretModel] = nil

                if TurretModel then
                    VisualEffectServer:SpawnEffectsInRange(
                        "TurretSpawn",
                        nil,
                        character,
                        {spawnCFrame = spawnCFrame},
                        1000
                    )
                    
                    TweenPivot(TurretModel, finalCFrame, underCFrame, spawnDelay)

                    Debris:AddItem(TurretModel, 1)
                end
            end)
        end)
    end
end

return Turret