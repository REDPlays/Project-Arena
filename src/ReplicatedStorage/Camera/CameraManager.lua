local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Podiums = workspace:WaitForChild("Podiums")

local CameraManager = {}
CameraManager.__index = CameraManager

CameraManager.input = nil

function CameraManager.new()
    local newCamera = {}
    setmetatable(newCamera, CameraManager)

    return newCamera
end

function CameraManager:Init(player: Player, character: Model)
    self.player = player
    self.character = character

    self.playerModule = require(self.player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    self.activeMouseLock = self.playerModule.cameras.activeMouseLockController

    self.isActive = false
    self.lockCamera = false

    self.Camera = workspace.CurrentCamera

    self:Connections()
end

function CameraManager:OutsideToggle(bool)
    if bool then
        if not self.isActive then
            self.isActive = true

            self.activeMouseLock:DoMouseLockSwitch(
                "MouseLockSwitchAction",
                Enum.UserInputState.Begin,
                Enum.KeyCode.LeftControl
            )
        end
    else
        if self.isActive then
            self.isActive = false

            self.activeMouseLock:DoMouseLockSwitch(
                "MouseLockSwitchAction",
                Enum.UserInputState.Begin,
                Enum.KeyCode.LeftControl
            )
        end
    end
end

function CameraManager:ToggleColorCamera(toggle: boolean, cameraPivot: BasePart)
    if toggle then
        self.Camera.CameraType = Enum.CameraType.Scriptable

        self.Camera.CFrame = cameraPivot.CFrame
        self.Camera.Focus = cameraPivot.CFrame * CFrame.new(0, 0, -1)

    elseif not toggle then
        self.Camera.CameraType = Enum.CameraType.Custom

    end
end

function CameraManager:Connections()
    CameraManager.input = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent then
            if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.ButtonR3 then
                if self.lockCamera then
                    return
                end

                if not self.isActive then
                    self.isActive = true

                    self.activeMouseLock:DoMouseLockSwitch(
                        "MouseLockSwitchAction",
                        Enum.UserInputState.Begin,
                        Enum.KeyCode.LeftControl
                    )
                elseif self.isActive then
                    self.isActive = false

                    self.activeMouseLock:DoMouseLockSwitch(
                        "MouseLockSwitchAction",
                        Enum.UserInputState.Begin,
                        Enum.KeyCode.LeftControl
                    )
                end
            end
        end
    end)
end

function CameraManager:Disconnect()
    if CameraManager.input then
        CameraManager.input:Disconnect()
    end
end

function CameraManager:SetCeremony(enable)
    if enable then
        self.lockCamera = true

        self.Camera.CameraType = Enum.CameraType.Scriptable
        self.Camera.CFrame = Podiums.Camera.CFrame
    else
        self.lockCamera = false

        self.Camera.CameraType = Enum.CameraType.Custom
        if self.character and self.character:FindFirstChild("Humanoid") then
            self.Camera.CameraSubject = self.character.Humanoid
        end
    end
end

function CameraManager:Update(deltaTime)
    
end

return CameraManager