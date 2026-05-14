local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextAction = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UIAssets = Assets:WaitForChild("UI")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local ColorGroups = {
    [1] = "Primary",
    [2] = "Secondary",
    [3] = "Energy",
}

local ColorSelectionSystem = {}
ColorSelectionSystem.__index = ColorSelectionSystem

function ColorSelectionSystem.new(ColorUI, UIController, player, ColorBoard: Model)
    local newColorSelection = {}
    setmetatable(newColorSelection, ColorSelectionSystem)
    
    newColorSelection.ColorUI = ColorUI:WaitForChild("Background")

    newColorSelection.selectionColor = Color3.fromRGB(255, 203, 80)
    newColorSelection.nonSelectionColor = Color3.fromRGB(255, 255, 255)

    newColorSelection.UIController = UIController
    newColorSelection.Mouse = player:GetMouse()  

    newColorSelection.ColorBoard = ColorBoard
    newColorSelection.ColorPivot = ColorBoard.ColorPivot

    newColorSelection.isActive = false

    newColorSelection:Init()

    return newColorSelection
end

function ColorSelectionSystem:Init()
    self.connections = {}
    
    self.CurrentGroup = self.ColorBoard.CurrentGroup
    self.SectionGroup = self.ColorBoard.SectionGroup
    self.ColorGroup = self.ColorBoard.ColorGroup

    self.sectionDisplay = self.SectionGroup.Board.LabelTag.Background.Label

    self.groupNum = 1
    self.currentColorGroup = string.upper(ColorGroups[self.groupNum])
    self.sectionDisplay.Text = self.currentColorGroup

    self.rgbSliderValues = {
        ["R"] = 0,
        ["G"] = 0,
        ["B"] = 0,
    }

    self:BuildColorSliders()
    self:BuildColors()
end

function ColorSelectionSystem:BuildColorSliders()
    self.selectionSliders = {
        ["Left"] = self.SectionGroup.Left,
        ["Right"] = self.SectionGroup.Right,
    }

    for direction, button in pairs(self.selectionSliders) do
        local click = Instance.new("ClickDetector")
        click.Name = "Click"
        click.MaxActivationDistance = 75
        click.Parent = button

        self.connections[direction] = click.MouseClick:Connect(function()
            if direction == "Left" then
                self.groupNum -= 1

                if self.groupNum < 1 then
                    self.groupNum = #ColorGroups
                end
            elseif direction == "Right" then
                self.groupNum += 1

                if self.groupNum > #ColorGroups then
                    self.groupNum = 1
                end
            end

            self.currentColorGroup = string.upper(ColorGroups[self.groupNum])
            self.sectionDisplay.Text = self.currentColorGroup
        end)
    end

    self.sliders = {
        ["R"] = self.ColorBoard:FindFirstChild("RColor"),
        ["G"] = self.ColorBoard:FindFirstChild("GColor"),
        ["B"] = self.ColorBoard:FindFirstChild("BColor"),
    }

    for colorSection: "R" | "G"| "B" , colorboard in pairs(self.sliders) do
        local Dial: Model = colorboard:FindFirstChild("Dial")
        local Left: BasePart = colorboard:FindFirstChild("Left")
        local Right: BasePart = colorboard:FindFirstChild("Right")
        local Display: TextLabel = colorboard.Display.LabelTag.Background.Label

        local Arrows = {
            ["Left"] = Left,
            ["Right"] = Right,
        }

        for direction, button in pairs(Arrows) do
            local click = Instance.new("ClickDetector")
            click.Name = "Click"
            click.MaxActivationDistance = 75
            click.Parent = button

            self.connections["Slider"..direction] = click.MouseClick:Connect(function()
                warn("direction:", direction)
            end)
        end


    end
end

function ColorSelectionSystem:InputDetection()
    local keyboardOptions = {
        [Enum.UserInputType.Keyboard] = true,
        [Enum.UserInputType.MouseMovement] = true,
    }
    
    local controllerOptions = {
        [Enum.UserInputType.Gamepad1] = true,
        [Enum.KeyCode.Thumbstick1] = true,
        [Enum.KeyCode.Thumbstick2] = true,
    }
    
    local mobileOptions = {
        [Enum.UserInputType.Touch] = true,
    }

    UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
        if keyboardOptions[input.UserInputType] or mobileOptions[input.UserInputType] then
            self.SectionPrev.Text = "<"
            self.SectionNext.Text = ">"
            self.EscapeUI.Label.Text = "X"
        elseif controllerOptions[input.UserInputType] or controllerOptions[input.KeyCode] then
            self.SectionPrev.Text = "LB"
            self.SectionNext.Text = "RB"
            self.EscapeUI.Label.Text = "B"
        end
    end)
end

function ColorSelectionSystem:Connections()
    --functions
    local function Section(actionName, inputState: Enum.UserInputState, inputObject: InputObject)
        if not self.isActive then 
            return 
        end

        if actionName == "Next" and inputState == Enum.UserInputState.Begin then
            self.currentSection += 1
            if self.currentSection > 3 then
                self.currentSection = 1
            end

            self.SectionLabel.Text = self.Sections[self.currentSection]
        end

        if actionName == "Previous" and inputState == Enum.UserInputState.Begin then
            self.currentSection -= 1
            if self.currentSection < 1 then
                self.currentSection = 3
            end

            self.SectionLabel.Text = self.Sections[self.currentSection]
        end
    end

    local function Exit(actionName, inputState: Enum.UserInputState, inputObject: InputObject)
        if not self.isActive then 
            return 
        end

        if actionName == "Exit" and inputState == Enum.UserInputState.Begin then
            self.UIController:ToggleColorCamera(false)
        end
    end

    --Section Buttons
    self.NextBtn = self.SectionNext.Activated:Connect(function()
        Section("Next", Enum.UserInputState.Begin)
    end)

    self.PrevBtn = self.SectionPrev.Activated:Connect(function()
        Section("Previous", Enum.UserInputState.Begin)
    end)

    --Exit Button
    self.ExitBtn = self.EscapeUI.Activated:Connect(function()
        Exit("Exit", Enum.UserInputState.Begin)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.ButtonB then
            Exit("Exit", Enum.UserInputState.Begin)
        elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
            Section("Previous", Enum.UserInputState.Begin)
        elseif input.KeyCode == Enum.KeyCode.ButtonR1 then
            Section("Next", Enum.UserInputState.Begin)
        end
    end)

    --RGB Buttons
    self.rgbConnects = {}
    for btnId, button in self.rgbButtons do
        self.rgbConnects[btnId] = button.Activated:Connect(function()
            if self.currentRGB then
                self.currentRGB.TextColor3 = self.nonSelectionColor
            end

            self.currentRGB = button
            self.currentRGB.TextColor3 = self.selectionColor

            self.currentSlider = self.rgbSliders[btnId]
            self.currentBar = self.rgbBars[btnId]

            GuiService.SelectedObject = nil
        end)
    end

    --RGB Sliders
    self.rgbSliderConnections = {}
    for btnId, button: ImageButton in self.rgbSliders do
        self.rgbSliderConnections[btnId] = button.MouseButton1Down:Connect(function()
            self.mousePressSlider = true
        end)
    end

    self.letGo = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.mousePressSlider = false
        end
    end)

    --Controller Sticks
    self.trigBegan = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not self.isActive then 
            return 
        end

        if input.KeyCode == Enum.KeyCode.ButtonL2  then
            self.controllerPressSlider = true
            self.Direction = "Left"
        elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
            self.controllerPressSlider = true
            self.Direction = "Right"
        end
    end)

    self.trigEnded = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if not self.isActive then 
            return 
        end

        if input.KeyCode == Enum.KeyCode.ButtonL2 or input.KeyCode == Enum.KeyCode.ButtonR2 then
            self.controllerPressSlider = false
            self.Direction = nil
        end
    end)
end

function ColorSelectionSystem:BuildColors()
    self.colorConnections = {}

    local Colors = {}
    local originCFrame = self.ColorPivot.CFrame
    local startCFrame = originCFrame

    local rows = 7
    local columns = 18
    local horizonalSpacing = 1

    --build color grid
    for row=1, rows do
        for col=1, columns do
            if col > 1 then
                startCFrame *= CFrame.new(-horizonalSpacing, 0, 0)
            end

            local part = Instance.new("Part")
            part.Anchored = true
            part.Size = Vector3.new(1, 1, 1)
            part.CFrame = startCFrame
            part.Parent = self.ColorBoard.Colors

            local newColor

            if row < 7 then
                local hue = (col - 1) / columns
                local value = 1 - ((row - 1) / 6) * 0.8
                local saturation = 1 - ((row - 1) / 6) * 0.25

                newColor = Color3.fromHSV(hue, saturation, value)
                part.Color = newColor
            else
                local alpha = (col - 1) / (columns - 1)
                local brightness = 1 - alpha

                newColor = Color3.new(brightness, brightness, brightness)
                part.Color = newColor
            end

            Colors[part] = {
                color = newColor,
                part = part,
            }

            startCFrame = part.CFrame
        end

        startCFrame = originCFrame * CFrame.new(0, -(horizonalSpacing * row), 0)
    end

    local highlight = Instance.new("Highlight")
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.FillTransparency = 1
    highlight.Parent = workspace.Ignore

    for colorpart, colordata in pairs(Colors) do
        local click = Instance.new("ClickDetector")
        click.Name = "Click"
        click.MaxActivationDistance = 75
        click.Parent = colorpart

        self.colorConnections[colorpart] = {}

        self.colorConnections[colorpart].Click = click.MouseClick:Connect(function()
            warn("color:", colorpart, colordata.color)
        end)

        self.colorConnections[colorpart].Enter = click.MouseHoverEnter:Connect(function()
            highlight.Parent = colorpart
        end)

        self.colorConnections[colorpart].Leave = click.MouseHoverLeave:Connect(function()
            highlight.Parent = workspace.Ignore
        end)
    end
end

function ColorSelectionSystem:SetColor(Color: Color3)
    local RGBColor = Color3.fromRGB(
        Color.R * 255, 
        Color.G * 255,
        Color.B * 255
    )

    self.ColorIcon.BackgroundColor3 = RGBColor

    local section =  self.Sections[self.currentSection]

    --Event to fire to server to change color value
    Events.Client_Server.SelectColor:FireServer(section, RGBColor)
end

function snap(number, factor)
    if factor == 0 then
        return number
    else
        return math.floor(number/factor + 0.5) * factor
    end
end

function ColorSelectionSystem:Update(deltaTime)
    if not self.isActive then 
        return 
    end

   if self.mousePressSlider and self.currentRGB and self.currentSlider then
        local MousePos = UserInputService:GetMouseLocation().X
        local FrameSize = self.currentBar.AbsoluteSize.X
        local FramePos= self.currentBar.AbsolutePosition.X
        local pos = snap((MousePos - FramePos) / FrameSize, self.step)
        local percentage = math.clamp(pos, 0, 1)

        self.rgbValues[self.currentRGB] = percentage
        self.currentSlider.Position = UDim2.new(percentage, 0, 0.5, 0)

        local R = self.rgbValues[self.RBtn]
        local G = self.rgbValues[self.GBtn]
        local B = self.rgbValues[self.BBtn]
        local newColor = Color3.new(R, G, B)

        self:SetColor(newColor)
   end

   if self.controllerPressSlider and self.currentRGB and self.currentSlider then
        if self.Direction == "Left" then
            self.rgbValues[self.currentRGB] -= 1 * deltaTime
            self.rgbValues[self.currentRGB] = math.clamp(self.rgbValues[self.currentRGB], 0, 1)

            local percentage = self.rgbValues[self.currentRGB]

            self.currentSlider.Position = UDim2.new(percentage, 0, 0.5, 0)

            local R = self.rgbValues[self.RBtn]
            local G = self.rgbValues[self.GBtn]
            local B = self.rgbValues[self.BBtn]
            local newColor = Color3.new(R, G, B)

            self:SetColor(newColor)
        elseif self.Direction == "Right" then
            self.rgbValues[self.currentRGB] += 1 * deltaTime
            self.rgbValues[self.currentRGB] = math.clamp(self.rgbValues[self.currentRGB], 0, 1)

            local percentage = self.rgbValues[self.currentRGB]

            self.currentSlider.Position = UDim2.new(percentage, 0, 0.5, 0)

            local R = self.rgbValues[self.RBtn]
            local G = self.rgbValues[self.GBtn]
            local B = self.rgbValues[self.BBtn]
            local newColor = Color3.new(R, G, B)

            self:SetColor(newColor)
        end
   end
end

return ColorSelectionSystem