local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))

local UIController = {}
UIController.__index = UIController

function UIController.new()
    local newUI = {}
    setmetatable(newUI, UIController)

    return newUI
end

function UIController:Init(player, character, animationSystem, cameraSystem)
    self.player = player
    self.character = character
    self.humanoid = character:WaitForChild("Humanoid")
    self.rootPart = character:WaitForChild("HumanoidRootPart")

    self.animationSystem = animationSystem
    self.cameraSystem = cameraSystem

    self.HUD = self.player:WaitForChild("PlayerGui"):WaitForChild("HUD")
    self.Gameplay = self.HUD:WaitForChild("Gameplay")
    self.MoveList = self.Gameplay:WaitForChild("MoveList")
    self.Stats = self.Gameplay:WaitForChild("Stats")

    self.HealthBar = self.Stats:WaitForChild("HealthBar")
    self.DefenseBar = self.Stats:WaitForChild("DefenseBar")

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

    self:UISetup()
    self:StatConnect()
    self:Connect()
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
    }

    self.UICooldowns[moveType].CooldownUI.Text = duration
    self.UICooldowns[moveType].CooldownUI.Visible = true
end

function UIController:removeUICountdown(moveType)
    if not self.UICooldowns[moveType] then
        warn("not in cooldown")
        return
    end

    self.UICooldowns[moveType].CooldownUI.Visible = false

    self.UICooldowns[moveType] = nil
end

function UIController:StatConnect()
    self.statsFolder = self.character:FindFirstChild("Stats")
    if not self.statsFolder then
        return
    end

    --First Time Set
    local health = self.statsFolder:GetAttribute("Health")
    local maxHealth = self.statsFolder:GetAttribute("MaxHealth")
    self.HealthBar.Bar.Size = UDim2.new((health / maxHealth) * 1, 0, 1, 0)

    local defense = self.statsFolder:GetAttribute("Defense")
    local maxDefense = self.statsFolder:GetAttribute("MaxDefense")
    self.DefenseBar.Bar.Size = UDim2.new((defense / maxDefense) * 1, 0, 1, 0)

    self.healthDisplay = self.humanoid.HealthChanged:Connect(function()
        local health = self.statsFolder:GetAttribute("Health")
        local maxHealth = self.statsFolder:GetAttribute("MaxHealth")

        self.HealthBar.Bar.Size = UDim2.new((health / maxHealth) * 1, 0, 1, 0)
    end)

    self.defenseDisplay = self.statsFolder:GetAttributeChangedSignal("Defense"):Connect(function()
        local defense = self.statsFolder:GetAttribute("Defense")
        local maxDefense = self.statsFolder:GetAttribute("MaxDefense")

        self.DefenseBar.Bar.Size = UDim2.new((defense / maxDefense) * 1, 0, 1, 0)
    end)
end

function UIController:Connect()
    self.input = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not self.class then
            return
        end

        if self.statsFolder:GetAttribute("Stunned") and self.statsFolder:GetAttribute("Stunned") == true then
            return
        end

        if self.statsFolder:GetAttribute("Blocking") and self.statsFolder:GetAttribute("Blocking") == true then
            return
        end

        if input.KeyCode == Enum.KeyCode.C then
            if self.debounces.Block then
                return
            end

            local canBlock = Events.Client_Server.Input:InvokeServer(self.class, "Block")
            if canBlock then
                self.debounces.Block = true

                self.cameraSystem:OutsideToggle(true)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = false,
                    loop = true
                }
                self.animationSystem:Play(self.class, "Block", nil, conditionalData)
            end
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.debounces.LMBMove then
                return
            end

            self.currTime = os.clock()

            self.LMBs += 1
            if self.LMBs > self.maxCount then
                self.LMBs = 1
            end

            if self.currTime - self.prevTime >= 1 then
                self.LMBs = 1
            end
            
            local animInfo = self.animationSystem:animInfo(self.class, "LMBMove", self.LMBs)
            
            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "LMBMove", animInfo, self.LMBs)
            if canAttack then
                self.debounces.LMBMove = true
                local currentClassData = ClassData[self.class]
                
                local cooldownDuration = currentClassData.Cooldowns["LMBMove"]
                self:toggleUICountdown("LMBMove", cooldownDuration)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                local function hitBoxCallBack()
                    local currentClassData = ClassData[self.class]
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
            end
        end

        if input.KeyCode == Enum.KeyCode.Q then
            if self.debounces.QMove then
                return
            end

            local animInfo = self.animationSystem:animInfo(self.class, "QMove")

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "QMove", animInfo)
            if canAttack then
                warn("Can QMove")
                self.debounces.QMove = true
                local currentClassData = ClassData[self.class]
                
                local cooldownDuration = currentClassData.Cooldowns["QMove"]
                self:toggleUICountdown("QMove", cooldownDuration)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                local function hitBoxCallBack()
                    local currentClassData = ClassData[self.class]
                    if not currentClassData then
                        return
                    end

                    local moveData = currentClassData.MoveData

                    local currentMoveData = moveData.QMove

                    if currentMoveData.CameraLock then
                        self.cameraSystem:OutsideToggle(true)
                    end

                    Events.Client_Server.Moves:FireServer(self.class, "QMove", currentMoveData)
                end

                self.animationSystem:Play(self.class, "QMove", nil, conditionalData, hitBoxCallBack)
            end
        end

        if input.KeyCode == Enum.KeyCode.E then
            if self.debounces.EMove then
                return
            end

            local animInfo = self.animationSystem:animInfo(self.class, "EMove")

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "EMove", animInfo)
            if canAttack then
                warn("Can EMove")
                self.debounces.EMove = true
                local currentClassData = ClassData[self.class]
                
                local cooldownDuration = currentClassData.Cooldowns["EMove"]
                self:toggleUICountdown("EMove", cooldownDuration)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                local function hitBoxCallBack()
                    local currentClassData = ClassData[self.class]
                    if not currentClassData then
                        return
                    end

                    local moveData = currentClassData.MoveData

                    local currentMoveData = moveData.EMove

                    if currentMoveData.CameraLock then
                        self.cameraSystem:OutsideToggle(true)
                    end

                    Events.Client_Server.Moves:FireServer(self.class, "EMove", currentMoveData)
                end

                self.animationSystem:Play(self.class, "EMove", nil, conditionalData, hitBoxCallBack)
            end
        end

        if input.KeyCode == Enum.KeyCode.F then
            if self.debounces.FMove then
                return
            end

            local animInfo = self.animationSystem:animInfo(self.class, "FMove")

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "FMove", animInfo)
            if canAttack then
                warn("Can FMove")
                self.debounces.FMove = true
                local currentClassData = ClassData[self.class]
                
                local cooldownDuration = currentClassData.Cooldowns["FMove"]
                self:toggleUICountdown("FMove", cooldownDuration)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                local function hitBoxCallBack()
                    local currentClassData = ClassData[self.class]
                    if not currentClassData then
                        return
                    end

                    local moveData = currentClassData.MoveData

                    local currentMoveData = moveData.FMove

                    if currentMoveData.CameraLock then
                        self.cameraSystem:OutsideToggle(true)
                    end

                    Events.Client_Server.Moves:FireServer(self.class, "FMove", currentMoveData)
                end

                self.animationSystem:Play(self.class, "FMove", nil, conditionalData, hitBoxCallBack)
            end
        end
    end)

    self.input2 = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if not self.class then
            return
        end

        if input.KeyCode == Enum.KeyCode.C then
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
end

function UIController:LoadCharacter(class)
    self.class = class
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
end

function UIController:Update(deltaTime)
    local Overhead: BillboardGui = self.character:FindFirstChild("Overhead")
    if Overhead then
        if Overhead.Enabled then
            Overhead.Enabled = false
        end
    end

    for moveType, UIData in pairs(self.UICooldowns) do
        if not UIData.CooldownUI then
            continue
        end

        if UIData.duration <= 0 then
            self:removeUICountdown(moveType)

            continue
        end 

        UIData.duration -= deltaTime
        UIData.duration = math.clamp(UIData.duration, 0, UIData.maxDuration)

        local durationText = string.format("%0.2f", UIData.duration)

        UIData.CooldownUI.Text = durationText --UIData.duration
    end
end

return UIController