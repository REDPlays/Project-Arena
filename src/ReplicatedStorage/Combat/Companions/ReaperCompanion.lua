local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local CharacterCompanions = Assets:WaitForChild("CharacterCompanions")
local ReaperCompanionAssets = CharacterCompanions:WaitForChild("Reaper")
local ReaperCompanionAnimations = ReaperCompanionAssets:WaitForChild("Animations")

local HitboxManager = require(ReplicatedStorage.RepFiles:WaitForChild("Combat"):WaitForChild("HitboxManager"))

local ReaperCompanion = {}
ReaperCompanion.__index = ReaperCompanion

function ReaperCompanion.new(player: Player, companion: Model, restOffset: CFrame, moveData: {}, team: string)
    local self = setmetatable({}, ReaperCompanion)

    self.player = player
    self.character = player.Character
    self.rootPart = self.character:FindFirstChild("HumanoidRootPart")
    self.stats = self.character:FindFirstChild("Stats") :: Folder

    self.class = "Reaper"
    self.moveData = moveData
    self.currentM1 = 0

    self.companion = companion
    self.companionRoot = companion:FindFirstChild("HumanoidRootPart")
    self.Animator = companion:WaitForChild("Controller").Animator :: Animator
    self.companion:SetAttribute("CurrentClass", self.class)
    self.companion:SetAttribute("Team", team)

    self.restOffset = restOffset or CFrame.new(0, 0, 0)
    self.m1Offset = CFrame.new(0, 0, -12)
    self.tweenTime = 0.05

    self.animations = {} :: {[string] : AnimationTrack}
    self.animations.Idle = self.Animator:LoadAnimation(ReaperCompanionAnimations.Idle)
    self.animations.Idle.Priority = Enum.AnimationPriority.Idle

    self.animations.M1_1 = self.Animator:LoadAnimation(ReaperCompanionAnimations.M1_1)
    self.animations.M1_1.Priority = Enum.AnimationPriority.Action

    self.animations.M1_2 = self.Animator:LoadAnimation(ReaperCompanionAnimations.M1_2)
    self.animations.M1_2.Priority = Enum.AnimationPriority.Action

    self.animations.M1_3 = self.Animator:LoadAnimation(ReaperCompanionAnimations.M1_3)
    self.animations.M1_3.Priority = Enum.AnimationPriority.Action

    self.connections = {}
    self.returnTween = nil
    self.returnDelay = 0.75
    self.blockReturn = false

    return self
end

function ReaperCompanion:ConfigureStats()
    local Stats = Instance.new("Folder")
    Stats.Name = "Stats"
    Stats.Parent = self.companion

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
    Stats:SetAttribute("Silenced", false)
    Stats:SetAttribute("Reflecting", false)
    
    Stats:SetAttribute("Awakened", true)
    Stats:SetAttribute("HideUI", false)
    Stats:SetAttribute("M1", 0)
end

function ReaperCompanion:Init()
    self:ConfigureStats()

    self.animations.Idle:Play()

    if self.stats then
        self.connections.M1Stat = self.stats:GetAttributeChangedSignal("M1"):Connect(function()
            local currentM1 = self.stats:GetAttribute("M1") or 0
            if currentM1 == 0 then return end

            self.currentM1 = currentM1
            self:M1(currentM1)
        end)
    end

    local m1Tracks = {"M1_1", "M1_2", "M1_3"}
    for trackName, track: AnimationTrack in pairs(self.animations) do
        if table.find(m1Tracks, trackName) then
            self.connections[trackName] = track:GetMarkerReachedSignal("Attack"):Connect(function()
                HitboxManager:HitboxCreateMove(
                    self.companion, 
                    self.class, 
                    "LMBMove", 
                    self.currentM1, 
                    {isCompanion = true, player = self.player}
                )
            end)

            self.connections[trackName.."Stop"] = track.Stopped:Connect(function()
                local CompanionWeld = self.rootPart:FindFirstChild("CompanionWeld")
                if not CompanionWeld then return end

                self.blockReturn = false

                task.delay(self.returnDelay, function()
                    if self.blockReturn then return end

                    local info = TweenInfo.new(self.tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
                    self.returnTween = TweenService:Create(CompanionWeld, info, {C0 = self.restOffset})
                    self.returnTween:Play()
                end)
            end)
        end
    end
end

function ReaperCompanion:M1(currentM1: number)
    local currentString = "M1_"..currentM1

    if not self.animations[currentString] then return end

    local CompanionWeld = self.rootPart:FindFirstChild("CompanionWeld")
    if not CompanionWeld then return end

    if self.returnTween then
        self.returnTween:Cancel()
        self.returnTween = nil
    end

    local info = TweenInfo.new(self.tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    TweenService:Create(CompanionWeld, info, {C0 = self.m1Offset}):Play()

    self.blockReturn = true

    self.animations[currentString]:Play()
end

function ReaperCompanion:Destroy()
    if self.animations then
        for _, track in pairs(self.animations) do
            track:Stop()
        end
    end

    if self.connections then
        for _, connection in pairs(self.connections) do
            connection:Disconnect()
        end
    end
end

function ReaperCompanion:Update(deltaTime)
    
end

return ReaperCompanion