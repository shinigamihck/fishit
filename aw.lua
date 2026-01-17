-- ==========================================
-- SANZHUY HUB | FISH IT (ORION UI VERSION)
-- PART 1 — CORE SYSTEM + STATE + SERVICES
-- DARK MODE (A2)
-- ==========================================

if _G.FishItWORK then return end
_G.FishItWORK = true

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- REMOTES
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")

-- ==========================================
-- STATE
-- ==========================================

AutoFish = false
AutoSell = false
AutoWeather = false
AUTO_TOTEM = false

FlyEnabled = false
FlySpeed = 50

FishDelay = 0.13
SellInterval = 5
WeatherDelay = 5

RUNNING_TOTEM = true

_G.ANTI_AFK = true
_G.CLEAN_FISH_UI = true

-- ==========================================
-- PING FUNCTION
-- ==========================================

local function getRealPing()
    local network = Stats:FindFirstChild("Network")
    if not network then return nil end

    local serverStats = network:FindFirstChild("ServerStatsItem")
    if not serverStats then return nil end

    local pingStat = serverStats:FindFirstChild("Data Ping")
    if not pingStat then return nil end

    return pingStat:GetValue()
end

-- ==========================================
-- ANTI AFK
-- ==========================================

local vu = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    if not _G.ANTI_AFK then return end
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)

-- ==========================================
-- FLY SYSTEM CORE
-- ==========================================

local flyConn
local bv, bg

function stopFly()
    FlyEnabled = false
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

function startFly()
    local char = LP.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    bg = Instance.new("BodyGyro", hrp)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = hrp.CFrame

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConn = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end

        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        bv.Velocity = move.Magnitude > 0 and move.Unit * FlySpeed or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(0.2)
    stopFly()
end)

-- ==========================================
-- FISHING CONTROLLER AUTO LOAD
-- ==========================================

FishingController = nil

task.spawn(function()
    repeat
        task.wait(0.25)
        local ok, ctrl = pcall(function()
            return require(ReplicatedStorage.Controllers.FishingController)
        end)
        if ok then
            FishingController = ctrl
        end
    until FishingController
end)

print("PART 1 Loaded ✓ (CORE READY)")
-- ==========================================
-- PART 2 — ORION UI (DARK MODE)
-- ==========================================

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "Fish It | Sanzhuy Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SanzhuyHub"
})

-- ==========================================
-- MAIN TAB (Auto Farm)
-- ==========================================

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Auto Fish",
    Default = false,
    Callback = function(v)
        AutoFish = v
    end
})

MainTab:AddToggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(v)
        AutoSell = v
    end
})

MainTab:AddToggle({
    Name = "Auto Weather",
    Default = false,
    Callback = function(v)
        AutoWeather = v
    end
})

MainTab:AddSlider({
    Name = "Sell Interval",
    Min = 1,
    Max = 30,
    Default = SellInterval,
    Increment = 1,
    ValueName = "s",
    Callback = function(v)
        SellInterval = v
    end
})

-- ==========================================
-- FARM TAB
-- ==========================================

local FarmTab = Window:MakeTab({
    Name = "Farm Settings",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

FarmTab:AddSlider({
    Name = "Fishing Delay",
    Min = 0.05,
    Max = 0.3,
    Default = FishDelay,
    Increment = 0.01,
    ValueName = "sec",
    Callback = function(v)
        FishDelay = v
    end
})

FarmTab:AddToggle({
    Name = "Clean Fish UI (FPS Boost)",
    Default = _G.CLEAN_FISH_UI,
    Callback = function(v)
        _G.CLEAN_FISH_UI = v
    end
})

-- ==========================================
-- UTILITY TAB (Fly, Speeds)
-- ==========================================

local UtilTab = Window:MakeTab({
    Name = "Utility",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

UtilTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(v)
        FlyEnabled = v
        if v then startFly() else stopFly() end
    end
})

UtilTab:AddSlider({
    Name = "Fly Speed",
    Min = 50,
    Max = 800,
    Default = FlySpeed,
    Increment = 25,
    ValueName = "speed",
    Callback = function(v)
        FlySpeed = v
    end
})

-- ==========================================
-- SHOP TAB (Totem System)
-- ==========================================

local ShopTab = Window:MakeTab({
    Name = "Totem / Merchant",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

ShopTab:AddToggle({
    Name = "Auto Totem",
    Default = false,
    Callback = function(v)
        AUTO_TOTEM = v
    end
})

ShopTab:AddButton({
    Name = "Toggle Merchant",
    Callback = function()
        local gui = LP.PlayerGui:FindFirstChild("Merchant")
        if gui then
            gui.Enabled = not gui.Enabled
        end
    end
})

-- ==========================================
-- MISC TAB
-- ==========================================

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

MiscTab:AddToggle({
    Name = "Anti AFK",
    Default = true,
    Callback = function(v)
        _G.ANTI_AFK = v
    end
})

MiscTab:AddButton({
    Name = "Hide / Show UI",
    Callback = function()
        OrionLib:Toggle()
    end
})

MiscTab:AddButton({
    Name = "Close Script",
    Callback = function()
        AUTO_TOTEM = false
        AutoFish = false
        AutoSell = false
        AutoWeather = false
        FlyEnabled = false
        pcall(stopFly)
        _G.FishItWORK = false
        OrionLib:Destroy()
    end
})

print("PART 2 Loaded ✓ (ORION UI READY)")
-- ==========================================
-- PART 3 — AUTO FISH / SELL / WEATHER
-- ==========================================

-- AUTO FISH
task.spawn(function()
    while _G.FishItWORK do
        task.wait(FishDelay)

        if AutoFish and FishingController then
            local guid = FishingController:GetCurrentGUID()

            if not guid then
                pcall(function()
                    FishingController:RequestChargeFishingRod(
                        workspace.CurrentCamera.ViewportSize / 2,
                        true
                    )
                end)
            else
                pcall(function()
                    FishingController:FishingMinigameClick()
                end)
            end
        end
    end
end)

-- AUTO SELL
task.spawn(function()
    while _G.FishItWORK do
        task.wait(SellInterval)

        if AutoSell and sellRF then
            pcall(function()
                sellRF:InvokeServer()
            end)
        end
    end
end)

-- AUTO WEATHER
task.spawn(function()
    local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")
    local WeatherList = {"Storm", "Cloudy", "Wind"}

    while _G.FishItWORK do
        task.wait(WeatherDelay)
        if AutoWeather then
            for _,w in ipairs(WeatherList) do
                pcall(function()
                    purchaseRF:InvokeServer(w)
                end)
                task.wait(1.25)
            end
        end
    end
end)

print("PART 3 Loaded ✓")
-- ==========================================
-- PART 4 — CLEAN FISH UI + FLY AUTO FIX
-- ==========================================

-- Fly auto-reapply
task.spawn(function()
    while _G.FishItWORK do
        task.wait(0.15)
        if FlyEnabled and (not bv or not bg) then
            startFly()
        end
    end
end)

-- Clean Fish UI
local function shouldHideLabel(label)
    if not label:IsA("TextLabel") then return false end
    if not label.Text then return false end

    local t = label.Text:lower()

    if t:match("^%s*you%s+got") then return false end
    if t:match("%d+%.?%d*%s*kg") then return true end
    if t:match("^1%s+in%s+%d+") then return true end
    if t:find("lvl") then return true end

    if label.TextSize >= 26 then
        local y = label.AbsolutePosition.Y
        local cy = workspace.CurrentCamera.ViewportSize.Y
        if y > cy*0.25 and y < cy*0.65 then
            return true
        end
    end
    return false
end

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1.4)
        if not _G.CLEAN_FISH_UI then continue end

        local pg = LP:FindFirstChild("PlayerGui")
        if not pg then continue end

        local fishGui = pg:FindFirstChild("FishingUI")
        if not fishGui then continue end

        for _,o in ipairs(fishGui:GetDescendants()) do
            if shouldHideLabel(o) then
                o.Visible = false
            end
        end
    end
end)

print("PART 4 Loaded ✓")
-- ==========================================
-- PART 5 — AUTO TOTEM SYSTEM
-- ==========================================

local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")

local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipToolFromHotbar = Net:RemoteEvent("EquipToolFromHotbar")

local COOLDOWN = 0
local retryWait = false
local TRY_INTERVAL = 300

local function GetTotemUUID()
    local inv = Data:Get({"Inventory","Totems"})
    if inv and #inv > 0 then return inv[1].UUID end
    return nil
end

-- auto equip rod
task.spawn(function()
    while _G.FishItWORK do
        task.wait(2.5)
        if AUTO_TOTEM then
            pcall(function()
                EquipToolFromHotbar:FireServer(1)
            end)
        end
    end
end)

TotemSpawned.OnClientEvent:Connect(function()
    COOLDOWN = 3600
end)

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)
        if not AUTO_TOTEM then continue end

        if COOLDOWN > 0 then
            COOLDOWN -= 1
            continue
        end

        if retryWait and os.clock() < retryWait then continue end

        local uuid = GetTotemUUID()
        if not uuid then continue end

        local success = false
        local conn

        conn = TotemSpawned.OnClientEvent:Connect(function()
            success = true
            conn:Disconnect()
        end)

        SpawnTotem:FireServer(uuid)
        task.wait(0.6)

        if conn then conn:Disconnect() end
        if not success then
            retryWait = os.clock() + TRY_INTERVAL
        end
    end
end)

print("PART 5 Loaded ✓")
-- ==========================================
-- PART 6 — TELEPORT TAB
-- ==========================================

local Locations = {
    { Name = "Ancient Jungle", CFrame = CFrame.new(1562.54, 6.62, -233.16) },
    { Name = "Ancient Ruin", CFrame = CFrame.new(6076.29, -585.92, 4625.92) },
    { Name = "Coral Reefs", CFrame = CFrame.new(-2752.80, 4, 2165.78) },
    { Name = "Crater Island", CFrame = CFrame.new(1027.12, 2.89, 5148.10) },
    { Name = "Fisherman Island", CFrame = CFrame.new(73.35, 9.53, 2709.50) },
    { Name = "Kohana", CFrame = CFrame.new(-595.69, 19.25, 429.86) },
    { Name = "Pirate Cove", CFrame = CFrame.new(3398.70, 10.34, 3491.11) },
    { Name = "Treasure Room", CFrame = CFrame.new(-3597.20, -280.11, -1633.28) },
    { Name = "Tropical Grove", CFrame = CFrame.new(-2128.62, 53.48, 3637.66) },
    { Name = "Weather Machine", CFrame = CFrame.new(-1527.67, 2.87, 1914.66) },
}

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

TeleportTab:AddSection("Teleport To Players")

for _,plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then
        TeleportTab:AddButton({
            Name = plr.Name,
            Callback = function()
                local me = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local him = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if me and him then
                    me.CFrame = him.CFrame * CFrame.new(0,0,-3)
                end
            end
        })
    end
end

TeleportTab:AddSection("Teleport To Spots")

for _,spot in ipairs(Locations) do
    TeleportTab:AddButton({
        Name = spot.Name,
        Callback = function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spot.CFrame + Vector3.new(0,5,0)
            end
        end
    })
end

print("PART 6 Loaded ✓")
print("✓ FULL ORION VERSION LOADED — DELTA READY")
