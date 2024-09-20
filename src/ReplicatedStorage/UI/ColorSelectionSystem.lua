local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ColorSelectionSystem = {}
ColorSelectionSystem.__index = ColorSelectionSystem

function ColorSelectionSystem.new(ColorUI)
    local newColorSelection = {}
    setmetatable(newColorSelection, ColorSelectionSystem)
    
    newColorSelection.ColorUI = ColorUI

    newColorSelection.selectionColor = Color3.fromRGB(255, 203, 80)

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

    self.rgbButtons = {
        [self.RBtn] = self.RBtn,
        [self.GBtn] = self.GBtn,
        [self.BBtn] = self.BBtn,
    }

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

function ColorSelectionSystem:Mouse_Touch_Setup()
    --section buttons
    self.prev_MT_Connect = self.SectionPrev.Activated:Connect(function()
        print("Prev Section")
    end)

    self.next_MT_Connect = self.SectionNext.Activated:Connect(function()
        print("Next Section")
    end)

    --rgb buttons
    local rgbConnects = {}
    for btnId, button in self.rgbButtons do
        rgbConnects[btnId] = button.Activated:Connect(function()
            print("Edit color for:", btnId)
        end)
    end
end

function ColorSelectionSystem:Controller_Setup()
    
end

function ColorSelectionSystem:Update(deltaTime)
    
end

return ColorSelectionSystem