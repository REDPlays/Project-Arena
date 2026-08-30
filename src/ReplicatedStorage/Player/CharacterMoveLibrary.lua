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
    ["Oni"] = {
        ["LMBMove"] = "M1",
        ["QMove"] = "Club Slam",
        ["EMove"] = "Sumo Rush",
        ["FMove"] = "Enraged",
    },

}

return CharacterMoveLibrary