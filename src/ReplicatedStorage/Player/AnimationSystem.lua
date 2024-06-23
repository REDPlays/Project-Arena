local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyProvider = game:GetService("KeyframeSequenceProvider")

local AnimationData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Player"):WaitForChild("AnimationData"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))

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

function AnimationSystem:animInfo(class, animName, animCount)
    local anim = AnimationData[class][animName]
    if type(anim) == "table" then
        anim = AnimationData[class][animName][animCount]
    end

    local animId = anim.AnimationId
    if not animId then
        return 0
    end

    if self.cache[animId] then
        return self.cache[animId]
    end

    local newSequence = KeyProvider:GetKeyframeSequenceAsync(animId)
    local Keyframes = newSequence:GetKeyframes()

    local length = 0
    for i=1, #Keyframes do
        local Time = Keyframes[i].Time
        if Time > length then
            length = Time
        end
    end

    self.cache[animId] = length

    return self.cache[animId]
end

function AnimationSystem:CreateConditionalData()
    local conditionalData = {
        priority = Enum.AnimationPriority.Action,
        weight = defaultWeight,
        speed = defaultSpeed,
        fadeTime = defaultFadeTime,
        loop = false,
        isAttack = false
    }

    return conditionalData
end

function AnimationSystem:ChangeClass(class)
    self.currentAnimations.Idle:Stop()

    self.currentAnimations.Idle = self.animator:LoadAnimation(AnimationData[class].Idle)
    self.currentAnimations.Idle.Priority = Enum.AnimationPriority.Idle
    self.currentAnimations.Idle:Play()

    self.currentAnimations.Walk:Stop()

    self.currentAnimations.Walk = self.animator:LoadAnimation(AnimationData[class].Run)
    self.currentAnimations.Walk.Priority = Enum.AnimationPriority.Movement
end

function AnimationSystem:Play(class, animName, animCount, conditionalData, hitBoxCallBack, hasEvent)
    conditionalData = conditionalData or self:CreateConditionalData()
    hasEvent = hasEvent or false

    conditionalData.weight = conditionalData.weight or defaultWeight
    conditionalData.speed = conditionalData.speed or defaultSpeed
    conditionalData.fadeTime = conditionalData.fadeTime or defaultFadeTime
    conditionalData.loop = conditionalData.loop or false
    conditionalData.isAttack = conditionalData.isAttack or false

    if animName == "LMBMove" then
        conditionalData.weight = 1.5
    end

    local anim = AnimationData[class][animName]
    if type(anim) == "table" then
        anim = AnimationData[class][animName][animCount]
    end

    self.currentAnimations[animName] = self.animator:LoadAnimation(anim)
    self.currentAnimations[animName].Priority = conditionalData.priority
    self.currentAnimations[animName].Looped = conditionalData.loop
    self.currentAnimations[animName]:Play(conditionalData.fadeTime, conditionalData.weight, conditionalData.speed)

    if conditionalData.isAttack then
        self:HitBoxEvent(self.currentAnimations[animName], hitBoxCallBack, hasEvent) 
    end
end

function AnimationSystem:Stop(class, animName)
    if self.currentAnimations[animName] then
        self.currentAnimations[animName]:Stop()
    end
end

function AnimationSystem:HitBoxEvent(animation: AnimationTrack, hitBoxCallBack, hasEvent)
    if hasEvent then
        local marker = animation:GetMarkerReachedSignal("Attack"):Connect(function()
            --spawnHitbox
            hitBoxCallBack()
        end)
    
        local stopped
        stopped = animation.Stopped:Connect(function()
            if stopped then
                stopped:Disconnect()
            end
    
            if marker then
                marker:Disconnect()
            end
        end) 
    else
        --spawnHitbox
        hitBoxCallBack()
    end
end

function AnimationSystem:Disconnect()
    for animName, track in pairs(self.currentAnimations) do
        if track then
            track:Stop()
            self.currentAnimations[animName] = nil
        end
    end
end

function AnimationSystem:Update(deltaTime)
    if not self.humanoid then
        return
    end

    local moveDir = self.humanoid.MoveDirection.Magnitude

    if moveDir <= 0.5 then
        if not self.currentAnimations.Idle.IsPlaying then
            self.currentAnimations.Idle:Play()
        end

        if self.currentAnimations.Walk.IsPlaying then
            self.currentAnimations.Walk:Stop()
        end
    elseif moveDir > 0.5 then
        if self.currentAnimations.Idle.IsPlaying then
            self.currentAnimations.Idle:Stop()
        end

        if not self.currentAnimations.Walk.IsPlaying then
            self.currentAnimations.Walk:Play()
        elseif self.currentAnimations.Walk.IsPlaying then
            local class = self.player:GetAttribute("CurrentClass")
            local currentClassData = ClassData[class]
            if not currentClassData then
                return
            end

            local animSpeed = (self.humanoid.WalkSpeed / currentClassData.Speed) * 1

            self.currentAnimations.Walk:AdjustSpeed(animSpeed)
        end
    end
end

return AnimationSystem