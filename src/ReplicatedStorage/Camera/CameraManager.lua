local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local CameraManager = {}
CameraManager.__index = CameraManager

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

function CameraManager:Connections()
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent then
            if input.KeyCode == Enum.KeyCode.LeftControl then
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

function CameraManager:Update(deltaTime)
    
end

return CameraManager