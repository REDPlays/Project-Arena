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
    EMove = Animations:WaitForChild("Pyromancer"):WaitForChild("FMove"),
    FMove = Animations:WaitForChild("Pyromancer"):WaitForChild("QMove"),

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

return AnimationData