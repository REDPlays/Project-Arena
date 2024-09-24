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

    self.Sections = {
        [1] = "Primary",
        [2] = "Secondary",
        [3] = "Energy",
    }

    self.currentSection = 1

    self:Connections()
    self:SetupPresets()
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

    ContextAction:BindAction("Previous", Section, false, Enum.KeyCode.ButtonL1)
    ContextAction:BindAction("Next", Section, false, Enum.KeyCode.ButtonR1)

    --Exit Button
    self.ExitBtn = self.EscapeUI.Activated:Connect(function()
        Exit("Exit", Enum.UserInputState.Begin)
    end)

    ContextAction:BindAction("Exit", Exit, false, Enum.KeyCode.ButtonB)

    --RGB Buttons
    local rgbConnects = {}
    for btnId, button in self.rgbButtons do
        rgbConnects[btnId] = button.Activated:Connect(function()
            if self.currentRGB then
                self.currentRGB.TextColor3 = self.nonSelectionColor
            end

            self.currentRGB = button
            self.currentRGB.TextColor3 = self.selectionColor

            self.currentSlider = self.rgbSliders[btnId]
        end)
    end
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
                print("Color:", newColor)
            end)

            self.PresetColors[tostring(newColor)] = {
                Color = newColor,
                Button = newUI,
                connection = connection
            }
        end
    end
end

function ColorSelectionSystem:SetColor(Color)
    self.ColorIcon.BackgroundColor3 = Color

    warn("Set Color for Section:", self.currentSection, Color)

    --Event to fire to server to change color value
end

function ColorSelectionSystem:Update(deltaTime)
   
end

return ColorSelectionSystem