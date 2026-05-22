local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))

local ColorSelectionSystem = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("UI"):WaitForChild("ColorSelectionSystem"))
local GameplayUI = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("UI"):WaitForChild("GameplayUI"))
local SettingsUI = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("UI"):WaitForChild("SettingsUI"))

local TestState = workspace:GetAttribute("TestState")

local InputActions = ReplicatedStorage:WaitForChild("Inputs")
local GameplayActions: InputContext = InputActions:WaitForChild("Gameplay")
local UIActions: InputContext = InputActions:WaitForChild("UI")

local UIController = {}
UIController.__index = UIController

function UIController.new()
    local newUI = {}
    setmetatable(newUI, UIController)

    return newUI
end

function UIController:Init(player, character, animationSystem, cameraSystem, ceremonySystem)
    self.player = player
    self.character = character
    self.humanoid = character:WaitForChild("Humanoid")
    self.rootPart = character:WaitForChild("HumanoidRootPart")

    self.animationSystem = animationSystem
    self.cameraSystem = cameraSystem
    self.ceremonySystem = ceremonySystem

    self.HUD = self.player:WaitForChild("PlayerGui"):WaitForChild("HUD")
    self.HUD.Enabled = true

    self.Indicator = self.HUD:WaitForChild("Indicator")
    self.Leaderboard = self.HUD:WaitForChild("Leaderboard")
    self.Settings = self.HUD:WaitForChild("Settings")
    self.GameplayMobile = self.HUD:WaitForChild("GameplayMobile")

    self.gameplayUI = GameplayUI.new(player, character, self, self.HUD, animationSystem, cameraSystem)
    self.settingsUI = SettingsUI.new(player, character, self.Settings, self.GameplayMobile)

    self.IndicatorMenu = self.Indicator:WaitForChild("Menu")
    self.IndicatorContext = self.IndicatorMenu:WaitForChild("Context")
    self.IndicatorTimer = self.IndicatorMenu:WaitForChild("Timer")

    self.IndicatorTeam = self.Indicator:WaitForChild("TeamDeath")
    self.IndicatorRedCount = self.IndicatorTeam:WaitForChild("RedCount")
    self.IndicatorBlueCount = self.IndicatorTeam:WaitForChild("BlueCount")

    self.HolderFrame = self.Leaderboard:WaitForChild("Holder")
    self.LeaderClose = self.Leaderboard:WaitForChild("CloseButton")
    self.hideLeaderboard = false
    self.hideTween = nil
    self.hideTween2 = nil

    self.SettingsHolder = self.Settings:WaitForChild("Background")
    self.hideSettings = false
    self.hideSetTween = nil
    self.SettingsHolder.Position = UDim2.fromScale(-2, 0.65)
    self.SettingsHolder.Visible = true

    self.Winnerboard = self.HUD:WaitForChild("Winnerboard")
    self.Winnerboard.Visible = false
    self.Winnerboard.GroupTransparency = 1

    self.Debugger = self.HUD:WaitForChild("Debugger")
    self.Debugger.Visible = false
    self.TokenBtn = self.Debugger:WaitForChild("Tokens")
    self.KillBtn = self.Debugger:WaitForChild("Kills")
    self.WinBtn = self.Debugger:WaitForChild("Wins")

    self.colorSystem = ColorSelectionSystem.new(self.HUD.ColorIndicator, self, self.player, workspace:WaitForChild("ColorBoard"))

    self.placementUI = {
        [1] = self.Winnerboard:WaitForChild("First"),
        [2] = self.Winnerboard:WaitForChild("Second"),
        [3] = self.Winnerboard:WaitForChild("Third"),
    }

    if TestState then
        self.Debugger.Visible = true
        self:SetupTestConnect()
    end

    self:StatConnect()
    self:Connect()
end

function UIController:SetupTestConnect()
    self.tokenInput = self.TokenBtn.MouseButton1Click:Connect(function()
        local feedback = Events.Client_Server.Debugger:InvokeServer("Tokens")
        --warn("Feedback:", feedback)
    end)

    self.killInput = self.KillBtn.MouseButton1Click:Connect(function()
        local feedback = Events.Client_Server.Debugger:InvokeServer("Kills")
        --warn("Feedback:", feedback)
    end)

    self.winInput = self.WinBtn.MouseButton1Click:Connect(function()
        local feedback = Events.Client_Server.Debugger:InvokeServer("Wins")
        --warn("Feedback:", feedback)
    end)
end

function UIController:StatConnect()
    self.statsFolder = self.character:FindFirstChild("Stats")
    if not self.statsFolder then
        return
    end

    --toggle dummy Overhead
    for _, dummy in pairs(workspace.Dummies:GetChildren()) do
        local targetUI = dummy:FindFirstChild("Overhead")
        if not targetUI then
            continue
        end

        local statusUI = dummy:FindFirstChild("StatusUI")
        if not statusUI then
            continue
        end

        if targetUI.Enabled == true then
            targetUI.Enabled = false
        end

        if statusUI.Enabled == true then
            statusUI.Enabled = false
        end

        task.delay(.15, function()
            targetUI.Enabled = true
            statusUI.Enabled = true
        end)
    end
end

function UIController:HideLeaderboard()
    local info = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    self.hideLeaderboard = not self.hideLeaderboard

    local Goal1, Goal2 = {}, {}
    if self.hideLeaderboard then
        if TestState then
            self.Debugger.Visible = false
        end

        Goal1 = {Position = UDim2.fromScale(2, 0.5)}
        Goal2 = {Position = UDim2.fromScale(1, 0)}
    elseif not self.hideLeaderboard then
        if TestState then
            self.Debugger.Visible = true
        end

        Goal1 = {Position = UDim2.fromScale(0.5, 0.5)}
        Goal2 = {Position = UDim2.fromScale(0.02, 0)}
    end

    if self.hideTween then
        self.hideTween:Pause()
    end

    if self.hideTween2 then
        self.hideTween2:Pause()
    end

    self.hideTween = TweenService:Create(self.HolderFrame, info, Goal1)
    self.hideTween:Play()

    self.hideTween2 = TweenService:Create(self.LeaderClose, info, Goal2)
    self.hideTween2:Play()
end

function UIController:HideSettings()
    local info = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    self.hideSettings = not self.hideSettings

    local Goal1 = {}
    if self.hideSettings then
        Goal1 = {Position = UDim2.fromScale(0, 0.65)}
        elseif not self.hideSettings then
        Goal1 = {Position = UDim2.fromScale(-2, 0.65)}
    end

    if self.hideSetTween then
        self.hideSetTween:Pause()
    end

    self.hideSetTween = TweenService:Create(self.SettingsHolder, info, Goal1)
    self.hideSetTween:Play()
end

function UIController:DisplayWinners(rewardData, rewardCount)
    for placement, UI in pairs(self.placementUI) do
        if placement <= rewardCount then
            UI.Visible = true
        else
            UI.Visible = false
        end
    end

    --[==[self.Winnerboard.Visible = true
    local info =TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(self.Winnerboard, info, {GroupTransparency = 0}):Play()

    for placement, data in pairs(rewardData) do
        local copyCharacter = data.character:Clone()

        local currentUI = self.placementUI[placement]
        if not currentUI then
            continue
        end

        local viewPort = currentUI:FindFirstChild("ViewportFrame")
        if not viewPort then
            continue
        end

        local PlaceHolder = viewPort:FindFirstChild("PlaceHolder")
        if PlaceHolder then
            PlaceHolder:Destroy()
        end

        copyCharacter.Parent = viewPort
        copyCharacter:PivotTo(CFrame.new(0, 0, 0))

        viewPort.PlayerName.Text = data.playerName
        viewPort.Tokens.Text = "Tokens - ".. data.tokens
        viewPort.Kills.Text = "Kills - "..data.kills
    end

    task.delay(3, function()
        TweenService:Create(self.Winnerboard, info, {GroupTransparency = 1}):Play()
        task.delay(.25, function()
            self.Winnerboard.Visible = false
        end)
    end)]==]
end

function UIController:ShowInputButtons(inputType: string)
    local keyboardUI = CollectionService:GetTagged("PC")
    local controllerUI = CollectionService:GetTagged("Controller")

    if inputType == "Keyboard" then
        for _, obj in pairs(keyboardUI) do
            obj.Visible = true
        end

        for _, obj in pairs(controllerUI) do
            obj.Visible = false
        end
    elseif inputType == "Controller" then
        for _, obj in pairs(keyboardUI) do
            obj.Visible = false
        end

        for _, obj in pairs(controllerUI) do
            obj.Visible = true
        end
    elseif inputType == "Mobile" then
        for _, obj in pairs(keyboardUI) do
            obj.Visible = false
        end

        for _, obj in pairs(controllerUI) do
            obj.Visible = false
        end
    end
end

function UIController:Connect()
    self.input = UIActions.Leaderboard.Pressed:Connect(function()
        self:HideLeaderboard()
    end)

    self.input2 = UIActions.Settings.Pressed:Connect(function()
        self:HideSettings()
    end)

    self.countDownEvent = Events.Server_Client.CountDown.OnClientEvent:Connect(function(context, countDown)
        if not context then
            return
        end

        if not countDown then
            return
        end

        if context == "Ceremony" then
            self.Indicator.Visible = false
        else
            self.Indicator.Visible = true
        end

        self.IndicatorContext.Text = context

        local min = math.floor(countDown / 60)
        local sec = countDown % 60
        local formattedTime = string.format("%i:%02i", min, sec)

        self.IndicatorTimer.Text = formattedTime
    end)

    self.scoreCount = Events.Server_Client.ScoreCount.OnClientEvent:Connect(function(context, scoreData)
        if context == "Team Death Match" then
            local redTeam = scoreData.Red
            local blueTeam = scoreData.Blue

            self.IndicatorRedCount.Text = tostring(redTeam)
            self.IndicatorBlueCount.Text = tostring(blueTeam)
        else
            --any other gamemode in the future
        end
    end)

    self.toggleUI = Events.Server_Client.ToggleUI.OnClientEvent:Connect(function(context)
        if context == "Team Death Match" then
            self.IndicatorTeam.Visible = true
        elseif context == "Free For All" then
            self.IndicatorTeam.Visible = false
        end
    end)

    self.rewardsEvent = Events.Server_Client.Rewards.OnClientEvent:Connect(function(rewardData, rewardCount)
        self:DisplayWinners(rewardData, rewardCount)
    end)

    self.ceremonyEvent = Events.Server_Client.Ceremony.OnClientEvent:Connect(function(ceremonyType, enable, playerList)
        self.ceremonySystem:ToggleCeremony(ceremonyType, enable, playerList)
    end)
end

function UIController:LoadCharacter(class)
    if self.gameplayUI then
        self.gameplayUI:LoadCharacter(class)
    end
end

function UIController:Disconnect()
    if self.gameplayUI then
        self.gameplayUI:Disconnect()
    end

    if self.settingsUI then
        self.settingsUI:Disconnect()
    end

    if self.colorSystem then
        self.colorSystem:Disconnect()
    end

    if self.input then
        self.input:Disconnect()
        self.input = nil
    end

    if self.input2 then
        self.input2:Disconnect()
        self.input2 = nil
    end

    if self.cooldownEvent then
        self.cooldownEvent:Disconnect()
        self.cooldownEvent = nil
    end

    if self.countDownEvent then
        self.countDownEvent:Disconnect()
        self.countDownEvent = nil
    end

    if self.rewardsEvent then
        self.rewardsEvent:Disconnect()
    end

    if self.animationEvent then
        self.animationEvent:Disconnect()
    end
end

function UIController:Update(deltaTime)
    self.gameplayUI:Update(deltaTime)
    self.settingsUI:Update(deltaTime)
    self.colorSystem:Update(deltaTime)

    --constant check for new players
    if self.colorSystem.isActive then
        local blackList = {
            ["Main"] = true,
            ["Handle1"] = true,
            ["Handle2"] = true,
        }
        for _, plr in pairs(Players:GetPlayers()) do
            local character = plr.Character
            if character ~= self.character then
                for _, object in pairs(character:GetDescendants()) do
                    if object:IsA("BasePart") and object ~= character.PrimaryPart and not blackList[object.Name] then
                        object.Transparency = 1
                    elseif object:IsA("BillboardGui") then
                        object.Enabled = false
                    end
                end
            end
        end
    end

    local Overhead: BillboardGui = self.character:FindFirstChild("Overhead")
    if Overhead then
        if Overhead.Enabled then
            Overhead.Enabled = false
        end
    end

    local StatusUI: BillboardGui = self.character:FindFirstChild("StatusUI")
    if StatusUI then
        StatusUI.Enabled = true
    end

    --toggle player Overhead
    for _, player in pairs(Players:GetChildren()) do
        local character = player.Character
        if not character then
            continue
        end

        local targetUI = character:FindFirstChild("Overhead")
        if not targetUI then
            continue
        end

        local targetUI2 = character:FindFirstChild("StatusUI")
        if not targetUI2 then
            continue
        end

        if character == self.character then
            continue
        end

        local Stats = character:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        if Stats:GetAttribute("HideUI") then
            continue
        end

        targetUI.Enabled = true
        targetUI2.Enabled = true
    end

    --toggle dummy Overhead
    for _, character in pairs(workspace.Dummies:GetChildren()) do
        local targetUI = character:FindFirstChild("Overhead")
        if not targetUI then
            continue
        end

        local targetUI2 = character:FindFirstChild("StatusUI")
        if not targetUI2 then
            continue
        end

        if character == self.character then
            continue
        end

        local Stats = character:FindFirstChild("Stats")
        if not Stats then
            continue
        end

        if Stats:GetAttribute("HideUI") then
            continue
        end

        targetUI.Enabled = true
        targetUI2.Enabled = true
    end
end

return UIController