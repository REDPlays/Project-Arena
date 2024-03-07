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
    Role = "Brawler",
    DamageList = {
        ["LMBMove"] = {5, 5 ,5 ,10},
        ["QMove"] = 5,
        ["EMove"] = 5,
        ["FMove"] = 5,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 1,
        ["EMove"] = 1,
        ["FMove"] = 1,
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
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 2.5, -2.5),
        },
        ["FMove"] = {
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 2.5, -2.5),
        },
    },
    MoveData = {
        ["LMBMove"] = {
            Stunned = false,
        },
        ["QMove"] = {
            Stunned = false,
        },
        ["EMove"] = {
            Stunned = false,
        },
        ["FMove"] = {
            Stunned = false,
        },
    }
}

ClassData["DevilKnight"] = {
    Health = 100,
    Defense = 100,
    Speed = 30,
    Role = "Brawler",
    DamageList = {
        ["LMBMove"] = {5, 5 ,5 ,10},
        ["QMove"] = 5,
        ["EMove"] = 5,
        ["FMove"] = 5,
    },
    Cooldowns = {
        ["LMBMove"] = .5,
        ["QMove"] = 1,
        ["EMove"] = 1,
        ["FMove"] = 1,
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
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 2.5, -2.5),
        },
        ["FMove"] = {
            Size = Vector3.new(5, 5, 5),
            Offset = CFrame.new(0, 2.5, -2.5),
        },
    },
    MoveData = {
        ["LMBMove"] = {
            Stunned = false,
        },
        ["QMove"] = {
            Stunned = false,
        },
        ["EMove"] = {
            Stunned = false,
        },
        ["FMove"] = {
            Stunned = false,
        },
    }
}

return ClassData