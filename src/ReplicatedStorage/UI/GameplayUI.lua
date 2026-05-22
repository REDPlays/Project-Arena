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

local function CurrentDevice() : "PC" | "Console" | "Mobile"
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    end

    if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
        return "Console"
    end

    return "PC"
end

local function HoldButton()
    local isMouseClick = false
    local isConsoleClick = false
    local isMobile = false

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not UserInputService.TouchEnabled then
        isMouseClick = true
    end

    if UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR1) and not UserInputService.TouchEnabled then
        isConsoleClick = true
    end



    return isMouseClick or isConsoleClick
end

local GameplayUI = {}
GameplayUI.__index = GameplayUI

function GameplayUI.new(player: Player, character: Model, UIController, HUD: ScreenGui, animationSystem, cameraSystem)
    local self = setmetatable({}, GameplayUI)

    self.player = player
    self.character = character
    self.humanoid = character:WaitForChild("Humanoid")
    self.rootPart = character:WaitForChild("HumanoidRootPart")
    
    self.UIController = UIController
    self.animationSystem = animationSystem
    self.cameraSystem = cameraSystem

    self.HUD = HUD

    self.device = CurrentDevice()

    self.GameplayFrames = {
        ["PC"] = HUD:WaitForChild("Gameplay"),
        ["Console"] = HUD:WaitForChild("Gameplay"),
        ["Mobile"] = HUD:WaitForChild("GameplayMobile")
    }

    for _, frame: Frame in pairs(self.GameplayFrames) do
        frame.Visible = false
    end

    self.Gameplay = self.GameplayFrames[self.device]
    self.MoveList = self.Gameplay:WaitForChild("MoveList")
    self.Stats = self.Gameplay:WaitForChild("Stats")

    self.Btns = {
        LMBMove = self.MoveList.LMB_Btn,
        QMove = self.MoveList.Q_Btn,
        EMove = self.MoveList.E_Btn,
        FMove = self.MoveList.F_Btn,
    }

    self.HealthBar = self.Stats:WaitForChild("Health")
    self.DefenseBar = self.Stats:WaitForChild("Defense")

    self.Gameplay.Visible = true
    
    self.LMBs = 0
    self.maxCount = 3
    self.currTime = 0
    self.prevTime = 0
    
    self.UICooldowns = {}
    self.debounces = {
        Block = false,
        LMBMove = false,
        QMove = false, 
        EMove = false,
        FMove = false,
    }

    self:Init()

    return self
end

function GameplayUI:Init()
    self.statsFolder = self.character:FindFirstChild("Stats")

    self:Setup()
    self:StatConnect()
    self:Connect()
end

function GameplayUI:LoadCharacter(class)
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

function GameplayUI:Setup()
    for btnName, btn in pairs(self.Btns) do
        local Cooldown = btn:FindFirstChild("Cooldown")
        if Cooldown then
            Cooldown.Visible = false
        end
    end
end

function GameplayUI:ShowInputButtons(inputType: string)
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

function GameplayUI:LockInPlace(noMovement, moveType)
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

function GameplayUI:StatConnect()
    local HealthDisplay = self.HealthBar:FindFirstChild("DisplayTop")
    local HealthDisplay2 = self.HealthBar:FindFirstChild("DisplayBot")
    local HealthLeft = self.HealthBar:FindFirstChild("Left")
    local HealthRight = self.HealthBar:FindFirstChild("Right")

    local DefenseDisplay = self.DefenseBar:FindFirstChild("DisplayTop")
    local DefenseDisplay2 = self.DefenseBar:FindFirstChild("DisplayBot")
    local DefenseLeft = self.DefenseBar:FindFirstChild("Left")
    local DefenseRight = self.DefenseBar:FindFirstChild("Right")

    if HealthDisplay and HealthDisplay2 and HealthLeft and HealthRight then
        local health = self.statsFolder:GetAttribute("Health")
        local maxHealth = self.statsFolder:GetAttribute("MaxHealth")

        HealthDisplay.Text = health
        HealthDisplay2.Text = maxHealth
        
        self.healthDisplay = self.humanoid.HealthChanged:Connect(function()
            health = self.statsFolder:GetAttribute("Health")
            maxHealth = self.statsFolder:GetAttribute("MaxHealth")

            HealthDisplay.Text = math.floor(health)
            HealthDisplay2.Text = math.floor(maxHealth)

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

    if DefenseDisplay and DefenseDisplay2 and DefenseLeft and DefenseRight then
        local defense = self.statsFolder:GetAttribute("Defense")
        local maxDefense = self.statsFolder:GetAttribute("MaxDefense")

        DefenseDisplay.Text = defense
        DefenseDisplay2.Text = maxDefense

        self.defenseDisplay = self.statsFolder:GetAttributeChangedSignal("Defense"):Connect(function()
            defense = self.statsFolder:GetAttribute("Defense")
            maxDefense = self.statsFolder:GetAttribute("MaxDefense")

            DefenseDisplay.Text = math.floor(defense)
            DefenseDisplay2.Text = math.floor(maxDefense)

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
end

function GameplayUI:Connect()
    self.inputChange = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
        if keyboardOptions[input.UserInputType] then
            self:ShowInputButtons("Keyboard")
        elseif controllerOptions[input.UserInputType] or controllerOptions[input.KeyCode] then
            self:ShowInputButtons("Controller")
        elseif mobileOptions[input.UserInputType] then
            self:ShowInputButtons("Mobile")
        end
    end)

    self.input = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
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

        local isAwakened = self.statsFolder:GetAttribute("Awakened")

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

        if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonX then
            if self.debounces.QMove then
                return
            end

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "QMove")
            if canAttack then
                self.debounces.QMove = true
                local currentClassData = ClassData[self.class]

                local animationName = "QMove"
                
                local cooldownDuration = currentClassData.Cooldowns["QMove"]
                local DoubleCooldown

                local hasEvent
                if currentClassData.MoveData["QMove"][1] then
                    if isAwakened then
                        hasEvent = currentClassData.MoveData.QMove[2].hasEvent
                        DoubleCooldown = currentClassData.MoveData.QMove[2].DoubleCooldown
                    else
                        hasEvent = currentClassData.MoveData.QMove[1].hasEvent
                        DoubleCooldown = currentClassData.MoveData.QMove[1].DoubleCooldown
                    end
                else
                    hasEvent = currentClassData.MoveData.QMove.hasEvent
                    DoubleCooldown = currentClassData.MoveData.QMove.DoubleCooldown
                end

                if DoubleCooldown then
                    if self.character:GetAttribute("DoubleCooldown") == "QMove" then
                        cooldownDuration = cooldownDuration[2]
                    else
                        cooldownDuration = cooldownDuration[1]
                    end

                    if isAwakened then
                        animationName = "QMove2"
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

                local noMovement = currentClassData.MoveData.QMove.noMovement
                self:LockInPlace(noMovement, "QMove")

                self.animationSystem:Play(self.class, animationName, nil, conditionalData, hitBoxCallBack, hasEvent)
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
                local DoubleCooldown
                
                local hasEvent
                if currentClassData.MoveData["EMove"][1] then
                    if isAwakened then
                        hasEvent = currentClassData.MoveData.EMove[2].hasEvent
                        DoubleCooldown = currentClassData.MoveData.EMove[2].DoubleCooldown
                    else
                        hasEvent = currentClassData.MoveData.EMove[1].hasEvent
                        DoubleCooldown = currentClassData.MoveData.EMove[1].DoubleCooldown
                    end
                else
                    hasEvent = currentClassData.MoveData.EMove.hasEvent
                    DoubleCooldown = currentClassData.MoveData.EMove.DoubleCooldown
                end
                
                if DoubleCooldown then
                    if self.character:GetAttribute("DoubleCooldown") == "EMove" then
                        cooldownDuration = cooldownDuration[2]
                    else
                        cooldownDuration = cooldownDuration[1]
                    end
                    
                    if isAwakened then
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

                local animationName = "FMove"
                
                local cooldownDuration = currentClassData.Cooldowns["FMove"]
                local DoubleCooldown

                local hasEvent
                if currentClassData.MoveData["FMove"][1] then
                    if isAwakened then
                        hasEvent = currentClassData.MoveData.FMove[2].hasEvent
                        DoubleCooldown = currentClassData.MoveData.FMove[2].DoubleCooldown
                    else
                        hasEvent = currentClassData.MoveData.FMove[1].hasEvent
                        DoubleCooldown = currentClassData.MoveData.FMove[1].DoubleCooldown
                    end
                else
                    hasEvent = currentClassData.MoveData.FMove.hasEvent
                    DoubleCooldown = currentClassData.MoveData.FMove.DoubleCooldown
                end

                if DoubleCooldown then
                    if self.character:GetAttribute("DoubleCooldown") == "FMove" then
                        cooldownDuration = cooldownDuration[2]
                    else
                        cooldownDuration = cooldownDuration[1]
                    end

                    if isAwakened then
                        animationName = "FMove2"
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

                local noMovement = currentClassData.MoveData.FMove.noMovement
                self:LockInPlace(noMovement, "FMove")

                self.animationSystem:Play(self.class, animationName, nil, conditionalData, hitBoxCallBack, hasEvent)
            end
        end
    end)

    self.input2 = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
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
    
    self.cooldownEvent = Events.Server_Client.Cooldown.OnClientEvent:Connect(function(moveType: string, actionType: string)
        if actionType == "Single" then
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

        elseif actionType == "Multi" then
            moveType = moveType or {}

            for _, _moveType in ipairs(moveType) do
                if _moveType == "LMBMove" then
                    self.prevTime = self.currTime
                    self.debounces.LMBMove = false
                end
                
                if _moveType == "QMove" then
                    self.debounces.QMove = false
                end

                if _moveType == "EMove" then
                    self.debounces.EMove = false
                end

                if _moveType == "FMove" then
                    self.debounces.FMove = false
                end
                
                self:removeUICountdown(_moveType)
            end

        end
    end)

    self.animationEvent = Events.Server_Client.AnimationSystem.OnClientEvent:Connect(function(data, moveType: string)
        if data == "Cancel" then
            self.animationSystem:Stop(self.class, moveType)
        end
    end)
end

function GameplayUI:M1()
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

    self.debounces.LMBMove = true

    local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "LMBMove", self.LMBs)
    if canAttack then
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
        self.debounces.LMBMove = false
    end
end

function GameplayUI:MoveInput(moveType: string)
    
end

function GameplayUI:toggleUICountdown(moveType: string, duration: number)
    if self.UICooldowns[moveType] then
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

function GameplayUI:removeUICountdown(moveType: string)
    if not self.UICooldowns[moveType] then
        return
    end

    self.UICooldowns[moveType].duration = self.UICooldowns[moveType].maxDuration

    local Left = self.Btns[moveType]:FindFirstChild("Left")
    local Right = self.Btns[moveType]:FindFirstChild("Right")
    local Layer3 = self.Btns[moveType]:FindFirstChild("Layer3")
    if Left and Right and Layer3 then
        Left.Visible = true
        Left.Layer.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Left.Layer.UIGradient.Rotation = 0

        Right.Visible = true
        Right.Layer.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Right.Layer.UIGradient.Rotation = 180

        Layer3.Visible = false
    end
    
    self.UICooldowns[moveType].CooldownUI.Visible = false
    self.UICooldowns[moveType].MoveName.TextTransparency = 0
    self.UICooldowns[moveType] = nil
end

function GameplayUI:UpdateUI()
    if self.statsFolder then
        local isAwakened =  self.statsFolder:GetAttribute("Awakened")

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

function GameplayUI:Disconnect()
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

    if self.animationEvent then
        self.animationEvent:Disconnect()
    end
end

function GameplayUI:Update(deltaTime: number)
    self:UpdateUI()

    if HoldButton() then
        self:M1()
    end

    if not self.class then
        if self.Gameplay.Visible then
            self.Gameplay.Visible = false
        end
    elseif self.class then
        if not self.Gameplay.Visible then
            self.Gameplay.Visible = true
        end
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

    if self.statsFolder then
        --Silenced Icon on Moves UI
        local Silenced = self.statsFolder:GetAttribute("Silenced")

        for _, btn in pairs(self.Btns) do
            local silenceIcon: ImageLabel = btn:FindFirstChild("Silenced")
            if silenceIcon then
                silenceIcon.Visible = Silenced
            end
        end

    end
end

return GameplayUI