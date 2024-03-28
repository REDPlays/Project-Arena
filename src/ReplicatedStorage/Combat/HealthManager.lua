local CollectionService = game:GetService("CollectionService")

local HealthManager = {}

function HealthManager:Damage(character, damage)
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

    humanoid:TakeDamage(damage)
    Stats:SetAttribute("Health", humanoid.Health)
    Stats:SetAttribute("MaxHealth", maxHealth)
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