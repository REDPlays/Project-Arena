local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hitboxes = Assets:WaitForChild("Hitboxes")

local Events = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Events"))
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))
local StateManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("StateManager"))
local HealthManager = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("HealthManager"))

local VisualEffectServer = require(ReplicatedStorage.RepFiles.VisualEffects.VisualEffectServer)

local IgnoreFolder = workspace.Ignore

local WindTornado = {}

function WindTornado:Activate(player, character, rootPart, placementCFrame, class, classData, moveType)
    local ShowHitboxes = workspace:GetAttribute("ShowHitboxes")

    local damage = classData.DamageList[moveType]

    local Stats = character:FindFirstChild("Stats")
    if not Stats then
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end
   
    local duration = 2
    local _delay = .5
    local speed = 50

    Stats:SetAttribute("AbilityLocked", true)
    task.delay(_delay, function()
        Stats:SetAttribute("AbilityLocked", false)
    end)

    local startCFrame = placementCFrame * CFrame.new(0, 0, -5)

    local rayparams = RaycastParams.new()
    rayparams.FilterType = Enum.RaycastFilterType.Exclude

    local Hitbox: BasePart = Hitboxes.Hitbox:Clone()
    Hitbox.Transparency = 1
    if ShowHitboxes then
        Hitbox.Transparency = .5
    end

    Hitbox.Size = classData.Hitboxes[moveType].Size
    Hitbox.CFrame = startCFrame
    Hitbox.Anchored = true
    Hitbox.Parent = IgnoreFolder

    local VFX_ID = "RapidSlashes"..HttpService:GenerateGUID(false)

    VisualEffectServer:SpawnEffectsInRange(
        "WindTornado",
        nil,
        character,
        {hitbox = Hitbox, duration = duration},
        1000,
        VFX_ID
    )

    local alreadyHit = {}
    local function hitDetection()
        local touched = Hitbox.Touched:Connect(function() end)
        local touchedObjects = Hitbox:GetTouchingParts()

        if touched then
            touched:Disconnect()
        end

        for i=1, #touchedObjects do
            local object = touchedObjects[i]
            local parent = object.Parent
            
            if not parent:IsA("Model") then
                continue
            end
            
            if parent == character then
                continue
            end
            
            --ignoreTargets
            if CollectionService:HasTag(parent, "Ignore") then
                continue
            end
            
            local enemyHum = parent:FindFirstChild("Humanoid")
            if not enemyHum then
                continue
            end
            
            local enemyRoot = parent:FindFirstChild("HumanoidRootPart")
            if not enemyRoot then
                continue
            end
            
            if alreadyHit[parent.Name] then
                continue
            end
            
            if CollectionService:HasTag(parent, "Invulnerable") then
                continue
            end

            alreadyHit[parent.Name] = true
            
            local isBlocking = StateManager:CheckState(parent, "Blocking")
            if isBlocking then
                --Block Indication
                HealthManager:Block(parent, damage, character)
                continue
            end
            
            --apply burn
            if classData.MoveData[moveType].Burn then
                StateManager:AddTarget(parent, "Burn", 3)
            end

            --apply stun
            if classData.MoveData[moveType].Stunned then
                StateManager:AddTarget(parent, "Stunned", 2)
            end

            --apply slow
            if classData.MoveData[moveType].Slow then
                StateManager:AddTarget(parent, "Slow", 2)
            end

            --apply knockup
            if classData.MoveData[moveType].Knockup then
                StateManager:AddTarget(parent, "Knockup", 50)
            end

            --apply silence
            if classData.MoveData[moveType].Silenced then
                StateManager:AddTarget(parent, "Silenced", 2)
            end

            StateManager:AddTarget(parent, "Attacked", 2)

            HealthManager:Damage(parent, damage, character)
        end
    end

    local function movement(dt)
        local overlap = OverlapParams.new()
        overlap.FilterDescendantsInstances = {workspace.Obstacles}
        overlap.FilterType = Enum.RaycastFilterType.Include

        local partList = workspace:GetPartsInPart(Hitbox, overlap)

        if #partList > 0 then
            Hitbox.CFrame = Hitbox.CFrame
        else
            Hitbox.CFrame *= CFrame.new(0, 0, -speed * dt)
        end

        local newCFR = Hitbox.CFrame

        local characterList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            local plrChar = plr.Character
            if not plrChar then
                continue
            end
            table.insert(characterList, plrChar)
        end

        rayparams.FilterDescendantsInstances = {workspace.Dummies, workspace.Ignore, workspace.Obstacles, workspace.VFX, characterList}

        local ray = workspace:Raycast(newCFR.Position, newCFR.UpVector * -1000, rayparams)
        if ray then
            local rayPosition = ray.Position

            Hitbox.Position = rayPosition + Vector3.new(0, Hitbox.Size.Y/2, 0)
        end
    end

    local thread = coroutine.create(function()
        while true do
            local dt = task.wait()

            hitDetection()

            movement(dt)
        end
    end)

    Debris:AddItem(Hitbox, duration)

    task.delay(duration, function()
        if thread then
            task.cancel(thread)
        end

        VisualEffectServer:TerminateVFX(
            "WindTornado",
            nil,
            character,
            {},
            VFX_ID
        )
    end)

    coroutine.resume(thread)
end

return WindTornado