local Modifiers = {
    --base mods
    ["isAOE"] = false,
    ["isProjectile"] = false,
    ["hasEvent"] = false,
    ["ignoreLMBMoveCD"] = false,
    ["isMultiShot"] = false,
    ["CameraLock"] = false,
    ["Knockup"] = false,
    ["noMovement"] = false,
    ["DoubleCooldown"] = false,

    --status effects
    ["Stunned"] = false,
    ["Burn"] = false,
    ["Slow"] = false,
    ["Silenced"] = false,

    --passives
    ["HydroStack"] = false,
}

local ClassMoveData = {}

--passing modifiers in will set them to true
function ClassMoveData:SetupModifiers(modifiersToSetTrue: {})
    local newModList = table.clone(Modifiers)

    for mod, _ in pairs(newModList) do
        if table.find(modifiersToSetTrue, mod) then
            newModList[mod] = true
        end
    end

    return newModList
end

return ClassMoveData