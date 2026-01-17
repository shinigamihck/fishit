-- ==========================================
--  FISH IT | SANZHUY HUB (RAYFIELD VERSION)
--  PART 1: STATE + SERVICES + ANTI AFK
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

-- REMOTES (Net)
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")

-- ==========================================
-- STATE / SETTINGS
-- ==========================================

AutoFish = false
AutoSell = false
AutoWeather = false

AUTO_TOTEM = false
RUNNING_TOTEM = true

FlyEnabled = false
FlySpeed = 50

FishDelay = 0.13
SellInterval = 5
WeatherDelay = 5

-- ping display safe later
local function getRealPing()
    local network = Stats:FindFirstChild("Network")
    if not network then return nil end
    local serverStats = network:FindFirstChild("ServerStatsItem")
    if not serverStats then return nil end
    local ping = serverStats:FindFirstChild("Data Ping")
    if not ping then return nil end
    return ping:GetValue()
end

-- ==========================================
-- ANTI AFK
-- ==========================================

local vu = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    if _G.ANTI_AFK == false then return end
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
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.CFrame = hrp.CFrame

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)

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
-- FISHING CONTROLLER LOAD
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

-- ==========================================
-- CLEAN FISH UI TOGGLE FLAG
-- ==========================================

_G.CLEAN_FISH_UI = true
_G.ANTI_AFK = true

-- PART 1 SELESAI
print("PART 1 Loaded ✓")
-- ==========================================
-- PART 2: RAYFIELD UI (DEFAULT STYLE)
-- ==========================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "Fish It | Sanzhuy Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SanzhuyHub"
})

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
    Callback = function(v)
        FlySpeed = v
    end
})

OrionLib:Init()


-- ==========================================
-- SHOP TAB
-- ==========================================

local ShopTab = Window:CreateTab("Shop", 4483362458)

ShopTab:CreateToggle({
    Name = "Auto Totem",
    CurrentValue = AUTO_TOTEM,
    Callback = function(v)
        AUTO_TOTEM = v
    end
})

ShopTab:CreateButton({
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

local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = _G.ANTI_AFK,
    Callback = function(v)
        _G.ANTI_AFK = v
    end
})

MiscTab:CreateButton({
    Name = "Hide / Show UI",
    Callback = function()
        Rayfield:ToggleUI()
    end
})

MiscTab:CreateButton({
    Name = "Close Script",
    Callback = function()
        AutoFish = false
        AutoSell = false
        AutoWeather = false
        AUTO_TOTEM = false
        FlyEnabled = false
        pcall(stopFly)
        Rayfield:Destroy()
        _G.FishItWORK = false
    end
})

Rayfield:Notify({
    Title = "Loaded!",
    Content = "Fish It Hub (Rayfield UI) siap digunakan",
    Duration = 5
})

print("PART 2 Loaded ✓")
-- ==========================================
-- PART 3: AUTO FISH + AUTO SELL + AUTO WEATHER
-- ==========================================

-- ========= AUTO FISH LOOP =========

task.spawn(function()
    while _G.FishItWORK do
        task.wait(FishDelay)

        if AutoFish and FishingController then
            local guid = FishingController:GetCurrentGUID()

            if not guid then
                -- lempar kail
                pcall(function()
                    FishingController:RequestChargeFishingRod(
                        workspace.CurrentCamera.ViewportSize / 2,
                        true
                    )
                end)
            else
                -- mini game click
                pcall(function()
                    FishingController:FishingMinigameClick()
                end)
            end
        end
    end
end)


-- ========= AUTO SELL LOOP =========

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


-- ========= AUTO WEATHER LOOP =========

task.spawn(function()
    local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")
    local WeatherList = {"Storm", "Cloudy", "Wind"}

    while _G.FishItWORK do
        task.wait(WeatherDelay)

        if AutoWeather and purchaseRF then
            for _,weather in ipairs(WeatherList) do
                pcall(function()
                    purchaseRF:InvokeServer(weather)
                end)
                task.wait(1.5)
            end
        end
    end
end)

print("PART 3 Loaded ✓")
-- ==========================================
-- PART 4: FLY LOOP + CLEAN FISH UI (FPS BOOST)
-- ==========================================


-- ========= FLY MOVEMENT LOOP =========

task.spawn(function()
    while _G.FishItWORK do
        task.wait(0.1)
        if FlyEnabled == false then continue end

        -- Safety auto-reapply if body movers vanish
        local char = LP.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if not bv or not bg then
            startFly()
        end
    end
end)



-- ========= CLEAN FISH UI (HIDE BIG TEXT) =========

local function shouldHideLabel(label)
    if not label:IsA("TextLabel") then return false end
    if not label.Text or label.Text == "" then return false end

    local text = label.Text:lower()

    -- KEEP only “you got:”
    if text:match("^%s*you%s+got%s*:") then
        return false
    end

    -- Hide KG, chances, level text
    if text:match("%d+%.?%d*%s*kg") then return true end
    if text:match("^1%s+in%s+%d+") then return true end
    if text:find("lvl") then return true end

    -- Hide large banner text
    if label.TextSize >= 26 then
        local y = label.AbsolutePosition.Y
        local camY = workspace.CurrentCamera.ViewportSize.Y
        if y > camY*0.2 and y < camY*0.6 then
            return true
        end
    end

    return false
end


task.spawn(function()
    while _G.FishItWORK do
        task.wait(1.5)

        if not _G.CLEAN_FISH_UI then continue end

        local pg = LP:FindFirstChild("PlayerGui")
        if not pg then continue end

        local fishGui = pg:FindFirstChild("FishingUI")
        if not fishGui then continue end

        for _, obj in ipairs(fishGui:GetDescendants()) do
            if shouldHideLabel(obj) then
                obj.Visible = false
            end
        end
    end
end)


print("PART 4 Loaded ✓")
-- ==========================================
-- PART 5: AUTO TOTEM SYSTEM (FULL CLEAN)
-- ==========================================

-- Load Replion for Data Inventory
local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")

-- Remotes
local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipToolFromHotbar = Net:RemoteEvent("EquipToolFromHotbar")

-- Internal state
local COOLDOWN = 0
local retryWait = false
local TRY_INTERVAL = 300  -- Retry 5 menit


-- ======== Ambil UUID Totem Player ========

local function GetTotemUUID()
    local inv = Data:Get({"Inventory", "Totems"})
    if inv and #inv > 0 then
        return inv[1].UUID
    end
    return nil
end


-- ======== Auto Equip Rod (Wajib setiap 2.5s) ========

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


-- ======== Saat Server Confirm Totem Spawn ========

TotemSpawned.OnClientEvent:Connect(function()
    COOLDOWN = 3600 -- cooldown totem 1 jam
end)


-- ======== AUTO TOTEM LOOP UTAMA ========

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)

        if not AUTO_TOTEM then
            continue
        end

        -- Cooldown berjalan normal
        if COOLDOWN > 0 then
            COOLDOWN -= 1
            continue
        end

        -- Jika lagi masa retry
        if retryWait then
            if os.clock() < retryWait then
                continue
            else
                retryWait = false
            end
        end

        -- Cari totem
        local uuid = GetTotemUUID()
        if not uuid then
            warn("[TOTEM] Tidak ada Totem di inventory.")
            continue
        end

        -- Fire to server
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
            warn("[TOTEM] Gagal spawn. Retry 5 menit.")
            retryWait = os.clock() + TRY_INTERVAL
        end
    end
end)

print("PART 5 Loaded ✓")
-- ==========================================
-- PART 6: SCREEN SCALE (MOBILE) + FPS BOOST
-- ==========================================

-- ========= SCREEN SCALE FIX (MOBILE SAFE) =========

task.spawn(function()
    local player = Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui")

    local function applyScale()
        local cam = workspace.CurrentCamera
        if not cam then return end

        local w = cam.ViewportSize.X
        local scale = 1

        if UIS.TouchEnabled then
            if w <= 360 then
                scale = 0.45
            elseif w <= 400 then
                scale = 0.5
            elseif w <= 440 then
                scale = 0.55
            elseif w <= 480 then
                scale = 0.6
            elseif w <= 600 then
                scale = 0.7
            else
                scale = 0.8
            end
        end

        -- Rayfield pakai ScreenGui internal
        for _,g in ipairs(gui:GetChildren()) do
            if g:IsA("ScreenGui") and g:FindFirstChildOfClass("UIScale") then
                g:FindFirstChildOfClass("UIScale").Scale = scale
            end
        end
    end

    applyScale()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
end)


-- ========= FPS BOOSTER (GUI FILTER) =========

task.spawn(function()
    while _G.FishItWORK do
        task.wait(3)

        local pg = LP:FindFirstChild("PlayerGui")
        if not pg then continue end

        -- matikan gui berat yang gak penting
        for _,gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") then
                if gui.Name ~= "Rayfield" and gui.Name ~= "Chat" then
                    -- jangan destroy, cukup disable jika bisa
                    pcall(function()
                        if gui.Enabled ~= nil then
                            gui.Enabled = true
                        end
                    end)
                end
            end
        end
    end
end)

print("PART 6 Loaded ✓")
-- ==========================================
-- PART 7: TELEPORT SYSTEM + FINALIZE
-- ==========================================

-- ========= TELEPORT LOCATIONS =========
-- (diambil dari script asli kamu, FULL)

Locations = {
    { Name = "Ancient Jungle", CFrame = CFrame.new(1562.54, 6.62, -233.16) },
    { Name = "Ancient Ruin", CFrame = CFrame.new(6076.29, -585.92, 4625.92) },
    { Name = "Coral Reefs", CFrame = CFrame.new(-2752.80, 4.0, 2165.78) },
    { Name = "Crater Island", CFrame = CFrame.new(1027.12, 2.89, 5148.10) },
    { Name = "Fisherman Island", CFrame = CFrame.new(73.35, 9.53, 2709.50) },
    { Name = "Kohana", CFrame = CFrame.new(-595.69, 19.25, 429.86) },
    { Name = "Pirate Cove", CFrame = CFrame.new(3398.70, 10.34, 3491.11) },
    { Name = "Treasure Room", CFrame = CFrame.new(-3597.20, -280.11, -1633.28) },
    { Name = "Tropical Grove", CFrame = CFrame.new(-2128.62, 53.48, 3637.66) },
    { Name = "Weather Machine", CFrame = CFrame.new(-1527.67, 2.87, 1914.66) },
}

-- ========= RAYFIELD TELEPORT TAB =========

local TeleportTab = Window:CreateTab("Teleport", 4483362458)

TeleportTab:CreateSection("Teleport To Players")

for _,plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then
        TeleportTab:CreateButton({
            Name = plr.Name,
            Callback = function()
                local hrp1 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local hrp2 = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp1 and hrp2 then
                    hrp1.CFrame = hrp2.CFrame * CFrame.new(0,0,-3)
                end
            end
        })
    end
end

TeleportTab:CreateSection("Teleport To Fishing Spots")

for _,spot in ipairs(Locations) do
    TeleportTab:CreateButton({
        Name = spot.Name,
        Callback = function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spot.CFrame + Vector3.new(0,5,0)
            end
        end
    })
end


-- ========= FINAL CONFIRM =========

Rayfield:Notify({
    Title = "Sanzhuy Hub",
    Content = "All systems loaded successfully ✅",
    Duration = 6
})

print("PART 7 Loaded ✓")
print("✅ FULL SCRIPT LOADED — RAYFIELD VERSION")
