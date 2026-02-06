local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local BaseVFX = VFXAssets:WaitForChild("Base")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local RunningVFX = {}
RunningVFX.__index = RunningVFX

function RunningVFX.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, RunningVFX)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function RunningVFX:Activate(target, sourceUnit, conditionalData)
    local vfx = RunningVFX.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function RunningVFX:DisplayVFX()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "running vfx"
    self.Folder.Parent = workspace.VFX
    
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    self.humanoid = self.sourceUnit:FindFirstChild("Humanoid")

    self.Rayparams = RaycastParams.new()
    self.Rayparams.FilterType = Enum.RaycastFilterType.Exclude

    self.landed = self.humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Landed then
            self:LandSmoke()
        end
    end)

    self.side = 0
    
    self.stopped = false
    self.step = 0
    self.maxStep = 0.025

    self.maxSmoke = 5
    self.smokeList = {}
end

function RunningVFX:Terminate()
    self.stopped = true

    if self.landed then
        self.landed:Disconnect()
    end

    if self.Folder then
        self.Folder:Destroy()
    end
end

function RunningVFX:LandSmoke()
    local playerList = {}
    for _, plr in pairs(game.Players:GetChildren()) do
        local char = plr.Character
        table.insert(playerList, char)
    end

    self.Rayparams.FilterDescendantsInstances = {workspace.Dummies, workspace.Ignore, workspace.Obstacles, workspace.VFX, playerList}

    local ray = workspace:Raycast(self.rootPart.Position, Vector3.new(0, -5, 0), self.Rayparams)
    if ray then
        local floorPosition = ray.Position
        local floorCFrame = CFrame.new(floorPosition, floorPosition + self.rootPart.CFrame.LookVector)

        local num = 5
        for i=1, num do
            local size = math.random(100, 120)/100
            local dist = math.random(65, 70)/100
            local lifeTime = math.random(100, 125)/100

            local newCFrame =  floorCFrame * CFrame.Angles(0, math.rad(math.random(-180,  180)), 0) * CFrame.new(0, 0, -dist)
            local orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
            
            local RandomDirection = newCFrame * CFrame.new(math.random(-15, 15)/10, 0.5, -3)
            local randomRotation = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))

            local smoke = BaseVFX.Running.Smoke:Clone()
            smoke.Color = Color3.fromRGB(255, 255, 255)
            smoke.Material = Enum.Material.SmoothPlastic
            smoke.Size = Vector3.new(size, size, size)
            smoke.CFrame = newCFrame
            smoke.Orientation = orientation
            smoke.Parent = self.Folder

             local info = TweenInfo.new(lifeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(smoke, info, {Size = Vector3.new(0, 0, 0), Position = RandomDirection.Position, Orientation = randomRotation}):Play()

            Debris:AddItem(smoke, lifeTime)
        end
    end
end

function RunningVFX:Footstep()
    local size = math.random(50, 75)/100

    local playerList = {}
    for _, plr in pairs(game.Players:GetChildren()) do
        local char = plr.Character
        table.insert(playerList, char)
    end

    self.Rayparams.FilterDescendantsInstances = {workspace.Dummies, workspace.Ignore, workspace.Obstacles, workspace.VFX, playerList}

    local spawnOrigins = {
        [0] = CFrame.new(-0.5, 0, 0),
        [1] = CFrame.new(0.5, 0, 0),
    }

    local origin  = (self.rootPart.CFrame * spawnOrigins[self.side]).Position
    local ray = workspace:Raycast(origin, Vector3.new(0, -3.5, 0), self.Rayparams)
    if ray then
        local floorPosition = ray.Position + Vector3.new(0, 0.5, 0)
        local floorCFrame = CFrame.new(floorPosition, floorPosition + self.rootPart.CFrame.LookVector)

        local orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
        local lifeTime = 1

        local smoke = BaseVFX.Running.Smoke:Clone()
        smoke.Color = Color3.fromRGB(255, 255, 255)
        smoke.Material = Enum.Material.SmoothPlastic
        smoke.Size = Vector3.new(size, size, size)
        smoke.CFrame = floorCFrame
        smoke.Orientation = orientation
        smoke.Parent = self.Folder

        local RandomDirection = floorCFrame * CFrame.new(math.random(-15, 15)/10, 1, 2)
        local randomRotation = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))

        local info = TweenInfo.new(lifeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(smoke, info, {Size = Vector3.new(0, 0, 0), Position = RandomDirection.Position, Orientation = randomRotation}):Play()

        table.insert(self.smokeList, smoke)
        Debris:AddItem(smoke, lifeTime)
    end
end

function RunningVFX:Update(deltaTime)
    if self.stopped then
        return
    end

    if not self.humanoid then
        return
    end

    if self.humanoid.Health <= 0 then
        return
    end

    local MoveDirection = self.humanoid.MoveDirection.Magnitude
    if MoveDirection > 0 then
        if #self.smokeList >= self.maxSmoke then
            local firstsmoke = self.smokeList[1]
            table.remove(self.smokeList, 1)
            if firstsmoke then
                local debrisLife = 0.1
                local info = TweenInfo.new(debrisLife, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(firstsmoke, info, {Size = Vector3.new(0, 0, 0)}):Play()
                Debris:AddItem(firstsmoke, debrisLife)
            end
        end

       self.step += deltaTime
        if self.step >= self.maxStep then
            self.step = 0

            self:Footstep()

            self.side += 1
            if self.side > 1 then
                self.side =  0
            end
        end
    end
end

return RunningVFX