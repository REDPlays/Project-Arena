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
    Speed = 30,
    Role = "Support",
    DamageList = {
        ["LMBMove"] = {15, 15, 15},
        ["QMove"] = 10,
        ["EMove"] = 10,
        ["FMove"] = 5,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 5,
        ["EMove"] = 5,
        ["FMove"] = 10,
    },
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
        },
        ["QMove"] = {
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = false,
        },
        ["EMove"] = {
            Stunned = false,
            Burn = false,
            Slow = true,
            CameraLock = false,
        },
        ["FMove"] = {
            Stunned = false,
            Burn = false,
            Slow = false,
            CameraLock = true,
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
    DamageList = {
        ["LMBMove"] = {2, 2, 2},
        ["QMove"] = 2,
        ["EMove"] = 4,
        ["FMove"] = 10,
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
        },
        ["QMove"] = {
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = false,
        },
        ["EMove"] = {
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = true,
        },
        ["FMove"] = {
            Stunned = false,
            Burn = true,
            Slow = false,
            CameraLock = false,
        },
    },
    VisualEffects = {
        ["LMBMove"] = "FireBall",
        ["QMove"] = "FireBall",
        ["EMove"] = "AngelicCharge",
        ["FMove"] = "SunBeam",
    }
}

return ClassData