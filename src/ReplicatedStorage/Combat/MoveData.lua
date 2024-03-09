local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MoveData = {}

MoveData["AngelKnight"] = {
    ["QMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves"):WaitForChild("HolyBeam")),
    ["EMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves"):WaitForChild("AngelicCharge")),
    ["FMove"] = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Combat"):WaitForChild("Moves"):WaitForChild("SunBeam")),
}

return MoveData