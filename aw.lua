-- =====================================================
-- SANZHUY HUB — UI CORE (BAGIAN 1)
-- Glass Gray Transparent + White Text
-- Tab System + Floating Toggle + Element Builders
-- =====================================================

if _G.SZ_FISHIT_RUNNING then return end
_G.SZ_FISHIT_RUNNING = true

-- SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- REMOVE OLD
pcall(function()
    LP.PlayerGui:FindFirstChild("SanzhuyHubUI"):Destroy()
end)

pcall(function()
    Lighting:FindFirstChild("SanzhuyBlur"):Destroy()
end)

-- =====================================================
-- BLUR EFFECT
-- =====================================================
local blur = Instance.new("BlurEffect")
blur.Name = "SanzhuyBlur"
blur.Size = 18
blur.Parent = Lighting

-- =====================================================
-- ROOT UI
-- =====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "SanzhuyHubUI"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

-- MOBILE SCALE
local scale = Instance.new("UIScale", gui)

local function updateScale()
    if not UIS.TouchEnabled then
        scale.Scale = 1
        return
    end

    local w = Camera.ViewportSize.X
    if w < 380 then scale.Scale = 0.55
    elseif w < 420 then scale.Scale = 0.60
    elseif w < 480 then scale.Scale = 0.65
    elseif w < 600 then scale.Scale = 0.75
    else scale.Scale = 0.85 end
end

updateScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

-- =====================================================
-- THEME
-- =====================================================
local THEME = {
    BG = Color3.fromRGB(220,220,220),          -- abu abu terang semi transparan
    TEXT = Color3.fromRGB(255,255,255),        -- putih
    STROKE = Color3.fromRGB(200,200,200),      -- garis putih pudar
}

-- =====================================================
-- MAIN WINDOW
-- =====================================================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,720,0,420)
main.Position = UDim2.new(0.5,-360,0.5,-210)
main.BackgroundColor3 = THEME.BG
main.BackgroundTransparency = 0.82
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke", main)
stroke.Color = THEME.STROKE
stroke.Transparency = 0.65
stroke.Thickness = 1

-- =====================================================
-- HEADER
-- =====================================================
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1,0,0,36)
header.BackgroundTransparency = 1
header.Font = Enum.Font.GothamBold
header.TextSize = 15
header.TextColor3 = THEME.TEXT
header.Text = "SANZHUY HUB — FISH IT"

-- =====================================================
-- SIDEBAR
-- =====================================================
local sidebar = Instance.new("Frame", main)
sidebar.Position = UDim2.new(0,0,0,36)
sidebar.Size = UDim2.new(0,140,1,-36)
sidebar.BackgroundColor3 = THEME.BG
sidebar.BackgroundTransparency = 0.83
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,12)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0,8)

-- =====================================================
-- CONTENT AREA
-- =====================================================
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,150,0,46)
content.Size = UDim2.new(1,-160,1,-56)
content.BackgroundTransparency = 1

-- TAB STORAGE
local Tabs = {}
local CurrentTab

-- =====================================================
-- NEW TAB FUNCTION
-- =====================================================
function NewTab(name : string)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1,-12,0,32)
    btn.BackgroundColor3 = THEME.BG
    btn.BackgroundTransparency = 0.75
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = THEME.TEXT
    btn.TextSize = 12
    btn.Text = name
    Instance.new("UICorner", btn)

    local frame = Instance.new("Frame", content)
    frame.Size = UDim2.new(1,0,1,0)
    frame.Visible = false
    frame.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Visible = false end
        CurrentTab = frame
        frame.Visible = true
    end)

    if not CurrentTab then
        CurrentTab = frame
        frame.Visible = true
    end

    Tabs[name] = frame
    return frame
end

-- =====================================================
-- ELEMENT BUILDERS
-- =====================================================

-- Toggle button
function MakeToggle(parent : Instance, label : string, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0,260,0,32)
    b.BackgroundColor3 = THEME.BG
    b.BackgroundTransparency = 0.72
    b.TextColor3 = THEME.TEXT
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.Text = label .. " : OFF"
    Instance.new("UICorner", b)

    local on = false

    b.MouseButton1Click:Connect(function()
        on = not on
        b.Text = label.." : "..(on and "ON" or "OFF")
        if callback then callback(on) end
    end)

    return b
end

-- Button
function MakeButton(parent, text, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0,260,0,32)
    b.BackgroundColor3 = THEME.BG
    b.BackgroundTransparency = 0.72
    b.TextColor3 = THEME.TEXT
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.Text = text
    Instance.new("UICorner", b)

    if callback then
        b.MouseButton1Click:Connect(callback)
    end

    return b
end

-- Label
function MakeLabel(parent, text)
    local t = Instance.new("TextLabel", parent)
    t.Size = UDim2.new(0,260,0,22)
    t.BackgroundTransparency = 1
    t.TextColor3 = THEME.TEXT
    t.Font = Enum.Font.Gotham
    t.TextSize = 12
    t.Text = text
    return t
end

-- Slider (Fly Speed)
function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0,260,0,50)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,18)
    label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = THEME.TEXT
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Text = text .. ": " .. default

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1,0,0,6)
    bar.Position = UDim2.new(0,0,0,28)
    bar.BackgroundColor3 = THEME.BG
    bar.BackgroundTransparency = 0.7
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,3)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = THEME.TEXT
    fill.BackgroundTransparency = 0.4
    Instance.new("UICorner", fill)

    local dragging = false

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local rel = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel,0,1,0)
            local val = math.floor(min + (max-min)*rel)
            label.Text = text..": "..val
            if callback then callback(val) end
        end
    end)

    return frame
end

-- =====================================================
-- FLOATING TOGGLE BUTTON
-- =====================================================
local float = Instance.new("ImageButton", gui)
float.Size = UDim2.new(0,48,0,48)
float.Position = UDim2.new(0.03,0,0.4,0)
float.Image = "rbxassetid://72407089659970"
float.BackgroundColor3 = THEME.BG
float.BackgroundTransparency = 0.7
float.Active = true
float.Draggable = true
Instance.new("UICorner", float)

float.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- =====================================================
-- UI CORE SELESAI
-- =====================================================

print("✅ BAGIAN 1 UI CORE LOADED")
_G.SZ_UI_READY = true

-- =====================================================
-- SANZHUY HUB — BAGIAN 2
-- MAIN LOGIC (Auto Fish, Auto Sell, Auto Weather, Ping)
-- =====================================================

-- ⛔ WAJIB: BAGIAN 1 HARUS SUDAH JALAN
repeat task.wait() until _G.SZ_UI_READY

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer

-- =====================================================
-- NET / REMOTES (OFFICIAL)
-- =====================================================
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")
local purchaseWeatherRF = Net:RemoteFunction("PurchaseWeatherEvent")

-- =====================================================
-- STATE (GLOBAL)
-- =====================================================
_G.SZ_STATE = _G.SZ_STATE or {
    AutoFish = false,
    AutoSell = false,
    AutoWeather = false
}

-- =====================================================
-- CREATE TABS (FROM UI CORE)
-- =====================================================
local tMain = NewTab("MAIN")

-- =====================================================
-- UI ELEMENTS (MAIN TAB)
-- =====================================================
local lblStatus = MakeLabel(tMain, "Status: Idle")
local lblPing = MakeLabel(tMain, "Ping: -- ms")

MakeToggle(tMain, "Auto Fish", function(v)
    _G.SZ_STATE.AutoFish = v
end)

MakeToggle(tMain, "Auto Sell", function(v)
    _G.SZ_STATE.AutoSell = v
end)

MakeToggle(tMain, "Auto Weather", function(v)
    _G.SZ_STATE.AutoWeather = v
end)

-- =====================================================
-- REAL PING (AKURAT - STATS)
-- =====================================================
task.spawn(function()
    while _G.SZ_FISHIT_RUNNING do
        task.wait(1)

        local net = Stats:FindFirstChild("Network")
        local server = net and net:FindFirstChild("ServerStatsItem")
        local pingStat = server and server:FindFirstChild("Data Ping")

        if pingStat then
            local ping = pingStat:GetValue()
            lblPing.Text = string.format("Ping: %.1f ms", ping)
        else
            lblPing.Text = "Ping: --"
        end
    end
end)

-- =====================================================
-- FISHING CONTROLLER (WAJIB)
-- =====================================================
local FishingController
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

-- =====================================================
-- AUTO FISH LOOP (ORIGINAL)
-- =====================================================
local FishDelay = 0.13 -- CPU SAFE

task.spawn(function()
    while _G.SZ_FISHIT_RUNNING do
        task.wait(FishDelay)

        if _G.SZ_STATE.AutoFish and FishingController then
            local guid = FishingController:GetCurrentGUID()

            if not guid then
                pcall(function()
                    FishingController:RequestChargeFishingRod(
                        workspace.CurrentCamera.ViewportSize / 2,
                        true
                    )
                end)
            else
                FishingController:FishingMinigameClick()
            end
        end
    end
end)

-- =====================================================
-- AUTO SELL LOOP (SAFE)
-- =====================================================
local SellInterval = 5

task.spawn(function()
    while _G.SZ_FISHIT_RUNNING do
        task.wait(SellInterval)

        if _G.SZ_STATE.AutoSell and sellRF then
            pcall(function()
                sellRF:InvokeServer()
            end)
        end
    end
end)

-- =====================================================
-- AUTO WEATHER LOOP (OFFICIAL)
-- =====================================================
local WeatherDelay = 5
local WeatherList = {"Storm", "Cloudy", "Wind"}

task.spawn(function()
    while _G.SZ_FISHIT_RUNNING do
        task.wait(WeatherDelay)

        if _G.SZ_STATE.AutoWeather and purchaseWeatherRF then
            for _,weather in ipairs(WeatherList) do
                pcall(function()
                    purchaseWeatherRF:InvokeServer(weather)
                end)
                task.wait(1.5)
            end
        end
    end
end)

-- =====================================================
-- STATUS LABEL UPDATE
-- =====================================================
task.spawn(function()
    while _G.SZ_FISHIT_RUNNING do
        task.wait(0.5)

        lblStatus.Text =
            "AutoFish: "..(_G.SZ_STATE.AutoFish and "ON" or "OFF")..
            " | AutoSell: "..(_G.SZ_STATE.AutoSell and "ON" or "OFF")..
            " | Weather: "..(_G.SZ_STATE.AutoWeather and "ON" or "OFF")
    end
end)

print("✅ BAGIAN 2 (MAIN LOGIC) LOADED")

-- =====================================================
-- SANZHUY HUB — BAGIAN 3
-- UTIL (Fly System, Slider, AntiAFK, Clean UI, FPS Boost)
-- =====================================================

-- Pastikan UI Core loaded
repeat task.wait() until _G.SZ_UI_READY

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GLOBAL STATE
_G.SZ_STATE = _G.SZ_STATE or {}
_G.SZ_STATE.Fly = false
_G.SZ_STATE.FlySpeed = 50

-- Create UTIL TAB
local tUtil = NewTab("UTIL")

-- =====================================================
-- ANTI AFK
-- =====================================================
local VirtualUser = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

MakeLabel(tUtil, "Anti AFK: ACTIVE")

-- =====================================================
-- FLY SYSTEM (FULL ORIGINAL YOUR LOGIC)
-- =====================================================
local flyConn
local bv, bg

local function stopFly()
    _G.SZ_STATE.Fly = false

    if flyConn then flyConn:Disconnect() end
    flyConn = nil

    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    bv = nil
    bg = nil
end

local function startFly()
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
        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        bv.Velocity = move.Magnitude > 0
            and move.Unit * _G.SZ_STATE.FlySpeed
            or Vector3.zero

        bg.CFrame = cam.CFrame
    end)
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    stopFly()
end)

-- Toggle Fly (UI)
MakeToggle(tUtil, "Fly", function(on)
    _G.SZ_STATE.Fly = on
    if on then startFly() else stopFly() end
end)

-- Fly Speed Slider
MakeSlider(
    tUtil,
    "Fly Speed",
    50,
    800,
    50,
    function(val)
        _G.SZ_STATE.FlySpeed = val
    end
)

-- =====================================================
-- CLEAN UI FISHING (YOU GOT ONLY)
-- =====================================================
MakeLabel(tUtil, "Clean Fish UI: Enabled")

local function shouldHideLabel(label)
    if not label:IsA("TextLabel") then return false end
    if not label.Text or label.Text == "" then return false end

    local txt = label.Text:lower()

    -- KEEP only: “you got:”
    if txt:match("^%s*you%s+got%s*:") then
        return false
    end

    -- Everything else hide:
    if txt:match("^1%s+in%s+%d+") then return true end
    if txt:match("%(%s*[%d%.]+%s*kg%s*%)") then return true end
    if txt:find("lvl") then return true end
    if label.TextSize >= 26 then return true end

    return false
end

task.spawn(function()
    while _G.SZ_FISHIT_RUNNING do
        task.wait(2)

        local pg = LP:FindFirstChild("PlayerGui")
        if not pg then continue end

        local fishGui = pg:FindFirstChild("FishingUI")
        if not fishGui then continue end

        for _,v in ipairs(fishGui:GetDescendants()) do
            if shouldHideLabel(v) then
                v.Visible = false
            end
        end
    end
end)

-- =====================================================
-- FPS BOOSTER (LIGHT)
-- =====================================================
MakeLabel(tUtil, "FPS Boost: ACTIVE")

task.spawn(function()
    while _G.SZ_FISHIT_RUNNING do
        task.wait(1)
        -- Tidak agresif biar aman
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end
end)

print("✅ BAGIAN 3 (UTIL) LOADED")

-- =====================================================
-- SANZHUY HUB — BAGIAN 4
-- SHOP TAB (AUTO TOTEM FULL + MERCHANT)
-- =====================================================

-- Tunggu UI siap
repeat task.wait() until _G.SZ_UI_READY

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- =====================================================
-- NEW TAB
-- =====================================================
local tShop = NewTab("SHOP")

-- =====================================================
-- ORIGINAL STATE
-- =====================================================
_G.SZ_STATE = _G.SZ_STATE or {}
_G.SZ_STATE.AutoTotem = false

-- =====================================================
-- REMOTES & MODULES
-- =====================================================
local Net = require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)

local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipToolFromHotbar = Net:RemoteEvent("EquipToolFromHotbar")

local Data = Replion.Client:WaitReplion("Data")

-- =====================================================
-- UI ELEMENTS
-- =====================================================
local lblTotemStatus = MakeLabel(tShop, "Auto Totem: OFF")
local lblCooldown = MakeLabel(tShop, "Cooldown: Idle")
local lblRetry = MakeLabel(tShop, "Retry: --")

MakeToggle(tShop, "Auto Totem", function(v)
    _G.SZ_STATE.AutoTotem = v
    lblTotemStatus.Text = "Auto Totem: " .. (v and "ON" or "OFF")
end)

-- =====================================================
-- FUNCTION: GET TOTEM UUID
-- =====================================================
local function GetTotemUUID()
    local inv = Data:Get({"Inventory","Totems"})
    if inv then
        for _,item in ipairs(inv) do
            return item.UUID
        end
    end
    return nil
end

-- =====================================================
-- AUTO EQUIP FISHING ROD LOOP
-- =====================================================
task.spawn(function()
    while _G.SZ_FISHIT_RUNNING do
        task.wait(2.5)

        if _G.SZ_STATE.AutoTotem then
            pcall(function()
                EquipToolFromHotbar:FireServer(1) -- slot 1
            end)
        end
    end
end)

-- =====================================================
-- COOLDOWN SYSTEM (ORIGINAL)
-- =====================================================
local COOLDOWN = 0
local RETRY_END = false
local TRY_INTERVAL = 300 -- 5 menit

-- =====================================================
-- TOTEM SPAWNED EVENT (PEMBARUAN COOLDOWN)
-- =====================================================
TotemSpawned.OnClientEvent:Connect(function()
    COOLDOWN = 3600
    lblCooldown.Text = "Cooldown: 3600s"

    -- Equip rod again
    task.delay(0.2, function()
        pcall(function()
            EquipToolFromHotbar:FireServer(1)
        end)
    end)
end)

-- =====================================================
-- AUTO TOTEM LOOP (FULL)
-- =====================================================
task.spawn(function()
    while _G.SZ_FISHIT_RUNNING do
        task.wait(1)

        if not _G.SZ_STATE.AutoTotem then
            lblTotemStatus.Text = "Auto Totem: OFF"
            lblCooldown.Text = "Cooldown: Idle"
            lblRetry.Text = "Retry: --"
            continue
        end

        lblTotemStatus.Text = "Auto Totem: ON"

        -- COOL DOWN berjalan
        if COOLDOWN > 0 then
            lblCooldown.Text = "Cooldown: "..COOLDOWN.."s"
            COOLDOWN -= 1
            continue
        end

        -- Jika sedang dalam masa retry
        if RETRY_END then
            local remain = math.floor(RETRY_END - os.clock())
            if remain > 0 then
                lblRetry.Text = "Retry in: " .. remain .. "s"
                continue
            else
                RETRY_END = false
                lblRetry.Text = "Retry: Ready"
            end
        end

        -- PASANG TOTEM
        local uuid = GetTotemUUID()
        if not uuid then
            lblTotemStatus.Text = "Totem: NOT FOUND"
            continue
        end

        lblTotemStatus.Text = "Placing Totem..."

        -- Listen success
        local success = false
        local conn
        conn = TotemSpawned.OnClientEvent:Connect(function()
            success = true
            if conn then conn:Disconnect() end
        end)

        SpawnTotem:FireServer(uuid)
        task.wait(0.5)

        if conn then conn:Disconnect() end

        if success then
            lblTotemStatus.Text = "Totem Placed!"
            -- cooldown handled by event
        else
            lblTotemStatus.Text = "FAILED! Retry 5m"
            RETRY_END = os.clock() + TRY_INTERVAL
        end
    end
end)

-- =====================================================
-- MERCHANT TOGGLE (OPEN/CLOSE)
-- =====================================================
local merchantPanel = LP.PlayerGui:FindFirstChild("Merchant")
local merchantOpen = false

MakeButton(tShop, "Merchant", function()
    if not merchantPanel then return end

    merchantOpen = not merchantOpen
    merchantPanel.Enabled = merchantOpen
end)

print("✅ BAGIAN 4 (AUTO TOTEM + MERCHANT) LOADED")

-- =====================================================
-- SANZHUY HUB — BAGIAN 5 (FINAL)
-- TP MENU (PLAYER + SPOT, SCROLLABLE)
-- =====================================================

repeat task.wait() until _G.SZ_UI_READY

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- =====================================================
-- TAB TP
-- =====================================================
local tTP = NewTab("TP")

-- =====================================================
-- TAB SWITCH BUTTONS
-- =====================================================
local tabFrame = Instance.new("Frame", tTP)
tabFrame.Size = UDim2.new(0,260,0,30)
tabFrame.BackgroundTransparency = 1

local btnPlayer = Instance.new("TextButton", tabFrame)
btnPlayer.Size = UDim2.new(0.5,-4,1,0)
btnPlayer.Text = "Player"
btnPlayer.Font = Enum.Font.GothamBold
btnPlayer.TextSize = 12
btnPlayer.TextColor3 = Color3.new(1,1,1)
btnPlayer.BackgroundTransparency = 0.3
Instance.new("UICorner", btnPlayer)

local btnSpot = Instance.new("TextButton", tabFrame)
btnSpot.Position = UDim2.new(0.5,4,0,0)
btnSpot.Size = UDim2.new(0.5,-4,1,0)
btnSpot.Text = "Spot"
btnSpot.Font = Enum.Font.Gotham
btnSpot.TextSize = 12
btnSpot.TextColor3 = Color3.new(1,1,1)
btnSpot.BackgroundTransparency = 0.6
Instance.new("UICorner", btnSpot)

-- =====================================================
-- SCROLL CONTAINER
-- =====================================================
local scroll = Instance.new("ScrollingFrame", tTP)
scroll.Size = UDim2.new(0,260,0,300)
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

-- =====================================================
-- SPOT DATA (FULL – ORIGINAL)
-- =====================================================
local Locations = {
    {Name="Ancient Jungle",CFrame=CFrame.new(1562.54028,6.62499952,-233.164978)},
    {Name="Ancient Ruin",CFrame=CFrame.new(6076.29297,-585.924255,4625.92578)},
    {Name="Captain Jones (Quest)",CFrame=CFrame.new(3312.1604,9.09943581,3681.58276)},
    {Name="Coral Reefs",CFrame=CFrame.new(-2752.8064,4.00034237,2165.78516)},
    {Name="Crater Island",CFrame=CFrame.new(1027.12122,2.89895344,5148.10498)},
    {Name="Deadman Compas (Quest)",CFrame=CFrame.new(-3437.02661,-22.3605175,-1500.29492)},
    {Name="Esoteric Depths",CFrame=CFrame.new(3249.08862,-1301.52979,1373.68054)},
    {Name="Fisherman Island",CFrame=CFrame.new(73.3565826,9.53157043,2709.50098)},
    {Name="Kohana",CFrame=CFrame.new(-595.69751,19.2500706,429.863037)},
    {Name="Kohana Volcano",CFrame=CFrame.new(-559.593994,21.2289829,153.752396)},
    {Name="Kuil Suci",CFrame=CFrame.new(1471.79675,-22.1250019,-607.50592)},
    {Name="Pirate Cove",CFrame=CFrame.new(3398.70093,10.3427305,3491.1123)},
    {Name="Pirate Treasure Room",CFrame=CFrame.new(3340.80273,-301.512665,3090.66382)},
    {Name="Sisyphus Statue",CFrame=CFrame.new(-3745.26025,-135.074417,-1008.6817)},
    {Name="Traveling Merchant",CFrame=CFrame.new(-133.942184,3.1812315,2767.25952)},
    {Name="Treasure Room",CFrame=CFrame.new(-3597.20093,-280.117279,-1633.28735)},
    {Name="Tropical Grove",CFrame=CFrame.new(-2128.62183,53.487011,3637.66479)},
    {Name="Weather Machine",CFrame=CFrame.new(-1527.67334,2.87499976,1914.66492)},
}

-- =====================================================
-- UTILS
-- =====================================================
local function clear()
    for _,v in ipairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
end

-- =====================================================
-- PLAYER LIST
-- =====================================================
local function showPlayers()
    clear()

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1,0,0,26)
            b.Text = plr.Name
            b.Font = Enum.Font.Gotham
            b.TextSize = 12
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundTransparency = 0.65
            Instance.new("UICorner", b)

            b.MouseButton1Click:Connect(function()
                local hrp1 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local hrp2 = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp1 and hrp2 then
                    hrp1.CFrame = hrp2.CFrame * CFrame.new(0,0,-3)
                end
            end)
        end
    end
end

-- =====================================================
-- SPOT LIST
-- =====================================================
local function showSpots()
    clear()

    for _,spot in ipairs(Locations) do
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(1,0,0,26)
        b.Text = spot.Name
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.TextColor3 = Color3.new(1,1,1)
        b.BackgroundTransparency = 0.65
        Instance.new("UICorner", b)

        b.MouseButton1Click:Connect(function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spot.CFrame + Vector3.new(0,5,0)
            end
        end)
    end
end

-- =====================================================
-- TAB LOGIC
-- =====================================================
btnPlayer.MouseButton1Click:Connect(function()
    btnPlayer.BackgroundTransparency = 0.3
    btnSpot.BackgroundTransparency = 0.6
    btnPlayer.Font = Enum.Font.GothamBold
    btnSpot.Font = Enum.Font.Gotham
    showPlayers()
end)

btnSpot.MouseButton1Click:Connect(function()
    btnSpot.BackgroundTransparency = 0.3
    btnPlayer.BackgroundTransparency = 0.6
    btnSpot.Font = Enum.Font.GothamBold
    btnPlayer.Font = Enum.Font.Gotham
    showSpots()
end)

-- DEFAULT
showPlayers()

print("✅ BAGIAN 5 (TP MENU) LOADED")
