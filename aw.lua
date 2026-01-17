--========================================================--
-- FLUENT UI COMPACT FRAMEWORK (PART 1)
--========================================================--

if _G.FishItWORK then return end
_G.FishItWORK = true

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Destroy Old UI
pcall(function()
    LP.PlayerGui:FindFirstChild("FishItFluentUI"):Destroy()
end)

-- Main ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "FishItFluentUI"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

-- Color Theme (Fluent Compact)
local THEME = {
    BG         = Color3.fromRGB(28, 30, 35),
    PANEL      = Color3.fromRGB(35, 37, 43),
    ACCENT     = Color3.fromRGB(76, 162, 255),
    ACCENT2    = Color3.fromRGB(120, 170, 255),
    TEXT       = Color3.fromRGB(235, 240, 255),
    BUTTON     = Color3.fromRGB(48, 50, 58),
    BUTTON_H   = Color3.fromRGB(60, 65, 75),
    BORDER     = Color3.fromRGB(90, 100, 120)
}

-- Create Main Window (Compact size)
local Main = Instance.new("Frame", gui)
Main.Size = UDim2.new(0, 450, 0, 330)   -- COMPACT SIZE
Main.Position = UDim2.new(0.5, -225, 0.5, -165)
Main.BackgroundColor3 = THEME.BG
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

-- Rounded Corner
local cr = Instance.new("UICorner", Main)
cr.CornerRadius = UDim.new(0, 10)

-- Border Stroke
local stroke = Instance.new("UIStroke", Main)
stroke.Color = THEME.BORDER
stroke.Thickness = 1
stroke.Transparency = 0.45

--============================================
-- HEADER BAR
--============================================
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = THEME.PANEL
Header.BorderSizePixel = 0

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = THEME.TEXT
Title.Text = "Fish It • Fluent UI"

-- Close Button
local Close = Instance.new("TextButton", Header)
Close.Size = UDim2.new(0, 34, 0, 28)
Close.Position = UDim2.new(1, -38, 0.5, -14)
Close.BackgroundColor3 = THEME.BUTTON
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255,120,120)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.BorderSizePixel = 0
local cc = Instance.new("UICorner", Close)
cc.CornerRadius = UDim.new(0, 6)

Close.MouseButton1Click:Connect(function()
    gui:Destroy()
    _G.FishItWORK = false
end)

--============================================
-- SIDEBAR
--============================================
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 110, 1, -34)
Sidebar.Position = UDim2.new(0, 0, 0, 34)
Sidebar.BackgroundColor3 = THEME.PANEL
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local sbLayout = Instance.new("UIListLayout", Sidebar)
sbLayout.Padding = UDim.new(0, 6)
sbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sbLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local sbPad = Instance.new("UIPadding", Sidebar)
sbPad.PaddingTop = UDim.new(0, 10)

--============================================
-- CONTENT AREA
--============================================
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -120, 1, -34)
Content.Position = UDim2.new(0, 115, 0, 34)
Content.BackgroundColor3 = THEME.BG
Content.BorderSizePixel = 0

local Tabs = {}
local CurrentTab = nil

-- Create Tab Button + Page
local function CreateTab(name)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1, -14, 0, 30)
    Btn.BackgroundColor3 = THEME.BUTTON
    Btn.Text = name
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.TextColor3 = THEME.TEXT
    Btn.BorderSizePixel = 0

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = THEME.BUTTON_H end)
    Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = THEME.BUTTON end)

    local Page = Instance.new("ScrollingFrame", Content)
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.BorderSizePixel = 0
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollBarThickness = 4

    local layout = Instance.new("UIListLayout", Page)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    Tabs[name] = Page

    Btn.MouseButton1Click:Connect(function()
        for _,pg in pairs(Tabs) do pg.Visible = false end
        Page.Visible = true
        CurrentTab = name
    end)

    return Page
end

-- TAB LIST (Compact)
local TabAutomation = CreateTab("Automation")
local TabTeleport   = CreateTab("Teleport")
local TabShop       = CreateTab("Shop")
local TabFly        = CreateTab("Fly")
local TabSettings   = CreateTab("Settings")

TabAutomation.Visible = true
CurrentTab = "Automation"

print("✔ PART 1 Loaded — Fluent UI Base Framework")


--========================================================--
-- PART 2 — FLUENT UI COMPONENTS + AUTOMATION TAB
--========================================================--

-- THEME VAR (ambil dari Part 1)
local THEME = {
    BG         = Color3.fromRGB(28, 30, 35),
    PANEL      = Color3.fromRGB(35, 37, 43),
    ACCENT     = Color3.fromRGB(76, 162, 255),
    ACCENT2    = Color3.fromRGB(120, 170, 255),
    TEXT       = Color3.fromRGB(235, 240, 255),
    BUTTON     = Color3.fromRGB(48, 50, 58),
    BUTTON_H   = Color3.fromRGB(60, 65, 75),
    BORDER     = Color3.fromRGB(90, 100, 120)
}

--========================================================--
-- COMPONENT: SECTION TITLE
--========================================================--
local function CreateSection(parent, text)
    local S = Instance.new("TextLabel", parent)
    S.Size = UDim2.new(1, -10, 0, 24)
    S.Text = text
    S.TextXAlignment = Enum.TextXAlignment.Left
    S.Font = Enum.Font.GothamBold
    S.TextSize = 13
    S.TextColor3 = THEME.ACCENT
    S.BackgroundTransparency = 1
    return S
end

--========================================================--
-- COMPONENT: BUTTON
--========================================================--
local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -20, 0, 32)
    Btn.Text = text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.BackgroundColor3 = THEME.BUTTON
    Btn.TextColor3 = THEME.TEXT
    Btn.BorderSizePixel = 0

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseEnter:Connect(function()
        Btn.BackgroundColor3 = THEME.BUTTON_H
    end)
    Btn.MouseLeave:Connect(function()
        Btn.BackgroundColor3 = THEME.BUTTON
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Btn
end

--========================================================--
-- COMPONENT: TOGGLE
--========================================================--
local function CreateToggle(parent, text, default, callback)
    local Hold = Instance.new("Frame", parent)
    Hold.Size = UDim2.new(1, -20, 0, 35)
    Hold.BackgroundColor3 = THEME.BUTTON
    Hold.BorderSizePixel = 0

    Instance.new("UICorner", Hold).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Hold)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = THEME.TEXT
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Btn = Instance.new("TextButton", Hold)
    Btn.Size = UDim2.new(0, 45, 0, 22)
    Btn.Position = UDim2.new(1, -50, 0.5, -11)
    Btn.BackgroundColor3 = default and THEME.ACCENT or Color3.fromRGB(120, 60, 60)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local state = default

    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = state and "ON" or "OFF"
        Btn.BackgroundColor3 = state and THEME.ACCENT or Color3.fromRGB(120,60,60)
        if callback then callback(state) end
    end)

    return Hold
end

--========================================================--
-- COMPONENT: SLIDER
--========================================================--
local function CreateSlider(parent, text, min, max, default, callback)
    local Holder = Instance.new("Frame", parent)
    Holder.Size = UDim2.new(1, -20, 0, 45)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Holder)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = THEME.TEXT
    Label.Text = text .. " : " .. default

    local Bar = Instance.new("Frame", Holder)
    Bar.Position = UDim2.new(0, 0, 0, 22)
    Bar.Size = UDim2.new(1, 0, 0, 10)
    Bar.BackgroundColor3 = THEME.BUTTON
    Bar.BorderSizePixel = 0
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = THEME.ACCENT
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        local x = (input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
        x = math.clamp(x, 0, 1)

        local value = math.floor(min + x * (max - min))

        Fill.Size = UDim2.new(x, 0, 1, 0)
        Label.Text = text .. " : " .. value

        if callback then callback(value) end
    end)

    return Holder
end

--========================================================--
-- AUTOMATION TAB CONTENT
--========================================================--

-- STATE (logic)
AutoFish = AutoFish or false
AutoSell = AutoSell or false
AutoWeather = AutoWeather or false

SellInterval = SellInterval or 5
WeatherDelay = WeatherDelay or 5

-- Build UI
CreateSection(TabAutomation, "AUTO FARM")

CreateToggle(TabAutomation, "Auto Fish", AutoFish, function(v)
    AutoFish = v
end)

CreateToggle(TabAutomation, "Auto Sell", AutoSell, function(v)
    AutoSell = v
end)

CreateSlider(TabAutomation, "Sell Interval (s)", 1, 30, SellInterval, function(v)
    SellInterval = v
end)

CreateSection(TabAutomation, "WEATHER")

CreateToggle(TabAutomation, "Auto Weather", AutoWeather, function(v)
    AutoWeather = v
end)

CreateSlider(TabAutomation, "Weather Delay (s)", 1, 20, WeatherDelay, function(v)
    WeatherDelay = v
end)

print("✔ PART 2 Loaded — Fluent UI Components + Automation Live")


--========================================================--
-- PART 3 — FLUENT TELEPORT TAB (PLAYER + SPOT)
--========================================================--

local THEME = {
    BG         = Color3.fromRGB(28, 30, 35),
    PANEL      = Color3.fromRGB(35, 37, 43),
    ACCENT     = Color3.fromRGB(76, 162, 255),
    ACCENT2    = Color3.fromRGB(120, 170, 255),
    TEXT       = Color3.fromRGB(235, 240, 255),
    BUTTON     = Color3.fromRGB(48, 50, 58),
    BUTTON_H   = Color3.fromRGB(60, 65, 75),
    BORDER     = Color3.fromRGB(90, 100, 120)
}

local LP = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")

---------------------------------------------------------------------
-- TELEPORT TAB CONTAINER
---------------------------------------------------------------------
local TP = CreateTabContainer(TabTeleport)

---------------------------------------------------------------------
-- SECTION TITLE
---------------------------------------------------------------------
CreateSection(TP, "TELEPORT MENU")

---------------------------------------------------------------------
-- TOP BUTTONS (PLAYER / SPOT)
---------------------------------------------------------------------
local topBar = Instance.new("Frame", TP)
topBar.Size = UDim2.new(1, -10, 0, 34)
topBar.BackgroundTransparency = 1

local layoutH = Instance.new("UIListLayout", topBar)
layoutH.FillDirection = Enum.FillDirection.Horizontal
layoutH.Padding = UDim.new(0, 6)

local function newTabBtn(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -4, 1, 0)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BackgroundColor3 = THEME.BUTTON
    b.TextColor3 = THEME.TEXT
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local btnPlayer = newTabBtn("Players")
local btnSpot   = newTabBtn("Spots")

btnPlayer.Parent = topBar
btnSpot.Parent = topBar

---------------------------------------------------------------------
-- CONTENT SCROLL AREA
---------------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame", TP)
scroll.Size = UDim2.new(1, -12, 1, -60)
scroll.Position = UDim2.new(0, 6, 0, 50)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 6)

---------------------------------------------------------------------
-- CREATE FLUENT LIST BUTTON
---------------------------------------------------------------------
local function CreateTPButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -4, 0, 32)
    Btn.Text = text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.TextColor3 = THEME.TEXT
    Btn.BackgroundColor3 = THEME.BUTTON
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseEnter:Connect(function()
        Btn.BackgroundColor3 = THEME.BUTTON_H
    end)
    Btn.MouseLeave:Connect(function()
        Btn.BackgroundColor3 = THEME.BUTTON
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Btn
end

---------------------------------------------------------------------
-- CLEAR LIST
---------------------------------------------------------------------
local function ClearScroll()
    for _,v in ipairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
end

---------------------------------------------------------------------
-- TELEPORT PLAYER LIST
---------------------------------------------------------------------
local function LoadPlayerList()
    ClearScroll()

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local Btn = CreateTPButton(plr.Name, function()
                local me = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local them = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if me and them then
                    me.CFrame = them.CFrame + Vector3.new(0, 3, -3)
                end
            end)
            Btn.Parent = scroll
        end
    end
end

---------------------------------------------------------------------
-- TELEPORT SPOT LIST
---------------------------------------------------------------------
local Locations = {
    {Name="Kohana", CFrame=CFrame.new(-595,19,429)},
    {Name="Fisherman Island", CFrame=CFrame.new(73,9,2709)},
    {Name="Coral Reefs", CFrame=CFrame.new(-2752,4,2165)},
    {Name="Weather Machine", CFrame=CFrame.new(-1527,2,1914)},
    {Name="Tropical Grove", CFrame=CFrame.new(-2128,53,3637)},
}

local function LoadSpotList()
    ClearScroll()

    for _,spot in ipairs(Locations) do
        local Btn = CreateTPButton(spot.Name, function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spot.CFrame + Vector3.new(0, 4, 0)
            end
        end)
        Btn.Parent = scroll
    end
end

---------------------------------------------------------------------
-- TAB TOGGLE LOGIC
---------------------------------------------------------------------
local currentTab = "Players"

local function SetTab(name)
    currentTab = name

    if name == "Players" then
        btnPlayer.BackgroundColor3 = THEME.ACCENT
        btnPlayer.TextColor3 = Color3.new(1,1,1)

        btnSpot.BackgroundColor3 = THEME.BUTTON
        btnSpot.TextColor3 = THEME.TEXT

        LoadPlayerList()

    else
        btnSpot.BackgroundColor3 = THEME.ACCENT
        btnSpot.TextColor3 = Color3.new(1,1,1)

        btnPlayer.BackgroundColor3 = THEME.BUTTON
        btnPlayer.TextColor3 = THEME.TEXT

        LoadSpotList()
    end
end

btnPlayer.MouseButton1Click:Connect(function()
    SetTab("Players")
end)

btnSpot.MouseButton1Click:Connect(function()
    SetTab("Spots")
end)

---------------------------------------------------------------------
-- AUTO REFRESH PLAYER LIST
---------------------------------------------------------------------
task.spawn(function()
    while _G.FishItWORK do
        task.wait(4)
        if currentTab == "Players" then
            LoadPlayerList()
        end
    end
end)

---------------------------------------------------------------------
-- INIT DEFAULT
---------------------------------------------------------------------
SetTab("Players")

print("✔ PART 3 Loaded — Fluent Teleport System Active")
--========================================================--
-- PART 4 — FLUENT SHOP TAB (AUTO TOTEM + MERCHANT + REJOIN)
--========================================================--

local LP = game:GetService("Players").LocalPlayer
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local THEME = {
    BG         = Color3.fromRGB(28, 30, 35),
    PANEL      = Color3.fromRGB(35, 37, 43),
    ACCENT     = Color3.fromRGB(76, 162, 255),
    TEXT       = Color3.fromRGB(235, 240, 255),
    BUTTON     = Color3.fromRGB(48, 50, 58),
    BUTTON_H   = Color3.fromRGB(60, 65, 75),
}

---------------------------------------------------------------------
-- SHOP TAB CONTAINER
---------------------------------------------------------------------
local ShopTab = CreateTabContainer(TabShop)

CreateSection(ShopTab, "SHOP & SYSTEM")

---------------------------------------------------------------------
-- AUTO TOTEM CORE DATA
---------------------------------------------------------------------
local AUTO_TOTEM = false
local COOLDOWN = 0
local retryWait = false
local TRY_INTERVAL = 300

local Net = require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)

local Data = Replion.Client:WaitReplion("Data")
local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipToolHB = Net:RemoteEvent("EquipToolFromHotbar")

---------------------------------------------------------------------
-- GET UUID
---------------------------------------------------------------------
local function GetTotemUUID()
    local inv = Data:Get({"Inventory","Totems"})
    if inv then
        for _,item in ipairs(inv) do
            return item.UUID
        end
    end
end

---------------------------------------------------------------------
-- GUI TEXT FEEDBACK
---------------------------------------------------------------------
local Status = Instance.new("TextLabel", ShopTab)
Status.Size = UDim2.new(1, -10, 0, 24)
Status.Text = "Totem: Idle"
Status.TextColor3 = THEME.TEXT
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.BackgroundTransparency = 1

---------------------------------------------------------------------
-- AUTO TOTEM TOGGLE (FLUENT)
---------------------------------------------------------------------
CreateToggle(ShopTab, "Auto Totem", false, function(v)
    AUTO_TOTEM = v
    Status.Text = v and "Totem: Activated" or "Totem: Idle"
end)

---------------------------------------------------------------------
-- MERCHANT BUTTON
---------------------------------------------------------------------
CreateButton(ShopTab, "Open Merchant", function()
    local m = LP.PlayerGui:FindFirstChild("Merchant")
    if m then
        m.Enabled = not m.Enabled
    end
end)

---------------------------------------------------------------------
-- REJOIN BUTTON (FLUENT STYLE)
---------------------------------------------------------------------
CreateButton(ShopTab, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LP)
end)

---------------------------------------------------------------------
-- EVENT: TOTEM SUCCESS
---------------------------------------------------------------------
TotemSpawned.OnClientEvent:Connect(function()
    COOLDOWN = 3600
    Status.Text = "Totem active (Cooldown: 3600s)"
    task.delay(0.2, function()
        EquipToolHB:FireServer(1)
    end)
end)

---------------------------------------------------------------------
-- AUTO EQUIP LOOP
---------------------------------------------------------------------
task.spawn(function()
    while _G.FishItWORK do
        task.wait(2.5)
        if AUTO_TOTEM then
            pcall(function()
                EquipToolHB:FireServer(1)
            end)
        end
    end
end)

---------------------------------------------------------------------
-- AUTO TOTEM LOOP
---------------------------------------------------------------------
task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)

        if not AUTO_TOTEM then
            Status.Text = "Totem: Idle"
            continue
        end

        -- COOLDOWN berjalan
        if COOLDOWN > 0 then
            Status.Text = "Cooldown: " .. COOLDOWN .. "s"
            COOLDOWN -= 1
            continue
        end

        -- retry block
        if retryWait then
            local left = math.floor(retryWait - os.clock())
            Status.Text = "Retry in: "..left.."s"

            if os.clock() >= retryWait then
                retryWait = false
            else
                continue
            end
        end

        -- pasang totem
        local uuid = GetTotemUUID()
        if uuid then
            Status.Text = "Placing Totem..."

            local success = false
            local conn
            conn = TotemSpawned.OnClientEvent:Connect(function()
                success = true
                conn:Disconnect()
            end)

            SpawnTotem:FireServer(uuid)
            task.wait(0.4)

            if conn then conn:Disconnect() end

            if success then
                Status.Text = "Totem Placed!"
            else
                Status.Text = "Failed! Retry 5 min"
                retryWait = os.clock() + TRY_INTERVAL
            end

        else
            Status.Text = "No Totem Found"
        end
    end
end)

print("✔ PART 4 Loaded — Shop Tab + Auto Totem + Rejoin Button Active")

--========================================================--
-- PART 5 — FLUENT FLY TAB
--========================================================--

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

---------------------------------------------------------------------
-- FLY TAB CONTAINER
---------------------------------------------------------------------
local FlyTab = CreateTabContainer(TabFly)

CreateSection(FlyTab, "FLY CONTROLS")

---------------------------------------------------------------------
-- STATE (pakai variable global logic kamu)
---------------------------------------------------------------------
FlyEnabled = FlyEnabled or false
FlySpeed   = FlySpeed or 150

---------------------------------------------------------------------
-- FLY TOGGLE
---------------------------------------------------------------------
CreateToggle(FlyTab, "Fly Enabled", FlyEnabled, function(v)
    FlyEnabled = v
    if v then
        pcall(startFly)
    else
        pcall(stopFly)
    end
end)

---------------------------------------------------------------------
-- FLY SPEED SLIDER
---------------------------------------------------------------------
CreateSlider(FlyTab, "Fly Speed", 50, 800, FlySpeed, function(v)
    FlySpeed = v
end)

---------------------------------------------------------------------
-- INFO TEXT
---------------------------------------------------------------------
local info = Instance.new("TextLabel", FlyTab)
info.Size = UDim2.new(1, -10, 0, 22)
info.BackgroundTransparency = 1
info.TextXAlignment = Enum.TextXAlignment.Left
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.TextColor3 = Color3.fromRGB(200, 210, 230)
info.Text = "WASD + Space / Ctrl to move"

---------------------------------------------------------------------
-- SAFETY: STOP FLY ON CHARACTER RESET
---------------------------------------------------------------------
LP.CharacterAdded:Connect(function(char)
    task.wait(0.25)
    pcall(stopFly)
    if FlyEnabled then
        task.wait(0.2)
        pcall(startFly)
    end
end)

print("✔ PART 5 Loaded — Fluent Fly Tab Active")
