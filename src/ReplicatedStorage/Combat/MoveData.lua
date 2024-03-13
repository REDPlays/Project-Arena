local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MoveData = {}

MoveData["AngelKnight"] = {
    ["QMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves"):WaitForChild("HolyBeam")),
    ["EMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves"):WaitForChild("AngelicCharge")),
    ["FMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves"):WaitForChild("SunBeam")),
}

MoveData["Pyromancer"] = {
    ["QMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves"):WaitForChild("TripleFireBall")),
    ["EMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves"):WaitForChild("Flamethrower")),
    ["FMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves"):WaitForChild("Eruption")),
}

return MoveData