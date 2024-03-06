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

function UIController:Init(player, character, animationSystem)
    self.player = player
    self.character = character

    self.animationSystem = animationSystem

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

    self:Connect()
end

function UIController:Connect()
    self.input = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not self.class then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                self.animationSystem:Play(self.class, "LMBMove", self.LMBs, conditionalData)

                self.prevTime = self.currTime
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
end

function UIController:LoadCharacter(class)
    self.class = class
end

function UIController:Update(deltaTime)
    
end

return UIController