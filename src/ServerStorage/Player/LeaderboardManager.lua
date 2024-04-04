local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local UI = Assets.UI

local LeaderboardManager = {}
LeaderboardManager.playerList = {}

function LeaderboardManager:Init(playerManager)
    LeaderboardManager.playerManager = playerManager
end

function LeaderboardManager:PlayerJoin(currPlayer: Player)
    if LeaderboardManager.playerList[currPlayer.UserId] then
        return
    end

    local playerData = LeaderboardManager.playerManager:GetData(currPlayer)

    for _, player: Player in pairs(Players:GetChildren()) do
        local otherPlayerUI = player:FindFirstChild("PlayerGui")
        if not otherPlayerUI then
            continue
        end

        local otherHUD = otherPlayerUI:FindFirstChild("HUD")
        if not otherHUD then
            continue
        end

        local otherLeader = otherHUD:FindFirstChild("Leaderboard")
        if not otherLeader then
            continue
        end

        local newUI = UI.FrameBase:Clone()
        newUI.Name = currPlayer.UserId
        newUI.PlayerName.Text = currPlayer.Name
        newUI.KillCount.Text = playerData.Kills
        newUI.Tokens.Text = playerData.Tokens
        newUI.Wins.Text = playerData.Wins
        newUI.Visible = true
        if player == currPlayer then
            newUI.LayoutOrder = 1
        else
            newUI.LayoutOrder = 2
        end
        newUI.Parent = otherLeader.Holder
    end

    LeaderboardManager.playerList[currPlayer.UserId] = currPlayer
end

function LeaderboardManager:PlayerLeave(currPlayer: Player)
    if not LeaderboardManager.playerList[currPlayer.UserId] then
        return
    end

    for _, player: Player in pairs(Players:GetChildren()) do
        local otherPlayerUI = player:FindFirstChild("PlayerGui")
        if not otherPlayerUI then
            continue
        end

        local otherHUD = otherPlayerUI:FindFirstChild("HUD")
        if not otherHUD then
            continue
        end

        local otherLeader = otherHUD:FindFirstChild("Leaderboard")
        if not otherLeader then
            continue
        end

        local oldUI = otherLeader.Holder:FindFirstChild(currPlayer.UserId)
        if oldUI then
            oldUI:Destroy()
        end
    end

    LeaderboardManager.playerList[currPlayer.UserId] = nil
end

function LeaderboardManager:Update(deltaTime)
    for _, player: Player in pairs(Players:GetChildren()) do
        local PlayerUI = player:FindFirstChild("PlayerGui")
        if not PlayerUI then
            continue
        end

        local HUD = PlayerUI:FindFirstChild("HUD")
        if not HUD then
            continue
        end

        local Leader = HUD:FindFirstChild("Leaderboard")
        if not Leader then
            continue
        end

        for UserId, currPlayer: Player in pairs(LeaderboardManager.playerList) do
            local theirPlayerData = LeaderboardManager.playerManager:GetData(currPlayer)
            if not theirPlayerData then
                continue
            end

            local theirUI = Leader.Holder:FindFirstChild(currPlayer.UserId)
            if not theirUI then
                continue
            end

            theirUI.PlayerName.Text = currPlayer.Name
            theirUI.KillCount.Text = theirPlayerData.Kills
            theirUI.Tokens.Text = theirPlayerData.Tokens
            theirUI.Wins.Text = theirPlayerData.Wins
        end
    end
end

return LeaderboardManager