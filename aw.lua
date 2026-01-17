-- =====================================================
-- PART 0 : INIT & LOGIC BASE
-- =====================================================

if _G.FishItWORK then return end
_G.FishItWORK = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Net
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")

-- VARIABLE (JANGAN PAKAI local)
AutoFish = false
AutoSell = false
AutoWeather = false
AUTO_TOTEM = false
FlyEnabled = false
FlySpeed = 150
SellInterval = 5
WeatherDelay = 5
FishDelay = 0.13

-- Anti AFK
local VirtualUser = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Fishing Controller Loader
FishingController = nil
task.spawn(function()
    repeat task.wait(0.25)
        local ok, ctrl = pcall(function()
            return require(ReplicatedStorage.Controllers.FishingController)
        end)
        if ok then FishingController = ctrl end
    until FishingController
end)

-- =====================================================
-- FLY SYSTEM (USED BY UI HUB)
-- =====================================================

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

        bv.Velocity = move.Magnitude > 0 and move.Unit * FlySpeed or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end

-- =====================================================
-- PART 1 : UI HUB CORE (SIDEBAR + PAGE SYSTEM)
-- =====================================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Cleanup old UI
pcall(function()
    LP.PlayerGui:FindFirstChild("FishItUI_HUB"):Destroy()
end)

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "FishItUI_HUB"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

-- Main Window
local Main = Instance.new("Frame", gui)
Main.Size = UDim2.new(0, 640, 0, 380)
Main.Position = UDim2.new(0.5, -320, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- =========================
-- HEADER
-- =========================

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
Header.BorderSizePixel = 0

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Fish It | DEV HUB"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- =========================
-- SIDEBAR
-- =========================

local Sidebar = Instance.new("Frame", Main)
Sidebar.Position = UDim2.new(0, 0, 0, 36)
Sidebar.Size = UDim2.new(0, 150, 1, -36)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 10)

-- =========================
-- CONTENT AREA
-- =========================

local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0, 150, 0, 36)
Content.Size = UDim2.new(1, -150, 1, -36)
Content.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
Content.BorderSizePixel = 0

-- =========================
-- TAB SYSTEM
-- =========================

local Tabs = {}
local CurrentTab = nil

local function CreateTab(tabName)
    -- Sidebar Button
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1, -16, 0, 32)
    Btn.Text = tabName
    Btn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.BorderSizePixel = 0

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    -- Page
    local Page = Instance.new("Frame", Content)
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.Visible = false
    Page.BackgroundTransparency = 1

    Tabs[tabName] = Page

    Btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Tabs) do
            v.Visible = false
        end
        Page.Visible = true
        CurrentTab = tabName
    end)

    return Page
end

-- =========================
-- CREATE DEFAULT TABS
-- =========================

local TabAutomation = CreateTab("Automation")
local TabTeleport   = CreateTab("Teleport")
local TabShop       = CreateTab("Shop")
local TabFly        = CreateTab("Fly")
local TabSettings   = CreateTab("Settings")

-- Default tab
TabAutomation.Visible = true
CurrentTab = "Automation"

print("✅ PART 1 LOADED : UI HUB CORE")


-- =====================================================
-- PART 2 : UI COMPONENTS (BUTTON / TOGGLE / SLIDER)
-- =====================================================

-- pastikan PART 1 sudah ada
assert(TabAutomation and TabFly and TabTeleport, "PART 1 belum diload!")

-- =========================
-- HELPER : SECTION
-- =========================

local function CreateSection(parent, titleText)
    local Section = Instance.new("Frame", parent)
    Section.Size = UDim2.new(1, 0, 0, 40)
    Section.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", Section)
    Title.Size = UDim2.new(1, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = Color3.fromRGB(180, 200, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13

    local Layout = Instance.new("UIListLayout", Section)
    Layout.Padding = UDim.new(0, 6)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    return Section
end

-- =========================
-- TOGGLE
-- =========================

local function CreateToggle(parent, text, default, callback)
    local Toggle = Instance.new("Frame", parent)
    Toggle.Size = UDim2.new(1, 0, 0, 36)
    Toggle.BackgroundColor3 = Color3.fromRGB(32, 35, 48)
    Toggle.BorderSizePixel = 0

    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Toggle)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12

    local Btn = Instance.new("TextButton", Toggle)
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.Position = UDim2.new(1, -50, 0.5, -10)
    Btn.Text = default and "ON" or "OFF"
    Btn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 120) or Color3.fromRGB(120, 50, 50)
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.BorderSizePixel = 0

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local State = default

    Btn.MouseButton1Click:Connect(function()
        State = not State
        Btn.Text = State and "ON" or "OFF"
        Btn.BackgroundColor3 = State and Color3.fromRGB(0,170,120) or Color3.fromRGB(120,50,50)
        if callback then
            callback(State) -- ← TEMPAT HUBUNGKAN LOGIC
        end
    end)

    return Toggle
end

-- =========================
-- BUTTON
-- =========================

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.Text = text
    Btn.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.BorderSizePixel = 0

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        if callback then
            callback() -- ← TEMPAT LOGIC
        end
    end)

    return Btn
end

-- =========================
-- SLIDER
-- =========================

local function CreateSlider(parent, text, min, max, default, callback)
    local Holder = Instance.new("Frame", parent)
    Holder.Size = UDim2.new(1, 0, 0, 44)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Holder)
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = text .. " : " .. default
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = Color3.fromRGB(220,220,220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12

    local Bar = Instance.new("Frame", Holder)
    Bar.Position = UDim2.new(0, 0, 0, 22)
    Bar.Size = UDim2.new(1, 0, 0, 10)
    Bar.BackgroundColor3 = Color3.fromRGB(60,60,80)
    Bar.BorderSizePixel = 0

    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0,170,200)
    Fill.BorderSizePixel = 0

    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local x = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * x)
            Fill.Size = UDim2.new(x, 0, 1, 0)
            Label.Text = text .. " : " .. value
            if callback then
                callback(value) -- ← TEMPAT LOGIC
            end
        end
    end)

    return Holder
end

print("✅ PART 2 LOADED : UI COMPONENTS")

-- =====================================================
-- PART 3 : TAB CONTAINER SYSTEM (ANTI ACAK)
-- =====================================================

local function CreateTabContainer(tab)
    local Holder = Instance.new("Frame", tab)
    Holder.Size = UDim2.new(1, 0, 1, 0)
    Holder.BackgroundTransparency = 1

    local Padding = Instance.new("UIPadding", Holder)
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)

    local Layout = Instance.new("UIListLayout", Holder)
    Layout.Padding = UDim.new(0, 10)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    return Holder
end

print("✅ PART 3 LOADED : TAB CONTAINER READY")



-- =====================================================
-- PART 3 : CONNECT UI COMPONENTS TO YOUR LOGIC
-- =====================================================

-- pastikan variabel logic kamu SUDAH ADA sebelum part ini:
-- AutoFish, AutoSell, AutoWeather, FlyEnabled, FlySpeed, SellInterval, WeatherDelay

assert(TabAutomation, "PART 1 belum terload!")

-- ======================================================
-- AUTOMATION TAB
-- ======================================================

local SecAuto = CreateSection(TabAutomation, "AUTO FARM")

CreateToggle(SecAuto, "Auto Fish", AutoFish, function(v)
    AutoFish = v
end)

CreateToggle(SecAuto, "Auto Sell", AutoSell, function(v)
    AutoSell = v
end)

CreateSlider(SecAuto, "Sell Interval (S)", 1, 30, SellInterval, function(v)
    SellInterval = v
end)

local SecWeather = CreateSection(TabAutomation, "WEATHER")

CreateToggle(SecWeather, "Auto Weather", AutoWeather, function(v)
    AutoWeather = v
end)

CreateSlider(SecWeather, "Delay Weather (S)", 1, 15, WeatherDelay, function(v)
    WeatherDelay = v
end)


-- ======================================================
-- SHOP TAB
-- ======================================================

local SecShop = CreateSection(TabShop, "TOTEM")

CreateToggle(SecShop, "Auto Totem", AUTO_TOTEM, function(v)
    AUTO_TOTEM = v
end)

local SecMerchant = CreateSection(TabShop, "MERCHANT")

CreateButton(SecMerchant, "Open Merchant", function()
    local merchantGui = LP.PlayerGui:FindFirstChild("Merchant")
    if merchantGui then
        merchantGui.Enabled = not merchantGui.Enabled
    end
end)


-- ======================================================
-- FLY TAB
-- ======================================================

local SecFly = CreateSection(TabFly, "FLY MODE")

CreateToggle(SecFly, "Fly Enabled", FlyEnabled, function(v)
    FlyEnabled = v
    if FlyEnabled then
        startFly()
    else
        stopFly()
    end
end)

CreateSlider(SecFly, "Fly Speed", 50, 800, FlySpeed, function(v)
    FlySpeed = v
end)


-- ======================================================
-- TELEPORT TAB
-- ======================================================

local SecTPPlayer = CreateSection(TabTeleport, "Teleport to Player")

-- Scroll list will be generated (same logic as old UI)
local PlayerList = Instance.new("ScrollingFrame", TabTeleport)
PlayerList.Position = UDim2.new(0, 0, 0, 60)
PlayerList.Size = UDim2.new(1, -10, 1, -70)
PlayerList.BackgroundTransparency = 1
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", PlayerList)
layout.Padding = UDim.new(0, 4)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function RefreshPlayers()
    for _,c in ipairs(PlayerList:GetChildren()) do
        if c:IsA("TextButton") then
            c:Destroy()
        end
    end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local B = CreateButton(PlayerList, plr.Name, function()
                local hrp1 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local hrp2 = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp1 and hrp2 then
                    hrp1.CFrame = hrp2.CFrame + Vector3.new(0,2,-3)
                end
            end)
            B.Size = UDim2.new(1, -10, 0, 28)
        end
    end
end

RefreshPlayers()


-- ======================================================
-- OTHER / SETTINGS (optional slot)
-- ======================================================

local SecOther = CreateSection(TabSettings, "OTHER")

CreateButton(SecOther, "Refresh Player List", function()
    RefreshPlayers()
end)

CreateButton(SecOther, "Close UI", function()
    gui:Destroy()
    _G.FishItWORK = false
end)

print("✅ PART 3 LOADED : UI MAPPING COMPLETE")

-- =====================================================
-- PART 4 : AUTOMATION TAB (CLEAN)
-- =====================================================

local AutoHolder = CreateTabContainer(TabAutomation)

CreateSection(AutoHolder, "AUTO FARM")

CreateToggle(AutoHolder, "Auto Fish", AutoFish, function(v)
    AutoFish = v
end)

CreateToggle(AutoHolder, "Auto Sell", AutoSell, function(v)
    AutoSell = v
end)

CreateSlider(AutoHolder, "Sell Interval (S)", 1, 30, SellInterval, function(v)
    SellInterval = v
end)

CreateSection(AutoHolder, "WEATHER")

CreateToggle(AutoHolder, "Auto Weather", AutoWeather, function(v)
    AutoWeather = v
end)

CreateSlider(AutoHolder, "Delay Weather (S)", 1, 15, WeatherDelay, function(v)
    WeatherDelay = v
end)

print("✅ PART 4 LOADED : AUTOMATION CLEAN")


-- =====================================================
-- PART 4 : LOGIC LOOPS (FINAL)
-- =====================================================

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
                FishingController:FishingMinigameClick()
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
                task.wait(1.5)
            end
        end
    end
end)

-- AUTO TOTEM
task.spawn(function()
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
        if inv then
            for _,item in ipairs(inv) do
                return item.UUID
            end
        end
    end

    local function EquipRod()
        EquipToolFromHotbar:FireServer(1)
    end

    TotemSpawned.OnClientEvent:Connect(function()
        COOLDOWN = 3600
        task.delay(0.2, EquipRod)
    end)

    while _G.FishItWORK do
        task.wait(1)

        if not AUTO_TOTEM then
            continue
        end

        if COOLDOWN > 0 then
            COOLDOWN -= 1
            continue
        end

        if retryWait then
            if os.clock() >= retryWait then
                retryWait = false
            else
                continue
            end
        end

        local uuid = GetTotemUUID()
        if uuid then
            local success = false
            local conn
            conn = TotemSpawned.OnClientEvent:Connect(function()
                success = true
                conn:Disconnect()
            end)

            SpawnTotem:FireServer(uuid)
            task.wait(0.5)
            if conn then conn:Disconnect() end

            if not success then
                retryWait = os.clock() + TRY_INTERVAL
            end
        end
    end
end)

-- FLY SAFETY
task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)
        if not FlyEnabled then
            pcall(stopFly)
        end
    end
end)

-- CLEAN FISH UI (FPS BOOST)
task.spawn(function()
    local pg = LP:WaitForChild("PlayerGui")
    while _G.FishItWORK do
        task.wait(2)
        local fishGui = pg:FindFirstChild("FishingUI")
        if not fishGui then continue end

        for _,v in ipairs(fishGui:GetDescendants()) do
            if v:IsA("TextLabel") and v.TextSize >= 26 then
                v.Visible = false
            end
        end
    end
end)

print("✅ PART 4 LOADED : ALL LOGIC RUNNING")

-- =====================================================
-- PART 5 : TELEPORT TAB (CLEAN)
-- =====================================================

local TPHolder = CreateTabContainer(TabTeleport)

CreateSection(TPHolder, "TELEPORT TO PLAYER")

local PlayerList = Instance.new("ScrollingFrame", TPHolder)
PlayerList.Size = UDim2.new(1, 0, 0, 200)
PlayerList.ScrollBarThickness = 4
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
PlayerList.BackgroundTransparency = 1

local plLayout = Instance.new("UIListLayout", PlayerList)
plLayout.Padding = UDim.new(0, 6)

local function RefreshPlayers()
    for _,v in ipairs(PlayerList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local btn = CreateButton(PlayerList, plr.Name, function()
                local hrp1 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local hrp2 = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp1 and hrp2 then
                    hrp1.CFrame = hrp2.CFrame * CFrame.new(0,0,-3)
                end
            end)
            btn.Size = UDim2.new(1, 0, 0, 28)
        end
    end
end

RefreshPlayers()

CreateSection(TPHolder, "TELEPORT TO SPOT")

local SpotList = Instance.new("ScrollingFrame", TPHolder)
SpotList.Size = UDim2.new(1, 0, 0, 260)
SpotList.ScrollBarThickness = 4
SpotList.AutomaticCanvasSize = Enum.AutomaticSize.Y
SpotList.BackgroundTransparency = 1

local spotLayout = Instance.new("UIListLayout", SpotList)
spotLayout.Padding = UDim.new(0, 6)

for _,spot in ipairs(Locations) do
    local btn = CreateButton(SpotList, spot.Name, function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = spot.CFrame + Vector3.new(0,5,0)
        end
    end)
    btn.Size = UDim2.new(1, 0, 0, 28)
end

print("✅ PART 5 LOADED : TELEPORT CLEAN")


-- =====================================================
-- PART 5 : ADD-ON SYSTEM (OPTIONAL EXTRAS)
-- =====================================================

task.wait(0.5)

local pg = LP:WaitForChild("PlayerGui")
local hubGui = pg:FindFirstChild("FishItUI_HUB")
if not hubGui then return end

-- ===================================================================
-- 1️⃣ FLOATING TOGGLE BUTTON (SHOW / HIDE UI HUB)
-- ===================================================================

local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "FishItFloatingToggle"
floatBtn.Parent = hubGui
floatBtn.Size = UDim2.new(0, 48, 0, 48)
floatBtn.Position = UDim2.new(0.03, 0, 0.4, 0)
floatBtn.Image = "rbxassetid://72407089659970"
floatBtn.BackgroundTransparency = 0
floatBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
floatBtn.BorderSizePixel = 0
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.AutoButtonColor = false

local corner = Instance.new("UICorner", floatBtn)
corner.CornerRadius = UDim.new(0, 12)

local panelVisible = true

floatBtn.MouseButton1Click:Connect(function()
    panelVisible = not panelVisible
    Main.Visible = panelVisible
end)

-- ===================================================================
-- 2️⃣ AUTO SCALE FIX (LOW-END & MOBILE)
-- ===================================================================

task.wait(0.5)

local screenScale = hubGui:FindFirstChildOfClass("UIScale")
if not screenScale then
    screenScale = Instance.new("UIScale", hubGui)
end

local function applyScale()
    if not UIS.TouchEnabled then
        screenScale.Scale = 1
        return
    end

    local w = workspace.CurrentCamera.ViewportSize.X
    if w <= 360 then screenScale.Scale = 0.45
    elseif w <= 400 then screenScale.Scale = 0.5
    elseif w <= 440 then screenScale.Scale = 0.55
    elseif w <= 480 then screenScale.Scale = 0.6
    elseif w <= 600 then screenScale.Scale = 0.7
    else screenScale.Scale = 0.8
    end
end

applyScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)

-- ===================================================================
-- 3️⃣ CYBERPUNK THEME (TANPA LAG)
-- ===================================================================

local THEME = {
    PANEL = Color3.fromRGB(20, 24, 30),
    BUTTON = Color3.fromRGB(28, 32, 40),
    BUTTON_H = Color3.fromRGB(0, 140, 180),
    TEXT = Color3.fromRGB(220, 235, 255),
    BORDER = Color3.fromRGB(0, 180, 220)
}

local function style(obj)
    if obj:IsA("Frame") then
        obj.BackgroundColor3 = THEME.PANEL

    elseif obj:IsA("TextButton") then
        obj.BackgroundColor3 = THEME.BUTTON
        obj.TextColor3 = THEME.TEXT

        obj.MouseEnter:Connect(function()
            obj.BackgroundColor3 = THEME.BUTTON_H
        end)
        obj.MouseLeave:Connect(function()
            obj.BackgroundColor3 = THEME.BUTTON
        end)

    elseif obj:IsA("TextLabel") then
        obj.TextColor3 = THEME.TEXT
    end

    if (obj:IsA("Frame") or obj:IsA("TextButton")) and not obj:FindFirstChild("UICorner") then
        Instance.new("UICorner", obj).CornerRadius = UDim.new(0, 6)
    end

    if (obj:IsA("Frame") or obj:IsA("TextButton")) then
        local s = obj:FindFirstChild("UIStroke")
        if not s then s = Instance.new("UIStroke", obj) end
        s.Color = THEME.BORDER
        s.Thickness = 1
        s.Transparency = 0.6
    end
end

for _,v in ipairs(hubGui:GetDescendants()) do
    style(v)
end

print("✅ PART 5 LOADED : ADD-ON FEATURES ACTIVE")

-- =====================================================
-- PART 6 : SHOP TAB (CLEAN)
-- =====================================================

local ShopHolder = CreateTabContainer(TabShop)

CreateSection(ShopHolder, "TOTEM")

CreateToggle(ShopHolder, "Auto Totem", AUTO_TOTEM, function(v)
    AUTO_TOTEM = v
end)

CreateSection(ShopHolder, "MERCHANT")

CreateButton(ShopHolder, "Open Merchant", function()
    local mg = LP.PlayerGui:FindFirstChild("Merchant")
    if mg then mg.Enabled = not mg.Enabled end
end)

print("✅ PART 6 LOADED : SHOP CLEAN")



-- =====================================================
-- PART 6 : ADVANCED FEATURES (TELEPORT + PING + SAFETY)
-- =====================================================

-- =====================================================
-- 1️⃣ TELEPORT SPOT LIST (TAB TELEPORT)
-- =====================================================

local Locations = {
    { Name = "Ancient Jungle", CFrame = CFrame.new(1562.54028, 6.62499952, -233.164978) },
    { Name = "Ancient Ruin", CFrame = CFrame.new(6076.29297, -585.924255, 4625.92578) },
    { Name = "Captain Jones ( Quest )", CFrame = CFrame.new(
        3312.1604, 9.09943581, 3681.58276,
        -0.620493293, 3.23666143e-08, 0.784211755,
        1.96114573e-08, 1, -2.57555914e-08,
        -0.784211755, -6.01637129e-10, -0.620493293
    ) },
    { Name = "Coral Reefs", CFrame = CFrame.new(-2752.8064, 4.00034237, 2165.78516) },
    { Name = "Crater Island", CFrame = CFrame.new(1027.12122, 2.89895344, 5148.10498) },
    { Name = "Deadman Compas ( Quest )", CFrame = CFrame.new(
        -3437.02661, -22.3605175, -1500.29492,
        0.949759126, -0.000316226506, -0.312981725,
        -0.00030944933, 0.999998033, -0.0019494053,
        0.312981725, 0.0019483174, 0.949757159
    ) },
    { Name = "Esoteric Depths", CFrame = CFrame.new(3249.08862, -1301.52979, 1373.68054) },
    { Name = "Fisherman Island", CFrame = CFrame.new(73.3565826, 9.53157043, 2709.50098) },
    { Name = "Kohana", CFrame = CFrame.new(-595.69751, 19.2500706, 429.863037) },
    { Name = "Kohana Volcano", CFrame = CFrame.new(-559.593994, 21.2289829, 153.752396) },
    { Name = "Kuil Suci", CFrame = CFrame.new(1471.79675, -22.1250019, -607.50592) },
    { Name = "Pirate Cove", CFrame = CFrame.new(
        3398.70093, 10.3427305, 3491.1123,
        0.350104898, -5.98848899e-08, -0.936710477,
        4.57310989e-08, 1, -4.68386041e-08,
        0.936710477, -2.64383768e-08, 0.350104898
    ) },
    { Name = "Pirate Treasure Room", CFrame = CFrame.new(
        3340.80273, -301.512665, 3090.66382,
        0.851593554, -5.62464919e-08, 0.524202645,
        4.72129109e-08, 1, 3.05993844e-08,
        -0.524202645, -1.30910449e-09, 0.851593554
    ) },
    { Name = "Sisyphus Statue", CFrame = CFrame.new(-3745.26025, -135.074417, -1008.6817) },
    { Name = "Traveling Merchant", CFrame = CFrame.new(
        -133.942184, 3.1812315, 2767.25952,
        0.9507429, 1.0076019e-07, -0.309980601,
        -8.28868707e-08, 1, 7.08305095e-08,
        0.309980601, -4.16482813e-08, 0.9507429
    ) },
    { Name = "Treasure Room", CFrame = CFrame.new(-3597.20093, -280.117279, -1633.28735) },
    { Name = "Tropical Grove", CFrame = CFrame.new(-2128.62183, 53.487011, 3637.66479) },
    { Name = "Weather Machine", CFrame = CFrame.new(-1527.67334, 2.87499976, 1914.66492) }
}

local SecSpot = CreateSection(TabTeleport, "Teleport to Spot")

local SpotList = Instance.new("ScrollingFrame", TabTeleport)
SpotList.Position = UDim2.new(0, 0, 0, 200)
SpotList.Size = UDim2.new(1, -10, 1, -210)
SpotList.BackgroundTransparency = 1
SpotList.ScrollBarThickness = 4
SpotList.AutomaticCanvasSize = Enum.AutomaticSize.Y

local spotLayout = Instance.new("UIListLayout", SpotList)
spotLayout.Padding = UDim.new(0, 4)

for _,spot in ipairs(Locations) do
    local b = CreateButton(SpotList, spot.Name, function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = spot.CFrame + Vector3.new(0, 5, 0)
        end
    end)
    b.Size = UDim2.new(1, -10, 0, 28)
end

-- =====================================================
-- 2️⃣ REAL PING MONITOR (LIGHTWEIGHT)
-- =====================================================

local Stats = game:GetService("Stats")

local PingLabel = Instance.new("TextLabel", Header)
PingLabel.Size = UDim2.new(0, 80, 1, 0)
PingLabel.Position = UDim2.new(1, -90, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextSize = 12
PingLabel.Text = "Ping: --"
PingLabel.TextColor3 = Color3.fromRGB(200,200,200)

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)

        local net = Stats:FindFirstChild("Network")
        local server = net and net:FindFirstChild("ServerStatsItem")
        local pingStat = server and server:FindFirstChild("Data Ping")

        if pingStat then
            local ping = pingStat:GetValue()
            PingLabel.Text = string.format("Ping: %.0f", ping)

            if ping <= 80 then
                PingLabel.TextColor3 = Color3.fromRGB(0,255,120)
            elseif ping <= 150 then
                PingLabel.TextColor3 = Color3.fromRGB(255,200,0)
            else
                PingLabel.TextColor3 = Color3.fromRGB(255,80,80)
            end
        end
    end
end)

-- =====================================================
-- 3️⃣ SAFE CLOSE HANDLER (GLOBAL)
-- =====================================================

local closing = false

local function SafeClose()
    if closing then return end
    closing = true

    AutoFish = false
    AutoSell = false
    AutoWeather = false
    AUTO_TOTEM = false
    FlyEnabled = false

    pcall(stopFly)

    task.wait(0.2)

    pcall(function()
        if gui then gui:Destroy() end
    end)

    _G.FishItWORK = false
    warn("❌ FishIt HUB closed safely")
end

-- Close via Settings Tab
CreateButton(TabSettings, "❌ FORCE CLOSE SCRIPT", SafeClose)

-- Auto close if UI destroyed manually
gui.Destroying:Connect(function()
    SafeClose()
end)

print("✅ PART 6 LOADED : TELEPORT + PING + SAFETY")

-- =====================================================
-- PART 7 : FLY TAB (CLEAN)
-- =====================================================

local FlyHolder = CreateTabContainer(TabFly)

CreateSection(FlyHolder, "FLY MODE")

CreateToggle(FlyHolder, "Fly Enabled", FlyEnabled, function(v)
    FlyEnabled = v
    if v then startFly() else stopFly() end
end)

CreateSlider(FlyHolder, "Fly Speed", 50, 800, FlySpeed, function(v)
    FlySpeed = v
end)

print("✅ PART 7 LOADED : FLY CLEAN")


-- =====================================================
-- PART 7 : STABILITY, RESPAWN & FAIL-SAFE SYSTEM
-- =====================================================

-- =====================================================
-- 1️⃣ SAFE CHARACTER RESPAWN HANDLER
-- =====================================================

local function OnCharacterAdded(char)
    task.spawn(function()
        char:WaitForChild("HumanoidRootPart", 5)

        -- stop fly supaya tidak bug
        pcall(stopFly)

        -- re-apply fly kalau toggle masih ON
        if FlyEnabled then
            task.wait(0.3)
            pcall(startFly)
        end
    end)
end

if LP.Character then
    OnCharacterAdded(LP.Character)
end

LP.CharacterAdded:Connect(OnCharacterAdded)

-- =====================================================
-- 2️⃣ AUTO REFRESH PLAYER LIST (TELEPORT TAB)
-- =====================================================

task.spawn(function()
    while _G.FishItWORK do
        task.wait(5)

        -- Refresh kalau UI masih ada
        if typeof(RefreshPlayers) == "function" then
            pcall(RefreshPlayers)
        end
    end
end)

Players.PlayerAdded:Connect(function()
    if typeof(RefreshPlayers) == "function" then
        task.wait(1)
        pcall(RefreshPlayers)
    end
end)

Players.PlayerRemoving:Connect(function()
    if typeof(RefreshPlayers) == "function" then
        task.wait(1)
        pcall(RefreshPlayers)
    end
end)

-- =====================================================
-- 3️⃣ GLOBAL FAIL-SAFE (PLAYER LEAVING / KICKED)
-- =====================================================

LP.AncestryChanged:Connect(function(_, parent)
    if not parent then
        _G.FishItWORK = false
        warn("⚠️ Player left game, stopping FishIt HUB")
    end
end)

-- =====================================================
-- 4️⃣ NET / REMOTE FAIL PROTECTION
-- =====================================================

task.spawn(function()
    while _G.FishItWORK do
        task.wait(10)

        -- Net check
        if not ReplicatedStorage:FindFirstChild("Packages") then
            warn("⚠️ Packages folder missing, stopping script")
            _G.FishItWORK = false
            break
        end

        -- FishingController check
        if AutoFish and not FishingController then
            warn("⚠️ FishingController lost, reloading...")
            pcall(function()
                FishingController = require(ReplicatedStorage.Controllers.FishingController)
            end)
        end
    end
end)

-- =====================================================
-- 5️⃣ LOOP LEAK PROTECTION (ANTI DOUBLE RUN)
-- =====================================================

task.spawn(function()
    local lastState = _G.FishItWORK
    while true do
        task.wait(3)

        if lastState and not _G.FishItWORK then
            warn("🛑 FishIt HUB stopped, all loops should end")
            break
        end

        lastState = _G.FishItWORK
    end
end)

print("✅ PART 7 LOADED : STABILITY & FAIL-SAFE ACTIVE")


-- =====================================================
-- PART 8 : SETTINGS TAB (CLEAN)
-- =====================================================

local SetHolder = CreateTabContainer(TabSettings)

CreateSection(SetHolder, "SYSTEM")

CreateButton(SetHolder, "Close UI", function()
    if gui then gui:Destroy() end
    _G.FishItWORK = false
end)

CreateButton(SetHolder, "Save Config", saveConfig)
CreateButton(SetHolder, "Load Config", loadConfig)

print("✅ PART 8 LOADED : SETTINGS CLEAN")


-- =====================================================
-- PART 8 : CONFIG SAVE & AUTO LOAD
-- =====================================================

-- ===============================
-- CONFIG FILE PATH
-- ===============================

local CONFIG_FOLDER = "FishItHub"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"

-- ===============================
-- FILE HELPERS (SAFE)
-- ===============================

local function canFS()
    return writefile and readfile and isfile and makefolder
end

if canFS() and not isfolder(CONFIG_FOLDER) then
    makefolder(CONFIG_FOLDER)
end

-- ===============================
-- GET CURRENT CONFIG
-- ===============================

local function getConfig()
    return {
        AutoFish = AutoFish,
        AutoSell = AutoSell,
        AutoWeather = AutoWeather,
        AUTO_TOTEM = AUTO_TOTEM,
        FlyEnabled = FlyEnabled,
        FlySpeed = FlySpeed,
        SellInterval = SellInterval,
        WeatherDelay = WeatherDelay,
    }
end

-- ===============================
-- APPLY CONFIG
-- ===============================

local function applyConfig(cfg)
    if typeof(cfg) ~= "table" then return end

    AutoFish = cfg.AutoFish or false
    AutoSell = cfg.AutoSell or false
    AutoWeather = cfg.AutoWeather or false
    AUTO_TOTEM = cfg.AUTO_TOTEM or false

    FlyEnabled = cfg.FlyEnabled or false
    FlySpeed = tonumber(cfg.FlySpeed) or FlySpeed

    SellInterval = tonumber(cfg.SellInterval) or SellInterval
    WeatherDelay = tonumber(cfg.WeatherDelay) or WeatherDelay

    -- apply fly state safely
    task.delay(0.3, function()
        if FlyEnabled then
            pcall(startFly)
        else
            pcall(stopFly)
        end
    end)
end

-- ===============================
-- SAVE CONFIG
-- ===============================

local function saveConfig()
    if not canFS() then return end

    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONEncode(getConfig())
    end)

    if ok then
        writefile(CONFIG_FILE, data)
    end
end

-- ===============================
-- LOAD CONFIG
-- ===============================

local function loadConfig()
    if not canFS() then return end
    if not isfile(CONFIG_FILE) then return end

    local ok, cfg = pcall(function()
        local raw = readfile(CONFIG_FILE)
        return game:GetService("HttpService"):JSONDecode(raw)
    end)

    if ok and cfg then
        applyConfig(cfg)
        warn("✅ FishIt HUB config loaded")
    end
end

-- ===============================
-- AUTO LOAD (ON START)
-- ===============================

task.spawn(function()
    task.wait(1)
    loadConfig()
end)

-- ===============================
-- AUTO SAVE LOOP
-- ===============================

task.spawn(function()
    local last = ""

    while _G.FishItWORK do
        task.wait(3)

        local ok, now = pcall(function()
            return game:GetService("HttpService"):JSONEncode(getConfig())
        end)

        if ok and now ~= last then
            last = now
            saveConfig()
        end
    end
end)

-- ===============================
-- MANUAL SAVE BUTTON (SETTINGS TAB)
-- ===============================

pcall(function()
    CreateButton(TabSettings, "💾 Save Config", function()
        saveConfig()
        warn("💾 Config saved")
    end)

    CreateButton(TabSettings, "📂 Load Config", function()
        loadConfig()
        warn("📂 Config loaded")
    end)
end)

print("✅ PART 8 LOADED : CONFIG SAVE & AUTO LOAD")

-- =====================================================
-- PART 8 : CONFIG SAVE & AUTO LOAD
-- =====================================================

-- ===============================
-- CONFIG FILE PATH
-- ===============================

local CONFIG_FOLDER = "FishItHub"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"

-- ===============================
-- FILE HELPERS (SAFE)
-- ===============================

local function canFS()
    return writefile and readfile and isfile and makefolder
end

if canFS() and not isfolder(CONFIG_FOLDER) then
    makefolder(CONFIG_FOLDER)
end

-- ===============================
-- GET CURRENT CONFIG
-- ===============================

local function getConfig()
    return {
        AutoFish = AutoFish,
        AutoSell = AutoSell,
        AutoWeather = AutoWeather,
        AUTO_TOTEM = AUTO_TOTEM,
        FlyEnabled = FlyEnabled,
        FlySpeed = FlySpeed,
        SellInterval = SellInterval,
        WeatherDelay = WeatherDelay,
    }
end

-- ===============================
-- APPLY CONFIG
-- ===============================

local function applyConfig(cfg)
    if typeof(cfg) ~= "table" then return end

    AutoFish = cfg.AutoFish or false
    AutoSell = cfg.AutoSell or false
    AutoWeather = cfg.AutoWeather or false
    AUTO_TOTEM = cfg.AUTO_TOTEM or false

    FlyEnabled = cfg.FlyEnabled or false
    FlySpeed = tonumber(cfg.FlySpeed) or FlySpeed

    SellInterval = tonumber(cfg.SellInterval) or SellInterval
    WeatherDelay = tonumber(cfg.WeatherDelay) or WeatherDelay

    -- apply fly state safely
    task.delay(0.3, function()
        if FlyEnabled then
            pcall(startFly)
        else
            pcall(stopFly)
        end
    end)
end

-- ===============================
-- SAVE CONFIG
-- ===============================

local function saveConfig()
    if not canFS() then return end

    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONEncode(getConfig())
    end)

    if ok then
        writefile(CONFIG_FILE, data)
    end
end

-- ===============================
-- LOAD CONFIG
-- ===============================

local function loadConfig()
    if not canFS() then return end
    if not isfile(CONFIG_FILE) then return end

    local ok, cfg = pcall(function()
        local raw = readfile(CONFIG_FILE)
        return game:GetService("HttpService"):JSONDecode(raw)
    end)

    if ok and cfg then
        applyConfig(cfg)
        warn("✅ FishIt HUB config loaded")
    end
end

-- ===============================
-- AUTO LOAD (ON START)
-- ===============================

task.spawn(function()
    task.wait(1)
    loadConfig()
end)

-- ===============================
-- AUTO SAVE LOOP
-- ===============================

task.spawn(function()
    local last = ""

    while _G.FishItWORK do
        task.wait(3)

        local ok, now = pcall(function()
            return game:GetService("HttpService"):JSONEncode(getConfig())
        end)

        if ok and now ~= last then
            last = now
            saveConfig()
        end
    end
end)

-- ===============================
-- MANUAL SAVE BUTTON (SETTINGS TAB)
-- ===============================

pcall(function()
    CreateButton(TabSettings, "💾 Save Config", function()
        saveConfig()
        warn("💾 Config saved")
    end)

    CreateButton(TabSettings, "📂 Load Config", function()
        loadConfig()
        warn("📂 Config loaded")
    end)
end)

print("✅ PART 8 LOADED : CONFIG SAVE & AUTO LOAD")


-- =====================================================
-- PART 10 : KEYBIND & QUICK CONTROL SYSTEM
-- =====================================================

local UIS = game:GetService("UserInputService")

-- prevent double bind
local _keyBound = false
if _keyBound then return end
_keyBound = true

-- ===============================
-- HELPER
-- ===============================

local function toggle(varName)
    _G[varName] = not _G[varName]
    warn(varName .. " => " .. tostring(_G[varName]))
end

local function safeToggleFly()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        pcall(startFly)
    else
        pcall(stopFly)
    end
    warn("FlyEnabled => ", FlyEnabled)
end

-- ===============================
-- INPUT LISTENER
-- ===============================

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- IGNORE CHAT
    if UIS:GetFocusedTextBox() then return end

    local key = input.KeyCode

    -- FLY
    if key == Enum.KeyCode.F then
        safeToggleFly()

    -- AUTO FISH
    elseif key == Enum.KeyCode.G then
        AutoFish = not AutoFish
        warn("AutoFish => ", AutoFish)

    -- AUTO SELL
    elseif key == Enum.KeyCode.H then
        AutoSell = not AutoSell
        warn("AutoSell => ", AutoSell)

    -- AUTO WEATHER
    elseif key == Enum.KeyCode.J then
        AutoWeather = not AutoWeather
        warn("AutoWeather => ", AutoWeather)

    -- AUTO TOTEM
    elseif key == Enum.KeyCode.K then
        AUTO_TOTEM = not AUTO_TOTEM
        warn("AUTO_TOTEM => ", AUTO_TOTEM)

    -- TOGGLE UI
    elseif key == Enum.KeyCode.RightShift then
        if gui and Main then
            Main.Visible = not Main.Visible
        end

    -- EMERGENCY STOP
    elseif key == Enum.KeyCode.Delete then
        warn("🛑 EMERGENCY STOP ACTIVATED")

        AutoFish = false
        AutoSell = false
        AutoWeather = false
        AUTO_TOTEM = false
        FlyEnabled = false

        pcall(stopFly)

        _G.FishItWORK = false

        pcall(function()
            if gui then gui:Destroy() end
        end)
    end
end)

print("✅ PART 10 LOADED : KEYBIND SYSTEM ACTIVE")
-- =====================================================
-- PART 11 : AUTO RECONNECT + SMART REJOIN SYSTEM
-- =====================================================

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local PLACE_ID = game.PlaceId
local AUTO_REJOIN_ENABLED = true
local PING_REJOIN_ENABLED = true
local MAX_PING = 650       -- ping limit rejoin
local PING_HOLD = 20       -- detik ping jelek sebelum rejoin

local pingHighSince = nil

-- =====================================================
-- FUNGSI AMAN JOIN ULANG
-- =====================================================

local function safeReconnect()
    if not AUTO_REJOIN_ENABLED then return end
    warn("🔄 Reconnecting to same server...")

    task.wait(1)

    local success = false
    repeat
        success = pcall(function()
            TeleportService:Teleport(PLACE_ID, LP)
        end)
        task.wait(2)
    until success

    warn("✅ Teleport succeeded (retry loop exit)")
end

-- =====================================================
-- SMART LOW PING SERVER (API)
-- =====================================================

local function getLowPingServer()
    local cursor = ""
    local servers = {}

    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(
            PLACE_ID,
            cursor
        )

        local data = HttpService:JSONDecode(game:HttpGet(url))
        for _, srv in ipairs(data.data) do
            if srv.ping and srv.playing < srv.maxPlayers then
                table.insert(servers, srv.id)
            end
        end

        cursor = data.nextPageCursor
    until not cursor

    if #servers == 0 then return nil end
    return servers[math.random(1, #servers)]
end

local function smartRejoin()
    if not PING_REJOIN_ENABLED then return end
    warn("📡 Smart Rejoin → searching low ping server...")

    local target = getLowPingServer()

    if target then
        warn("Connecting to better server: " .. target)
        TeleportService:TeleportToPlaceInstance(PLACE_ID, target, LP)
    else
        warn("⚠️ No better server found, fallback reconnect")
        safeReconnect()
    end
end

-- =====================================================
-- PING MONITOR
-- =====================================================

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)

        if not getRealPing then continue end
        
        local ping = getRealPing()
        if not ping then continue end

        if ping > MAX_PING then
            if not pingHighSince then
                pingHighSince = tick()
            elseif tick() - pingHighSince >= PING_HOLD then
                warn("🚨 High Ping for too long → Rejoin triggered")
                smartRejoin()
                break
            end
        else
            pingHighSince = nil
        end
    end
end)

-- =====================================================
-- AUTO REJOIN ON DISCONNECT (ERROR 277 etc)
-- =====================================================

TeleportService.TeleportInitFailed:Connect(function(player, err)
    warn("⚠️ Teleport failed:", err)
    task.wait(2)
    safeReconnect()
end)

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        warn("⚠️ Teleport failed → retrying")
        safeReconnect()
    end
end)

-- =====================================================
-- BLOCK POPUP KICK
-- =====================================================

task.spawn(function()
    while _G.FishItWORK do
        task.wait(0.5)

        local pg = LP:FindFirstChild("PlayerGui")
        if not pg then continue end
        
        for _,v in ipairs(pg:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name:lower():find("kick") then
                warn("🛑 Kick popup blocked!")
                v:Destroy()
                safeReconnect()
                return
            end
        end
    end
end)

print("✅ PART 11 LOADED : AUTO RECONNECT + SMART SERVER SYSTEM READY")
