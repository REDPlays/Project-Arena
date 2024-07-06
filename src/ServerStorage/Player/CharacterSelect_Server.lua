local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))

local Assets = ReplicatedStorage.Assets
local CharacterModels = Assets.CharacterModels
local UI = Assets.UI

local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))

local tick = 0
local maxTick = 0.5

local CharacterSelectServer = {}
CharacterSelectServer.uiConnections = {}

CharacterSelectServer.hasClass = {}

function CharacterSelectServer:Init(lobby, roundManager, playerManager)
    CharacterSelectServer.Lobby = lobby
    CharacterSelectServer.Classes = lobby:WaitForChild("Classes")

    CharacterSelectServer.roundManager = roundManager
    CharacterSelectServer.playerManager = playerManager

    --Temporary(Make a map manager)
    CharacterSelectServer.Teleporter = workspace.Teleporter

    CharacterSelectServer:Setup()
end

function CharacterSelectServer:Setup()
    CharacterSelectServer.ClassList = {}
    for _, group in pairs(CharacterSelectServer.Classes:GetChildren()) do
        CharacterSelectServer.ClassList[group.Name] = {}

        for _, class in pairs(group:GetChildren()) do
            CharacterSelectServer.ClassList[group.Name][class.Name] = class
            class:SetAttribute("ClassID", class.Name)

            local currClassData = ClassData[class.Name]

            local Bounds = class.Bounds
            local PurchaseUI = Bounds:WaitForChild("PurchaseUI")

            PurchaseUI.Background:WaitForChild("Banner").Text = "Token Cost: "..currClassData.Cost

            local Wall = class.Wall
            local DescriptionUI = Wall:WaitForChild("DescriptionUI")

            DescriptionUI.Background:WaitForChild("ClassName").Text= "["..class.Name.."]"
            DescriptionUI.Background:WaitForChild("Health").Text = "HP: "..currClassData.Health
            DescriptionUI.Background:WaitForChild("Speed").Text = "Speed: "..currClassData.Speed
            DescriptionUI.Background:WaitForChild("Role").Text = "Role: "..currClassData.Role
            DescriptionUI.Background:WaitForChild("Description").Text = currClassData.Description
        end
    end
end

function CharacterSelectServer:DummyJoined(dummy)
    local rootPart = dummy:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame *= CFrame.new(0, 1, 0)
    end

    local Stats = Instance.new("Folder")
    Stats.Name = "Stats"
    Stats.Parent = dummy

    Stats:SetAttribute("Health", 50)
    Stats:SetAttribute("MaxHealth", 50)

    Stats:SetAttribute("Defense", 50)
    Stats:SetAttribute("MaxDefense", 50)

    Stats:SetAttribute("Speed", 60)

    Stats:SetAttribute("Blocking", false)
    Stats:SetAttribute("Stunned", false)
    Stats:SetAttribute("Attacked", false)
    Stats:SetAttribute("Burn", false)
    Stats:SetAttribute("AbilityLocked", false)
    Stats:SetAttribute("Slowed", false)
    Stats:SetAttribute("Invulnerable", false)

    Stats:SetAttribute("HideUI", false)

    Stats:SetAttribute("Color1", Color3.fromRGB(255, 255, 255))
    Stats:SetAttribute("Color2", Color3.fromRGB(255, 255, 255))
    Stats:SetAttribute("Color3", Color3.fromRGB(255, 255, 255))

    CharacterSelectServer:GiveUI(dummy, Stats)
end

function CharacterSelectServer:PlayerJoined(player)
    local character = player.Character
    if not character then
        return
    end

    local Stats = Instance.new("Folder")
    Stats.Name = "Stats"
    Stats.Parent = character

    Stats:SetAttribute("Health", 50)
    Stats:SetAttribute("MaxHealth", 50)

    Stats:SetAttribute("Defense", 50)
    Stats:SetAttribute("MaxDefense", 50)

    --60 being lobbySpeed
    Stats:SetAttribute("Speed", 60)

    Stats:SetAttribute("Blocking", false)
    Stats:SetAttribute("Stunned", false)
    Stats:SetAttribute("Attacked", false)
    Stats:SetAttribute("Burn", false)
    Stats:SetAttribute("AbilityLocked", false)
    Stats:SetAttribute("Slowed", false)
    Stats:SetAttribute("Invulnerable", false)

    Stats:SetAttribute("Color1", Color3.fromRGB(255, 255, 255))
    Stats:SetAttribute("Color2", Color3.fromRGB(255, 255, 255))
    Stats:SetAttribute("Color3", Color3.fromRGB(255, 255, 255))

    CharacterSelectServer:GiveUI(character, Stats)

    --Set Stats
    CharacterSelectServer:SetStats(player, nil)
end

function CharacterSelectServer:GiveUI(character, Stats)
    if not character then
        return
    end

    local humanoid: Humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local UIAttach = rootPart:FindFirstChild("UI")
    if UIAttach then
        UIAttach:Destroy()
    end

    local oldOverhead = character:FindFirstChild("Overhead")
    if oldOverhead then
        oldOverhead:Destroy()
    end

    local oldStatusUI = character:FindFirstChild("StatusUI")
    if oldStatusUI then
        oldStatusUI:Destroy()
    end

    local newAttach = Instance.new("Attachment")
    newAttach.Name = "UI"
    newAttach.Parent = rootPart
    newAttach.Position = Vector3.new(0, 3, 0)

    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    local Overhead: BillboardGui = UI.Overhead:Clone()
    Overhead.Adornee = newAttach
    Overhead.PlayerName.Text = character.Name
    Overhead.Enabled = false
    Overhead.Parent = character

    local StatusUI: BillboardGui = UI.StatusUI:Clone()
    StatusUI.Adornee = newAttach
    StatusUI.Enabled = false
    StatusUI.Parent = character

    if CharacterSelectServer.uiConnections[character] then
        if CharacterSelectServer.uiConnections[character].health then
            CharacterSelectServer.uiConnections[character].health:Disconnect()
        end

        if CharacterSelectServer.uiConnections[character].defense then
            CharacterSelectServer.uiConnections[character].defense:Disconnect()
        end
    end

    CharacterSelectServer.uiConnections[character] = {}
    CharacterSelectServer.uiConnections[character].health = Stats:GetAttributeChangedSignal("Health"):Connect(function()
        local health = Stats:GetAttribute("Health")
        local maxHealth = Stats:GetAttribute("MaxHealth")

        if not Overhead then
            return
        end

        local HealthBar = Overhead.Background:FindFirstChild("HealthBar")
        if not HealthBar then
            return
        end

        HealthBar.Bar.Size = UDim2.new((health / maxHealth) * 1, 0, 1, 0)
    end)

    CharacterSelectServer.uiConnections[character].defense = Stats:GetAttributeChangedSignal("Defense"):Connect(function()
        local defense = Stats:GetAttribute("Defense")
        local maxDefense = Stats:GetAttribute("MaxDefense")

        if not Overhead then
            return
        end

        local DefenseBar = Overhead.Background:FindFirstChild("DefenseBar")
        if not DefenseBar then
            return
        end

        DefenseBar.Bar.Size = UDim2.new((defense / maxDefense) * 1, 0, 1, 0)
    end)

    --First Time Set
    local health = Stats:GetAttribute("Health")
    local maxHealth = Stats:GetAttribute("MaxHealth")
    Overhead.Background.HealthBar.Bar.Size = UDim2.new((health / maxHealth) * 1, 0, 1, 0)

    local defense = Stats:GetAttribute("Defense")
    local maxDefense = Stats:GetAttribute("MaxDefense")
    Overhead.Background.DefenseBar.Bar.Size = UDim2.new((defense / maxDefense) * 1, 0, 1, 0)
end

function CharacterSelectServer:SetStats(player, className)
    local character = player.Character
    if not character then
        return
    end

    local humanoid: Humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        CharacterSelectServer:PlayerJoined(player)
    end

    if className then
        local currentClassData = ClassData[className]
        if not currentClassData then
            return
        end

        Stats:SetAttribute("Health", currentClassData.Health)
        Stats:SetAttribute("MaxHealth", currentClassData.Health)
        Stats:SetAttribute("Defense", currentClassData.Defense)
        Stats:SetAttribute("MaxDefense", currentClassData.Defense)
        Stats:SetAttribute("Speed", currentClassData.Speed)
    end

    humanoid.MaxHealth = Stats:GetAttribute("MaxHealth")
    humanoid.Health = Stats:GetAttribute("Health")
    humanoid.WalkSpeed = Stats:GetAttribute("Speed")
end

function CharacterSelectServer:CheckClass(player, className)
    local currentClass = player:GetAttribute("CurrentClass")
    if className == currentClass then
        return true
    end

    local character = player.Character
    if not character then
        return true
    end

    local Appearance = character:FindFirstChild("Appearance")
    if Appearance then
        Appearance:Destroy()
    end

    local Gear = character:FindFirstChild("Gear")
    if Gear then
        Gear:Destroy()
    end

    player:SetAttribute("CurrentClass", nil)

    return
end

function CharacterSelectServer:SetCharacter(player, group, className)
    local currentClass = CharacterSelectServer.ClassList[group][className]
    if not currentClass then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    --check for prevClass
    local isSameClass = CharacterSelectServer:CheckClass(player, className)

    local classFile = CharacterModels:FindFirstChild(className)
    if not classFile then
        return
    end

    --This way because if someone is somehow stuck but has their class they can step on and teleport still!
    if not isSameClass then
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

        --Set Class
        player:SetAttribute("CurrentClass", className)

        --Set Stats
        CharacterSelectServer:SetStats(player, className)

        if not CharacterSelectServer.hasClass[player] then
            CharacterSelectServer.hasClass[player] = {
                player = player,
                character = character
            }
        end
    end

    --Teleport player
    if CharacterSelectServer.roundManager.roundStart then
        CharacterSelectServer.roundManager:TeleportPlayer(player)
    else
        if not workspace:GetAttribute("TestState") then
            CollectionService:AddTag(character, "Invulnerable")
        end
        character:PivotTo(CharacterSelectServer.Teleporter.CFrame * CFrame.new(0, 1, 0))
    end
end

function CharacterSelectServer:SelectCharacter(player, className, ID)
    local currentClass = nil
    local group = nil

    for groupName, classes in pairs(CharacterSelectServer.ClassList) do
        if classes[className] then
            local serverID = classes[className]:GetAttribute("ClassID")
            if ID == serverID then
                currentClass = className
                group = groupName
            end
        end
    end

    local CheckClass = CharacterSelectServer.playerManager:CheckClass(player, className)
    
    if not CheckClass then
        local enoughTokens = CharacterSelectServer.playerManager:AddClass(player, className)
        if not enoughTokens then
            return
        end
    end

    CharacterSelectServer:SetCharacter(player, group, currentClass)

    if currentClass then
        return true
    else
        return
    end
end

function CharacterSelectServer:UpdateStatues()
    for _, player in pairs(Players:GetChildren()) do
        local playerData = CharacterSelectServer.playerManager:GetData(player)
        if not playerData then
            continue
        end

        local Tokens = playerData.Tokens
        if not Tokens then
            continue
        end

        local Classes = playerData.Classes
        if not Classes then
            continue
        end

        Events.Server_Client.UpdateStatue:FireClient(player, Tokens, Classes)
    end
end

function CharacterSelectServer:Update(deltaTime)
    tick += deltaTime

    if tick < maxTick then
        return
    end

    tick = 0

    CharacterSelectServer:UpdateStatues()
end

local function SelectCharacter(player, className, ID)
    return CharacterSelectServer:SelectCharacter(player, className, ID)
end

Events.Client_Server.CharacterSelect.OnServerInvoke = SelectCharacter

return CharacterSelectServer