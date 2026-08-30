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
    ["QMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Engineer:WaitForChild("ConcussiveBomb")),
    ["EMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Engineer:WaitForChild("Turret")),
    ["FMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Engineer:WaitForChild("ElectroBall")),
}

MoveData["Ranger"] = {
    ["QMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Ranger:WaitForChild("PiecingArrow")),
    ["EMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Ranger:WaitForChild("NetTrap")),
    ["FMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Ranger:WaitForChild("ExplosiveArrow")),
}

MoveData["Shinobi"] = {
    ["QMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Shinobi:WaitForChild("QuickDash")),
    ["EMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Shinobi:WaitForChild("ShurikenThrow")),
    ["FMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Shinobi:WaitForChild("Retreat")),
}

MoveData["Oni"] = {
    ["Club Slam"] = require(Moves.Oni.ClubSlam),
    ["Sumo Rush"] = require(Moves.Oni.SumoRush),
    ["Sumo Stance"] = require(Moves.Oni.SumoStance),
    ["Enraged"] = require(Moves.Oni.Enraged),
}

MoveData["Judge"] = {
    ["QMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Oni:WaitForChild("ClubSlam")),
    ["EMove"] = {
        [1] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Oni:WaitForChild("SumoRush")),
        [2] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Oni:WaitForChild("SumoStance")),
    },
    ["FMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Oni:WaitForChild("Enraged")),
}

MoveData["Hydromancer"] = {
    ["QMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Hydromancer:WaitForChild("WaterWave")),
    ["EMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Hydromancer:WaitForChild("WaterBubble")),
    ["FMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Hydromancer:WaitForChild("Whirlpool")),
}

 MoveData["Reaper"] = {
    ["QMove"] = {
        [1] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Reaper:WaitForChild("SoulSlice")),
        [2] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Reaper:WaitForChild("ReapersBlight")),
    },
    ["EMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Reaper:WaitForChild("ReapersCalling")),
    ["FMove"] = {
        [1] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Reaper:WaitForChild("GrimReaping")),
        [2] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves").Reaper:WaitForChild("Enshroud")),
    },
}

return MoveData