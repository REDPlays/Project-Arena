local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

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

    self:StatConnect()
    self:Connect()
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

    self.healthDisplay = self.statsFolder:GetAttributeChangedSignal("Health"):Connect(function()
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

        if input.KeyCode == Enum.KeyCode.LeftShift then
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

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                local function hitBoxCallBack()
                    local isProjectile = false
                    Events.Client_Server.Hitbox:FireServer(self.class, "LMBMove", self.LMBs, isProjectile)
                end

                self.animationSystem:Play(self.class, "LMBMove", self.LMBs, conditionalData, hitBoxCallBack)
            end
        end

        if input.KeyCode == Enum.KeyCode.Q then
            local animInfo = self.animationSystem:animInfo(self.class, "QMove")

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "QMove", animInfo)
            if canAttack then
                warn("Can QMove")
            end
        end

        if input.KeyCode == Enum.KeyCode.E then
            local animInfo = self.animationSystem:animInfo(self.class, "EMove")

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "EMove", animInfo)
            if canAttack then
                warn("Can EMove")
            end
        end

        if input.KeyCode == Enum.KeyCode.F then
            local animInfo = self.animationSystem:animInfo(self.class, "FMove")

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, "FMove", animInfo)
            if canAttack then
                warn("Can FMove")
            end
        end
    end)

    self.input2 = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if not self.class then
            return
        end

        if input.KeyCode == Enum.KeyCode.LeftShift then
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

    Events.Server_Client.Cooldown.OnClientEvent:Connect(function(moveType)
        if moveType == "LMBMove" then
            self.prevTime = self.currTime
            self.debounces.LMBMove = false
        end

        if moveType == "Block" then
            self.animationSystem:Stop(self.class, "Block")
        end
    end)
end

function UIController:LoadCharacter(class)
    self.class = class
end

function UIController:Update(deltaTime)

end

return UIController