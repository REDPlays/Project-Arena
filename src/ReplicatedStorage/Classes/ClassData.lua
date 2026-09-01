local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassMoveData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassMoveData"))

local WalkSpeeds = {
    ["Tank"] = 22,
    ["Burst"] = 24,
    ["Brawler"] = 24,
    ["Summoner"] = 24,
    ["Marksman"] = 24,
    ["Support"] = 26,
    ["Assassin"] = 26,
}

local ClassData = {}

ClassData["Base"] = {
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(7, 5, 7),
            Offset = CFrame.new(0, 2.5, -3.5),
        },
        ["QMove"] = {
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 2.5, -2.5),
        },
        ["EMove"] = {
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 2.5, -2.5),
        },
        ["FMove"] = {
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 2.5, -2.5),
        },
    },
}

ClassData["AngelKnight"] = {
    ClassName = "AngelKnight",
    Health = 125,
    Defense = 100,
    Speed = WalkSpeeds.Support,
    Role = "Support",
    Cost = 200,
    Description = "Agressive Healer",
    DamageList = {
        ["M1"] = {8, 8, 8},
        ["Holy Beam"] = 25,
        ["Angelic Charge"] = 10,
        ["Sun Beam"] = 5,
    },
    Cooldowns = {
        ["M1"] = 0.5,
        ["Holy Beam"] = 7,
        ["Angelic Charge"] = 5,
        ["Sun Beam"] = 10,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(12, 5, 7),
            Offset = CFrame.new(0, 4, -4),
        },
        ["Holy Beam"] = {
            Size = Vector3.new(0, 0, 0),
            Offset = CFrame.new(0, 0, 0),
        },
        ["Angelic Charge"] = {
            Size = Vector3.new(7, 7, 7),
            Offset = CFrame.new(0, 3.5, 0),
        },
        ["Sun Beam"] = {
            Size = Vector3.new(6, 6, 20),
            Offset = CFrame.new(0, 3, -12),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({}),
        ["Holy Beam"] = ClassMoveData:SetupModifiers({}),
        ["Angelic Charge"] = ClassMoveData:SetupModifiers({"Slow"}),
        ["Sun Beam"] = ClassMoveData:SetupModifiers({"CameraLock"}),
    },
    MoveDataDurations = {
        ["M1"] = {},
        ["Holy Beam"] = {},
        ["Angelic Charge"] = {Slow = 2},
        ["Sun Beam"] = {},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Holy Beam"] = {},
        ["Angelic Charge"] = {},
        ["Sun Beam"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "AngelKnightM1",
        ["QMove"] = "",
        ["EMove"] = "",
        ["FMove"] = "",
    },
}

ClassData["Pyromancer"] = {
    ClassName = "Pyromancer",
    Health = 100,
    Defense = 100,
    Speed = WalkSpeeds.Burst,
    ProjectileSpeed = 75,
    ProjectileDuration = 1,
    Role = "Burst",
    Cost = 200,
    Ammo = 1, --number of shots per LMB
    ShotDelay = 0.15, --delay between shots(based on ammo)
    Description = "Fire Connoisseur",
    DamageList = {
        ["M1"] = {3, 3, 3},
        ["Triple Fire Ball"] = 4,
        ["Flame thrower"] = 3,
        ["Eruption"] = 25,
    },
    Cooldowns = {
        ["M1"] = 0.5,
        ["Triple Fire Ball"] = 3,
        ["Flame thrower"] = 7,
        ["Eruption"] = 10,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(4, 4, 4),
            Offset = CFrame.new(0, 0, -2),
        },
        ["Triple Fire Ball"] = {
            Size = Vector3.new(3, 3, 3),
            Offset = CFrame.new(0, 0, -1),
        },
        ["Flame thrower"] = {
            Size = Vector3.new(6, 6, 20),
            Offset = CFrame.new(0, 3, -12),
        },
        ["Eruption"] = {
            Size = Vector3.new(20, 20, 20),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({"isProjectile", "Burn"}),
        ["Triple Fire Ball"] = ClassMoveData:SetupModifiers({"Burn", "isProjectile"}),
        ["Flame thrower"] = ClassMoveData:SetupModifiers({"Burn", "CameraLock"}),
        ["Eruption"] = ClassMoveData:SetupModifiers({"Burn"}),
    },
    MoveDataDurations = {
        ["M1"] = {Burn = 3},
        ["Triple Fire Ball"] = {Burn = 3},
        ["Flame thrower"] = {Burn = 3},
        ["Eruption"] = {Burn = 3},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Triple Fire Ball"] = {},
        ["Flame thrower"] = {},
        ["Eruption"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "FireBall",
        ["QMove"] = "FireBall",
        ["EMove"] = "",
        ["FMove"] = "",
    },
}

ClassData["ShieldWarrior"] = {
    ClassName = "ShieldWarrior",
    Health = 250,
    Defense = 150,
    Speed = WalkSpeeds.Tank,
    Role = "Tank",
    Cost = 200,
    Description = "Shield Hero",
    DamageList = {
        ["M1"] = {8, 8, 8},
        ["Shield Slam"] = 20,
        ["Shield Jump"] = 25,
        ["Colosseum"] = 0,
    },
    Cooldowns = {
        ["M1"] = 0.5,
        ["Shield Slam"] = 3.5,
        ["Shield Jump"] = 7,
        ["Colosseum"] = 15,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(7, 5, 5),
            Offset = CFrame.new(0, 4, -4),
        },
        ["Shield Slam"] = {
            Size = Vector3.new(6, 6, 6),
            Offset = CFrame.new(0, 3, -6),
        },
        ["Shield Jump"] = {
            Size = Vector3.new(5, 20, 20),
            Offset = CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0, math.rad(-90)),
        },
        ["Colosseum"] = {
            Size = Vector3.new(20, 20, 20),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({}),
        ["Shield Slam"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Knockup"}),
        ["Shield Jump"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Stunned"}),
        ["Colosseum"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement"}),
    },
    MoveDataDurations = {
        ["M1"] = {},
        ["Shield Slam"] = {Knockup = 50},
        ["Shield Jump"] = {Stunned = 3},
        ["Colosseum"] = {},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Shield Slam"] = {},
        ["Shield Jump"] = {},
        ["Colosseum"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "ShieldWarriorM1",
        ["QMove"] = "ShieldSlam",
        ["EMove"] = "ShieldJump",
        ["FMove"] = "Colosseum",
    },
}

ClassData["Samurai"] = {
    ClassName = "Samurai",
    ignoreLMBMoveCD = false,
    Health = 150,
    Defense = 100,
    Speed = WalkSpeeds.Brawler,
    Role = "Brawler",
    Cost = 200,
    Description = "The way of the blade",
    DamageList = {
        ["M1"] = {4, 4, 4},
        ["Shadow Step"] = 15,
        ["Rapid Slashes"] = 1,
        ["Wind Tornado"] = 25,
    },
    Cooldowns = {
        ["M1"] = 0.5,
        ["Shadow Step"] = 10,
        ["Rapid Slashes"] = 7,
        ["Wind Tornado"] = 15,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(8, 6, 6),
            Offset = CFrame.new(0, 4, -4),
        },
        ["Shadow Step"] = {
            Size = Vector3.new(6, 6, 6),
            Offset = CFrame.new(0, 3, -6),
        },
        ["Rapid Slashes"] = {
            Size = Vector3.new(12, 8, 12),
            Offset = CFrame.new(0, 4, -6),
        },
        ["Wind Tornado"] = {
            Size = Vector3.new(10, 15, 10),
            Offset = CFrame.new(0, 7.5, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({}),
        ["Shadow Step"] = ClassMoveData:SetupModifiers({}),
        ["Rapid Slashes"] = ClassMoveData:SetupModifiers({"Slow", "noMovement"}),
        ["Wind Tornado"] = ClassMoveData:SetupModifiers({"hasEvent", "Slow", "Knockup"}),
    },
    MoveDataDurations = {
        ["M1"] = {},
        ["Shadow Step"] = {},
        ["Rapid Slashes"] = {Slow = 2},
        ["Wind Tornado"] = {Knockup = 50, Slow = 2},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Shadow Step"] = {},
        ["Rapid Slashes"] = {},
        ["Wind Tornado"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "SamuraiM1",
        ["QMove"] = "",
        ["EMove"] = "",
        ["FMove"] = "",
    },
}

ClassData["Engineer"] = {
    ClassName = "Engineer",
    Health = 100,
    Defense = 100,
    Speed = WalkSpeeds.Summoner,
    ProjectileSpeed = 100,
    ProjectileDuration = 1,
    Role = "Summoner",
    Cost = 200,
    Ammo = 4, --number of shots per LMB
    ShotDelay = 0.1, --delay between shots(based on ammo)
    Description = "Master Mechanic",
    DamageList = {
        ["M1"] = {3, 3, 3},
        ["Concussive Mine"] = 10,
        ["Turret"] = 1,
        ["Electro Ball"] = {5, 15},
    },
    Cooldowns = {
        ["M1"] = 1.25,
        ["Concussive Mine"] = 4,
        ["Turret"] = 20,
        ["Electro Ball"] = 15,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(2, 2, 4),
            Offset = {
                CFrame.new(0, 1, -3),
                CFrame.new(0, 1, -3),
                CFrame.new(0, 1, -3),
            },
        },
        ["Concussive Mine"] = {
            Size = Vector3.new(3, 7, 7),
            Size2 = Vector3.new(15, 15, 15),
            Offset = CFrame.new(0, 0, -1),
        },
        ["Turret"] = {
            Size = Vector3.new(2, 2, 4),
            Offset = CFrame.new(0, 0, -2),
        },
        ["Electro Ball"] = {
            Size = {
                Size1 = Vector3.new(8, 8, 8),
                Size2 = Vector3.new(20, 20, 20),
            },
            Offset = CFrame.new(0, 2, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({"isProjectile", "isMultiShot"}),
        ["Concussive Mine"] = ClassMoveData:SetupModifiers({"hasEvent", "Silenced", "Slow"}),
        ["Turret"] = ClassMoveData:SetupModifiers({"noMovement", "CameraLock", "isProjectile"}),
        ["Electro Ball"] = ClassMoveData:SetupModifiers({"noMovement", "Stunned"}),
    },
    MoveDataDurations = {
        ["M1"] = {},
        ["Concussive Mine"] = {Silenced = 2, Slow = 3},
        ["Turret"] = {},
        ["Electro Ball"] = {Stunned = 2},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Concussive Mine"] = {},
        ["Turret"] = {},
        ["Electro Ball"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "EngineerM1",
        ["QMove"] = "",
        ["EMove"] = "Turret",
        ["FMove"] = "",
    },
}

ClassData["Ranger"] = {
    ClassName = "Ranger",
    Health = 100,
    Defense = 100,
    Speed = WalkSpeeds.Marksman,
    ProjectileSpeed = 100,
    ProjectileDuration = 1,
    Role = "Marksman",
    Cost = 200,
    Ammo = 1, --number of shots per LMB
    ShotDelay = 0.1, --delay between shots(based on ammo)
    Description = "Eyes of an Eagle",
    DamageList = {
        ["M1"] = {5, 5, 5},
        ["Piercing Arrow"] = 15,
        ["Net Trap"] = 20,
        ["Explosive Arrow"] = 10,
    },
    Cooldowns = {
        ["M1"] = 0.75,
        ["Piercing Arrow"] = 3,
        ["Net Trap"] = 3,
        ["Explosive Arrow"] = 10,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(2, 2, 4),
            Offset = {
                CFrame.new(1, 1, 0.5),
                CFrame.new(1, 1, 0.5),
                CFrame.new(1, 1, 0.5),
            },
        },
        ["Piercing Arrow"] = {
            Size = Vector3.new(3, 3, 6),
            Offset = CFrame.new(1, 1, 0.5),
        },
        ["Net Trap"] = {
            Size = Vector3.new(3, 7, 7),
            Size2 = Vector3.new(15, 15, 15),
            Offset = CFrame.new(0, 0, -1),
        },
        ["Explosive Arrow"] = {
            Size = Vector3.new(3, 3, 6),
            Size2 = Vector3.new(20, 20, 20),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({"isProjectile", "isMultiShot"}),
        ["Piercing Arrow"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "isProjectile"}),
        ["Net Trap"] = ClassMoveData:SetupModifiers({"hasEvent", "Stunned"}),
        ["Explosive Arrow"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Burn", "isProjectile"}),
    },
    MoveDataDurations = {
        ["M1"] = {},
        ["Piercing Arrow"] = {},
        ["Net Trap"] = {Stunned = 3},
        ["Explosive Arrow"] = {Burn = 3},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Piercing Arrow"] = {},
        ["Net Trap"] = {},
        ["Explosive Arrow"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "RangerM1",
        ["QMove"] = "",
        ["EMove"] = "",
        ["FMove"] = "",
    },
}

ClassData["Shinobi"] = {
    ClassName = "Shinobi",
    ignoreLMBMoveCD = false,
    Health = 125,
    Defense = 100,
    Speed = WalkSpeeds.Assassin,
    Role = "Assassin",
    Cost = 400,
    Description = "Master of the Shadows",
    DamageList = {
        ["M1"] = {3, 3, 3},
        ["Quick Dash"] = 15,
        ["Shuriken Throw"] = 10,
        ["Retreat"] = 25,
    },
    Cooldowns = {
        ["M1"] = 0.4,
        ["Quick Dash"] = 10,
        ["Shuriken Throw"] = 15,
        ["Retreat"] = {0.25, 15},
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(8, 6, 6),
            Offset = CFrame.new(0, 4, -4),
        },
        ["Quick Dash"] = {
            Size = Vector3.new(7, 7, 7),
            Offset = CFrame.new(0, 3.5, 0),
        },
        ["Shuriken Throw"] = {
            Size = Vector3.new(8, 8, 12),
            Offset = CFrame.new(0, 4, -6),
        },
        ["Retreat"] = {
            Size = Vector3.new(10, 15, 10),
            Offset = CFrame.new(0, 7.5, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({}),
        ["Quick Dash"] = ClassMoveData:SetupModifiers({"Slow"}),
        ["Shuriken Throw"] = ClassMoveData:SetupModifiers({"hasEvent"}),
        ["Retreat"] = ClassMoveData:SetupModifiers({"DoubleCooldown"}),
    },
    MoveDataDurations = {
        ["M1"] = {},
        ["Quick Dash"] = {Slow = 2},
        ["Shuriken Throw"] = {},
        ["Retreat"] = {},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Quick Dash"] = {},
        ["Shuriken Throw"] = {},
        ["Retreat"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "ShinobiM1",
        ["QMove"] = "",
        ["EMove"] = "",
        ["FMove"] = "",
    },
}

ClassData["Oni"] = {
    ClassName = "Oni",
    ignoreLMBMoveCD = false,
    Health = 175,
    Defense = 100,
    Speed = WalkSpeeds.Brawler,
    Role = "Brawler",
    Cost = 400,
    Description = "The strongest of warriors",
    DamageList = {
        ["M1"] = {3, 3, 3},
        ["Club Slam"] = {15, 30},
        ["Sumo Rush"] = 20,
        ["Sumo Stance"] = 10,
        ["Enraged"] = 25,
    },
    Cooldowns = {
        ["M1"] = 0.4,
        ["Club Slam"] = 5,
        ["Sumo Rush"] = 15,
        ["Sumo Stance"] = 15,
        ["Enraged"] = 40,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(8, 6, 6),
            Size2 = Vector3.new(12, 9, 9),
            Offset = CFrame.new(0, 4, -4),
            Offset2 = CFrame.new(0, 4.5, -5)
        },
        ["Club Slam"] = {
            Size = Vector3.new(7, 7, 14),
            Offset = CFrame.new(0, 3.5, -7),
        },
        ["Sumo Rush"] = {
            Size = Vector3.new(8, 16, 16),
            Offset = CFrame.new(0, 2, 0),
        },
        ["Sumo Stance"] = {
            Size = Vector3.new(10, 15, 10),
            Offset = CFrame.new(0, 7.5, 0),
        },
        ["Enraged"] = {
            Size = Vector3.new(0, 0, 0),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({}),
        ["Club Slam"] = {
            ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Slow"}),
            ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Slow", "Knockup"})
        },
        ["Sumo Rush"] = ClassMoveData:SetupModifiers({"DoubleCooldown", "Knockup"}),
        ["Sumo Stance"] = ClassMoveData:SetupModifiers({"DoubleCooldown", "Knockup"}),
        ["Enraged"] = ClassMoveData:SetupModifiers({"noMovement"}),
    },
    MoveDataDurations = {
        ["M1"] = {},
        ["Club Slam"] = {
            {Slow = 3,},
            {Slow = 3, Knockup = 50,},
        },
        ["Sumo Rush"] = {Knockup = 35},
        ["Sumo Stance"] = {Knockup = 70},
        ["Enraged"] = {},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Club Slam"] = {},
        ["Sumo Rush"] = {},
        ["Sumo Stance"] = {},
        ["Enraged"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "OniM1",
        ["QMove"] = "",
        ["EMove"] = {"", ""},
        ["FMove"] = "",
    },
}

ClassData["Judge"] = {
    ClassName = "Judge",
    ignoreLMBMoveCD = false,
    Health = 100,
    Defense = 100,
    Speed = WalkSpeeds.Support,
    Role = "Support",
    Cost = 400,
    Description = "Justice Prevails",
    DamageList = {
        ["M1"] = {3, 3, 3},
        ["Club Slam"] = {15, 30},
        ["Sumo Rush"] = 20,
        ["Sumo Stance"] = 10,
        ["Enraged"] = 25,
    },
    Cooldowns = {
        ["M1"] = 0.4,
        ["Club Slam"] = 5,
        ["Sumo Rush"] = 15,
        ["Sumo Stance"] = 15,
        ["Enraged"] = 40,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(8, 6, 6),
            Size2 = Vector3.new(12, 9, 9),
            Offset = CFrame.new(0, 4, -4),
            Offset2 = CFrame.new(0, 4.5, -5)
        },
        ["Club Slam"] = {
            Size = Vector3.new(7, 7, 14),
            Offset = CFrame.new(0, 3.5, -7),
        },
        ["Sumo Rush"] = {
            Size = Vector3.new(8, 16, 16),
            Offset = CFrame.new(0, 2, 0),
        },
        ["Sumo Stance"] = {
            Size = Vector3.new(10, 15, 10),
            Offset = CFrame.new(0, 7.5, 0),
        },
        ["Enraged"] = {
            Size = Vector3.new(0, 0, 0),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({}),
        ["Club Slam"] = {
            ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Slow"}),
            ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Slow", "Knockup"})
        },
        ["Sumo Rush"] = ClassMoveData:SetupModifiers({"DoubleCooldown", "Knockup"}),
        ["Sumo Stance"] = ClassMoveData:SetupModifiers({"DoubleCooldown", "Knockup"}),
        ["Enraged"] = ClassMoveData:SetupModifiers({"noMovement"}),
    },
    MoveDataDurations = {
        ["M1"] = {},
        ["Club Slam"] = {
            {Slow = 3,},
            {Slow = 3, Knockup = 50,},
        },
        ["Sumo Rush"] = {Knockup = 35},
        ["Sumo Stance"] = {Knockup = 70},
        ["Enraged"] = {},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Club Slam"] = {},
        ["Sumo Rush"] = {},
        ["Sumo Stance"] = {},
        ["Enraged"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "OniM1",
        ["QMove"] = "",
        ["EMove"] = {"", ""},
        ["FMove"] = "",
    },
}

ClassData["Hydromancer"] = {
    ClassName = "Hydromancer",
    Health = 100,
    Defense = 100,
    Speed = WalkSpeeds.Support,
    ProjectileSpeed = 75,
    ProjectileDuration = 1,
    Role = "Burst",
    Cost = 200,
    Ammo = 1, --number of shots per LMB
    ShotDelay = 0.15, --delay between shots(based on ammo)
    Description = "Sustainer of life",
    DamageList = {
        ["M1"] = {7, 7, 7},
        ["Water Wave"] = 4,
        ["Water Bubble"] = 3,
        ["Whirlpool"] = 2,
    }, 
    Cooldowns = {
        ["M1"] = 0.5,
        ["Water Wave"] = 3,
        ["Water Bubble"] = 7,
        ["Whirlpool"] = 10,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 0, -2),
        },
        ["Water Wave"] = {
            Size = Vector3.new(8, 9, 3),
            Offset = CFrame.new(0, 0, -1),
        },
        ["Water Bubble"] = {
            Size = Vector3.new(8, 8, 8),
            Offset = CFrame.new(0, 3, 0),
        },
        ["Whirlpool"] = {
            Size = Vector3.new(20, 20, 20),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({"isProjectile", "HydroStack"}),
        ["Water Wave"] = ClassMoveData:SetupModifiers({"Knockback"}),
        ["Water Bubble"] = ClassMoveData:SetupModifiers({}),
        ["Whirlpool"] = ClassMoveData:SetupModifiers({"Slow"}),
    },
    MoveDataDurations = {
        ["M1"] = {},
        ["Water Wave"] = {Knockback = 50},
        ["Water Bubble"] = {},
        ["Whirlpool"] = {Slow = 1},
    },
    MoveDataAdditional = {
        ["M1"] = {},
        ["Water Wave"] = {},
        ["Water Bubble"] = {},
        ["Whirlpool"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "WaterBall",
        ["QMove"] = "",
        ["EMove"] = "",
        ["FMove"] = "",
    },
}

ClassData["Reaper"] = {
    ClassName = "Reaper",
    HasCompanion = true,
    ignoreLMBMoveCD = false,
    Health = 150,
    Defense = 100,
    Speed = WalkSpeeds.Summoner,
    Role = "Summoner",
    Cost = 200,
    Description = "Bringer of Death",
    DamageList = {
        ["M1"] = {4, 4, 4},
        ["Soul Slice"] = 15,
        ["Reapers Blight"] = 15,
        ["Reapers Calling"] = 1,
        ["Grim Reaping"] = 25,
        ["Enshroud"] = 1,
    },
    Cooldowns = {
        ["M1"] = 0.5,
        ["Soul Slice"] = 5,
        ["Reapers Blight"] = 10,
        ["Reapers Calling"] = 1,
        ["Grim Reaping"] = 2,
        ["Enshroud"] = 10,
    },
    Hitboxes = {
        ["M1"] = {
            Size = Vector3.new(8, 6, 6),
            Offset = CFrame.new(0, 4, -3),
            Size2 = Vector3.new(16, 6, 12),
            Offset2 = CFrame.new(0, 4, -6),
        },
        ["Soul Slice"] = {
            Size = Vector3.new(18, 6, 10),
            Offset = CFrame.new(0, 3, -4),
        },
        ["Reapers Blight"] = {
            Size = Vector3.new(12, 8, 12),
            Offset = CFrame.new(0, 4, -6),
        },
        ["Reapers Calling"] = {
            Size = Vector3.new(0, 0, 0),
            Offset = CFrame.new(0, 0, 0),
        },
        ["Grim Reaping"] = {
            Size = Vector3.new(14, 6, 14),
            Offset = CFrame.new(0, 3, 0),
        },
        ["Enshroud"] = {
            Size = Vector3.new(0, 0, 0),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["M1"] = ClassMoveData:SetupModifiers({"LifeSteal"}),
        ["Soul Slice"] = ClassMoveData:SetupModifiers({"DoubleCooldown", "LifeSteal", "hasEvent"}),
        ["Reapers Blight"] = ClassMoveData:SetupModifiers({"DoubleCooldown", "Burn"}),
        ["Reapers Calling"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "DoubleCooldown"}),
        ["Grim Reaping"] = ClassMoveData:SetupModifiers({"DoubleCooldown"}),
        ["Enshroud"] = ClassMoveData:SetupModifiers({"DoubleCooldown", "noMovement", "hasEvent"})
    },
    MoveDataDurations = {
        ["M1"] = {LifeSteal = 0},
        ["Soul Slice"] = {LifeSteal = 0},
        ["Reapers Blight"] = {Burn = 3},
        ["Reapers Calling"] = {},
        ["Grim Reaping"] = {},
        ["Enshroud"] = {},
    },
    MoveDataAdditional = {
        ["M1"] = {
            LifeSteal = {heal = 0.5},
        },
        ["Soul Slice"] = {
            LifeSteal = {heal = 10},
        },
        ["Reapers Blight"] = {},
        ["Reapers Calling"] = {},
        ["Grim Reaping"] = {},
        ["Enshroud"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "ReaperM1",
        ["QMove"] = "",
        ["EMove"] = "",
        ["FMove"] = "",
    },
}

return ClassData