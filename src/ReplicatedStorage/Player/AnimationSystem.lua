local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyProvider = game:GetService("KeyframeSequenceProvider")

local AnimationData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Player"):WaitForChild("AnimationData"))

local AnimationSystem = {}
AnimationSystem.__index = AnimationSystem

local defaultFadeTime = 0.100000001
local defaultWeight = 1
local defaultSpeed = 1

function AnimationSystem.new()
    local newAnimation = {}
    setmetatable(newAnimation, AnimationSystem)

    return AnimationSystem
end

function AnimationSystem:Init(player, character)
    self.player = player
    self.character = character
    self.humanoid = self.character:FindFirstChild("Humanoid")
    self.animator = self.humanoid:FindFirstChild("Animator")

    self.currentAnimations = {}
    self.cache = {}

    self:Setup()
end

function AnimationSystem:Setup()
    self.currentAnimations.Idle = self.animator:LoadAnimation(AnimationData.Base.Idle)
    self.currentAnimations.Idle.Priority = Enum.AnimationPriority.Idle
    self.currentAnimations.Idle:Play()
    
    self.currentAnimations.Walk = self.animator:LoadAnimation(AnimationData.Base.Walk)
    self.currentAnimations.Walk.Priority = Enum.AnimationPriority.Movement
end

function AnimationSystem:Update(deltaTime)
    if not self.humanoid then
        return
    end

    local moveDir = self.humanoid.MoveDirection.Magnitude

    if moveDir <= 0.5 then
        if self.currentAnimations.Walk.IsPlaying then
            self.currentAnimations.Walk:Stop()
        end
    elseif moveDir > 0.5 then
        if not self.currentAnimations.Walk.IsPlaying then
            self.currentAnimations.Walk:Play()
        end
    end
end

return AnimationSystem