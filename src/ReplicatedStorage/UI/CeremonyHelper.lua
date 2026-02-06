local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local CharacterModels = Assets:WaitForChild("CharacterModels")
local Animations = Assets:WaitForChild("Animations")
local Emotes = Animations:WaitForChild("Emotes")

local CeremonyHelper = {}

function CeremonyHelper:ApplyClass(className, character: Model, player: Player)
    local classFile = CharacterModels:FindFirstChild(className)
    if not classFile then
        return
    end
    --Equip Appearance
    local Folder = Instance.new("Folder")
    Folder.Name = "Appearance"
    Folder.Parent = character

    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("BasePart") then
            local piece = classFile:FindFirstChild(obj.Name)
            if not piece then continue end

            piece = piece:Clone()
            piece.PrimaryPart.Transparency = 1
            piece.Parent = Folder
            piece.PrimaryPart.CFrame = obj.CFrame

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = piece.PrimaryPart
            weld.Part1 = obj
            weld.Parent = weld.Part0
        end
    end

    --Equip Gear
    local gear = classFile.Gear:Clone()
    gear.Handle1.CFrame = character:WaitForChild("Left Arm").CFrame * CFrame.new(0, -1, 0)
    gear.Handle2.CFrame = character:WaitForChild("Right Arm").CFrame * CFrame.new(0, -1, 0)
    gear.Handle1.Transparency = 1
    gear.Handle2.Transparency = 1
    gear.Parent = character

    local leftHandle = Instance.new("Motor6D")
    leftHandle.Name = "leftHandle"
    leftHandle.Part0 = character:WaitForChild("Left Arm")
    leftHandle.Part1 = gear.Handle1
    leftHandle.C0 = CFrame.new(0, -1, 0)
    leftHandle.Parent = leftHandle.Part0

    local rightHandle = Instance.new("Motor6D")
    rightHandle.Name = "rightHandle"
    rightHandle.Part0 = character:WaitForChild("Right Arm")
    rightHandle.Part1 = gear.Handle2
    rightHandle.C0 = CFrame.new(0, -1, 0)
    rightHandle.Parent = rightHandle.Part0

    local function SelectColor(section, Color)
        local Groups = {
            ["Primary"] = "Group1",
            ["Secondary"] = "Group2",
            ["Energy"] = "Group3",
        }
    
        --Setting Colors on Character
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("BasePart") then
                if obj.Name == Groups[section] then
                    obj.Color = Color
                end
            end
        end
    end

    SelectColor("Primary", player:GetAttribute("Primary"))
    SelectColor("Secondary", player:GetAttribute("Secondary"))
    SelectColor("Energy", player:GetAttribute("Energy"))
end

function CeremonyHelper:Emote(character: Model, animationName)
    animationName = animationName or "Emote1"

    local Humanoid = character:FindFirstChild("Humanoid")
    if not Humanoid then
        return
    end

    local anim = Humanoid.Animator:LoadAnimation(Emotes[animationName])
    anim:Play()
end

return CeremonyHelper