local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local CharacterSelectClient = {}

function CharacterSelectClient:Init(lobby, uiController, animationSystem)
    CharacterSelectClient.Lobby = lobby
    CharacterSelectClient.Classes = lobby:WaitForChild("Classes")

    CharacterSelectClient.uiController = uiController
    CharacterSelectClient.animationSystem = animationSystem

    CharacterSelectClient:Setup()
end

function CharacterSelectClient:Setup()
    CharacterSelectClient.ClassList = {}
    CharacterSelectClient.Bounds = {}

    for _, group in pairs(CharacterSelectClient.Classes:GetChildren()) do
        CharacterSelectClient.ClassList[group.Name] = {}

        for _, class in pairs(group:GetChildren()) do
            CharacterSelectClient.ClassList[group.Name][class.Name] = class

            local bounds:BasePart = class:WaitForChild("Bounds")

            local alreadyTouched = false

            CharacterSelectClient.Bounds[class.Name] = bounds.Touched:Connect(function(otherPart)
                if not otherPart:IsA("BasePart") then return end

                local character = otherPart.Parent
                if not character:IsA("Model") then return end

                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")

                if not humanoid or not rootPart then return end

                if alreadyTouched then return end

                alreadyTouched = true

                local valid = Events.Client_Server.CharacterSelect:InvokeServer(class.Name, class:GetAttribute("ClassID"))
                if valid then
                    alreadyTouched = false

                    --Setup UI
                    CharacterSelectClient.uiController:LoadCharacter(class:GetAttribute("ClassID"))
                    
                else
                    warn("invalid classname and ID")
                    alreadyTouched = false
                end
            end)
        end
    end
end

function CharacterSelectClient:Disconnect()
    CharacterSelectClient.uiController = nil
    CharacterSelectClient.animationSystem = nil

    for className, event in pairs(CharacterSelectClient.Bounds) do
        if event then
            event:Disconnect()
        end

        CharacterSelectClient.Bounds[className] = nil
    end
end

return CharacterSelectClient