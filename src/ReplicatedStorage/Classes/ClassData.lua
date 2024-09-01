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
    Health = 100,
    Defense = 100,
    Speed = 35,
    Role = "Support",
    Cost = 200,
    Description = "Agressive Healer",
    DamageList = {
        ["LMBMove"] = {8, 8, 8},
        ["QMove"] = 15,
        ["EMove"] = 10,
        ["FMove"] = 3,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 10,
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
        ["LMBMove"] = {
            isAOE = false,
            isProjectile = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            ignoreLMBMoveCD = false,
            Silenced = false,
        },
        ["QMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
        ["EMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = true,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
        ["FMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = true,
            Knockup = false,
            Silenced = false,
        },
    },
    VisualEffects = {
        ["LMBMove"] = "AngelKnightM1",
        ["QMove"] = "HolyBeam",
        ["EMove"] = "AngelicCharge",
        ["FMove"] = "SunBeam",
    }
}

ClassData["Pyromancer"] = {
    Health = 100,
    Defense = 100,
    Speed = 30,
    ProjectileSpeed = 50,
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
        ["LMBMove"] = {
            isAOE = false,
            isProjectile = true,
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            ignoreLMBMoveCD = false,
            isMultiShot = false,
            Silenced = false,
        },
        ["QMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
        ["EMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = true,
            Knockup = false,
            Silenced = false,
        },
        ["FMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
    },
    VisualEffects = {
        ["LMBMove"] = "FireBall",
        ["QMove"] = "FireBall",
        ["EMove"] = "Flamethrower",
        ["FMove"] = "Eruption",
    }
}

ClassData["ShieldWarrior"] = {
    Health = 250,
    Defense = 150,
    Speed = 27,
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
        ["EMove"] = 10,
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
        ["LMBMove"] = {
            isAOE = false,
            isProjectile = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            ignoreLMBMoveCD = false,
            Silenced = false,
        },
        ["QMove"] = {
            hasEvent = true,
            noMovement = true,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = true,
            Silenced = false,
        },
        ["EMove"] = {
            hasEvent = true,
            noMovement = true,
            Stunned = true,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
        ["FMove"] = {
            hasEvent = true,
            noMovement = true,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
    },
    VisualEffects = {
        ["LMBMove"] = "ShieldWarriorM1",
        ["QMove"] = "ShieldSlam",
        ["EMove"] = "ShieldJump",
        ["FMove"] = "SunBeam",
    }
}

ClassData["Samurai"] = {
    ignoreLMBMoveCD = false,
    Health = 100,
    Defense = 100,
    Speed = 35,
    Role = "Brawler",
    Cost = 200,
    Description = "The way of the blade",
    DamageList = {
        ["LMBMove"] = {8, 8, 8},
        ["QMove"] = 15,
        ["EMove"] = 1,
        ["FMove"] = 25,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 5,
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
        ["LMBMove"] = {
            isAOE = false,
            isProjectile = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            ignoreLMBMoveCD = false,
            Silenced = false,
        },
        ["QMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
        ["EMove"] = {
            hasEvent = false,
            noMovement = true,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
        ["FMove"] = {
            hasEvent = true,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = true,
            CameraLock = false,
            Knockup = true,
            Silenced = false,
        },
    },
    VisualEffects = {
        ["LMBMove"] = "SamuraiM1",
        ["QMove"] = "ShadowStep",
        ["EMove"] = "RapidSlashes",
        ["FMove"] = "WindTornado",
    }
}

ClassData["Engineer"] = {
    Health = 90,
    Defense = 100,
    Speed = 24,
    ProjectileSpeed = 100,
    Role = "Summoner",
    Cost = 200,
    Ammo = 3, --number of shots per LMB
    ShotDelay = 0.15, --delay between shots(based on ammo)
    Description = "Master Mechanic",
    DamageList = {
        ["LMBMove"] = {3, 3, 3},
        ["QMove"] = 10,
        ["EMove"] = 1,
        ["FMove"] = {5, 15},
    },
    Cooldowns = {
        ["LMBMove"] = .75,
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
        ["LMBMove"] = {
            isAOE = false,
            isProjectile = true,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            ignoreLMBMoveCD = false,
            isMultiShot = true,
            Silenced = false,
        },
        ["QMove"] = {
            hasEvent = true,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = true,
        },
        ["EMove"] = {
            hasEvent = false,
            noMovement = true,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = true,
            Knockup = false,
            Silenced = false,
        },
        ["FMove"] = {
            hasEvent = false,
            noMovement = true,
            Stunned = true,
            Burn = false,
            Slow = true,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
    },
    VisualEffects = {
        ["LMBMove"] = "EngineerM1",
        ["QMove"] = "ConcussiveBomb",
        ["EMove"] = "Turret",
        ["FMove"] = "ElectroBall",
    }
}

ClassData["Ranger"] = {
    Health = 90,
    Defense = 100,
    Speed = 24,
    ProjectileSpeed = 100,
    Role = "Marksman",
    Cost = 200,
    Ammo = 1, --number of shots per LMB
    ShotDelay = 0.15, --delay between shots(based on ammo)
    Description = "Eyes of an Eagle",
    DamageList = {
        ["LMBMove"] = {7, 7, 7},
        ["QMove"] = 15,
        ["EMove"] = 10,
        ["FMove"] = 10,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
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
            Size = Vector3.new(2, 2, 2),
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
        ["LMBMove"] = {
            isAOE = false,
            isProjectile = true,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            ignoreLMBMoveCD = true,
            isMultiShot = false,
            Silenced = false,
        },
        ["QMove"] = {
            hasEvent = true,
            noMovement = true,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
        ["EMove"] = {
            hasEvent = true,
            noMovement = false,
            Stunned = true,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
        ["FMove"] = {
            hasEvent = true,
            noMovement = true,
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = false,
            Knockup = false,
            Silenced = false,
        },
    },
    VisualEffects = {
        ["LMBMove"] = "RangerM1",
        ["QMove"] = "PiercingArrow",
        ["EMove"] = "NetTrap",
        ["FMove"] = "ExplosiveArrow",
    }
}

return ClassData