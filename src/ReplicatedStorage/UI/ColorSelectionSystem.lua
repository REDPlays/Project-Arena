local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextAction = game:GetService("ContextActionService")

local ColorSelectionSystem = {}
ColorSelectionSystem.__index = ColorSelectionSystem

function ColorSelectionSystem.new(ColorUI, UIController, player)
    local newColorSelection = {}
    setmetatable(newColorSelection, ColorSelectionSystem)
    
    newColorSelection.ColorUI = ColorUI:WaitForChild("Background")

    newColorSelection.selectionColor = Color3.fromRGB(255, 203, 80)
    newColorSelection.nonSelectionColor = Color3.fromRGB(255, 255, 255)

    newColorSelection.UIController = UIController
    newColorSelection.Mouse = player:GetMouse()

    newColorSelection.isActive = false

    newColorSelection:Init()

    return newColorSelection
end

function ColorSelectionSystem:Init()
    self.SectionUI = self.ColorUI:WaitForChild("SectionUI")
    self.SectionLabel = self.SectionUI.Label.Section
    self.SectionPrev = self.SectionUI.Prev
    self.SectionNext = self.SectionUI.Next

    self.EscapeUI = self.ColorUI:WaitForChild("EscapeUI")
    self.EscapeButton = self.EscapeUI.Button
    
    self.rgbUI = self.ColorUI:WaitForChild("rgbUI")
    self.RBtn = self.rgbUI.R.RBtn
    self.GBtn = self.rgbUI.G.GBtn
    self.BBtn = self.rgbUI.B.BBtn

    self.RSlider = self.rgbUI.R.Holder.Slider
    self.GSlider = self.rgbUI.G.Holder.Slider
    self.BSlider = self.rgbUI.B.Holder.Slider

    self.RValue = self.rgbUI.R.Holder.Value
    self.GValue = self.rgbUI.G.Holder.Value
    self.BValue = self.rgbUI.B.Holder.Value

    self.rgbButtons = {
        [self.RBtn] = self.RBtn,
        [self.GBtn] = self.GBtn,
        [self.BBtn] = self.BBtn,
    }

    self.rgbSliders = {
        [self.RBtn] = self.RSlider,
        [self.GBtn] = self.GSlider,
        [self.BBtn] = self.BSlider,
    }

    self.rgbValues = {
        [self.RBtn] = self.RValue,
        [self.GBtn] = self.GValue,
        [self.BBtn] = self.BValue,
    }

    self.currentRGB = nil
    self.beganConnect = nil
    self.changeConnect = nil
    self.endConnect = nil

    self.UseMouse = false
    self.UseGamepad = false

    self.currentSlider = nil
    self.currentValue = nil

    if UserInputService.GamepadEnabled then
        self.SectionPrev.Text = "LB"
        self.SectionNext.Text = "RB"
    else
        self.SectionPrev.Text = "<"
        self.SectionNext.Text = ">"
    end

    self:Mouse_Touch_Setup()
    self:Controller_Setup()
end

function ColorSelectionSystem:ContextAction()
    self.beganConnect = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not self.isActive then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            print("Left Click Down")
            self.UseMouse = true
        end

        if input.KeyCode == Enum.KeyCode.ButtonL1 then
            print("LB")
        end
        if input.KeyCode == Enum.KeyCode.ButtonR1 then
            print("RB")
        end
    end)

    self.endConnect = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if not self.isActive then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            print("Left Click Up")
            self.UseMouse = false
        end
    end)

    self.changeConnect = UserInputService.InputChanged:Connect(function(input: InputObject, gameProcessedEvent)
        if not self.isActive then
            return
        end
        
        if input.KeyCode == Enum.KeyCode.Thumbstick1 then
            local XPosition = input.Position.X

            if XPosition > 0 and XPosition > 0.5 then
                print("Moving stick to the right")
            elseif XPosition < 0 and XPosition < -0.5  then
                print("Moving stick to the left")
            end
        end
    end)
end

function ColorSelectionSystem:Mouse_Touch_Setup()
    --section buttons
    self.prev_MT_Connect = self.SectionPrev.Activated:Connect(function()
        print("Prev Section")
    end)

    self.next_MT_Connect = self.SectionNext.Activated:Connect(function()
        print("Next Section")
    end)

    self.backButton = self.EscapeButton.Activated:Connect(function()
        print("Escape Color System")
        self.UIController:ToggleColorCamera(false)
    end)

    self:ContextAction()

    --rgb buttons
    local rgbConnects = {}
    for btnId, button in self.rgbButtons do
        rgbConnects[btnId] = button.Activated:Connect(function()
            if self.currentRGB then
                self.currentRGB.TextColor3 = self.nonSelectionColor
            end

            self.currentRGB = button
            self.currentRGB.TextColor3 = self.selectionColor

            self.currentSlider = self.rgbSliders[btnId]
            self.currentValue = self.rgbValues[btnId]
        end)
    end
end

function ColorSelectionSystem:Controller_Setup()
    
end

function ColorSelectionSystem:Update(deltaTime)
    if self.UseMouse then
        -- Get the 2D mouse position on the screen (normalized to 0-1 range for X)
        local mousePosition = self.Mouse.X / workspace.CurrentCamera.ViewportSize.X

        -- Apply the boost to the normalized mouse position
        local boostedMousePosition = mousePosition
        
        -- Get the target surface
        local target = self.Mouse.Target

        if target and self.currentSlider then
            -- Clamp the boosted X position to keep it within 0 and 1
            local xValue = math.clamp(boostedMousePosition, 0, 1)

            -- Update the slider's X position in the surface UI based on the boosted and clamped mouse position
            local sliderPosition = UDim2.fromScale(xValue, 0.5)
            self.currentSlider.Position = sliderPosition
        end
    end
end

return ColorSelectionSystem