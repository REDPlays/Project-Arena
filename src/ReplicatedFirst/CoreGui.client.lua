local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Maps = ReplicatedStorage:WaitForChild("Maps")

warn("PRELOAD ASSETS")
local assetList = {}
for _, objects in pairs(Assets:GetDescendants()) do
    if not objects:IsA("Folder") then
        table.insert(assetList, objects)
    end
end

local mapList = {}
for _, objects in pairs(Assets:GetDescendants()) do
    if not objects:IsA("Folder") then
        table.insert(mapList, objects)
    end
end

local function assetCallBack(assetId, assetFetchStatus)
    --print("PreloadAsync() resolved asset ID:", assetId)
    --print("PreloadAsync() final AssetFetchStatus:", assetFetchStatus)
end

local startTime = os.clock()
ContentProvider:PreloadAsync(assetList, assetCallBack)
ContentProvider:PreloadAsync(mapList, assetCallBack)

local preloadingTime = os.clock() - startTime
warn("FINISHED PRELOADING ASSETS IN :", preloadingTime)