local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local UI = Assets.UI

local function createPlayerFrame(currPlayer: Player, player: Player, playerData, otherLeader)
    local newUI = UI.FrameBase:Clone()
    newUI.Name = currPlayer.UserId
    newUI.Background.PlayerName.Display.Text = currPlayer.Name
    newUI.Background.Kills.Display.Text = playerData.Kills
    newUI.Background.Tokens.Display.Text = playerData.Tokens
    newUI.Background.Wins.Display.Text = playerData.Wins
    newUI.Visible = true

    if player == currPlayer then
        newUI.LayoutOrder = 1
    else
        newUI.LayoutOrder = 2
    end

    newUI.Parent = otherLeader.Holder
end

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

        createPlayerFrame(currPlayer, player, playerData, otherLeader)
    end

    LeaderboardManager.playerList[currPlayer.UserId] = currPlayer
end

function LeaderboardManager:SudoPlayerJoin(player: Player, LeaderUI, currPlayer: Player, playerData)
    createPlayerFrame(currPlayer, player, playerData, LeaderUI)
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
                LeaderboardManager:SudoPlayerJoin(player, Leader, currPlayer, theirPlayerData)
                continue
            end

            theirUI.Background.PlayerName.Display.Text = currPlayer.Name
            theirUI.Background.Kills.Display.Text = theirPlayerData.Kills
            theirUI.Background.Tokens.Display.Text = theirPlayerData.Tokens
            theirUI.Background.Wins.Display.Text = theirPlayerData.Wins
        end
    end
end

return LeaderboardManager