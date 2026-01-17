--====================================================--
--=========== FISHIT HUB — FINAL FULL MERGE ==========--
--================== BATCH 1 / 5 =====================--
--====================================================--

if _G.FishItHubLoaded then return end
_G.FishItHubLoaded = true

------------------------------------------------------
-- SERVICES
------------------------------------------------------
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

------------------------------------------------------
-- NET PACKAGE
------------------------------------------------------
local Net = require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)

-- Remote Functions
local sellRF = Net:RemoteFunction("SellAllItems")
local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")

-- Remote Events
local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipToolFromHotbar = Net:RemoteEvent("EquipToolFromHotbar")

-- Player Data (Replion)
local Data = Replion.Client:WaitReplion("Data")

------------------------------------------------------
-- GLOBAL FEATURES STATE
------------------------------------------------------
_G.FISH = {
    AutoFish      = false,
    AutoSell      = false,
    AutoWeather   = false,
    AutoTotem     = false,
    FlyEnabled    = false,

    FlySpeed      = 80,
    FishDelay     = 0.13,
    SellInterval  = 5,
    WeatherDelay  = 5,

    TotemCooldown = 0,
    RetryWait     = false
}

------------------------------------------------------
-- ANTI AFK
------------------------------------------------------
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

------------------------------------------------------
-- FISHING CONTROLLER (WAJIB ADA)
------------------------------------------------------
local FishingController = nil
task.spawn(function()
    repeat
        task.wait(0.25)
        local ok, result = pcall(function()
            return require(ReplicatedStorage.Controllers.FishingController)
        end)
        if ok and result then
            FishingController = result
        end
    until FishingController
end)

print("✔ BATCH 1 Loaded | Core Systems Ready")


--====================================================--
--================== BATCH 2 / 5 =====================--
--============= GLASS UI + PAGE SYSTEM ===============--
--====================================================--

------------------------------------------------------
-- REMOVE OLD UI (SAFE)
------------------------------------------------------
pcall(function()
    LP.PlayerGui:FindFirstChild("FishItHubUI"):Destroy()
end)

------------------------------------------------------
-- SCREEN GUI
------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FishItHubUI"
gui.ResetOnSpawn = false
gui.Parent = LP.PlayerGui


------------------------------------------------------
-- GLOBAL UI SCALE (CIUTKAN SELURUH HUB)
------------------------------------------------------
local UIScale = Instance.new("UIScale", gui)
UIScale.Scale = 0.75   -- 🔥 Kecil bagus (0.75)
-- Rekomendasi nilai:
-- 0.90 = Sedikit kecil
-- 0.80 = Pas untuk HP medium
-- 0.75 = Kecil tapi nyaman
-- 0.65 = Super mini (HP kecil)


------------------------------------------------------
-- BLUR EFFECT (SAFE)
------------------------------------------------------
local blur = Instance.new("BlurEffect")
blur.Name = "FishItHubBlur"
blur.Size = 14
blur.Parent = Lighting

------------------------------------------------------
-- THEME (GLASS MINIMAL)
------------------------------------------------------
local THEME = {
    BG      = Color3.fromRGB(18,18,22),
    PANEL   = Color3.fromRGB(25,25,30),
    BUTTON  = Color3.fromRGB(35,35,40),
    ACTIVE  = Color3.fromRGB(80,160,255),
    TEXT    = Color3.fromRGB(235,235,245),
    DIM     = Color3.fromRGB(160,160,170),
    BORDER  = Color3.fromRGB(255,255,255)
}

------------------------------------------------------
-- MAIN WINDOW
------------------------------------------------------
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 620, 0, 380)
main.Position = UDim2.new(0.5,-310,0.45,-190)
main.BackgroundColor3 = THEME.BG
main.BackgroundTransparency = 0.15
main.Active = true
main.Draggable = true
main.BorderSizePixel = 0

Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = THEME.BORDER
mainStroke.Transparency = 0.75

------------------------------------------------------
-- TITLE BAR
------------------------------------------------------
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,38)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Text = "FishIt Hub — Glass Minimal"
title.Size = UDim2.new(1,-50,1,0)
title.Position = UDim2.new(0,16,0,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = THEME.TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,32,0,32)
closeBtn.Position = UDim2.new(1,-36,0,3)
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = THEME.TEXT
closeBtn.BackgroundTransparency = 1

closeBtn.MouseButton1Click:Connect(function()
    _G.FishItHubLoaded = false
    pcall(function() blur:Destroy() end)
    pcall(function() gui:Destroy() end)
end)

------------------------------------------------------
-- SIDEBAR
------------------------------------------------------
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,150,1,-42)
sidebar.Position = UDim2.new(0,0,0,42)
sidebar.BackgroundColor3 = THEME.PANEL
sidebar.BackgroundTransparency = 0.2
sidebar.BorderSizePixel = 0

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,10)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0,6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

------------------------------------------------------
-- PAGE CONTAINER
------------------------------------------------------
local pages = Instance.new("Frame", main)
pages.Size = UDim2.new(1,-170,1,-42)
pages.Position = UDim2.new(0,170,0,42)
pages.BackgroundTransparency = 1

------------------------------------------------------
-- PAGE SYSTEM
------------------------------------------------------
local Pages = {}

local function createPage(name)
    local f = Instance.new("Frame", pages)
    f.Size = UDim2.new(1,0,1,0)
    f.Visible = false
    f.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0,10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    Pages[name] = f
    return f
end

local function switchPage(name)
    for n,p in pairs(Pages) do
        p.Visible = (n == name)
    end
end

------------------------------------------------------
-- CREATE PAGES
------------------------------------------------------
local MainPage   = createPage("Main")
local PlayerPage = createPage("Players")
local SpotPage   = createPage("Spots")
local VisualPage = createPage("Visual")
local MiscPage   = createPage("Misc")

switchPage("Main")

------------------------------------------------------
-- TAB BUTTON BUILDER
------------------------------------------------------
local function createTab(name)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1,-24,0,34)
    b.Text = name
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextColor3 = THEME.TEXT
    b.BackgroundColor3 = THEME.BUTTON
    b.BackgroundTransparency = 0.25
    b.BorderSizePixel = 0

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", b)
    s.Color = THEME.BORDER
    s.Transparency = 0.85

    b.MouseButton1Click:Connect(function()
        for _,x in ipairs(sidebar:GetChildren()) do
            if x:IsA("TextButton") then
                x.BackgroundColor3 = THEME.BUTTON
                x.BackgroundTransparency = 0.25
            end
        end

        b.BackgroundColor3 = THEME.ACTIVE
        b.BackgroundTransparency = 0.05
        switchPage(name)
    end)
end

------------------------------------------------------
-- CREATE TABS
------------------------------------------------------
createTab("Main")
createTab("Players")
createTab("Spots")
createTab("Visual")
createTab("Misc")

------------------------------------------------------
-- FLOATING TOGGLE BUTTON
------------------------------------------------------
local floatBtn = Instance.new("ImageButton", gui)
floatBtn.Size = UDim2.new(0,48,0,48)
floatBtn.Position = UDim2.new(0.03,0,0.4,0)
floatBtn.Image = "rbxassetid://72407089659970"
floatBtn.BackgroundColor3 = Color3.fromRGB(120,160,255)
floatBtn.BackgroundTransparency = 0.25
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.BorderSizePixel = 0

Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0,14)
local fs = Instance.new("UIStroke", floatBtn)
fs.Color = THEME.BORDER
fs.Transparency = 0.6

local visible = true
floatBtn.MouseButton1Click:Connect(function()
    visible = not visible
    main.Visible = visible

    if blur then
        blur.Enabled = visible
    end
end)

print("✔ BATCH 2 Loaded | Glass UI Ready")

--====================================================--
--================== BATCH 3 / 5 =====================--
--============= TOGGLES + FEATURES ENGINE ============--
--====================================================--

local F = _G.FISH

------------------------------------------------------
-- TOGGLE BUILDER (MASTER)
------------------------------------------------------
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,300,0,34)
    btn.BackgroundColor3 = THEME.BUTTON
    btn.BackgroundTransparency = 0.25
    btn.TextColor3 = THEME.TEXT
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Text = text .. " : OFF"

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and THEME.ACTIVE or THEME.BUTTON
        callback(state)
    end)

    return btn
end


------------------------------------------------------
-- UI → ENGINE TOGGLE MAP
------------------------------------------------------
local ToggleMap = {
    ["Auto Fish"] = function(v)  F.AutoFish = v end,
    ["Auto Sell"] = function(v)  F.AutoSell = v end,
    ["Auto Weather"] = function(v)  F.AutoWeather = v end,
    ["Auto Totem"] = function(v)  F.AutoTotem = v end,
    ["Fly"] = function(v)
        F.FlyEnabled = v
        if v then
            _G.StartFly()
        else
            _G.StopFly()
        end
    end,
}

------------------------------------------------------
-- APPLYTOGGLE WRAPPER
------------------------------------------------------
function _G.ApplyToggle(name, state)
    if ToggleMap[name] then
        ToggleMap[name](state)
    end
end

------------------------------------------------------
-- MAIN PAGE BUTTONS
------------------------------------------------------
createToggle(MainPage, "Auto Fish",    function(v) _G.ApplyToggle("Auto Fish", v) end)
createToggle(MainPage, "Auto Sell",    function(v) _G.ApplyToggle("Auto Sell", v) end)
createToggle(MainPage, "Auto Weather", function(v) _G.ApplyToggle("Auto Weather", v) end)
createToggle(MainPage, "Auto Totem",   function(v) _G.ApplyToggle("Auto Totem", v) end)


------------------------------------------------------
-- FULL TOTEM STATUS SYSTEM (SEPERTI UI LAMA)
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(1)

        -- Jika Auto Totem OFF → IDLE (UI lama style)
        if not F.AutoTotem then
            TotemStatus.Text = "Totem Status: Idle"
            TotemStatus.TextColor3 = Color3.fromRGB(200,200,200)
            continue
        end

        -- READY
        if F.TotemCooldown <= 0 then
            TotemStatus.Text = "Totem Status: READY"
            TotemStatus.TextColor3 = Color3.fromRGB(0,255,120)
        else
            -- COOLDOWN
            local m = math.floor(F.TotemCooldown / 60)
            local s = F.TotemCooldown % 60
            TotemStatus.Text = string.format("Totem Status: %02dm %02ds", m, s)
            TotemStatus.TextColor3 = Color3.fromRGB(255,200,80)
        end
    end
end)



createToggle(MainPage, "Fly",          function(v) _G.ApplyToggle("Fly", v) end)

------------------------------------------------------
-- TOTEM STATUS LABEL (DI MAIN TAB)
------------------------------------------------------
local TotemStatus = Instance.new("TextLabel", MainPage)
TotemStatus.Size = UDim2.new(0,300,0,20)
TotemStatus.BackgroundTransparency = 1
TotemStatus.Font = Enum.Font.Gotham
TotemStatus.TextSize = 12
TotemStatus.TextXAlignment = Enum.TextXAlignment.Left
TotemStatus.TextColor3 = THEME.TEXT
TotemStatus.Text = "Totem Status: Idle"



------------------------------------------------------
-- FLY ENGINE
------------------------------------------------------
local flyConn, bv, bg

function _G.StopFly()
    F.FlyEnabled = false
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

function _G.StartFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    bg = Instance.new("BodyGyro", hrp)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)

    flyConn = RS.RenderStepped:Connect(function()
        if not F.FlyEnabled then return end

        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        bv.Velocity = move.Magnitude > 0 and move.Unit * F.FlySpeed or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end


------------------------------------------------------
-- AUTO FISH LOOP
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(F.FishDelay)

        if F.AutoFish and FishingController then
            local guid = FishingController:GetCurrentGUID()

            if not guid then
                pcall(function()
                    FishingController:RequestChargeFishingRod(
                        workspace.CurrentCamera.ViewportSize / 2, true
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


------------------------------------------------------
-- AUTO SELL LOOP
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(F.SellInterval)
        if F.AutoSell then
            pcall(function()
                sellRF:InvokeServer()
            end)
        end
    end
end)


------------------------------------------------------
-- AUTO WEATHER LOOP
------------------------------------------------------
local WeatherList = {"Storm", "Cloudy", "Wind"}

task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(F.WeatherDelay)

        if F.AutoWeather then
            for _,weather in ipairs(WeatherList) do
                pcall(function()
                    purchaseRF:InvokeServer(weather)
                end)
                task.wait(1.3)
            end
        end
    end
end)

------------------------------------------------------
-- MISC TAB : REJOIN BUTTON
------------------------------------------------------
local RejoinBtn = Instance.new("TextButton", MiscPage)
RejoinBtn.Size = UDim2.new(0,300,0,34)
RejoinBtn.BackgroundColor3 = THEME.BUTTON
RejoinBtn.BackgroundTransparency = 0.25
RejoinBtn.TextColor3 = THEME.TEXT
RejoinBtn.Font = Enum.Font.GothamBold
RejoinBtn.TextSize = 12
RejoinBtn.BorderSizePixel = 0
RejoinBtn.Text = "Rejoin Server"

Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0,8)

RejoinBtn.MouseButton1Click:Connect(function()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LP)
    end)
end)


print("✔ BATCH 3 Loaded | Toggles + Engine Active")

--====================================================--
--================== BATCH 4 / 5 =====================--
--=========== AUTO TOTEM + TELEPORT SYSTEM ===========--
--====================================================--

local F = _G.FISH

------------------------------------------------------
-- AUTO TOTEM : GET UUID
------------------------------------------------------
local function GetTotemUUID()
    local inv = Data:Get({"Inventory","Totems"})
    if inv then
        for _,item in ipairs(inv) do
            return item.UUID
        end
    end
    return nil
end

------------------------------------------------------
-- TOTEM SPAWNED → EQUIP ROD (VERSI FINAL)
------------------------------------------------------
TotemSpawned.OnClientEvent:Connect(function()
    F.TotemCooldown = 3600

    -- UI Lama: Status EQUIPPING ROD
    TotemStatus.Text = "Totem Status: Equipping Rod..."
    TotemStatus.TextColor3 = Color3.fromRGB(80,160,255)

    task.delay(0.25, function()
        local equipped = Data:Get("EquippedItems")

        if equipped and equipped[1] then
            pcall(function() EquipToolFromHotbar:FireServer(1) end)
        else
            -- brute search slot 1–9
            for slot = 1,9 do
                pcall(function()
                    EquipToolFromHotbar:FireServer(slot)
                end)
                task.wait(0.05)
            end
        end
    end)
end)


------------------------------------------------------
-- AUTO TOTEM CORE LOOP
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(1)

        if not F.AutoTotem then continue end

        -- cooldown berjalan
        if F.TotemCooldown > 0 then
            F.TotemCooldown -= 1
            continue
        end

        -- retry wait aktif
        if F.RetryWait then
            if os.clock() < F.RetryWait then
                continue
            else
                F.RetryWait = false
            end
        end

        -- ambil UUID
        local uuid = GetTotemUUID()
        if not uuid then
            task.wait(4)
            continue
        end

        -- try spawn
        local success = false
        local conn = nil

        conn = TotemSpawned.OnClientEvent:Connect(function()
            success = true
            conn:Disconnect()
        end)

        SpawnTotem:FireServer(uuid)
        task.wait(0.5)

        if conn then conn:Disconnect() end

        -- gagal → retry dalam 5 menit
        if not success then
            F.RetryWait = os.clock() + 300
        end
    end
end)


--====================================================
-- TELEPORT MENU — MODE 1 (Players Tab + Spots Tab)
--====================================================

------------------------------------------------------
-- REFRESH PLAYER LIST
------------------------------------------------------
function _G.RefreshPlayerList(parent)
    -- clear old
    for _,v in ipairs(parent:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    -- spawn new buttons
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local b = Instance.new("TextButton", parent)
            b.Size = UDim2.new(0,300,0,32)
            b.BackgroundColor3 = THEME.BUTTON
            b.TextColor3 = THEME.TEXT
            b.Font = Enum.Font.Gotham
            b.TextSize = 12
            b.Text = plr.Name
            b.BorderSizePixel = 0

            Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

            b.MouseButton1Click:Connect(function()
                local me = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local target = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if me and target then
                    me.CFrame = target.CFrame * CFrame.new(0,0,-3)
                end
            end)
        end
    end
end

------------------------------------------------------
-- PLAYER PAGE LIST POPULATE
------------------------------------------------------
task.spawn(function()
    task.wait(1)
    _G.RefreshPlayerList(PlayerPage)
end)

Players.PlayerAdded:Connect(function()
    task.delay(0.5, function()
        _G.RefreshPlayerList(PlayerPage)
    end)
end)

Players.PlayerRemoving:Connect(function()
    task.delay(0.5, function()
        _G.RefreshPlayerList(PlayerPage)
    end)
end)


--====================================================
-- TELEPORT SPOTS (FULL A–Z)
--====================================================

local SpotList = {
    { Name = "Ancient Jungle",      CFrame = CFrame.new(1562.54, 6.62, -233.16) },
    { Name = "Ancient Ruin",        CFrame = CFrame.new(6076.29, -585.92, 4625.92) },
    { Name = "Captain Jones (Quest)", CFrame = CFrame.new(3312.16, 9.09, 3681.58) },
    { Name = "Coral Reefs",         CFrame = CFrame.new(-2752.8, 4.0, 2165.78) },
    { Name = "Crater Island",       CFrame = CFrame.new(1027.12, 2.89, 5148.10) },
    { Name = "Deadman Compass (Quest)", CFrame = CFrame.new(-3437.02, -22.36, -1500.29) },
    { Name = "Esoteric Depths",     CFrame = CFrame.new(3249.08, -1301.52, 1373.68) },
    { Name = "Fisherman Island",    CFrame = CFrame.new(73.35, 9.53, 2709.50) },
    { Name = "Kohana",              CFrame = CFrame.new(-595.69, 19.25, 429.86) },
    { Name = "Kohana Volcano",      CFrame = CFrame.new(-559.59, 21.22, 153.75) },
    { Name = "Kuil Suci",           CFrame = CFrame.new(1471.79, -22.12, -607.50) },
    { Name = "Pirate Cove",         CFrame = CFrame.new(3398.70, 10.34, 3491.11) },
    { Name = "Pirate Treasure Room",CFrame = CFrame.new(3340.80, -301.51, 3090.66) },
    { Name = "Sisyphus Statue",     CFrame = CFrame.new(-3745.26, -135.07, -1008.68) },
    { Name = "Traveling Merchant",  CFrame = CFrame.new(-133.94, 3.18, 2767.25) },
    { Name = "Treasure Room",       CFrame = CFrame.new(-3597.20, -280.11, -1633.28) },
    { Name = "Tropical Grove",      CFrame = CFrame.new(-2128.62, 53.48, 3637.66) },
    { Name = "Weather Machine",     CFrame = CFrame.new(-1527.67, 2.87, 1914.66) },
}

------------------------------------------------------
-- REFRESH SPOT LIST
------------------------------------------------------
function _G.RefreshSpotList(parent)
    -- clear
    for _,v in ipairs(parent:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    -- create
    for _,spot in ipairs(SpotList) do
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0,300,0,32)
        b.BackgroundColor3 = THEME.BUTTON
        b.TextColor3 = THEME.TEXT
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.Text = spot.Name
        b.BorderSizePixel = 0

        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

        b.MouseButton1Click:Connect(function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spot.CFrame + Vector3.new(0,5,0)
            end
        end)
    end
end

------------------------------------------------------
-- INITIALIZE SPOT PAGE
------------------------------------------------------
task.spawn(function()
    task.wait(1)
    _G.RefreshSpotList(SpotPage)
end)

print("✔ BATCH 4 Loaded | Auto Totem + Teleport Ready")

--====================================================--
--================== BATCH 5 / 5 =====================--
--========= CLEAN UI + FPS BOOST + FINALIZE ==========--
--====================================================--




------------------------------------------------------
-- REAL PING FUNCTION (PORT FROM FishItWORKUI)
------------------------------------------------------
local function GetRealPing()
    local network = Stats:FindFirstChild("Network")
    if not network then return nil end

    local serverStats = network:FindFirstChild("ServerStatsItem")
    if not serverStats then return nil end

    local pingStat = serverStats:FindFirstChild("Data Ping")
    if not pingStat then return nil end

    local value = pingStat:GetValue()
    if type(value) ~= "number" then return nil end

    return value
end

------------------------------------------------------
-- PING PANEL (FRAME, BUKAN TEXTLABEL)
------------------------------------------------------
local PingPanel = Instance.new("Frame", gui)
PingPanel.Name = "PingPanel"
PingPanel.Size = UDim2.new(0,140,0,26)
PingPanel.BackgroundColor3 = THEME.PANEL
PingPanel.BackgroundTransparency = 0.15
PingPanel.Visible = false
PingPanel.BorderSizePixel = 0

Instance.new("UICorner", PingPanel).CornerRadius = UDim.new(0,8)
local ps = Instance.new("UIStroke", PingPanel)
ps.Color = THEME.BORDER
ps.Transparency = 0.6

-- TEXT DI DALAM PANEL
local PingText = Instance.new("TextLabel", PingPanel)
PingText.Size = UDim2.new(1,0,1,0)
PingText.BackgroundTransparency = 1
PingText.Font = Enum.Font.Gotham
PingText.TextSize = 12
PingText.TextColor3 = THEME.TEXT
PingText.Text = "Ping: --"


Instance.new("UICorner", PingPanel).CornerRadius = UDim.new(0,8)


------------------------------------------------------
-- VISUAL TAB : SHOW PING PANEL TOGGLE
------------------------------------------------------
createToggle(VisualPage, "Show Ping Panel", function(state)
    PingPanel.Visible = state
end)


------------------------------------------------------
-- VISUAL TAB : MERCHANT BUTTON (AUTO CLOSE 5s)
------------------------------------------------------

local MerchantBtn = Instance.new("TextButton", VisualPage)
MerchantBtn.Size = UDim2.new(0,300,0,34)
MerchantBtn.BackgroundColor3 = THEME.BUTTON
MerchantBtn.BackgroundTransparency = 0.25
MerchantBtn.TextColor3 = THEME.TEXT
MerchantBtn.Font = Enum.Font.GothamBold
MerchantBtn.TextSize = 12
MerchantBtn.BorderSizePixel = 0
MerchantBtn.Text = "Open Merchant (Auto Close 5s)"

Instance.new("UICorner", MerchantBtn).CornerRadius = UDim.new(0,8)

local merchantGui = LP.PlayerGui:FindFirstChild("Merchant")

MerchantBtn.MouseButton1Click:Connect(function()
    if not merchantGui then return end

    -- Buka merchant
    merchantGui.Enabled = true

    -- Tutup panel utama kayak floatBtn
    if main.Visible then
        main.Visible = false
    end

    -- Auto close setelah 5 detik
    task.delay(5, function()
        if merchantGui then
            merchantGui.Enabled = false
        end
    end)
end)



------------------------------------------------------
-- PING UPDATE LOOP (COLOR SYSTEM + SAFE)
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(1)

        if not PingPanel.Visible then
            continue
        end

        local ping = GetRealPing()

        if not ping then
            PingText.Text = "Ping: --"
            PingText.TextColor3 = Color3.fromRGB(200,200,200)
        else
            PingText.Text = string.format("Ping: %.1f ms", ping)

            -- ⚡ WARNA PING
            if ping < 60 then
                PingText.TextColor3 = Color3.fromRGB(0,255,120)   -- hijau
            elseif ping < 120 then
                PingText.TextColor3 = Color3.fromRGB(255,255,0)   -- kuning
            elseif ping < 200 then
                PingText.TextColor3 = Color3.fromRGB(255,150,0)   -- oranye
            else
                PingText.TextColor3 = Color3.fromRGB(255,70,70)   -- merah
            end
        end
    end
end)


------------------------------------------------------
-- AUTO FOLLOW FLOAT BUTTON (PING NEMPEL)
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait()

        if PingPanel.Visible then
            PingPanel.Position = UDim2.new(
                floatBtn.Position.X.Scale,
                floatBtn.Position.X.Offset,
                floatBtn.Position.Y.Scale,
                floatBtn.Position.Y.Offset + floatBtn.Size.Y.Offset + 5
            )
        end
    end
end)

------------------------------------------------------
-- MAKE PING PANEL DRAGGABLE
------------------------------------------------------
local dragging = false
local dragPos = Vector2.new()

PingPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragPos = Vector2.new(input.Position.X - PingPanel.AbsolutePosition.X,
                              input.Position.Y - PingPanel.AbsolutePosition.Y)
    end
end)

PingPanel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        PingPanel.Position = UDim2.fromOffset(
            input.Position.X - dragPos.X,
            input.Position.Y - dragPos.Y
        )
    end
end)


--====================================================--
--========== PATCH: SCROLL PLAYER & SPOT =============--
--====================================================--

local function makeScrollable(page)
    -- simpan semua child lama
    local children = {}
    for _,v in ipairs(page:GetChildren()) do
        table.insert(children, v)
    end

    -- hapus layout lama
    for _,v in ipairs(children) do
        v.Parent = nil
    end

    -- buat ScrollingFrame
    local scroll = Instance.new("ScrollingFrame", page)
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 4
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,8)

    -- masukin ulang child
    for _,v in ipairs(children) do
        v.Parent = scroll
    end

    return scroll
end

------------------------------------------------------
-- APPLY TO PLAYER & SPOT PAGE
------------------------------------------------------
local PlayerScroll = makeScrollable(PlayerPage)
local SpotScroll   = makeScrollable(SpotPage)

------------------------------------------------------
-- UPDATE REFRESH FUNCTIONS TARGET
------------------------------------------------------
-- override supaya isi masuk ke ScrollingFrame

local _oldRefreshPlayer = _G.RefreshPlayerList
_G.RefreshPlayerList = function()
    _oldRefreshPlayer(PlayerScroll)
end

local _oldRefreshSpot = _G.RefreshSpotList
_G.RefreshSpotList = function()
    _oldRefreshSpot(SpotScroll)
end

-- initial refresh
task.delay(0.5, function()
    _G.RefreshPlayerList()
    _G.RefreshSpotList()
end)

print("✔ PATCH APPLIED | Player & Spot now scrollable")



local F = _G.FISH

------------------------------------------------------
-- CLEAN FISHING UI (KEEP ONLY "You got:")
------------------------------------------------------
local function shouldHideFishLabel(lb)
    if not lb:IsA("TextLabel") then return false end
    if not lb.Text or lb.Text == "" then return false end

    local t = lb.Text:lower()

    if t:match("^%s*you%s+got") then return false end
    if t:match("^1%s+in") then return true end
    if t:find("kg") then return true end
    if t:find("lvl") then return true end

    -- remove big banners
    if lb.TextSize >= 26 then
        local scrY = workspace.CurrentCamera.ViewportSize.Y
        local pos = lb.AbsolutePosition.Y
        if pos > scrY * 0.15 and pos < scrY * 0.7 then
            return true
        end
    end

    return false
end

task.spawn(function()
    local pg = LP:WaitForChild("PlayerGui")
    while _G.FishItHubLoaded do
        task.wait(2)
        local fishUI = pg:FindFirstChild("FishingUI")
        if not fishUI then continue end

        for _,v in ipairs(fishUI:GetDescendants()) do
            if shouldHideFishLabel(v) then
                v.Visible = false
            end
        end
    end
end)


------------------------------------------------------
-- LOW GFX MODE (ULTRA LIGHT)
------------------------------------------------------
task.spawn(function()
    Lighting.GlobalShadows = false
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.FogEnd = 999999
    Lighting.Brightness = 1

    for _,fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("SunRaysEffect")
        or fx:IsA("DepthOfFieldEffect")
        or fx:IsA("BloomEffect")
        or fx:IsA("ColorCorrectionEffect")
        then fx.Enabled = false end
    end
end)





------------------------------------------------------
-- FINAL STYLE PASS (GLASS MINIMAL)
------------------------------------------------------
local function applyStyle(obj)
    if obj:IsA("Frame") then
        obj.BackgroundTransparency = obj.BackgroundTransparency
        obj.BackgroundColor3 = obj.BackgroundColor3 or THEME.BG

    elseif obj:IsA("TextButton") then
        obj.BackgroundColor3 = obj.BackgroundColor3 or THEME.BUTTON
        obj.TextColor3 = THEME.TEXT
        obj.AutoButtonColor = false

    elseif obj:IsA("TextLabel") then
        obj.TextColor3 = THEME.TEXT
    end

    if (obj:IsA("Frame") or obj:IsA("TextButton")) and not obj:FindFirstChild("UICorner") then
        local c = Instance.new("UICorner", obj)
        c.CornerRadius = UDim.new(0, 10)
    end

    if (obj:IsA("Frame") or obj:IsA("TextButton")) and not obj:FindFirstChild("UIStroke") then
        local s = Instance.new("UIStroke", obj)
        s.Color = THEME.BORDER
        s.Thickness = 1
        s.Transparency = 0.75
    end
end

for _,v in ipairs(gui:GetDescendants()) do
    applyStyle(v)
end


------------------------------------------------------
-- SAFE EXIT HANDLER
------------------------------------------------------
function _G.CloseHub()
    _G.FishItHubLoaded = false
    F.FlyEnabled = false

    pcall(function() _G.StopFly() end)
    pcall(function() gui:Destroy() end)
    pcall(function() if Lighting:FindFirstChild("FishItHubBlur") then
        Lighting.FishItHubBlur:Destroy()
    end end)
end

print("====================================================")
print("✔ FISHIT HUB — FULL MERGE COMPLETE")
print("✔ ALL FEATURES ACTIVE & UI LOADED")
print("✔ Enjoy your new Glass Minimal Hub!")
print("====================================================")
