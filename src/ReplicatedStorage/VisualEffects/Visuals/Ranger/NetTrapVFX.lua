local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXAssets = ReplicatedStorage:WaitForChild("VFXAssets")
local RangerVFX = VFXAssets:WaitForChild("Ranger")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local NetTrap = {}
NetTrap.__index = NetTrap

function NetTrap.new(target, sourceUnit, conditionalData)
    local newVFX = {}
    setmetatable(newVFX, NetTrap)

    newVFX.target = target
    newVFX.sourceUnit = sourceUnit
    newVFX.conditionalData = conditionalData
    newVFX.floorCFrame = sourceUnit:GetPivot()

    newVFX.isTerminate = false

    return newVFX
end

function NetTrap:Activate(target, sourceUnit, conditionalData)
    local vfx = NetTrap.new(target, sourceUnit, conditionalData)
    vfx:DisplayVFX()

    return vfx
end

function NetTrap:DisplayVFX()
    self.rootPart = self.sourceUnit:FindFirstChild("HumanoidRootPart")
    if not self.rootPart then
        return
    end

    self.hitbox = self.conditionalData.hitbox
    if not self.hitbox then
        return
    end

    self.Folder = Instance.new("Folder")
    self.Folder.Name = "NetTrapVFX"
    self.Folder.Parent = workspace.VFX

    self.canFollow = true
    self.canRotate = true
    self.canRotateTrap = true
    self.angle = 0

    self.startA0Pos = Vector3.new(3.5, 2.5, 0)
    self.startA1Pos = Vector3.new(-3.5, 2.5, 0)

    self.endA0Pos = Vector3.new(2, 5.55, 0)
    self.endA1Pos = Vector3.new(-2, 5.55, 0)

    self.startBeamSize = 6
    self.endBeamSize = 12
    self.startBeamCurve = 4.667
    self.endBeamCurve = 2.667

    self.startFloorSize = Vector3.new(8.5, 0.1, 8.5)
    self.endFloorSize = Vector3.new(5.5, 0.1, 5.5)

    self.trap = RangerVFX.NetTrap.NetTrap:Clone()
    self.trap:PivotTo(self.hitbox.CFrame * CFrame.Angles(0, 0, math.rad(-90)) - Vector3.new(0, self.hitbox.Size.Y/4, 0))
    self.trap.Parent = self.Folder

    self.MainAttach = self.trap.Main.Attachment
    self.FloorVFX = self.trap.Main.FloorVFX
    self.A0 = self.MainAttach.A0
    self.A1 = self.MainAttach.A1
    self.Beam1 = self.MainAttach.Beam
    self.Beam2 = self.MainAttach.Beam2
    self.Chain1 = self.MainAttach.Chain1
    self.Chain2 = self.MainAttach.Chain2
end

function NetTrap:RunFunction(target: Model, sourceUnit: Model, conditionalData: {})
    if conditionalData.action == "Stop" then
        self.canRotateTrap = false


    elseif conditionalData.action == "Trap" then
        self.canRotateTrap = false

        self:TrapTarget(target)
    end
end

function NetTrap:Terminate(target, sourceUnit, conditionalData)
    if self.trap then
        local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        if self.A0 and self.A1 then
            TweenService:Create(self.A0, info, {Position = Vector3.new(self.A0.Position.X, 0, self.A0.Position.Z)}):Play()
            TweenService:Create(self.A1, info, {Position = Vector3.new(self.A1.Position.X, 0, self.A1.Position.Z)}):Play()
        end

        if self.Beam1 and self.Beam2 then
            TweenService:Create(self.Beam1, info, {Width0 = 0, Width1 = 0}):Play()
            TweenService:Create(self.Beam2, info, {Width0 = 0, Width1 = 0}):Play()
        end

        if self.FloorVFX then
            TweenService:Create(self.FloorVFX.SurfaceGui.ImageLabel, info, {ImageTransparency = 1}):Play()
        end

        local function disableBeam(container: BasePart | Attachment)
            for _, obj in pairs(container:GetDescendants()) do
                if obj:IsA("Beam") then
                    TweenService:Create(obj, info, {Width0 = 0, Width1 = 0}):Play()
                end
            end
        end

        if self.Chain1 and self.Chain2 then
            disableBeam(self.Chain1)
            disableBeam(self.Chain2)
        end

        TweenService:Create(self.trap.PrimaryPart, info, {CFrame = self.trap.PrimaryPart.CFrame - Vector3.new(0, 2.5, 0)}):Play()
    end

    task.delay(1, function()
        if self.Folder then
            self.Folder:Destroy()
        end
    end)
end

function NetTrap:Update(deltaTime)
    if not self.hitbox then
        return
    end

    if not self.canFollow then
        return
    end

    if not self.trap then
        return
    end

    if self.canRotate then
        self.angle += 120 * deltaTime

        self.FloorVFX.SurfaceGui.ImageLabel.Rotation = -self.angle
    end

    if self.canRotateTrap then
        local newCFrame = self.hitbox.CFrame * CFrame.Angles(0, 0, math.rad(-90)) - Vector3.new(0, self.hitbox.Size.Y/4, 0)
        self.trap:PivotTo(newCFrame * CFrame.Angles(0, math.rad(self.angle), 0)) 
    end
end

function NetTrap:TrapTarget(target: Model)
    if not self.trap then return end

    local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    if self.FloorVFX then
        TweenService:Create(self.FloorVFX, info, {Size = self.endFloorSize}):Play()
    end

    if self.A0 and self.A1 then
        TweenService:Create(self.A0, info, {Position = self.endA0Pos}):Play()
        TweenService:Create(self.A1, info, {Position = self.endA1Pos}):Play()
    end

    if self.Beam1 and self.Beam2 then
        TweenService:Create(self.Beam1, info, {CurveSize0 = self.endBeamCurve, CurveSize1 = -self.endBeamCurve, Width0 = self.endBeamSize, Width1 = self.endBeamSize}):Play()
        TweenService:Create(self.Beam2, info, {CurveSize0 = -self.endBeamCurve, CurveSize1 = self.endBeamCurve, Width0 = self.endBeamSize, Width1 = self.endBeamSize}):Play()
    end

    local function enableBeam(container: BasePart | Attachment, enabled: boolean)
        for _, obj in pairs(container:GetDescendants()) do
            if obj:IsA("Beam") then
                obj.Enabled = enabled
            end
        end
    end

    if self.Chain1 and self.Chain2 then
        enableBeam(self.Chain1, true)
        enableBeam(self.Chain2, true)
    end
end

return NetTrap