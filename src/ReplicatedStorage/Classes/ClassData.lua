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
        ["LMBMove"] = {10, 10, 10},
        ["QMove"] = 25,
        ["EMove"] = 10,
        ["FMove"] = 3,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 6,
        ["EMove"] = 5,
        ["FMove"] = 10,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(12, 5, 7),
            Offset = CFrame.new(0, 2.5, -3.5),
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
        },
        ["QMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
        },
        ["EMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = true,
            CameraLock = false,
            Knockup = false,
        },
        ["FMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = true,
            Knockup = false,
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
    Role = "Burst",
    Cost = 200,
    Description = "Fire Connoisseur",
    DamageList = {
        ["LMBMove"] = {5, 5, 5},
        ["QMove"] = 6,
        ["EMove"] = 6,
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
        },
        ["QMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = false,
            Knockup = false,
        },
        ["EMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = true,
            Knockup = false,
        },
        ["FMove"] = {
            hasEvent = false,
            noMovement = false,
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = false,
            Knockup = false,
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
    Speed = 25,
    Role = "Tank",
    Cost = 200,
    Description = "Shield Hero",
    DamageList = {
        ["LMBMove"] = {3, 3, 3},
        ["QMove"] = 10,
        ["EMove"] = 15,
        ["FMove"] = 15,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 1,-- 3.5,
        ["EMove"] = 1, --10,
        ["FMove"] = 10,
    },
    Hitboxes = {
        ["LMBMove"] = {
            Size = Vector3.new(7, 5, 5),
            Offset = CFrame.new(0, 2.5, -2.5),
        },
        ["QMove"] = {
            Size = Vector3.new(6, 6, 6),
            Offset = CFrame.new(0, 3, -6),
        },
        ["EMove"] = {
            Size = Vector3.new(15, 5, 15),
            Offset = CFrame.new(0, 2.5, 0),
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
        },
        ["QMove"] = {
            hasEvent = true,
            noMovement = true,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = true,
        },
        ["EMove"] = {
            hasEvent = true,
            noMovement = true,
            Stunned = true,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
        },
        ["FMove"] = {
            hasEvent = true,
            noMovement = false,
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
            Knockup = false,
        },
    },
    VisualEffects = {
        ["LMBMove"] = "ShieldWarriorM1",
        ["QMove"] = "ShieldSlam",
        ["EMove"] = "ShieldJump",
        ["FMove"] = "SunBeam",
    }
}

--ClassData["Samurai"] = {}

--ClassData["Engineer"] = {}

return ClassData