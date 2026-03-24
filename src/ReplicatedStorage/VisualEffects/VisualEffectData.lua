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

VisualEffectData["EngineerM1"] = require(Visuals:WaitForChild("Engineer"):WaitForChild("EngineerM1"))
VisualEffectData["Turret"] = require(Visuals:WaitForChild("Engineer"):WaitForChild("TurretShot"))
VisualEffectData["TurretSpawn"] = require(Visuals:WaitForChild("Engineer"):WaitForChild("TurretSpawnVFX"))
VisualEffectData["ConcussiveBomb"] = require(Visuals:WaitForChild("Engineer"):WaitForChild("ConcussiveBombVFX"))
VisualEffectData["ElectroBall"] = require(Visuals:WaitForChild("Engineer"):WaitForChild("ElectroBallVFX"))

VisualEffectData["RangerM1"] = require(Visuals:WaitForChild("Ranger"):WaitForChild("RangerM1"))
VisualEffectData["PiercingArrow"] = require(Visuals:WaitForChild("Ranger"):WaitForChild("PiercingArrowVFX"))
VisualEffectData["NetTrap"] = require(Visuals:WaitForChild("Ranger"):WaitForChild("NetTrapVFX"))
VisualEffectData["ExplosiveArrow"] = require(Visuals:WaitForChild("Ranger"):WaitForChild("ExplosiveArrowVFX"))

VisualEffectData["ShinobiM1"] = require(Visuals:WaitForChild("Shinobi"):WaitForChild("ShinobiM1"))
VisualEffectData["QuickDash"] = require(Visuals:WaitForChild("Shinobi"):WaitForChild("QuickDashVFX"))
VisualEffectData["ShurikenThrow"] = require(Visuals:WaitForChild("Shinobi"):WaitForChild("ShurikenThrowVFX"))
VisualEffectData["Retreat"] = require(Visuals:WaitForChild("Shinobi"):WaitForChild("RetreatVFX"))

VisualEffectData["ClubSlam"] = require(Visuals:WaitForChild("Oni"):WaitForChild("ClubSlamVFX"))
VisualEffectData["SumoRush"] = require(Visuals:WaitForChild("Oni"):WaitForChild("SumoRushVFX"))
VisualEffectData["Enraged"] = require(Visuals:WaitForChild("Oni"):WaitForChild("EnragedVFX"))
VisualEffectData["SumoStance"] = require(Visuals:WaitForChild("Oni"):WaitForChild("SumoStanceVFX"))


VisualEffectData["WaterBall"] = require(Visuals:WaitForChild("Hydromancer"):WaitForChild("WaterBallVFX"))
VisualEffectData["WaterWall"] = require(Visuals:WaitForChild("Hydromancer"):WaitForChild("WaterWallVFX"))
VisualEffectData["WaterBubble"] = require(Visuals:WaitForChild("Hydromancer"):WaitForChild("WaterBubbleVFX"))

VisualEffectData["Damage"] = require(Visuals:WaitForChild("Status"):WaitForChild("Damage"))
VisualEffectData["Blocked"] = require(Visuals:WaitForChild("Status"):WaitForChild("Blocked"))
VisualEffectData["Burn"] = require(Visuals:WaitForChild("Status"):WaitForChild("Burn"))
VisualEffectData["RunningVFX"] = require(Visuals:WaitForChild("Base"):WaitForChild("RunningVFX"))
VisualEffectData["HydroStack"] = require(Visuals:WaitForChild("Passives"):WaitForChild("HydroStackVFX"))

return VisualEffectData