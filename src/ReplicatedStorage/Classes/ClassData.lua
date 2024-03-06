local ClassData = {}

ClassData["AngelKnight"] = {
    Health = 100,
    Defense = 100,
    Speed = 30,
    Role = "Brawler",
    DamageList = {
        ["M1s"] = {5, 5 ,5 ,10},
        ["Q"] = 5,
        ["E"] = 5,
        ["F"] = 5,
    },
    Cooldowns = {
        ["LMBMove"] = 1,
        ["QMove"] = 1,
        ["EMove"] = 1,
        ["FMove"] = 1,
    }
}

return ClassData