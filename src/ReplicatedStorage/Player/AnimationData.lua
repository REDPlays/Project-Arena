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

AnimationData["DevilKnight"] = {
    LMBMove = {
        Animations:WaitForChild("DevilKnight"):WaitForChild("M1_1"),
        Animations:WaitForChild("DevilKnight"):WaitForChild("M1_2"),
        Animations:WaitForChild("DevilKnight"):WaitForChild("M1_3"),
    },

    Block = Animations:WaitForChild("DevilKnight"):WaitForChild("Block"),

    QMove = Animations:WaitForChild("DevilKnight"):WaitForChild("QMove"),
    EMove = Animations:WaitForChild("DevilKnight"):WaitForChild("EMove"),
    FMove = Animations:WaitForChild("DevilKnight"):WaitForChild("FMove"),

    Idle = Animations:WaitForChild("DevilKnight"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("DevilKnight"):WaitForChild("Run"),
}

return AnimationData