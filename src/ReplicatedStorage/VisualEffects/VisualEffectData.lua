local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("VisualEffects"):WaitForChild("Visuals")

local VisualEffectData = {}

VisualEffectData["AngelKnightM1"] = require(Visuals:WaitForChild("AngelKnight"):WaitForChild("AngelKnightM1"))
VisualEffectData["HolyBeam"] = require(Visuals:WaitForChild("AngelKnight"):WaitForChild("HolyBeamVFX"))
VisualEffectData["AngelicCharge"] = require(Visuals:WaitForChild("AngelKnight"):WaitForChild("AngelicChargeVFX"))
VisualEffectData["SunBeam"] = require(Visuals:WaitForChild("AngelKnight"):WaitForChild("SunBeamVFX"))

VisualEffectData["FireBall"] = require(Visuals:WaitForChild("Pyromancer"):WaitForChild("FireBallVFX"))
VisualEffectData["Flamethrower"] = require(Visuals:WaitForChild("Pyromancer"):WaitForChild("FlamethrowerVFX"))
VisualEffectData["Eruption"] = require(Visuals:WaitForChild("Pyromancer"):WaitForChild("EruptionVFX"))

VisualEffectData["ShieldWarriorM1"] = require(Visuals:WaitForChild("ShieldWarrior"):WaitForChild("ShieldWarriorM1"))
VisualEffectData["ShieldSlam"] = require(Visuals:WaitForChild("ShieldWarrior"):WaitForChild("ShieldSlamVFX"))
VisualEffectData["ShieldJump"] = require(Visuals:WaitForChild("ShieldWarrior"):WaitForChild("ShieldJumpVFX"))
VisualEffectData["Colosseum"] = require(Visuals:WaitForChild("ShieldWarrior"):WaitForChild("ColosseumVFX"))


VisualEffectData["SamuraiM1"] = require(Visuals:WaitForChild("Samurai"):WaitForChild("SamuraiM1"))
VisualEffectData["ShadowStep"] = require(Visuals:WaitForChild("Samurai"):WaitForChild("ShadowStepVFX"))
VisualEffectData["RapidSlashes"] = require(Visuals:WaitForChild("Samurai"):WaitForChild("RapidSlashesVFX"))
VisualEffectData["WindTornado"] = require(Visuals:WaitForChild("Samurai"):WaitForChild("WindTornadoVFX"))

VisualEffectData["Burn"] = require(Visuals:WaitForChild("Status"):WaitForChild("Burn"))

return VisualEffectData