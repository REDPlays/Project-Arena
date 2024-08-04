local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerManager = require(ServerStorage.ServerFiles.Player.PlayerManager)

local VisualEffectServer = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("VisualEffectServer"))

local HealthManager = {}

function HealthManager:Damage(character, damage, attacker)
    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end
    
    local currentHealth = humanoid.Health 
    local maxHealth = humanoid.MaxHealth

    if currentHealth <= 0 then
        return
    end

    --don't kill dummies
    if CollectionService:HasTag(character, "Dummies") and currentHealth <= damage then
        return
    end

    if CollectionService:HasTag(character, "Invulnerable") then
        return
    end

    VisualEffectServer:SpawnEffectsInRange(
        "Damage",
        nil,
        character,
        {},
        50
    )

    humanoid:TakeDamage(damage)
    Stats:SetAttribute("Health", humanoid.Health)
    Stats:SetAttribute("MaxHealth", maxHealth)

    if currentHealth - damage <= 0 then
        local attackerPlayer = Players:GetPlayerFromCharacter(attacker)
        if attackerPlayer then
            PlayerManager:AddKill(attackerPlayer)
        end
    end
end

function HealthManager:Block(character, damage, attacker)
    VisualEffectServer:SpawnEffectsInRange(
        "Blocked",
        nil,
        character,
        {},
        50
    )
end

function HealthManager:Heal(character, health)
    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    local currentHealth = humanoid.Health 
    local maxHealth = humanoid.MaxHealth

    if health >= maxHealth or health <= 0 then
        return
    end

    local newHealth = currentHealth + health
    newHealth = math.clamp(newHealth, 0, maxHealth)

    humanoid.Health = newHealth
    Stats:SetAttribute("Health", humanoid.Health)
    Stats:SetAttribute("MaxHealth", maxHealth)
end

return HealthManager