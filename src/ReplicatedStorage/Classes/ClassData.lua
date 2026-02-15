local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassMoveData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassMoveData"))

local WalkSpeeds = {
    ["Tank"] = 20,
    ["Burst"] = 24,
    ["Brawler"] = 24,
    ["Summoner"] = 24,
    ["Marksman"] = 24,
    ["Support"] = 28,
    ["Assassin"] = 28,
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
    Health = 125,
    Defense = 100,
    Speed = WalkSpeeds.Support,
    Role = "Support",
    Cost = 200,
    Description = "Agressive Healer",
    DamageList = {
        ["LMBMove"] = {8, 8, 8},
        ["QMove"] = 25,
        ["EMove"] = 10,
        ["FMove"] = 5,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 7 ,
        ["EMove"] = 5,
        ["FMove"] = 10,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(12, 5, 7),
            Offset = CFrame.new(0, 4, -4),
        },
        ["QMove"] = {
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 2.5, -2.5),
        },
        ["EMove"] = {
            Size = Vector3.new(7, 7, 7),
            Offset = CFrame.new(0, 3.5, 0),
        },
        ["FMove"] = {
            Size = Vector3.new(6, 6, 20),
            Offset = CFrame.new(0, 3, -12),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({}),
        ["QMove"] = ClassMoveData:SetupModifiers({}),
        ["EMove"] = ClassMoveData:SetupModifiers({"Slow"}),
        ["FMove"] = ClassMoveData:SetupModifiers({"CameraLock"}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {},
        ["QMove"] = {},
        ["EMove"] = {Slow = 2},
        ["FMove"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "AngelKnightM1",
        ["QMove"] = "HolyBeam",
        ["EMove"] = "AngelicCharge",
        ["FMove"] = "SunBeam",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Holy Beam",
        ["EMove"] = "Angelic Charge",
        ["FMove"] = "Sun Beam",
    },
}

ClassData["Pyromancer"] = {
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
        ["LMBMove"] = {3, 3, 3},
        ["QMove"] = 4,
        ["EMove"] = 3,
        ["FMove"] = 20,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 3,
        ["EMove"] = 7,
        ["FMove"] = 10,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(4, 4, 4),
            Offset = CFrame.new(0, 0, -2),
        },
        ["QMove"] = {
            Size = Vector3.new(3, 3, 3),
            Offset = CFrame.new(0, 0, -1),
        },
        ["EMove"] = {
            Size = Vector3.new(6, 6, 20),
            Offset = CFrame.new(0, 3, -12),
        },
        ["FMove"] = {
            Size = Vector3.new(20, 20, 20),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({"isProjectile", "Burn"}),
        ["QMove"] = ClassMoveData:SetupModifiers({"Burn"}),
        ["EMove"] = ClassMoveData:SetupModifiers({"Burn", "CameraLock"}),
        ["FMove"] = ClassMoveData:SetupModifiers({"Burn"}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {Burn = 3},
        ["QMove"] = {Burn = 3},
        ["EMove"] = {Burn = 3},
        ["FMove"] = {Burn = 3},
    },
    VisualEffects = {
        ["LMBMove"] = "FireBall",
        ["QMove"] = "FireBall",
        ["EMove"] = "Flamethrower",
        ["FMove"] = "Eruption",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Triple Fire Ball",
        ["EMove"] = "Flame thrower",
        ["FMove"] = "Eruption",
    },
}

ClassData["ShieldWarrior"] = {
    Health = 250,
    Defense = 150,
    Speed = WalkSpeeds.Tank,
    Role = "Tank",
    Cost = 200,
    Description = "Shield Hero",
    DamageList = {
        ["LMBMove"] = {8, 8, 8},
        ["QMove"] = 20,
        ["EMove"] = 25,
        ["FMove"] = 0,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 3.5,
        ["EMove"] = 7,
        ["FMove"] = 15,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(7, 5, 5),
            Offset = CFrame.new(0, 4, -4),
        },
        ["QMove"] = {
            Size = Vector3.new(6, 6, 6),
            Offset = CFrame.new(0, 3, -6),
        },
        ["EMove"] = {
            Size = Vector3.new(5, 20, 20),
            Offset = CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0, math.rad(-90)),
        },
        ["FMove"] = {
            Size = Vector3.new(20, 20, 20),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({}),
        ["QMove"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Knockup"}),
        ["EMove"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Stunned"}),
        ["FMove"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement"}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {},
        ["QMove"] = {Knockup = 50},
        ["EMove"] = {Stunned = 3},
        ["FMove"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "ShieldWarriorM1",
        ["QMove"] = "ShieldSlam",
        ["EMove"] = "ShieldJump",
        ["FMove"] = "Colosseum",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Shield Slam",
        ["EMove"] = "Shield Jump",
        ["FMove"] = "Colosseum",
    },
}

ClassData["Samurai"] = {
    ignoreLMBMoveCD = false,
    Health = 150,
    Defense = 100,
    Speed = WalkSpeeds.Brawler,
    Role = "Brawler",
    Cost = 200,
    Description = "The way of the blade",
    DamageList = {
        ["LMBMove"] = {4, 4, 4},
        ["QMove"] = 15,
        ["EMove"] = 1,
        ["FMove"] = 25,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 10,
        ["EMove"] = 7,
        ["FMove"] = 15,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(8, 6, 6),
            Offset = CFrame.new(0, 4, -4),
        },
        ["QMove"] = {
            Size = Vector3.new(6, 6, 6),
            Offset = CFrame.new(0, 3, -6),
        },
        ["EMove"] = {
            Size = Vector3.new(12, 8, 12),
            Offset = CFrame.new(0, 4, -6),
        },
        ["FMove"] = {
            Size = Vector3.new(10, 15, 10),
            Offset = CFrame.new(0, 7.5, 0),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({}),
        ["QMove"] = ClassMoveData:SetupModifiers({}),
        ["EMove"] = ClassMoveData:SetupModifiers({"Slow", "noMovement"}),
        ["FMove"] = ClassMoveData:SetupModifiers({"hasEvent", "Slow", "Knockup"}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {},
        ["QMove"] = {},
        ["EMove"] = {Slow = 2},
        ["FMove"] = {Knockup = 50, Slow = 2},
    },
    VisualEffects = {
        ["LMBMove"] = "SamuraiM1",
        ["QMove"] = "ShadowStep",
        ["EMove"] = "RapidSlashes",
        ["FMove"] = "WindTornado",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Shadow Step",
        ["EMove"] = "Rapid Slashes",
        ["FMove"] = "Wind Tornado",
    },
}

ClassData["Engineer"] = {
    Health = 100,
    Defense = 100,
    Speed = WalkSpeeds.Summoner,
    ProjectileSpeed = 150,
    ProjectileDuration = 1,
    Role = "Summoner",
    Cost = 200,
    Ammo = 4, --number of shots per LMB
    ShotDelay = 0.1, --delay between shots(based on ammo)
    Description = "Master Mechanic",
    DamageList = {
        ["LMBMove"] = {3, 3, 3},
        ["QMove"] = 10,
        ["EMove"] = 1,
        ["FMove"] = {5, 15},
    },
    Cooldowns = {
        ["LMBMove"] = 1.25,
        ["QMove"] = 4,
        ["EMove"] = 20,
        ["FMove"] = 15,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(2, 2, 4),
            Offset = {
                CFrame.new(0, 1, -3),
                CFrame.new(0, 1, -3),
                CFrame.new(0, 1, -3),
            },
        },
        ["QMove"] = {
            Size = Vector3.new(1, 1, 1),
            Size2 = Vector3.new(15, 15, 15),
            Offset = CFrame.new(0, 0, -1),
        },
        ["EMove"] = {
            Size = Vector3.new(2, 2, 4),
            Offset = CFrame.new(0, 0, -2),
        },
        ["FMove"] = {
            Size = {
                Size1 = Vector3.new(8, 8, 8),
                Size2 = Vector3.new(20, 20, 20),
            },
            Offset = CFrame.new(0, 2, 0),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({"isProjectile", "isMultiShot"}),
        ["QMove"] = ClassMoveData:SetupModifiers({"hasEvent", "Silenced"}),
        ["EMove"] = ClassMoveData:SetupModifiers({"noMovement", "CameraLock"}),
        ["FMove"] = ClassMoveData:SetupModifiers({"noMovement", "Stunned"}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {},
        ["QMove"] = {Silenced = 2},
        ["EMove"] = {},
        ["FMove"] = {Stunned = 2},
    },
    VisualEffects = {
        ["LMBMove"] = "EngineerM1",
        ["QMove"] = "ConcussiveBomb",
        ["EMove"] = "Turret",
        ["FMove"] = "ElectroBall",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Concussive Bomb",
        ["EMove"] = "Turret",
        ["FMove"] = "Electro Ball",
    },
}

ClassData["Ranger"] = {
    Health = 100,
    Defense = 100,
    Speed = WalkSpeeds.Marksman,
    ProjectileSpeed = 150,
    ProjectileDuration = 1,
    Role = "Marksman",
    Cost = 200,
    Ammo = 1, --number of shots per LMB
    ShotDelay = 0.1, --delay between shots(based on ammo)
    Description = "Eyes of an Eagle",
    DamageList = {
        ["LMBMove"] = {5, 5, 5},
        ["QMove"] = 15,
        ["EMove"] = 20,
        ["FMove"] = 10,
    },
    Cooldowns = {
        ["LMBMove"] = .75,
        ["QMove"] = 3,
        ["EMove"] = 3,
        ["FMove"] = 10,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(2, 2, 4),
            Offset = {
                CFrame.new(1, 1, 0.5),
                CFrame.new(1, 1, 0.5),
                CFrame.new(1, 1, 0.5),
            },
        },
        ["QMove"] = {
            Size = Vector3.new(3, 3, 6),
            Offset = CFrame.new(1, 1, 0.5),
        },
        ["EMove"] = {
            Size = Vector3.new(3, 7, 7),
            Size2 = Vector3.new(15, 15, 15),
            Offset = CFrame.new(0, 0, -1),
        },
        ["FMove"] = {
            Size = Vector3.new(3, 3, 6),
            Size2 = Vector3.new(20, 20, 20),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({"isProjectile", "isMultiShot"}),
        ["QMove"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement"}),
        ["EMove"] = ClassMoveData:SetupModifiers({"hasEvent", "Stunned"}),
        ["FMove"] = ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Burn"}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {},
        ["QMove"] = {},
        ["EMove"] = {Stunned = 3},
        ["FMove"] = {Burn = 3},
    },
    VisualEffects = {
        ["LMBMove"] = "RangerM1",
        ["QMove"] = "PiercingArrow",
        ["EMove"] = "NetTrap",
        ["FMove"] = "ExplosiveArrow",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Piercing Arrow",
        ["EMove"] = "Net Trap",
        ["FMove"] = "Explosive Arrow",
    },
}

ClassData["Shinobi"] = {
    ignoreLMBMoveCD = false,
    Health = 125,
    Defense = 100,
    Speed = WalkSpeeds.Assassin,
    Role = "Assassin",
    Cost = 400,
    Description = "Master of the Shadows",
    DamageList = {
        ["LMBMove"] = {3, 3, 3},
        ["QMove"] = 15,
        ["EMove"] = 10,
        ["FMove"] = 25,
    },
    Cooldowns = {
        ["LMBMove"] = .4,
        ["QMove"] = 10,
        ["EMove"] = 15,
        ["FMove"] = {0.25, 15},
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(8, 6, 6),
            Offset = CFrame.new(0, 4, -4),
        },
        ["QMove"] = {
            Size = Vector3.new(7, 7, 7),
            Offset = CFrame.new(0, 3.5, 0),
        },
        ["EMove"] = {
            Size = Vector3.new(8, 8, 12),
            Offset = CFrame.new(0, 4, -6),
        },
        ["FMove"] = {
            Size = Vector3.new(10, 15, 10),
            Offset = CFrame.new(0, 7.5, 0),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({}),
        ["QMove"] = ClassMoveData:SetupModifiers({"Slow"}),
        ["EMove"] = ClassMoveData:SetupModifiers({"hasEvent"}),
        ["FMove"] = ClassMoveData:SetupModifiers({"DoubleCooldown"}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {},
        ["QMove"] = {Slow = 2},
        ["EMove"] = {},
        ["FMove"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "ShinobiM1",
        ["QMove"] = "QuickDash",
        ["EMove"] = "ShurikenThrow",
        ["FMove"] = "Retreat",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Quick Dash",
        ["EMove"] = "Shuriken Throw",
        ["FMove"] = "Retreat",
    },
}

ClassData["Oni"] = {
    ignoreLMBMoveCD = false,
    Health = 175,
    Defense = 100,
    Speed = WalkSpeeds.Brawler,
    Role = "Brawler",
    Cost = 400,
    Description = "The strongest of warriors",
    DamageList = {
        ["LMBMove"] = {3, 3, 3},
        ["QMove"] = {15, 30},
        ["EMove"] = {20, 10},
        ["FMove"] = 25,
    },
    Cooldowns = {
        ["LMBMove"] = .4,
        ["QMove"] = 5,
        ["EMove"] = {15, 15},
        ["FMove"] = 40,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(8, 6, 6),
            Size2 = Vector3.new(12, 9, 9),
            Offset = CFrame.new(0, 4, -4),
            Offset2 = CFrame.new(0, 4.5, -5)
        },
        ["QMove"] = {
            Size = Vector3.new(7, 7, 14),
            Offset = CFrame.new(0, 3.5, -7),
        },
        ["EMove"] = {
            Size = Vector3.new(8, 16, 16),
            Offset = CFrame.new(0, 2, 0),
        },
        ["FMove"] = {
            Size = Vector3.new(10, 15, 10),
            Offset = CFrame.new(0, 7.5, 0),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({}),
        ["QMove"] = {
            ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Slow"}),
            ClassMoveData:SetupModifiers({"hasEvent", "noMovement", "Slow", "Knockup"})
        },
        ["EMove"] = {
            ClassMoveData:SetupModifiers({"DoubleCooldown", "Knockup"}),
            ClassMoveData:SetupModifiers({"DoubleCooldown", "Knockup"})
        },
        ["FMove"] = ClassMoveData:SetupModifiers({"noMovement"}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {},
        ["QMove"] = {{Slow = 3}, {Slow = 3, Knockup = 50}},
        ["EMove"] = {{Knockup = 35}, {Knockup = 70}},
        ["FMove"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "OniM1",
        ["QMove"] = "ClubSlam",
        ["EMove"] = {"SumoRush", "SumoStanceVFX"},
        ["FMove"] = "EnragedVFX",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Club Slam",
        ["EMove"] = {"Sumo Rush", "Sumo Stance"},
        ["FMove"] = "Enrage",
    },
}

ClassData["Judge"] = {
    ignoreLMBMoveCD = false,
    Health = 100,
    Defense = 100,
    Speed = WalkSpeeds.Support,
    Role = "Support",
    Cost = 400,
    Description = "Justice Prevails",
    DamageList = {
        ["LMBMove"] = {3, 3, 3},
        ["QMove"] = {15, 30},
        ["EMove"] = {20, 10},
        ["FMove"] = 25,
    },
    Cooldowns = {
        ["LMBMove"] = .4,
        ["QMove"] = 5,
        ["EMove"] = {15, 15},
        ["FMove"] = 40,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(8, 6, 6),
            Size2 = Vector3.new(12, 9, 9),
            Offset = CFrame.new(0, 4, -4),
            Offset2 = CFrame.new(0, 4.5, -5)
        },
        ["QMove"] = {
            Size = Vector3.new(7, 7, 14),
            Offset = CFrame.new(0, 3.5, -7),
        },
        ["EMove"] = {
            Size = Vector3.new(8, 16, 16),
            Offset = CFrame.new(0, 2, 0),
        },
        ["FMove"] = {
            Size = Vector3.new(10, 15, 10),
            Offset = CFrame.new(0, 7.5, 0),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({}),
        ["QMove"] = ClassMoveData:SetupModifiers({}),
        ["EMove"] = ClassMoveData:SetupModifiers({}),
        ["FMove"] = ClassMoveData:SetupModifiers({}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {},
        ["QMove"] = {},
        ["EMove"] = {},
        ["FMove"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "OniM1",
        ["QMove"] = "ClubSlam",
        ["EMove"] = {"SumoRush", "SumoStanceVFX"},
        ["FMove"] = "EnragedVFX",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Club Slam",
        ["EMove"] = {"Sumo Rush", "Sumo Stance"},
        ["FMove"] = "Enrage",
    },
}

ClassData["Hydromancer"] = {
    Health = 100,
    Defense = 100,
    Speed = WalkSpeeds.Support,
    ProjectileSpeed = 60,
    ProjectileDuration = 2,
    Role = "Burst",
    Cost = 200,
    Ammo = 1, --number of shots per LMB
    ShotDelay = 0.15, --delay between shots(based on ammo)
    Description = "Sustainer of life",
    DamageList = {
        ["LMBMove"] = {3, 3, 3},
        ["QMove"] = 4,
        ["EMove"] = 3,
        ["FMove"] = 20,
    }, 
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 3,
        ["EMove"] = 7,
        ["FMove"] = 10,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 0, -2),
        },
        ["QMove"] = {
            Size = Vector3.new(3, 3, 3),
            Offset = CFrame.new(0, 0, -1),
        },
        ["EMove"] = {
            Size = Vector3.new(6, 6, 20),
            Offset = CFrame.new(0, 3, -12),
        },
        ["FMove"] = {
            Size = Vector3.new(20, 20, 20),
            Offset = CFrame.new(0, 0, 0),
        },
    },
    MoveData = {
        ["LMBMove"] = ClassMoveData:SetupModifiers({"isProjectile", "HydroStack"}),
        ["QMove"] = ClassMoveData:SetupModifiers({}),
        ["EMove"] = ClassMoveData:SetupModifiers({}),
        ["FMove"] = ClassMoveData:SetupModifiers({}),
    },
    MoveDataDurations = {
        ["LMBMove"] = {},
        ["QMove"] = {},
        ["EMove"] = {},
        ["FMove"] = {},
    },
    VisualEffects = {
        ["LMBMove"] = "WaterBall",
        ["QMove"] = "FireBall",
        ["EMove"] = "Flamethrower",
        ["FMove"] = "Eruption",
    },
    MoveName = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Triple Fire Ball",
        ["EMove"] = "Flame thrower",
        ["FMove"] = "Eruption",
    },
}


return ClassData