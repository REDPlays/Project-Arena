local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerStorage = game:GetService("ServerStorage")
local ProfileService = require(ServerStorage.ServerFiles.Player.ProfileService)
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))

local DataTemplate = {
    Tokens = 600,
    Kills = 0,
    Wins = 0,

    ["Primary"] = {0.388235, 0.372549, 0.384314},
    ["Secondary"] = {0.639216, 0.635294, 0.647059},
    ["Energy"] = {0.639216, 0.635294, 0.647059},

	["Classes"] = {
		["AngelKnight"] = true,
        ["Pyromancer"] = true,
        ["ShieldWarrior"] = true,
        ["Samurai"] = true,
        ["Engineer"] = true,
        ["Ranger"] = true,
        ["Shinobi"] = true,
        ["Oni"] = true,
        ["Judge"] = false,
        ["Hydromancer"] = true,
	},
}

local ProfileStore = ProfileService.GetProfileStore("Test28", DataTemplate)

local Profiles = {}

local PlayerDataManager = {}

function PlayerDataManager:GetProfiles()
	return Profiles
end

function PlayerDataManager:Get(player: Player)
	local profile = Profiles[player]
	
	if profile then
		return profile.Data
	end
end

function PlayerDataManager:onPlayerAdded(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_"..player.UserId, "ForceLoad")

	if profile then
		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick()
		end)

		if player:IsDescendantOf(Players) then
			Profiles[player] = profile

            if not Profiles[player].Data["Primary"] then
                Profiles[player].Data["Primary"] = DataTemplate["Primary"]
            end

            if not Profiles[player].Data["Secondary"] then
                Profiles[player].Data["Secondary"] = DataTemplate["Secondary"]
            end

            if not Profiles[player].Data["Energy"] then
                Profiles[player].Data["Energy"] = DataTemplate["Energy"]
            end
		else
			profile:Release()
		end
	else
		player:Kick()
	end
end

function PlayerDataManager:onPlayerRemoving(player: Player)
	local profile = Profiles[player]
	if profile then
		profile:Release()
		Profiles[player] = nil
	end
end

function PlayerDataManager:AddKill(player: Player)
    local profile = Profiles[player]
    if profile then
        profile.Data.Kills += 1
    end
end

function PlayerDataManager:AddWin(player: Player)
    local profile = Profiles[player]
    if profile then
        profile.Data.Wins += 1
    end
end

function PlayerDataManager:AddToken(player: Player, tokenAmount: number)
    if not tokenAmount then
        return
    end

    if tokenAmount < 1 then
        return
    end

    local profile = Profiles[player]
    if profile then
        profile.Data.Tokens += tokenAmount
    end
end

function PlayerDataManager:RemoveToken(player: Player, tokenAmount: number)
    if not tokenAmount then
        return
    end

    if tokenAmount < 1 then
        return
    end

    local profile = Profiles[player]
    if profile then
        profile.Data.Tokens -= tokenAmount
    end
end

function PlayerDataManager:AddClass(player: Player, class)
    if not class then
        return false
    end

    local profile = Profiles[player]
    if profile then

        local tokens = profile.Data.Tokens
        if tokens >= ClassData[class].Cost then
            PlayerDataManager:RemoveToken(player, ClassData[class].Cost)
        else
            return false
        end

        profile.Data.Classes[class] = true

        return true
    end
end

function PlayerDataManager:CheckClass(player: Player, class)
    if not class then
        return
    end

    local profile = Profiles[player]
    if not profile then
        return
    end

    return profile.Data.Classes[class]
end

function PlayerDataManager:GetColor(player: Player, section)
    local profile = Profiles[player]
    if not profile then
        return
    end

    local colorSection = profile.Data[section]
    if not colorSection then
        return
    end

    return Color3.new(colorSection[1], colorSection[2], colorSection[3])
end

function PlayerDataManager:SetColor(player: Player, section, Color)
    local profile = Profiles[player]
    if not profile then
        return
    end

    local colorSection = profile.Data[section]
    if not colorSection then
        return
    end

    profile.Data[section] = {Color.R, Color.G, Color.B}
end

return PlayerDataManager
