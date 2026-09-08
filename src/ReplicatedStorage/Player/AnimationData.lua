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

    ["Holy Beam"] = Animations:WaitForChild("AngelKnight"):WaitForChild("Holy Beam"),
    ["Angelic Charge"] = Animations:WaitForChild("AngelKnight"):WaitForChild("Angelic Charge"),
    ["Sun Beam"] = Animations:WaitForChild("AngelKnight"):WaitForChild("Sun Beam"),

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

    ["Triple Fire Ball"] = Animations:WaitForChild("Pyromancer"):WaitForChild("Triple Fire Ball"),
    ["Flame thrower"] = Animations:WaitForChild("Pyromancer"):WaitForChild("Flame thrower"),
    ["Eruption"] = Animations:WaitForChild("Pyromancer"):WaitForChild("Eruption"),

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

    ["Shield Slam"] = Animations:WaitForChild("ShieldWarrior"):WaitForChild("Shield Slam"),
    ["Shield Jump"] = Animations:WaitForChild("ShieldWarrior"):WaitForChild("Shield Jump"),
    ["Colosseum"] = Animations:WaitForChild("ShieldWarrior"):WaitForChild("Colosseum"),

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

    ["Shadow Step"] = Animations:WaitForChild("Samurai"):WaitForChild("Shadow Step"),
    ["Rapid Slashes"] = Animations:WaitForChild("Samurai"):WaitForChild("Rapid Slashes"),
    ["Wind Tornado"] = Animations:WaitForChild("Samurai"):WaitForChild("Wind Tornado"),

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

    ["Concussive Mine"] = Animations:WaitForChild("Engineer"):WaitForChild("Concussive Mine"),
    ["Turret"] = Animations:WaitForChild("Engineer"):WaitForChild("Turret"),
    ["Electro Ball"] = Animations:WaitForChild("Engineer"):WaitForChild("Electro Ball"),

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

    ["Piercing Arrow"] = Animations:WaitForChild("Ranger"):WaitForChild("Piercing Arrow"),
    ["Net Trap"] = Animations:WaitForChild("Ranger"):WaitForChild("Net Trap"),
    ["Explosive Arrow"] = Animations:WaitForChild("Ranger"):WaitForChild("Explosive Arrow"),

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

    ["Quick Dash"] = Animations:WaitForChild("Shinobi"):WaitForChild("Quick Dash"),
    ["Shuriken Throw"] = Animations:WaitForChild("Shinobi"):WaitForChild("Shuriken Throw"),
    ["Retreat"] = Animations:WaitForChild("Shinobi"):WaitForChild("Retreat"),

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

    ["Club Slam"] = Animations:WaitForChild("Oni"):WaitForChild("Club Slam"),
    ["Sumo Rush"] = Animations:WaitForChild("Oni"):WaitForChild("Sumo Rush"),
    ["Sumo Stance"] = Animations:WaitForChild("Oni"):WaitForChild("Sumo Stance"),
    ["Enraged"] = Animations:WaitForChild("Oni"):WaitForChild("Enraged"),

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

    ["Club Slam"] = Animations:WaitForChild("Oni"):WaitForChild("Club Slam"),
    ["Sumo Rush"] = Animations:WaitForChild("Oni"):WaitForChild("Sumo Rush"),
    ["Sumo Stance"] = Animations:WaitForChild("Oni"):WaitForChild("Sumo Stance"),
    ["Enraged"] = Animations:WaitForChild("Oni"):WaitForChild("Enraged"),

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

    ["Water Wave"] = Animations:WaitForChild("Hydromancer"):WaitForChild("Water Wave"),
    ["Water Bubble"] = Animations:WaitForChild("Hydromancer"):WaitForChild("Water Bubble"),
    ["Whirlpool"] = Animations:WaitForChild("Hydromancer"):WaitForChild("Whirlpool"),

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

    ["Soul Slice"] = Animations:WaitForChild("Reaper"):WaitForChild("Soul Slice"),
    ["Reapers Blight"] = Animations:WaitForChild("Reaper"):WaitForChild("Reapers Blight"),
    ["Reapers Calling"] = Animations:WaitForChild("Reaper"):WaitForChild("Reapers Calling"),
    ["Grim Reaping"] = Animations:WaitForChild("Reaper"):WaitForChild("Grim Reaping"),
    ["Enshroud"] = Animations:WaitForChild("Reaper"):WaitForChild("Enshroud"),

    Idle = Animations:WaitForChild("Reaper"):WaitForChild("Idle"),
    Run = Animations:WaitForChild("Reaper"):WaitForChild("Run"),
}

return AnimationData