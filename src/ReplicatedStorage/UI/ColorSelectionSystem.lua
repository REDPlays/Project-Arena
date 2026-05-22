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
    
    newColorSelection.player = player
    newColorSelection.ColorUI = ColorUI
    newColorSelection.IndicatorText = ColorUI:FindFirstChild("TextLabel")

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

    self.currentDisplay = self.CurrentGroup.Display
    self.sectionDisplay = self.SectionGroup.Board.LabelTag.Background.Label

    self.groupNum = 1
    self.currentColorGroup = string.upper(ColorGroups[self.groupNum])
    self.sectionDisplay.Text = self.currentColorGroup

    self.playerColors = {
        ["Primary"] = self.player:GetAttribute("Primary"),
        ["Secondary"] = self.player:GetAttribute("Secondary"),
        ["Energy"] = self.player:GetAttribute("Energy"),
    }

    self.rgbSliderValues = {
        ["R"] = 0,
        ["G"] = 0,
        ["B"] = 0,
    }
    
    --initial set
    self.currentDisplay.Color = self.player:GetAttribute("Primary")
    self.sectionDisplay.TextColor3 = self.player:GetAttribute("Primary")

    self.highlight = Instance.new("Highlight")
    self.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    self.highlight.OutlineTransparency = 0
    self.highlight.FillTransparency = 1
    self.highlight.Parent = workspace.Ignore

    self:SetupConnections()
    self:BuildColorSliders()
    self:BuildColors()
end

function ColorSelectionSystem:SetupConnections()
    for colorSection, value in pairs(self.playerColors) do
        self.connections[colorSection] = self.player:GetAttributeChangedSignal(colorSection):Connect(function()
            self.playerColors[colorSection] = self.player:GetAttribute(colorSection)
            
            if ColorGroups[self.groupNum] == colorSection then
                self.currentDisplay.Color = self.player:GetAttribute(colorSection)
                self.sectionDisplay.TextColor3 = self.player:GetAttribute(colorSection)
            end
        end)
    end
end

function ColorSelectionSystem:BuildColorSliders()
    self.selectionSliders = {
        ["Left"] = self.SectionGroup.Left,
        ["Right"] = self.SectionGroup.Right,
    }

    self.sliders = {
        ["R"] = self.ColorBoard:FindFirstChild("RColor"),
        ["G"] = self.ColorBoard:FindFirstChild("GColor"),
        ["B"] = self.ColorBoard:FindFirstChild("BColor"),
    }

    self.colorDisplays = {}
    self.dials = {}
    self.sliderBack = {}

    self.canHoldSlider = false
    self.holdSliderDirection = nil
    self.holdSliderSection = nil
    self.buttonType = ""
    self.hoverClickDebounce = false
    self.hoverClickCooldown = 0.25
    self.hoverKey = ""

    for direction, button in pairs(self.selectionSliders) do
        local click = Instance.new("ClickDetector")
        click.Name = "Click"
        click.MaxActivationDistance = 75
        click.Parent = button

        --[==[
        self.connections["Click"..direction] = click.MouseClick:Connect(function()
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

            self.currentDisplay.Color = self.player:GetAttribute(ColorGroups[self.groupNum])
            self.sectionDisplay.TextColor3 = self.player:GetAttribute(ColorGroups[self.groupNum])
        end)
        ]==]

        self.connections["Enter"..direction] = click.MouseHoverEnter:Connect(function()
            if not self.canHoldSlider then
                self.canHoldSlider = true
            end
            self.holdSliderDirection = direction
            self.holdSliderSection = button
            self.buttonType = "Section"
            self.ColorUI.Visible = true
            self.highlight.Parent = button
        end)

        self.connections["Exit"..direction] = click.MouseHoverLeave:Connect(function()
            if self.canHoldSlider then
                self.canHoldSlider = false
            end
            self.holdSliderDirection = direction
            self.holdSliderSection = button
            self.buttonType = "Section"
            self.ColorUI.Visible = false
            self.highlight.Parent = workspace.Ignore
        end)
    end

    for colorSection: "R" | "G"| "B" , colorboard in pairs(self.sliders) do
        local Dial: Model = colorboard:FindFirstChild("Dial")
        local Back: BasePart = colorboard:FindFirstChild("Back")
        local Left: BasePart = colorboard:FindFirstChild("Left")
        local Right: BasePart = colorboard:FindFirstChild("Right")
        local Display: TextLabel = colorboard.Display.LabelTag.Background.Label
        self.dials[colorSection] = Dial
        self.sliderBack[colorSection] = Back
        self.colorDisplays[colorSection] = Display

        local Arrows = {
            ["Left"] = Left,
            ["Right"] = Right,
        }

        for direction, button in pairs(Arrows) do
            local click = Instance.new("ClickDetector")
            click.Name = "Click"
            click.MaxActivationDistance = 75
            click.Parent = button

            --[==[
            self.connections["Slider"..direction..colorSection] = click.MouseClick:Connect(function()
                local section: "Primary" | "Secondary" | "Energy" = ColorGroups[self.groupNum]
                local oldColor = self.playerColors[section]

                local NewValues = {
                    ["R"] = oldColor.R * 255,
                    ["G"] = oldColor.G * 255,
                    ["B"] = oldColor.B * 255
                }

                if NewValues[colorSection] then
                    if direction == "Left" then
                        NewValues[colorSection] -= 1
                        if NewValues[colorSection] < 0 then
                            NewValues[colorSection] = 255
                        end
                    elseif direction == "Right" then
                        NewValues[colorSection] += 1
                        if NewValues[colorSection] > 255 then
                            NewValues[colorSection] = 0
                        end
                    end
                end

                local RGBColor = Color3.fromRGB(
                    NewValues.R, 
                    NewValues.G, 
                    NewValues.B
                )

                Events.Client_Server.SelectColor:FireServer(section, RGBColor)
            end)
            ]==]

            self.connections["SliderEnter"..direction.. colorSection] = click.MouseHoverEnter:Connect(function()
                if not self.canHoldSlider then
                    self.canHoldSlider = true
                end
                self.holdSliderDirection = direction
                self.holdSliderSection = colorSection
                self.buttonType = "Sliders"
                self.ColorUI.Visible = true
                self.highlight.Parent = button
            end)

            self.connections["SliderExit"..direction.. colorSection] = click.MouseHoverLeave:Connect(function()
                if self.canHoldSlider then
                    self.canHoldSlider = false
                end
                self.holdSliderDirection = direction
                self.holdSliderSection = colorSection
                self.buttonType = "Sliders"
                self.ColorUI.Visible = false
                self.highlight.Parent = workspace.Ignore
            end)
        end

    end
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

    for colorpart, colordata in pairs(Colors) do
        local click = Instance.new("ClickDetector")
        click.Name = "Click"
        click.MaxActivationDistance = 75
        click.Parent = colorpart

        self.colorConnections[colorpart] = {}

        --[==[self.colorConnections[colorpart].Click = click.MouseClick:Connect(function()
            local section = ColorGroups[self.groupNum]
            if section then
                local RGBColor = Color3.fromRGB(
                    colordata.color.R * 255, 
                    colordata.color.G * 255,
                    colordata.color.B * 255
                )

                Events.Client_Server.SelectColor:FireServer(section, RGBColor)
            end
        end)]==]

        self.colorConnections[colorpart].Enter = click.MouseHoverEnter:Connect(function()
            if not self.canHoldSlider then
                self.canHoldSlider = true
            end
            self.holdSliderSection = colordata
            self.buttonType = "Preset"
            self.holdSliderDirection = "Center"
            self.ColorUI.Visible = true
            self.highlight.Parent = colorpart
        end)

        self.colorConnections[colorpart].Leave = click.MouseHoverLeave:Connect(function()
            if self.canHoldSlider then
                self.canHoldSlider = false
            end
            self.holdSliderSection = colordata
            self.buttonType = "Preset"
            self.holdSliderDirection = "Center"
            self.ColorUI.Visible = false
            self.highlight.Parent = workspace.Ignore
        end)
    end
end

function ColorSelectionSystem:HoldButton()
    local isMouseClick = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    local isConsoleClick = false
    local isMobile = false

    if self.holdSliderDirection and self.holdSliderDirection == "Left" then
        isConsoleClick = UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.DPadLeft)
    elseif self.holdSliderDirection and self.holdSliderDirection == "Right" then
        isConsoleClick = UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.DPadRight)
    elseif self.holdSliderDirection and self.holdSliderDirection == "Center" then
        isConsoleClick = UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.DPadDown)
    end

    return isMouseClick or isConsoleClick or isMobile
end

function ColorSelectionSystem:InputDetection()
    local isMouseKey = UserInputService.KeyboardEnabled or UserInputService.MouseEnabled
    local isGamepad = UserInputService.GamepadEnabled
    local isTouch = UserInputService.TouchEnabled

    if isMouseKey and not isGamepad and not isTouch then
        return 1
    elseif isGamepad then
        return 2
    elseif isTouch then
        return 3
    else
        return 0
    end
end

function ColorSelectionSystem:DisplayKey(visible: boolean)
    self.hoverKey = ""

    local inputType = self:InputDetection()

    if inputType and inputType == 1 then
        self.hoverKey = "Left Click"
    elseif inputType and inputType == 2 then
        if self.holdSliderDirection then
            if self.holdSliderDirection == "Left" then
                self.hoverKey = "Left DPad"
            elseif self.holdSliderDirection == "Right" then
                self.hoverKey = "Right DPad"
            elseif self.holdSliderDirection == "Center" then
                self.hoverKey = "Down DPad"
            end
        end
    elseif inputType and inputType == 3 then
        self.hoverKey = "Touch"
    end

    if self.IndicatorText then
        self.IndicatorText.Text = "Press ["..self.hoverKey.."] to Select."
        self.IndicatorText.Visible = visible
    end
end

function ColorSelectionSystem:Disconnect()
    
end

function ColorSelectionSystem:Update(deltaTime)
    if self.canHoldSlider and self.buttonType and not self.hoverClickDebounce then
        self:DisplayKey(true)
        if self:HoldButton() then
            self.hoverClickDebounce = true
            task.delay(self.hoverClickCooldown, function()
                self.hoverClickDebounce = false
            end) 

            if self.buttonType == "Sliders" then
                local section: "Primary" | "Secondary" | "Energy" = ColorGroups[self.groupNum]
                local oldColor = self.playerColors[section]

                local NewValues = {
                    ["R"] = oldColor.R * 255,
                    ["G"] = oldColor.G * 255,
                    ["B"] = oldColor.B * 255
                }

                if NewValues[self.holdSliderSection] then
                    if self.holdSliderDirection == "Left" then
                        NewValues[self.holdSliderSection] -= 1
                        if NewValues[self.holdSliderSection] < 0 then
                            NewValues[self.holdSliderSection] = 255
                        end
                    elseif self.holdSliderDirection == "Right" then
                        NewValues[self.holdSliderSection] += 1
                        if NewValues[self.holdSliderSection] > 255 then
                            NewValues[self.holdSliderSection] = 0
                        end
                    end
                end

                local RGBColor = Color3.fromRGB(
                    NewValues.R, 
                    NewValues.G, 
                    NewValues.B
                )

                Events.Client_Server.SelectColor:FireServer(section, RGBColor)
            elseif self.buttonType == "Section" then
                if self.holdSliderDirection == "Left" then
                    self.groupNum -= 1

                    if self.groupNum < 1 then
                        self.groupNum = #ColorGroups
                    end
                elseif self.holdSliderDirection == "Right" then
                    self.groupNum += 1

                    if self.groupNum > #ColorGroups then
                        self.groupNum = 1
                    end
                end

                self.currentColorGroup = string.upper(ColorGroups[self.groupNum])
                self.sectionDisplay.Text = self.currentColorGroup

                self.currentDisplay.Color = self.player:GetAttribute(ColorGroups[self.groupNum])
                self.sectionDisplay.TextColor3 = self.player:GetAttribute(ColorGroups[self.groupNum])
            elseif self.buttonType == "Preset" then
                local section = ColorGroups[self.groupNum]
                if section then
                    local RGBColor = Color3.fromRGB(
                        self.holdSliderSection.color.R * 255, 
                        self.holdSliderSection.color.G * 255,
                        self.holdSliderSection.color.B * 255
                    )

                    Events.Client_Server.SelectColor:FireServer(section, RGBColor)
                end
            end
        end
    end

    local section: "Primary" | "Secondary" | "Energy" = ColorGroups[self.groupNum]
    if not section then return end

    local color = self.playerColors[section]
    if not color then return end

    self.rgbSliderValues = {
        ["R"] = math.floor(color.R * 255),
        ["G"] = math.floor(color.G * 255),
        ["B"] = math.floor(color.B * 255),
    }

    for i, value in pairs(self.rgbSliderValues) do
        local percentage = value / 255

        if self.colorDisplays[i] then
            self.colorDisplays[i].Text = value
        end

        if self.sliderBack[i] and self.dials[i] then
            local backSize: Vector3 = self.sliderBack[i].Size
            local centerCFrame: CFrame = self.sliderBack[i].CFrame
            local leftCFrame: CFrame = centerCFrame * CFrame.new(-backSize.X/2, 0, 0)
            local rightCFrame: CFrame = centerCFrame * CFrame.new(backSize.X/2, 0, 0)

            local lerpedCFrame:CFrame = rightCFrame:Lerp(leftCFrame, percentage)
            self.dials[i]:PivotTo(lerpedCFrame)
        end
    end
end

return ColorSelectionSystem