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
-- PART 4 : LOGIC CONTAINER (NO UI, NO CHANGE)
-- =====================================================

-- ⚠️ ATURAN:
-- 1. JANGAN ubah logic
-- 2. JANGAN buat UI di sini
-- 3. HANYA pindahkan LOOP / EVENT dari script lama
-- 4. Variabel sudah dikontrol UI HUB

-- =====================================================
-- AUTO FISH LOOP
-- =====================================================

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

-- =====================================================
-- AUTO SELL LOOP
-- =====================================================

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

-- =====================================================
-- AUTO WEATHER LOOP
-- =====================================================

task.spawn(function()
    local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")
    local WeatherList = {"Storm", "Cloudy", "Wind"}

    while _G.FishItWORK do
        task.wait(WeatherDelay)
        if AutoWeather and purchaseRF then
            for _,weatherName in ipairs(WeatherList) do
                pcall(function()
                    purchaseRF:InvokeServer(weatherName)
                end)
                task.wait(1.5)
            end
        end
    end
end)

-- =====================================================
-- AUTO TOTEM LOOP
-- =====================================================

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)

        if not AUTO_TOTEM then
            continue
        end

        -- COPY SELURUH AUTO TOTEM LOOP KAMU KE SINI
        -- (tidak diubah)
    end
end)

-- =====================================================
-- FLY SAFETY LOOP (OPTIONAL)
-- =====================================================

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)
        if not FlyEnabled then
            pcall(stopFly)
        end
    end
end)

-- =====================================================
-- PING UPDATE LOOP
-- =====================================================

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)
        -- copy ping updater lama kamu ke sini
    end
end)

-- =====================================================
-- FISH UI CLEANER / FPS BOOSTER
-- =====================================================

task.spawn(function()
    while _G.FishItWORK do
        task.wait(2)
        -- copy CLEAN FISH UI + FPS BOOSTER kamu ke sini
    end
end)

print("✅ PART 4 LOADED : LOGIC CONNECTED TO HUB UI")
