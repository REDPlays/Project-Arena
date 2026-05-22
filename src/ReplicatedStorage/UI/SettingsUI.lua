local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Colors = {
    ["Enabled"] = Color3.fromRGB(104, 229, 154),
    ["Disabled"] = Color3.fromRGB(255, 90, 90),
}

local TogglePositions = {
    ["Enabled"] = UDim2.fromScale(0.75, 0.5),
    ["Disabled"] = UDim2.fromScale(0.25, 0.5),
}

local SettingsUI = {}
SettingsUI.__index = SettingsUI

function SettingsUI.new(player: Player, character: Model, settingsUI: Frame, gameplay: Frame)
    local self = setmetatable({}, SettingsUI)

    self.player = player
    self.character = character
    self.settings = settingsUI
    self.mobileUI = gameplay

    self.mobileMovelist = self.mobileUI.MoveList
    self.mobileStats = self.mobileUI.Stats

    self.mobileButtons = {
        self.mobileMovelist.LMB_Btn,
        self.mobileMovelist.Q_Btn,
        self.mobileMovelist.E_Btn,
        self.mobileMovelist.F_Btn,
    }

    self.Background = self.settings.Background.Background2.Background3

    self.MoveUI = self.Background.MoveUI

    self.Debounces = {
        ["MoveUI"] = false,
    }

    self.ToggleUIs = {
        ["MoveUI"] = self.MoveUI,
        
    }

    self.tweens = {
        ["MoveUI"] = nil
    }

    self:Init()

    return self
end

function SettingsUI:Init()
    self.statsFolder = self.character:FindFirstChild("Stats")

    self.connections = {}

    self:Connects()
    self:SetupToggleUI()
end

function SettingsUI:SetupToggleUI()
    local Info = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    for id, frame: Frame in pairs(self.ToggleUIs) do
        local Container: ImageLabel = frame.Container
        local Button: ImageButton = Container.Button

        Container.ImageColor3 = Colors.Disabled
        Button.ImageColor3 = Colors.Disabled
        Button.Position = TogglePositions.Disabled

        self.connections[id] = Button.MouseButton1Click:Connect(function()
            self.Debounces[id] = not self.Debounces[id]

            if id == "MoveUI" then
                self.statsFolder:SetAttribute("MoveUILock", self.Debounces[id])
                self:ToggleMobileUIMovement(self.Debounces[id])
            else

            end

            local colorToSet = nil
            local toggle = ""
            if self.Debounces[id] then
                colorToSet = Colors.Enabled
                toggle = "Enabled"
            else
                colorToSet = Colors.Disabled
                toggle = "Disabled"
            end

            Container.ImageColor3 = colorToSet
            Button.ImageColor3 = colorToSet

            if self.tweens[id] then
                self.tweens[id]:Pause()
            end

            self.tweens[id] = TweenService:Create(Button, Info, {Position = TogglePositions[toggle]})
            self.tweens[id]:Play()
        end)
    end
end

function SettingsUI:Connects()
    self.isDragging = false
    self.DragUI = nil
    self.dragOffset = Vector2.zero

    for i, btn in ipairs(self.mobileButtons) do
        local touchButton: ImageButton = btn.TouchButton
        
        self.connections[tostring(i).."Pressed"] = touchButton.MouseButton1Down:Connect(function(x, y)
            if not self.Debounces["MoveUI"] then
                return
            end

            self.isDragging = true
            self.DragUI = btn

            local mousePos = UserInputService:GetMouseLocation()

            local topLeft = btn.AbsolutePosition
            local size = btn.AbsoluteSize

            local center = topLeft + size / 2

            self.dragOffset = mousePos - center
        end)

        self.connections[tostring(i).."Released"] = touchButton.MouseButton1Up:Connect(function(x, y)
            if not self.Debounces["MoveUI"] then
                return
            end
            
            self.isDragging = false
            self.DragUI = nil
            self.dragOffset = Vector2.zero
        end)
    end
end

function SettingsUI:ToggleMobileUIMovement(enabled: boolean)
    for _, btn in ipairs(self.mobileButtons) do
        local touchButton: ImageButton = btn.TouchButton
        touchButton.BackgroundTransparency = enabled and 0.5 or 1
    end
end

function SettingsUI:Disconnect()
    
end

function SettingsUI:Update(deltaTime: number)
    if self.isDragging and self.DragUI then
        local mousePos = UserInputService:GetMouseLocation()

        local parent = self.DragUI.Parent
        local parentAbsPos = parent.AbsolutePosition

        local newCenter = mousePos - self.dragOffset

        self.DragUI.Position = UDim2.fromOffset(
            newCenter.X - parentAbsPos.X,
            newCenter.Y - parentAbsPos.Y
        )
    end
end

return SettingsUI