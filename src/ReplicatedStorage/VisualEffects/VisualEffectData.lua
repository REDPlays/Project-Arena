local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("Visuals")

local VisualEffectData = {}

VisualEffectData["AngelKnightM1"] = require(Visuals:WaitForChild("AngelKnight"):WaitForChild("AngelKnightM1"))
VisualEffectData["HolyBeam"] = require(Visuals:WaitForChild("AngelKnight"):WaitForChild("HolyBeamVFX"))
VisualEffectData["AngelicCharge"] = require(Visuals:WaitForChild("AngelKnight"):WaitForChild("AngelicChargeVFX"))
VisualEffectData["SunBeam"] = require(Visuals:WaitForChild("AngelKnight"):WaitForChild("SunBeamVFX"))

VisualEffectData["Burn"] = require(Visuals:WaitForChild("Status"):WaitForChild("Burn"))

return VisualEffectData