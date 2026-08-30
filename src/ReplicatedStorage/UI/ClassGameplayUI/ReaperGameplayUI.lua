local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local CharacterMoveLibrary = require(ReplicatedStorage.RepFiles.Player.CharacterMoveLibrary)
local GameplayUI = require(ReplicatedStorage.RepFiles.UI.GameplayUI)

local InputActions = ReplicatedStorage:WaitForChild("Inputs")
local GameplayActions: InputContext = InputActions:WaitForChild("Gameplay")
local UIActions: InputContext = InputActions:WaitForChild("UI")

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

export type Moveset = {
    ["QMove"]: number, -- 1 or 2
    ["EMove"]: number, -- 1 or 2
    ["FMove"]: number, -- 1 or 2
}

local ReaperGameplayUI = {}
ReaperGameplayUI.__index = ReaperGameplayUI
setmetatable(ReaperGameplayUI, GameplayUI)

function ReaperGameplayUI.new(player: Player, character: Model, UIController, HUD: ScreenGui, animationSystem, cameraSystem)
    local self = setmetatable(
        GameplayUI.new(player, character, UIController, HUD, animationSystem, cameraSystem), 
        ReaperGameplayUI
    )

    return self
end

function ReaperGameplayUI:Connect()
    self.inputChange = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
        if keyboardOptions[input.UserInputType] then
            self:ShowInputButtons("Keyboard")
        elseif controllerOptions[input.UserInputType] or controllerOptions[input.KeyCode] then
            self:ShowInputButtons("Controller")
        elseif mobileOptions[input.UserInputType] then
            self:ShowInputButtons("Mobile")
        end
    end)

    self.InputActions = {
        ["QMove"] = GameplayActions.QMove,
        ["EMove"] = GameplayActions.EMove,
        ["FMove"] = GameplayActions.FMove,

    } :: {[string]: InputBinding}

    --Input Action Connections
    self.IAC = {}

    for moveType: string, bind: InputBinding in pairs(self.InputActions) do
        self.IAC[moveType] = bind.Pressed:Connect(function()
            if self.statsFolder:GetAttribute("MoveUILock") then
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
            local isEnshroud = self.statsFolder:GetAttribute("Enshroud")
            
            if self.debounces[moveType] then
                return
            end

            local canAttack = Events.Client_Server.Input:InvokeServer(self.class, moveType)
            if canAttack then
                self.debounces[moveType] = true
                local currentClassData = ClassData[self.class]

                local animationName = moveType
                
                local cooldownDuration = currentClassData.Cooldowns[moveType]
                local DoubleCooldown

                local hasEvent
                if currentClassData.MoveData[moveType][1] then
                    if isAwakened then
                        hasEvent = currentClassData.MoveData[moveType][2].hasEvent
                        DoubleCooldown = currentClassData.MoveData[moveType][2].DoubleCooldown
                    else
                        hasEvent = currentClassData.MoveData[moveType][1].hasEvent
                        DoubleCooldown = currentClassData.MoveData[moveType][1].DoubleCooldown
                    end
                else
                    hasEvent = currentClassData.MoveData[moveType].hasEvent
                    DoubleCooldown = currentClassData.MoveData[moveType].DoubleCooldown
                end

                if DoubleCooldown then
                    if self.character:GetAttribute("DoubleCooldown") == moveType then
                        cooldownDuration = cooldownDuration[2]
                    else
                        cooldownDuration = cooldownDuration[1]
                    end

                    if isAwakened then
                        animationName = moveType.."2"
                    end
                end

                local moveNumbers: Moveset = CharacterMoveLibrary.Movesets[self.player]
                if moveNumbers then
                    local currentMoveNumber = moveNumbers[moveType]
                    if currentMoveNumber and currentMoveNumber ~= 1 then
                        animationName = moveType..tostring(moveNumbers[moveType])
                    end
                end

                if workspace:GetAttribute("NoCooldowns") then
                    cooldownDuration = 1
                end

                self:toggleUICountdown(moveType, cooldownDuration)

                local conditionalData = {
                    priority = Enum.AnimationPriority.Action,
                    isAttack = true,
                }

                local function hitBoxCallBack()
                    if not currentClassData then
                        return
                    end

                    local moveData = currentClassData.MoveData

                    local currentMoveData = moveData[moveType]

                    Events.Client_Server.Moves:FireServer(self.class, moveType, currentMoveData)
                end

                local noMovement = currentClassData.MoveData[moveType].noMovement
                self:LockInPlace(noMovement, moveType)

                self.animationSystem:Play(self.class, animationName, nil, conditionalData, hitBoxCallBack, hasEvent)
            end
        end)
    end

    self.LMBHeld = false
    self.IAC["LMB_Pressed"] = GameplayActions.LMBMove.Pressed:Connect(function()
        self.LMBHeld = true
    end)

    self.IAC["LMB_Released"] = GameplayActions.LMBMove.Released:Connect(function()
        self.LMBHeld = false
    end)
    
    self.cooldownEvent = Events.Server_Client.Cooldown.OnClientEvent:Connect(function(moveType: string, actionType: string)
        if actionType == "Single" then
            if moveType == "LMBMove" then
                self.prevTime = self.currTime
                self.debounces.LMBMove = false
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

    self.updateNumbers = Events.Server_Client.UpdateMoveNumber.OnClientEvent:Connect(function(moveNumbers: Moveset)
        CharacterMoveLibrary.Movesets[self.player] = moveNumbers
    end)

    local function getTarget() : Model
        local Closest = {math.huge, nil}
        local MousePos = Vector2.new(self.mouse.X, self.mouse.Y)

        --Players
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == self.player then continue end
            local char = plr.Character
            if not char then continue end
            local humRoot = char:FindFirstChild("HumanoidRootPart")
            if not humRoot then continue end
            local vector, onScreen = self.camera:WorldToScreenPoint(humRoot.Position)
            if not onScreen then continue end
            local distance = (MousePos - Vector2.new(vector.X, vector.Y)).Magnitude
            if distance < Closest[1] then
                Closest = {distance, char}
            end
        end

        --dummies
        if not Closest[2] then
            for _, dummy in ipairs(workspace.Dummies:GetChildren()) do
                local humRoot = dummy:FindFirstChild("HumanoidRootPart")
                if not humRoot then continue end
                local vector, onScreen = self.camera:WorldToScreenPoint(humRoot.Position)
                if not onScreen then continue end
                local distance = (MousePos - Vector2.new(vector.X, vector.Y)).Magnitude
                if distance < Closest[1] then
                    Closest = {distance, dummy}
                end
            end
        end

        return Closest[2]
    end

    Events.Server_Client.GetTarget.OnClientInvoke = getTarget
end

return ReaperGameplayUI