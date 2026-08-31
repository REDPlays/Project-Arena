export type Moveset = {
    ["LMBMove"]: string,
    ["QMove"]: string,
    ["EMove"]: string,
    ["FMove"]: string,
}

local CharacterMoveLibrary = {}

CharacterMoveLibrary.Movesets = {} :: {[Player]: Moveset}

CharacterMoveLibrary.BaseMovesets = {
    ["AngelKnight"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Holy Beam",
        ["EMove"] = "Angelic Charge",
        ["FMove"] = "Sun Beam",
    },
    ["Pyromancer"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Triple Fire Ball",
        ["EMove"] = "Flame thrower",
        ["FMove"] = "Eruption",
    },
    ["ShieldWarrior"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Shield Slam",
        ["EMove"] = "Shield Jump",
        ["FMove"] = "Colosseum",
    },
    ["Samurai"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Shadow Step",
        ["EMove"] = "Rapid Slashes",
        ["FMove"] = "Wind Tornado",
    },
    ["Engineer"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Concussive Mine",
        ["EMove"] = "Turret",
        ["FMove"] = "Electro Ball",
    },
    ["Ranger"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Piercing Arrow",
        ["EMove"] = "Net Trap",
        ["FMove"] = "Explosive Arrow",
    },
    ["Shinobi"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Quick Dash",
        ["EMove"] = "Shuriken Throw",
        ["FMove"] = "Retreat",
    },
    ["Oni"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Club Slam",
        ["EMove"] = "Sumo Rush",
        ["FMove"] = "Enraged",
    },
    ["Judge"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Club Slam",
        ["EMove"] = "Sumo Rush",
        ["FMove"] = "Enraged",
    },
    ["Hydromancer"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Water Wave",
        ["EMove"] = "Water Bubble",
        ["FMove"] = "Whirlpool",
    },

}

return CharacterMoveLibrary