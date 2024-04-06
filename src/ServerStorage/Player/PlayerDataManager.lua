local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerStorage = game:GetService("ServerStorage")
local ProfileService = require(ServerStorage.ServerFiles.Player.ProfileService)
local ClassData = require(ReplicatedStorage:WaitForChild("RepFiles"):WaitForChild("Classes"):WaitForChild("ClassData"))

local DataTemplate = {
    Tokens = 200,
    Kills = 0,
    Wins = 0,

	["Classes"] = {
		["AngelKnight"] = false,
        ["Pyromancer"] = false,
	},
}

local ProfileStore = ProfileService.GetProfileStore("Test10", DataTemplate)

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

return PlayerDataManager
