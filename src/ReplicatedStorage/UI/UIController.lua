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

local TestState = workspace:GetAttribute("TestState")

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
    self.IndicatorMenu = self.Indicator:WaitForChild("Menu")
    self.IndicatorContext = self.IndicatorMenu:WaitForChild("Context")
    self.IndicatorTimer = self.IndicatorMenu:WaitForChild("Timer")

    self.IndicatorTeam = self.Indicator:WaitForChild("TeamDeath")
    self.IndicatorRedCount = self.IndicatorTeam:WaitForChild("RedCount")
    self.IndicatorBlueCount = self.IndicatorTeam:WaitForChild("BlueCount")

    self.Gameplay = self.HUD:WaitForChild("Gameplay")
    self.MoveList = self.Gameplay:WaitForChild("MoveList")
    self.Stats = self.Gameplay:WaitForChild("Stats")

    self.HealthBar = self.Stats:WaitForChild("Health")
    self.DefenseBar = self.Stats:WaitForChild("Defense")

    self.Leaderboard = self.HUD:WaitForChild("Leaderboard")
    self.HolderFrame = self.Leaderboard:WaitForChild("Holder")
    self.hideLeaderboard = false
    self.hideTween = nil

    self.Winnerboard = self.HUD:WaitForChild("Winnerboard")
    self.Winnerboard.Visible = false
    self.Winnerboard.GroupTransparency = 1

    self.Debugger = self.HUD:WaitForChild("Debugger")
    self.Debugger.Visible = false
    self.TokenBtn = self.Debugger:WaitForChild("Tokens")
    self.KillBtn = self.Debugger:WaitForChild("Kills")
    self.WinBtn = self.Debugger:WaitForChild("Wins")

    self.ColorBoard = workspace:WaitForChild("ColorBoard")
    self.ColorBound = self.ColorBoard:WaitForChild("Bound")
    self.CameraPivot = self.ColorBoard:WaitForChild("CameraPivot")
    self.ColorPad = self.ColorBoard:WaitForChild("Pad1")
    self.ColorPad2 = self.ColorBoard:WaitForChild("Pad2")

    self.ColorUI = player:WaitForChild("PlayerGui"):WaitForChild("ColorUI")
    self.ColorUI.Enabled = false
    self.colorSystem = ColorSelectionSystem.new(self.ColorUI, self, self.player)

    self.disableColor = false
    self.SelectingColor = false

    self.placementUI = {
        [1] = self.Winnerboard:WaitForChild("First"),
        [2] = self.Winnerboard:WaitForChild("Second"),
        [3] = self.Winnerboard:WaitForChild("Third"),
    }

    self.Btns = {
        LMBMove = self.MoveList:WaitForChild("LMB_Btn"),
        QMove = self.MoveList:WaitForChild("Q_Btn"),
        EMove = self.MoveList:WaitForChild("E_Btn"),
        FMove = self.MoveList:WaitForChild("F_Btn"),
    }

    self.UICooldowns = {}

    self.LMBs = 0
    self.maxCount = 3
    self.currTime = 0
    self.prevTime = 0

    self.debounces = {
        Block = false,
        LMBMove = false,
        QMove = false,
        EMove = false,
        FMove = false,
    }

    if TestState then
        self.Debugger.Visible = true
        self:SetupTestConnect()
    end

    self:UISetup()
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

function UIController:UISetup()
    for btnName, btn in pairs(self.Btns) do
        local Cooldown = btn:FindFirstChild("Cooldown")
        if Cooldown then
            Cooldown.Visible = false
        end
    end
end

function UIController:toggleUICountdown(moveType, duration)
    if self.UICooldowns[moveType] then
        warn("already in cooldown")
        return
    end

    self.UICooldowns[moveType] = {
        UIObject = self.Btns[moveType],
        CooldownUI = self.Btns[moveType]:FindFirstChild("Cooldown"),
        duration = duration,
        maxDuration = duration,
        MoveName = self.Btns[moveType]:FindFirstChild("MoveName"),
    }

    local Left = self.Btns[moveType]:FindFirstChild("Left")
    local Right = self.Btns[moveType]:FindFirstChild("Right")
    local Layer3 = self.Btns[moveType]:FindFirstChild("Layer3")
    if Left and Right and Layer3 then
        Left.Layer.ImageColor3 = Color3.fromRGB(255, 0, 0)
        Right.Layer.ImageColor3 = Color3.fromRGB(255, 0, 0)
        Layer3.Visible = true
    end
    
    self.UICooldowns[moveType].MoveName.TextTransparency = 0.5
    self.UICooldowns[moveType].CooldownUI.Text = duration
    self.UICooldowns[moveType].CooldownUI.Visible = true
end

function UIController:removeUICountdown(moveType)
    if not self.UICooldowns[moveType] then
        warn("not in cooldown")
        return
    end

    local Left = self.Btns[moveType]:FindFirstChild("Left")
    local Right = self.Btns[moveType]:FindFirstChild("Right")
    local Layer3 = self.Btns[moveType]:FindFirstChild("Layer3")
    if Left and Right and Layer3 then
        Left.Layer.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Right.Layer.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Layer3.Visible = false
    end

    self.UICooldowns[moveType].CooldownUI.Visible = false
    self.UICooldowns[moveType].MoveName.TextTransparency = 0
    self.UICooldowns[moveType] = nil
end

function UIController:StatConnect()
    self.statsFolder = self.character:FindFirstChild("Stats")
    if not self.statsFolder then
        return
    end

    local HealthDisplay = self.HealthBar:FindFirstChild("Display")
    local HealthLeft = self.HealthBar:FindFirstChild("Left")
    local HealthRight = self.HealthBar:FindFirstChild("Right")

    local DefenseDisplay = self.DefenseBar:FindFirstChild("Display")
    local DefenseLeft = self.DefenseBar:FindFirstChild("Left")
    local DefenseRight = self.DefenseBar:FindFirstChild("Right")

    if HealthDisplay and HealthLeft and HealthRight then
        --First Time Set
        local health = self.statsFolder:GetAttribute("Health")
        local maxHealth = self.statsFolder:GetAttribute("MaxHealth")

        HealthDisplay.Text = health.." / "..maxHealth
        
        self.healthDisplay = self.humanoid.HealthChanged:Connect(function()
            health = self.statsFolder:GetAttribute("Health")
            maxHealth = self.statsFolder:GetAttribute("MaxHealth")

            HealthDisplay.Text = math.floor(health).." / "..math.floor(maxHealth)

            local percentage = 1 - (health / maxHealth)
            
            local rotation = percentage * 360
            if rotation > 180 then
                HealthLeft.Visible = false
            else
                HealthLeft.Visible = true
            end

            HealthLeft.Layer.UIGradient.Rotation = math.clamp(rotation, 0, 180)
            HealthRight.Layer.UIGradient.Rotation = math.clamp(rotation, 180, 360)
        end)
    end

    if DefenseDisplay and DefenseLeft and DefenseRight then
        --First Time Set
        local defense = self.statsFolder:GetAttribute("Defense")
        local maxDefense = self.statsFolder:GetAttribute("MaxDefense")

        DefenseDisplay.Text = defense.." / "..maxDefense

        self.defenseDisplay = self.statsFolder:GetAttributeChangedSignal("Defense"):Connect(function()
            defense = self.statsFolder:GetAttribute("Defense")
            maxDefense = self.statsFolder:GetAttribute("MaxDefense")

            DefenseDisplay.Text = math.floor(defense).." / "..math.floor(maxDefense)

            local percentage = 1 - (defense / maxDefense)
            
            local rotation = percentage * 360
            if rotation > 180 then
                DefenseLeft.Visible = false
            else
                DefenseLeft.Visible = true
            end

            DefenseLeft.Layer.UIGradient.Rotation = math.clamp(rotation, 0, 180)
            DefenseRight.Layer.UIGradient.Rotation = math.clamp(rotation, 180, 360)
        end)
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
    local info = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    if not self.hideLeaderboard then
        self.hideLeaderboard = true

        if self.hideTween then
            self.hideTween:Pause()
        end

        if TestState then
            self.Debugger.Visible = false
        end

        self.hideTween = TweenService:Create(self.Leaderboard, info, {Position = UDim2.new(1.25, 0, .5, 0)})
        self.hideTween:Play()
    elseif self.hideLeaderboard then
        self.hideLeaderboard = false

        if self.hideTween then
            self.hideTween:Pause()
        end

        if TestState then
            self.Debugger.Visible = true
        end

        self.hideTween = TweenService:Create(self.Leaderboard, info, {Position = UDim2.new(1, 0, .5, 0)})
        self.hideTween:Play()
    end
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

function UIController:LockInPlace(noMovement, moveType)
    if noMovement then
        local animationLength = self.animationSystem:animInfo(self.class, moveType)

        if self.rootPart:FindFirstChild("noMovement") then
            self.rootPart:FindFirstChild("noMovement"):Destroy()
        end
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "noMovement"
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = self.rootPart
        Debris:AddItem(bodyVelocity, animationLength)
    end
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

function UIController:Connect()
    self.inputChange = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
        if keyboardOptions[input.UserInputType] then
            self:ShowInputButtons("Keyboard")
        elseif controllerOptions[input.UserInputType] or controllerOptions[input.KeyCode] then
            self:ShowInputButtons("Controller")
        elseif mobileOptions[input.UserInputType] then
            self:ShowInputButtons("Mobile")
        end
    end)

    local percentage = 0
    local min = 0
    local testCooldown = false
    RunService.Heartbeat:Connect(function(deltaTime)
        if testCooldown then
            percentage -= deltaTime * 2
            percentage = math.clamp(percentage, min, 100)

            self.TestCooldownUI.Text = math.floor(percentage)

            local rotation = math.floor(math.clamp(percentage * 3.6, 0, 360))
            self.TestLeftUI.Rotation = math.clamp(rotation, 0, 180)
            self.TestRightUI.Rotation = math.clamp(rotation, 180, 360)

            if percentage <= min then
                testCooldown = false
                self.TestCooldownUI.Visible = false
                self.TestLeftLayer.ImageColor3 = Color3.fromRGB(255, 255, 255)
                self.TestLeftLayer2.ImageColor3 = Color3.fromRGB(255, 255, 255)
                --self.TestButtonsUI.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end)

    self.testHealthSlots = {}
    self.input = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.P then
            percentage = 100
            min = 0
            testCooldown = true
            self.TestCooldownUI.Visible = true
            self.TestLeftLayer.ImageColor3 = Color3.fromRGB(255, 0, 0)
            self.TestLeftLayer2.ImageColor3 = Color3.fromRGB(255, 0, 0)
            --self.TestButtonsUI.ImageColor3 = Color3.fromRGB(255, 0, 0)
        end

        if self.SelectingColor then
            return
        end

        if gameProcessedEvent then
            return
        end

        if input.KeyCode == Enum.KeyCode.Tab then
            self:HideLeaderboard()
        end

        if not self.class then
            return
        end

        if self.statsFolder:GetAttribute("Stunned") and self.statsFolder:GetAttribute("Stunned") == true then
            return
        end

        if self.statsFolder:GetAttribute("Blocking") and self.statsFolder:GetAttribute("Blocking") == true then
            return
        end

        if input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.ButtonL1 then
            if self.debounces.Block then
                return
            end

            local canBlock = Events.Client_Server.Input:InvokeServer(self.class, "Block")
            if canBlock then
                self.debounces.Block = true

                --self.cameraSystem:OutsideToggle(true)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = false,
                    loop = true
                }
                self.animationSystem:Play(self.class, "Block", nil, conditionalData)
            end
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR1 then
            if self.debounces.LMBMove then
                return
            end

            self.currTime = os.clock()

            self.LMBs += 1
            if self.LMBs > self.maxCount then
                self.LMBs = 1
            end

            if self.currTime - self.prevTime >= 1.5 then
                self.LMBs = 1
            end

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "LMBMove", self.LMBs)
            if canAttack then
                self.debounces.LMBMove = true
                local currentClassData = ClassData[self.class]
                
                local cooldownDuration = currentClassData.Cooldowns["LMBMove"]

                if self.LMBs >= 3 and not currentClassData.MoveData.LMBMove.ignoreLMBMoveCD then
                    cooldownDuration = 1
                end
                
                self:toggleUICountdown("LMBMove", cooldownDuration)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                    weight = 2,
                }

                local function hitBoxCallBack()
                    if not currentClassData then
                        return
                    end

                    local moveData = currentClassData.MoveData

                    local currentMoveData = moveData.LMBMove

                    if currentMoveData.CameraLock then
                        self.cameraSystem:OutsideToggle(true)
                    end

                    Events.Client_Server.Hitbox:FireServer(self.class, "LMBMove", self.LMBs, currentMoveData)
                end

                self.animationSystem:Play(self.class, "LMBMove", self.LMBs, conditionalData, hitBoxCallBack, true)
            elseif not canAttack then
                self.LMBs -= 1
                self.LMBs = math.clamp(self.LMBs, 0, 3)
            end
        end

        if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonX then
            if self.debounces.QMove then
                return
            end

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "QMove")
            if canAttack then
                self.debounces.QMove = true
                local currentClassData = ClassData[self.class]
                
                local cooldownDuration = currentClassData.Cooldowns["QMove"]
                if currentClassData.MoveData["QMove"].DoubleCooldown then
                    if self.character:GetAttribute("DoubleCooldown") == "QMove" then
                        cooldownDuration = cooldownDuration[2]
                    else
                        cooldownDuration = cooldownDuration[1]
                    end
                end

                if workspace:GetAttribute("NoCooldowns") then
                    cooldownDuration = 1
                end

                self:toggleUICountdown("QMove", cooldownDuration)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                local function hitBoxCallBack()
                    if not currentClassData then
                        return
                    end

                    local moveData = currentClassData.MoveData

                    local currentMoveData = moveData.QMove

                    Events.Client_Server.Moves:FireServer(self.class, "QMove", currentMoveData)
                end

                local hasEvent = currentClassData.MoveData.QMove.hasEvent
                local noMovement = currentClassData.MoveData.QMove.noMovement
                self:LockInPlace(noMovement, "QMove")

                self.animationSystem:Play(self.class, "QMove", nil, conditionalData, hitBoxCallBack, hasEvent)
            end
        end

        if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonY then
            if self.debounces.EMove then
                return
            end

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "EMove")
            if canAttack then
                self.debounces.EMove = true
                local currentClassData = ClassData[self.class]
                
                local animationName = "EMove"
                local cooldownDuration = currentClassData.Cooldowns["EMove"]
                if currentClassData.MoveData["EMove"].DoubleCooldown then
                    if self.character:GetAttribute("DoubleCooldown") == "EMove" then
                        cooldownDuration = cooldownDuration[2]
                    else
                        cooldownDuration = cooldownDuration[1]
                    end
                    
                    local Stats = self.character:FindFirstChild("Stats")
                    if Stats and Stats:GetAttribute("Awakened") then
                        animationName = "EMove2"
                    end
                end

                if workspace:GetAttribute("NoCooldowns") then
                    cooldownDuration = 1
                end

                self:toggleUICountdown("EMove", cooldownDuration)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                local function hitBoxCallBack()
                    if not currentClassData then
                        return
                    end

                    local moveData = currentClassData.MoveData

                    local currentMoveData = moveData.EMove

                    Events.Client_Server.Moves:FireServer(self.class, "EMove", currentMoveData)
                end

                local hasEvent = currentClassData.MoveData.EMove.hasEvent
                local noMovement = currentClassData.MoveData.EMove.noMovement
                self:LockInPlace(noMovement, "EMove")

                self.animationSystem:Play(self.class, animationName, nil, conditionalData, hitBoxCallBack, hasEvent)
            end
        end

        if input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonB then
            if self.debounces.FMove then
                return
            end

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "FMove")
            if canAttack then

                self.debounces.FMove = true
                local currentClassData = ClassData[self.class]
                
                local cooldownDuration = currentClassData.Cooldowns["FMove"]
                if currentClassData.MoveData["FMove"].DoubleCooldown then
                    if self.character:GetAttribute("DoubleCooldown") == "FMove" then
                        cooldownDuration = cooldownDuration[2]
                    else
                        cooldownDuration = cooldownDuration[1]
                    end
                end

                if workspace:GetAttribute("NoCooldowns") then
                    cooldownDuration = 1
                end
                
                self:toggleUICountdown("FMove", cooldownDuration)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                local function hitBoxCallBack()
                    if not currentClassData then
                        return
                    end

                    local moveData = currentClassData.MoveData

                    local currentMoveData = moveData.FMove

                    Events.Client_Server.Moves:FireServer(self.class, "FMove", currentMoveData)
                end

                local hasEvent = currentClassData.MoveData.FMove.hasEvent
                local noMovement = currentClassData.MoveData.FMove.noMovement
                self:LockInPlace(noMovement, "FMove")

                self.animationSystem:Play(self.class, "FMove", nil, conditionalData, hitBoxCallBack, hasEvent)
            end
        end
    end)

    self.input2 = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if self.SelectingColor then
            return
        end

        if not self.class then
            return
        end

        if input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.ButtonL1 then
            if not self.debounces.Block then
                return
            end
    
            local canBlock = Events.Client_Server.Input:InvokeServer(self.class, "Block")
            if canBlock then
                self.debounces.Block = false

                self.animationSystem:Stop(self.class, "Block")
            end
        end
    end)

    self.cooldownEvent = Events.Server_Client.Cooldown.OnClientEvent:Connect(function(moveType)
        if moveType == "LMBMove" then
            self.prevTime = self.currTime
            self.debounces.LMBMove = false
        end

        if moveType == "Block" then
            self.animationSystem:Stop(self.class, "Block")
        end

        if moveType == "QMove" then
            self.debounces.QMove = false
        end

        if moveType == "EMove" then
            self.debounces.EMove = false
        end

        if moveType == "FMove" then
            self.debounces.FMove = false
        end
    end)

    self.teleportDisable = Events.Server_Client.teleportDisable.OnClientEvent:Connect(function()
        self.disableColor = true
        self:ToggleColorCamera(false, nil, true)
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

    self.animationEvent = Events.Server_Client.AnimationSystem.OnClientEvent:Connect(function(data, moveType)
        if data == "Cancel" then
            self.animationSystem:Stop(self.class, moveType)
        end
    end)

    self.ceremonyEvent = Events.Server_Client.Ceremony.OnClientEvent:Connect(function(ceremonyType, enable, playerList)
        self.ceremonySystem:ToggleCeremony(ceremonyType, enable, playerList)
    end)
end

function UIController:ToggleColorCamera(toggle: boolean, cameraPivot: BasePart, ignoreTeleport: boolean)
    if toggle then
        if self.Gameplay.Visible == true then
            self.Gameplay.Visible = false
        end

        if self.Leaderboard.Visible == true then
            self.Leaderboard.Visible = false
        end

        self.ColorUI.Enabled = true
        self.colorSystem.isActive = true

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

        self.rootPart.Anchored = true
        if not ignoreTeleport then
            self.character:PivotTo(self.ColorPad2.CFrame)
        end
    elseif not toggle then
        if self.Gameplay.Visible == false then
            self.Gameplay.Visible = true
        end

        if self.Leaderboard.Visible == false then
            self.Leaderboard.Visible = true
        end

        self.ColorUI.Enabled = false
        self.colorSystem.isActive = false

        GuiService.SelectedObject = nil

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
                        object.Transparency = 0
                    elseif object:IsA("BillboardGui") then
                        object.Enabled = true
                    end
                end
            end
        end

        self.rootPart.Anchored = false
        if not ignoreTeleport then
            self.character:PivotTo(self.ColorPad.CFrame)
        end

        task.delay(1, function()
            self.SelectingColor = false
        end)
    end
    
    self.cameraSystem:ToggleColorCamera(toggle, cameraPivot)
end

function UIController:InColorBound()
    if self.disableColor then
        return
    end

    local overlap = OverlapParams.new()
    overlap.FilterDescendantsInstances = {self.character}
    overlap.FilterType = Enum.RaycastFilterType.Include

    local partList = workspace:GetPartsInPart(self.ColorBound)

    for _, object in partList do
        if object:IsA("BasePart") then
            local objectParent = object:FindFirstAncestorOfClass("Model")
            if not objectParent then
                continue
            end

            local humanoid = objectParent:FindFirstChild("Humanoid")
            if not humanoid then
                continue
            end

            local rootPart = objectParent:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                continue
            end

            if self.SelectingColor then
                continue
            end

            if objectParent ~= self.character then
                continue
            end

            self.SelectingColor = true

            self:ToggleColorCamera(true, self.CameraPivot)

            break
        end
    end
end

function UIController:LoadCharacter(class)
    self.class = class

    --set icons for moves
    self.animationSystem:ChangeClass(class)

    local currentClassData = ClassData[self.class]

    for btnName, btn in pairs(self.Btns) do
        local MoveName = btn:FindFirstChild("MoveName")
        if MoveName then
            local moveText = currentClassData.MoveName[btnName]
            if typeof(moveText) == "table" then
                moveText = moveText[1]
            end
            MoveName.Text = moveText
        end
    end
end

function UIController:UpdateUI()
    local Stats = self.character:FindFirstChild("Stats")
    if Stats then
        local isAwakened = Stats:GetAttribute("Awakened")

        if not self.class then
            return
        end

        local currentClassData = ClassData[self.class]
        if not currentClassData then
            return
        end

        for btnName, btn in pairs(self.Btns) do
            local MoveName = btn:FindFirstChild("MoveName")
            if MoveName then
                local moveText = currentClassData.MoveName[btnName]
                if typeof(moveText) == "table" then
                    if not isAwakened then
                        moveText = moveText[1]
                    elseif isAwakened then
                        moveText = moveText[2]
                    end
                end
                MoveName.Text = moveText
            end
        end
    end
end

function UIController:Disconnect()
    if self.healthDisplay then
        self.healthDisplay:Disconnect()
        self.healthDisplay = nil
    end

    if self.defenseDisplay then
        self.defenseDisplay:Disconnect()
        self.defenseDisplay = nil
    end

    if self.inputChange then
        self.inputChange:Disconnect()
        self.inputChange = nil
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

    if self.teleportDisable then
        self.teleportDisable:Disconnect()
        self.teleportDisable = nil
    end

    if self.rewardsEvent then
        self.rewardsEvent:Disconnect()
    end

    if self.animationEvent then
        self.animationEvent:Disconnect()
    end
end

function UIController:Update(deltaTime)
    self:UpdateUI()

    self:InColorBound()

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

    if not self.class then
        if self.SelectingColor then
            return
        end

        if self.Gameplay.Visible then
            self.Gameplay.Visible = false
        end
    elseif self.class then
        if self.SelectingColor then
            return
        end
        
        if not self.Gameplay.Visible then
            self.Gameplay.Visible = true
        end
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

    for moveType, UIData in pairs(self.UICooldowns) do
        local currentUIData = UIData
        if not currentUIData.CooldownUI then
            continue
        end

        if currentUIData.duration <= 0 then
            self:removeUICountdown(moveType)

            continue
        end 

        currentUIData.duration -= deltaTime
        currentUIData.duration = math.clamp(currentUIData.duration, 0, currentUIData.maxDuration)

        local durationText = string.format("%0.2f", currentUIData.duration)

        local Left = currentUIData.UIObject:FindFirstChild("Left")
        local Right = currentUIData.UIObject:FindFirstChild("Right")
        if Left and Right then
            local percentage = (currentUIData.duration / currentUIData.maxDuration)

            local rotation = percentage * 360
            if rotation > 180 then
                Left.Visible = false
            else
                Left.Visible = true
            end

            Left.Layer.UIGradient.Rotation = math.clamp(rotation, 0, 180)
            Right.Layer.UIGradient.Rotation = math.clamp(rotation, 180, 360)
        end

        currentUIData.CooldownUI.Text = durationText
    end

    local Stats = self.character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    --Silenced Icon on Moves UI
    local Silenced = Stats:GetAttribute("Silenced")

    for _, btn in pairs(self.Btns) do
        local silenceIcon: ImageLabel = btn:FindFirstChild("Silenced")
        if silenceIcon then
            silenceIcon.Visible = Silenced
        end
    end
end

return UIController