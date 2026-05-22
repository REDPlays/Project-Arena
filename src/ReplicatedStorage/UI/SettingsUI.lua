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

local MIN_SLIDER_SCALE = -0.5
local MAX_SLIDER_SCALE = 0.5
local MIN_VALUE = 0.5
local MAX_VALUE = 2

local function roundNumber(num, numPlaces)
    return math.floor(num * (10^numPlaces))/(10^numPlaces)
end

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
    self.ButtonScale = self.Background.ButtonScale

    self.Debounces = {
        ["MoveUI"] = false,
    }

    self.ToggleUIs = {
        ["MoveUI"] = self.MoveUI,
        
    }

    self.DragUIs = {
        ["Scale"] = self.ButtonScale
    }

    self.tweens = {
        ["MoveUI"] = nil
    }

    self.DragValues = {
        ["Scale"] = 1,
    }

    self.UIScales = {}

    self:Init()

    return self
end

function SettingsUI:Init()
    self.statsFolder = self.character:FindFirstChild("Stats")

    self.connections = {}

    self:Connects()
    self:SetupToggleUI()
    self:SetupDragUI()
    self:SetupScales()
end

function SettingsUI:SetupScales()
    for _, btn in ipairs(self.mobileButtons) do
        local UIScale = btn.UIScale
        table.insert(self.UIScales, UIScale)
    end
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

function SettingsUI:SetupDragUI()
    for id, frame: Frame in pairs(self.DragUIs) do
        local Slider = frame.Slider
        local Button = Slider.Button
        local UIDrag: UIDragDetector = Button.UIDragDetector
        local TextBox: TextBox = frame.TextBox

        local startValue = self.DragValues.Scale
        local startScale = ((startValue - MIN_VALUE) / (MAX_VALUE - MIN_VALUE)) * (MAX_SLIDER_SCALE - MIN_SLIDER_SCALE) + MIN_SLIDER_SCALE
        
        UIDrag.DragUDim2 = UDim2.fromScale(startScale, 0)

        self.connections[id.."Drag"] = UIDrag.DragContinue:Connect(function()
            local dragX = UIDrag.DragUDim2.X.Scale
            
            local scale = math.clamp(dragX, MIN_SLIDER_SCALE, MAX_SLIDER_SCALE)

            local value = ((scale - MIN_SLIDER_SCALE) / (MAX_SLIDER_SCALE - MIN_SLIDER_SCALE)) * (MAX_VALUE - MIN_VALUE) + MIN_VALUE
            TextBox.Text = roundNumber(value, 1)

            self.DragValues[id] = value
        end)

        self.connections[id.."Text"] = TextBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local newValue = tonumber(TextBox.Text)
                if newValue then
                    if newValue < MIN_VALUE then
                        newValue = MIN_VALUE
                    elseif newValue > MAX_VALUE then
                        newValue = MAX_VALUE
                    end

                    TextBox.Text = newValue

                    local newScale = ((newValue - MIN_VALUE) / (MAX_VALUE - MIN_VALUE)) * (MAX_SLIDER_SCALE - MIN_SLIDER_SCALE) + MIN_SLIDER_SCALE

                    UIDrag.DragUDim2 = UDim2.fromScale(newScale, 0)

                    self.DragValues[id] = newValue
                end
            end
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
    local Scale = self.DragValues.Scale
    if Scale then
        for _, UIScale: UIScale in ipairs(self.UIScales) do
            UIScale.Scale = Scale
        end
    end

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