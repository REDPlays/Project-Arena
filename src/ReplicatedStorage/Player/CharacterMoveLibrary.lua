export type Moveset = {
    ["QMove"]: number, -- 1 or 2
    ["EMove"]: number, -- 1 or 2
    ["FMove"]: number, -- 1 or 2
}

local CharacterMoveLibrary = {}

CharacterMoveLibrary.Movesets = {} :: {[Player]: Moveset}

return CharacterMoveLibrary