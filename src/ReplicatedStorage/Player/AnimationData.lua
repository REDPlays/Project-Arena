local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Animations = Assets:WaitForChild("Animations")

local AnimationData = {}

AnimationData["Base"] = {
    Idle = Animations:WaitForChild("Base"):WaitForChild("Idle"),
    Walk = Animations:WaitForChild("Base"):WaitForChild("Walk"),
    DummyAttack = Animations:WaitForChild("Base"):WaitForChild("DummyAttack"),
}

AnimationData["AngelKnight"] = {
    LMBMove = {
        Animations:WaitForChild("AngelKnight"):WaitForChild("M1_1"),
        Animations:WaitForChild("AngelKnight"):WaitForChild("M1_2"),
        Animations:WaitForChild("AngelKnight"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("AngelKnight"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("AngelKnight"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("AngelKnight"):WaitForChild("EMove"),
    FMove = Animations:WaitForChild("AngelKnight"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("AngelKnight"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("AngelKnight"):WaitForChild("Run"),
}

AnimationData["Pyromancer"] = {
    LMBMove = {
        Animations:WaitForChild("Pyromancer"):WaitForChild("M1_1"),
        Animations:WaitForChild("Pyromancer"):WaitForChild("M1_2"),
        Animations:WaitForChild("Pyromancer"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("Pyromancer"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("Pyromancer"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("Pyromancer"):WaitForChild("EMove"),
    FMove = Animations:WaitForChild("Pyromancer"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Pyromancer"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Pyromancer"):WaitForChild("Run"),
}

AnimationData["ShieldWarrior"] = {
    LMBMove = {
        Animations:WaitForChild("ShieldWarrior"):WaitForChild("M1_1"),
        Animations:WaitForChild("ShieldWarrior"):WaitForChild("M1_2"),
        Animations:WaitForChild("ShieldWarrior"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("Pyromancer"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("ShieldWarrior"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("ShieldWarrior"):WaitForChild("EMove"),
    FMove = Animations:WaitForChild("ShieldWarrior"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Pyromancer"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Pyromancer"):WaitForChild("Run"),
}

AnimationData["Samurai"] = {
    LMBMove = {
        Animations:WaitForChild("Samurai"):WaitForChild("M1_1"),
        Animations:WaitForChild("Samurai"):WaitForChild("M1_2"),
        Animations:WaitForChild("Samurai"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("Samurai"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("Samurai"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("Samurai"):WaitForChild("EMove"),
    FMove = Animations:WaitForChild("Samurai"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Samurai"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Samurai"):WaitForChild("Run"),
}

AnimationData["Engineer"] = {
    LMBMove = {
        Animations:WaitForChild("Engineer"):WaitForChild("M1_1"),
        Animations:WaitForChild("Engineer"):WaitForChild("M1_1"),
        Animations:WaitForChild("Engineer"):WaitForChild("M1_1"),
    },

    Block = Animations:WaitForChild("Pyromancer"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("Engineer"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("Engineer"):WaitForChild("EMove"),
    FMove = Animations:WaitForChild("Engineer"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Engineer"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Engineer"):WaitForChild("Run"),
}

AnimationData["Ranger"] = {
    LMBMove = {
        Animations:WaitForChild("Ranger"):WaitForChild("M1_1"),
        Animations:WaitForChild("Ranger"):WaitForChild("M1_2"),
        Animations:WaitForChild("Ranger"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("Pyromancer"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("Ranger"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("Ranger"):WaitForChild("EMove"),
    FMove = Animations:WaitForChild("Ranger"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Ranger"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Ranger"):WaitForChild("Run"),
}

AnimationData["Shinobi"] = {
    LMBMove = {
        Animations:WaitForChild("Shinobi"):WaitForChild("M1_1"),
        Animations:WaitForChild("Shinobi"):WaitForChild("M1_2"),
        Animations:WaitForChild("Shinobi"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("Shinobi"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("Shinobi"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("Shinobi"):WaitForChild("EMove"),
    FMove = Animations:WaitForChild("Shinobi"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Shinobi"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Shinobi"):WaitForChild("Run"),
}

AnimationData["Oni"] = {
    LMBMove = {
        Animations:WaitForChild("Oni"):WaitForChild("M1_1"),
        Animations:WaitForChild("Oni"):WaitForChild("M1_2"),
        Animations:WaitForChild("Oni"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("Oni"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("Oni"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("Oni"):WaitForChild("EMove"),
    EMove2 = Animations:WaitForChild("Oni"):WaitForChild("EMove2"),
    FMove = Animations:WaitForChild("Oni"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Oni"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Oni"):WaitForChild("Run"),
}

AnimationData["Judge"] = {
    LMBMove = {
        Animations:WaitForChild("Judge"):WaitForChild("M1_1"),
        Animations:WaitForChild("Judge"):WaitForChild("M1_2"),
        Animations:WaitForChild("Judge"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("Judge"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("Judge"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("Judge"):WaitForChild("EMove"),
    EMove2 = Animations:WaitForChild("Judge"):WaitForChild("EMove2"),
    FMove = Animations:WaitForChild("Judge"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Judge"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Judge"):WaitForChild("Run"),
}

AnimationData["Hydromancer"] = {
    LMBMove = {
        Animations:WaitForChild("Hydromancer"):WaitForChild("M1_1"),
        Animations:WaitForChild("Hydromancer"):WaitForChild("M1_2"),
        Animations:WaitForChild("Hydromancer"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("Hydromancer"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("Hydromancer"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("Hydromancer"):WaitForChild("EMove"),
    FMove = Animations:WaitForChild("Hydromancer"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Hydromancer"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Hydromancer"):WaitForChild("Run"),
}

AnimationData["Reaper"] = {
    LMBMove = {
        Animations:WaitForChild("Reaper"):WaitForChild("M1_1"),
        Animations:WaitForChild("Reaper"):WaitForChild("M1_2"),
        Animations:WaitForChild("Reaper"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("Reaper"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("Reaper"):WaitForChild("QMove"),
    QMove2 = Animations:WaitForChild("Reaper"):WaitForChild("QMove2"),
    EMove = Animations:WaitForChild("Reaper"):WaitForChild("EMove"),
    EMove2 = Animations:WaitForChild("Reaper"):WaitForChild("EMove2"),
    FMove = Animations:WaitForChild("Reaper"):WaitForChild("FMove"),
    FMove2 = Animations:WaitForChild("Reaper"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("Reaper"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Reaper"):WaitForChild("Run"),
}

return AnimationData