local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RepFiles = ReplicatedStorage:WaitForChild("RepFiles")
local CombatFiles = RepFiles:WaitForChild("Combat")
local Moves = CombatFiles:WaitForChild("Moves")

local MoveData = {}

MoveData["AngelKnight"] = {
    ["Holy Beam"] = require(Moves.AngelKnight.HolyBeam),
    ["Angelic Charge"] = require(Moves.AngelKnight.AngelicCharge),
    ["Sun Beam"] = require(Moves.AngelKnight.SunBeam),
}

MoveData["Pyromancer"] = {
    ["Triple Fire Ball"] = require(Moves.Pyromancer.TripleFireBall),
    ["Flame thrower"] = require(Moves.Pyromancer.Flamethrower),
    ["Eruption"] = require(Moves.Pyromancer.Eruption),
}

MoveData["ShieldWarrior"] = {
    ["Shield Slam"] = require(Moves.ShieldWarrior.ShieldSlam),
    ["Shield Jump"] = require(Moves.ShieldWarrior.ShieldJump),
    ["Colosseum"] = require(Moves.ShieldWarrior.Colosseum),
}

MoveData["Samurai"] = {
    ["Shadow Step"] = require(Moves.Samurai.ShadowStep),
    ["Rapid Slashes"] = require(Moves.Samurai.RapidSlashes),
    ["Wind Tornado"] = require(Moves.Samurai.WindTornado),
}

MoveData["Engineer"] = {
    ["Concussive Mine"] = require(Moves.Engineer.ConcussiveBomb),
    ["Turret"] = require(Moves.Engineer.Turret),
    ["Electro Ball"] = require(Moves.Engineer.ElectroBall),
}

MoveData["Ranger"] = {
    ["Piercing Arrow"] = require(Moves.Ranger.PiercingArrow),
    ["Net Trap"] = require(Moves.Ranger.NetTrap),
    ["Explosive Arrow"] = require(Moves.Ranger.ExplosiveArrow),
}

MoveData["Shinobi"] = {
    ["Quick Dash"] = require(Moves.Shinobi.QuickDash),
    ["Shuriken Throw"] = require(Moves.Shinobi.ShurikenThrow),
    ["Retreat"] = require(Moves.Shinobi.Retreat),
}

MoveData["Oni"] = {
    ["Club Slam"] = require(Moves.Oni.ClubSlam),
    ["Sumo Rush"] = require(Moves.Oni.SumoRush),
    ["Sumo Stance"] = require(Moves.Oni.SumoStance),
    ["Enraged"] = require(Moves.Oni.Enraged),
}

MoveData["Judge"] = {
    ["Club Slam"] = require(Moves.Oni.ClubSlam),
    ["Sumo Rush"] = require(Moves.Oni.SumoRush),
    ["Sumo Stance"] = require(Moves.Oni.SumoStance),
    ["Enraged"] = require(Moves.Oni.Enraged),
}

MoveData["Hydromancer"] = {
    ["Water Wave"] = require(Moves.Hydromancer.WaterWave),
    ["Water Bubble"] = require(Moves.Hydromancer.WaterBubble),
    ["Whirlpool"] = require(Moves.Hydromancer.Whirlpool),
}

 MoveData["Reaper"] = {
    ["Soul Slice"] = require(Moves.Reaper.SoulSlice),
    ["Reapers Blight"] = require(Moves.Reaper.ReapersBlight),
    ["Reapers Calling"] = require(Moves.Reaper.ReapersCalling),
    ["Grim Reaping"] = require(Moves.Reaper.GrimReaping),
    ["Enshroud"] = require(Moves.Reaper.Enshroud),
}

return MoveData