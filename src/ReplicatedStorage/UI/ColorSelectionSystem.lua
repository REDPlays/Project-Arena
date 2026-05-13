local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextAction = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UIAssets = Assets:WaitForChild("UI")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

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
    newColorSelection.HexPivot1 = ColorBoard.HexPivot1
    newColorSelection.HexPivot2 = ColorBoard.HexPivot2

    newColorSelection.isActive = false

    newColorSelection:Init()

    return newColorSelection
end

function ColorSelectionSystem:Init()
    self.SectionUI = self.ColorUI:WaitForChild("SectionUI")
    self.SectionLabel = self.SectionUI.Section
    self.SectionPrev = self.SectionUI.Prev
    self.SectionNext = self.SectionUI.Next

    self.EscapeUI = self.ColorUI:WaitForChild("EscapeUI")

    self.ColorIcon = self.ColorUI.ColorIcon

    self.LeftFrame = self.ColorUI:WaitForChild("LeftFrame")
    self.PresetColorHolder = self.LeftFrame.Holder
    self.ExampleColorBlock = self.PresetColorHolder.Example

    self.RightFrame = self.ColorUI:WaitForChild("RightFrame")
    self.RSlider = self.RightFrame.RSlider
    self.GSlider = self.RightFrame.GSlider
    self.BSlider = self.RightFrame.BSlider

    self.RBtn = self.RSlider.RBtn
    self.GBtn = self.GSlider.GBtn
    self.BBtn = self.BSlider.BBtn

    self.RBar = self.RSlider.Bar
    self.GBar = self.GSlider.Bar
    self.BBar = self.BSlider.Bar

    self.R_BarSlider = self.RBar.Slider
    self.G_BarSlider = self.GBar.Slider
    self.B_BarSlider = self.BBar.Slider

    self.rgbButtons = {
        [self.RBtn] = self.RBtn,
        [self.GBtn] = self.GBtn,
        [self.BBtn] = self.BBtn,
    }

    self.rgbBars = {
        [self.RBtn] = self.RBar,
        [self.GBtn] = self.GBar,
        [self.BBtn] = self.BBar,
    }

    self.rgbSliders = {
        [self.RBtn] = self.R_BarSlider,
        [self.GBtn] = self.G_BarSlider,
        [self.BBtn] = self.B_BarSlider,
    }

    self.rgbValues = {
        [self.RBtn] = 0,
        [self.GBtn] = 0,
        [self.BBtn] = 0,
    }

    self.currentRGB = nil
    self.currentSlider = nil
    self.currentBar = nil
    self.step = 0.01

    self.mousePressSlider = false
    self.controllerPressSlider = false
    self.Direction = nil

    self.Sections = {
        [1] = "Primary",
        [2] = "Secondary",
        [3] = "Energy",
    }

    self.currentSection = 1

    --Resize Sliders for Mobile
    if UserInputService.TouchEnabled then
        for _, button: ImageButton in self.rgbSliders do
            local xSize = button.Size.X.Scale
            local ySize = button.Size.Y.Scale

            button.Size = UDim2.new(xSize * 2, 0, ySize * 1.25, 0)
        end
    end
    
    self:InputDetection()
    self:Connections()
    self:SetupPresets()
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

function ColorSelectionSystem:BuildHexColors()
    local Colors = {}
    local originCFrame = self.HexPivot1.CFrame
    local startCFrame = originCFrame

    local rows = 7
    local columns = 18
    local horizonalSpacing = 1

    for row=1, rows do
        for col=1, columns do
            if col > 1 then
                startCFrame *= CFrame.new(-horizonalSpacing, 0, 0)
            end

            local part = Instance.new("Part")
            part.Anchored = true
            part.Size = Vector3.new(1, 1, 1)
            part.CFrame = startCFrame
            part.Parent = workspace.Ignore

            if row < 7 then
                local hue = (col - 1) / columns

                local value = 1 - ((row - 1) / 6) * 0.8

                local saturation = 1 - ((row - 1) / 6) * 0.25

                part.Color = Color3.fromHSV(hue, saturation, value)
            else
                local alpha = (col - 1) / (columns - 1)
                local brightness = 1 - alpha

                part.Color = Color3.new(brightness, brightness, brightness)
            end

            startCFrame = part.CFrame
        end

        startCFrame = originCFrame * CFrame.new(0, -(horizonalSpacing * row), 0)
    end

    --[==[
    local Colors = {}
    local colorCount = 1
    for i=0, 100, 2.5 do
        local h = i/100

        table.insert(Colors, colorCount, Color3.fromHSV(h, 1, 1))

        colorCount += 1
    end

    local BWcolors = {}
    local bwCount = 1
    for i=0, 100, 14 do
        local v = i/100

        table.insert(BWcolors, bwCount, Color3.fromHSV(0, 0, v))
    end

    local function toWorld(pivot, offset: Vector3)
        return pivot.CFrame:PointToWorldSpace(offset)
    end

    local function buildColorHex(colors, pivot)
        local hexSize = 1.25
        local radius = 3
        local index = 1

        for q = -radius, radius do
            for r = -radius, radius do
                local s = -q - r
                if math.abs(s) <= radius then
                    if index > #colors then return end

                    local x = hexSize * (3/2 * q)
                    local y = hexSize * (math.sqrt(3) * (r + q/2))

                    local worldPos = toWorld(pivot, Vector3.new(x, y, 0))

                    local part = UIAssets.Hexagon:Clone()
                    part.Color = colors[index]
                    part.Size = Vector3.new(part.Size.X * 2, part.Size.Y, part.Size.Z * 2)
                    part.CFrame = CFrame.new(worldPos, worldPos + pivot.CFrame.LookVector) * CFrame.Angles(math.rad(90), 0, 0)
                    part.Parent = self.ColorBoard.Colors

                    index += 1
                end
            end
        end
    end

    local function buildBWGrid(bwColors, pivot)
        local size = 1.2
        local count = #bwColors

        for i = 1, count do
            local offsetIndex = i - (count + 1) / 2

            local right = pivot.CFrame.RightVector

            local offset = right * (offsetIndex * size * 2)

            local worldPos = pivot.Position + offset

            local part = UIAssets.Hexagon:Clone()
            part.Color = bwColors[i]
            part.Size = Vector3.new(part.Size.X * 2, part.Size.Y, part.Size.Z * 2)
            part.CFrame = CFrame.new(worldPos, worldPos + pivot.CFrame.LookVector) * CFrame.Angles(math.rad(90), 0, 0)
            part.Parent = workspace
        end
    end

	buildColorHex(Colors, self.HexPivot1)
	buildBWGrid(BWcolors, self.HexPivot2)
    ]==]
end

function ColorSelectionSystem:SetupPresets()
    self.PresetColors = {}

    local maxColors = 1032

    for i=1, maxColors do
        local newColor = BrickColor.new(i)

        if not self.PresetColors[tostring(newColor)] then
            local newUI: ImageButton = self.ExampleColorBlock:Clone()
            newUI.BackgroundColor3 = newColor.Color
            newUI.Name = tostring(newColor)
            newUI.LayoutOrder = i
            newUI.Visible = true
            newUI.Parent = self.PresetColorHolder

            local connection = newUI.Activated:Connect(function(inputObject, clickCount)
                self:SetColor(newColor.Color)
            end)

            self.PresetColors[tostring(newColor)] = {
                Color = newColor,
                Button = newUI,
                connection = connection
            }
        end
    end

    self:BuildHexColors()
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