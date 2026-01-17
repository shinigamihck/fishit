--========================================================--
-- PART A : INIT & LOGIC BASE
--========================================================--

if _G.FishItWORK then return end
_G.FishItWORK = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Net Package
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")

-- GLOBAL LOGIC VARIABLE
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

-- Load Fishing Controller
FishingController = nil
task.spawn(function()
    repeat task.wait(0.2)
        local ok, mod = pcall(function()
            return require(ReplicatedStorage.Controllers.FishingController)
        end)
        if ok then FishingController = mod end
    until FishingController
end)

--========================================================--
-- FLY SYSTEM
--========================================================--

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
        local mv = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then mv += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv -= Vector3.new(0,1,0) end

        bv.Velocity = (mv.Magnitude > 0) and mv.Unit * FlySpeed or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end

--========================================================--
-- PART B : UI CORE + TAB SYSTEM
--========================================================--

-- Destroy old UI
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
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Fish It | CLEAN HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(235, 235, 245)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Position = UDim2.new(0, 0, 0, 36)
Sidebar.Size = UDim2.new(0, 150, 1, -36)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Sidebar.BorderSizePixel = 0

local sbLayout = Instance.new("UIListLayout", Sidebar)
sbLayout.Padding = UDim.new(0, 6)
sbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local sbPad = Instance.new("UIPadding", Sidebar)
sbPad.PaddingTop = UDim.new(0, 10)

-- Content Area
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0, 150, 0, 36)
Content.Size = UDim2.new(1, -150, 1, -36)
Content.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Content.BorderSizePixel = 0

-- Tab System
local Tabs = {}
local CurrentTab = nil

local function CreateTab(name)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1, -16, 0, 32)
    Btn.Text = name
    Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    Btn.TextColor3 = Color3.fromRGB(220, 220, 225)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("Frame", Content)
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.Visible = false

    Tabs[name] = Page

    Btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Tabs) do
            v.Visible = false
        end
        Page.Visible = true
        CurrentTab = name
    end)

    return Page
end

-- Create all tabs
local TabAutomation = CreateTab("Automation")
local TabTeleport   = CreateTab("Teleport")
local TabShop       = CreateTab("Shop")
local TabFly        = CreateTab("Fly")
local TabSettings   = CreateTab("Settings")

TabAutomation.Visible = true
CurrentTab = "Automation"

print("✅ PART 1 LOADED : CORE + UI READY")


--========================================================--
-- PART C : UI HELPERS (SECTION / BUTTON / TOGGLE / SLIDER)
--========================================================--

local function CreateSection(parent, titleText)
    local Sec = Instance.new("Frame", parent)
    Sec.Size = UDim2.new(1, 0, 0, 24)
    Sec.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Sec)
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = titleText
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(210,210,215)

    return Sec
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 52, 62)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(230,230,235)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Btn
end

local function CreateToggle(parent, text, default, callback)
    local Hold = Instance.new("Frame", parent)
    Hold.Size = UDim2.new(1, 0, 0, 34)
    Hold.BackgroundColor3 = Color3.fromRGB(50, 52, 62)
    Hold.BorderSizePixel = 0
    Instance.new("UICorner", Hold).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Hold)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0,10,0,0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(230,230,235)
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Btn = Instance.new("TextButton", Hold)
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.Position = UDim2.new(1, -48, 0.5, -10)
    Btn.BackgroundColor3 = default and Color3.fromRGB(0,170,120) or Color3.fromRGB(130,50,50)
    Btn.Text = default and "ON" or "OFF"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextSize = 11
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local state = default

    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = state and "ON" or "OFF"
        Btn.BackgroundColor3 = state and Color3.fromRGB(0,170,120) or Color3.fromRGB(130,50,50)
        if callback then callback(state) end
    end)

    return Hold
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Hold = Instance.new("Frame", parent)
    Hold.Size = UDim2.new(1, 0, 0, 45)
    Hold.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Hold)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(230,230,235)
    Label.Text = text .. " : " .. default

    local Bar = Instance.new("Frame", Hold)
    Bar.Position = UDim2.new(0,0,0,25)
    Bar.Size = UDim2.new(1,0,0,10)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 62, 72)
    Bar.BorderSizePixel = 0
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(0,140,200)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        local x = (input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
        x = math.clamp(x,0,1)

        local value = math.floor(min + x*(max-min))

        Fill.Size = UDim2.new(x,0,1,0)
        Label.Text = text .. " : " .. value

        if callback then callback(value) end
    end)

    return Hold
end

--========================================================--
-- PART D : TAB CONTAINER (ANTI ACAK)
--========================================================--

local function CreateTabContainer(tab)
    local Holder = Instance.new("Frame", tab)
    Holder.Size = UDim2.new(1, 0, 1, 0)
    Holder.BackgroundTransparency = 1

    local Padding = Instance.new("UIPadding", Holder)
    Padding.PaddingTop = UDim.new(0, 8)
    Padding.PaddingLeft = UDim.new(0, 8)
    Padding.PaddingRight = UDim.new(0, 8)

    local Layout = Instance.new("UIListLayout", Holder)
    Layout.Padding = UDim.new(0, 10)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    return Holder
end

--========================================================--
-- BUILD ALL TABS
--========================================================--


--========================--
-- 1. AUTOMATION TAB
--========================--

local AutoTab = CreateTabContainer(TabAutomation)

CreateSection(AutoTab, "AUTO FARM")

CreateToggle(AutoTab, "Auto Fish", AutoFish, function(v)
    AutoFish = v
end)

CreateToggle(AutoTab, "Auto Sell", AutoSell, function(v)
    AutoSell = v
end)

CreateSlider(AutoTab, "Sell Interval (s)", 1, 30, SellInterval, function(v)
    SellInterval = v
end)

CreateSection(AutoTab, "WEATHER")

CreateToggle(AutoTab, "Auto Weather", AutoWeather, function(v)
    AutoWeather = v
end)

CreateSlider(AutoTab, "Weather Delay (s)", 1, 20, WeatherDelay, function(v)
    WeatherDelay = v
end)



--========================--
-- 2. TELEPORT TAB
--========================--

local TP = CreateTabContainer(TabTeleport)

CreateSection(TP, "TELEPORT TO PLAYER")

local PlayerList = Instance.new("ScrollingFrame", TP)
PlayerList.Size = UDim2.new(1,0,0,150)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.ScrollBarThickness = 4
PlayerList.BackgroundTransparency = 1

local plLayout = Instance.new("UIListLayout", PlayerList)
plLayout.Padding = UDim.new(0,6)

local function RefreshPlayers()
    for _,v in ipairs(PlayerList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local b = CreateButton(PlayerList, p.Name, function()
                local hrp1 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local hrp2 = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if hrp1 and hrp2 then
                    hrp1.CFrame = hrp2.CFrame + Vector3.new(0,2,-2)
                end
            end)
            b.Size = UDim2.new(1,0,0,28)
        end
    end
end

RefreshPlayers()

CreateSection(TP, "TELEPORT TO SPOT")

local Locations = {
    {Name="Kohana", CFrame=CFrame.new(-595,19,429)},
    {Name="Fisherman Island", CFrame=CFrame.new(73,9,2709)},
    {Name="Coral Reefs", CFrame=CFrame.new(-2752,4,2165)},
    {Name="Weather Machine", CFrame=CFrame.new(-1527,2,1914)},
    {Name="Tropical Grove", CFrame=CFrame.new(-2128,53,3637)},
}

local SpotList = Instance.new("ScrollingFrame", TP)
SpotList.Size = UDim2.new(1,0,0,180)
SpotList.AutomaticCanvasSize = Enum.AutomaticSize.Y
SpotList.ScrollBarThickness = 4
SpotList.BackgroundTransparency = 1

local spLayout = Instance.new("UIListLayout", SpotList)
spLayout.Padding = UDim.new(0,6)

for _,spot in ipairs(Locations) do
    local b = CreateButton(SpotList, spot.Name, function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = spot.CFrame + Vector3.new(0,4,0)
        end
    end)
    b.Size = UDim2.new(1,0,0,28)
end



--========================--
-- 3. SHOP TAB
--========================--

local ShopTab = CreateTabContainer(TabShop)

CreateSection(ShopTab, "TOTEM")

CreateToggle(ShopTab, "Auto Totem", AUTO_TOTEM, function(v)
    AUTO_TOTEM = v
end)

CreateSection(ShopTab, "MERCHANT")

CreateButton(ShopTab, "Open Merchant", function()
    local g = LP.PlayerGui:FindFirstChild("Merchant")
    if g then g.Enabled = not g.Enabled end
end)



--========================--
-- 4. FLY TAB
--========================--

local FlyTab = CreateTabContainer(TabFly)

CreateSection(FlyTab, "FLY MODE")

CreateToggle(FlyTab, "Fly Enabled", FlyEnabled, function(v)
    FlyEnabled = v
    if v then startFly() else stopFly() end
end)

CreateSlider(FlyTab, "Fly Speed", 50, 800, FlySpeed, function(v)
    FlySpeed = v
end)



--========================--
-- 5. SETTINGS TAB
--========================--

local SetTab = CreateTabContainer(TabSettings)

CreateSection(SetTab, "SYSTEM")

CreateButton(SetTab, "Refresh Player List", function()
    RefreshPlayers()
end)

CreateButton(SetTab, "Close UI", function()
    gui:Destroy()
    _G.FishItWORK = false
end)



--========================================================--
-- PART 3 : LOGIC LOOPS (AUTOFARM / WEATHER / TOTEM / FLY)
--========================================================--

--========================--
-- AUTO FISH
--========================--
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


--========================--
-- AUTO SELL
--========================--
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


--========================--
-- AUTO WEATHER
--========================--
task.spawn(function()
    local purchase = Net:RemoteFunction("PurchaseWeatherEvent")
    local WeatherList = {"Storm", "Cloudy", "Wind"}

    while _G.FishItWORK do
        task.wait(WeatherDelay)

        if AutoWeather then
            for _,w in ipairs(WeatherList) do
                pcall(function()
                    purchase:InvokeServer(w)
                end)
                task.wait(1.4)
            end
        end
    end
end)


--========================--
-- AUTO TOTEM SYSTEM
--========================--

task.spawn(function()
    local Replion = require(ReplicatedStorage.Packages.Replion)
    local Data = Replion.Client:WaitReplion("Data")

    local SpawnTotem = Net:RemoteEvent("SpawnTotem")
    local TotemSpawned = Net:RemoteEvent("TotemSpawned")
    local EquipTool = Net:RemoteEvent("EquipToolFromHotbar")

    local COOLDOWN = 0
    local retryWait = false
    local TRY_INTERVAL = 300

    local function GetTotemUUID()
        local inv = Data:Get({"Inventory","Totems"})
        if inv then
            for _,itm in ipairs(inv) do
                return itm.UUID
            end
        end
    end

    -- If totem successfully spawned
    TotemSpawned.OnClientEvent:Connect(function()
        COOLDOWN = 3600
        task.delay(0.15, function()
            EquipTool:FireServer(1)
        end)
    end)

    while _G.FishItWORK do
        task.wait(1)

        if not AUTO_TOTEM then continue end
        if COOLDOWN > 0 then COOLDOWN -= 1 continue end

        if retryWait then
            if os.clock() >= retryWait then
                retryWait = false
            else
                continue
            end
        end

        local uuid = GetTotemUUID()
        if uuid then
            local ok = false
            local conn

            conn = TotemSpawned.OnClientEvent:Connect(function()
                ok = true
                conn:Disconnect()
            end)

            SpawnTotem:FireServer(uuid)
            task.wait(0.4)

            if conn then conn:Disconnect() end
            if not ok then
                retryWait = os.clock() + TRY_INTERVAL
            end
        end
    end
end)



--========================--
-- FLY SAFETY LOOP
--========================--
task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)
        if not FlyEnabled then
            pcall(stopFly)
        end
    end
end)


--========================--
-- CLEAN FISH UI / FPS BOOST
--========================--
task.spawn(function()
    local pg = LP:WaitForChild("PlayerGui")

    while _G.FishItWORK do
        task.wait(2)

        local fishgui = pg:FindFirstChild("FishingUI")
        if fishgui then
            for _,v in ipairs(fishgui:GetDescendants()) do
                if v:IsA("TextLabel") and v.TextSize >= 26 then
                    v.Visible = false
                end
            end
        end
    end
end)



--========================================================--
-- PART 3B : KEYBIND SYSTEM
--========================================================--

local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if UIS:GetFocusedTextBox() then return end

    local key = input.KeyCode

    if key == Enum.KeyCode.F then
        FlyEnabled = not FlyEnabled
        if FlyEnabled then startFly() else stopFly() end

    elseif key == Enum.KeyCode.G then
        AutoFish = not AutoFish

    elseif key == Enum.KeyCode.H then
        AutoSell = not AutoSell

    elseif key == Enum.KeyCode.J then
        AutoWeather = not AutoWeather

    elseif key == Enum.KeyCode.K then
        AUTO_TOTEM = not AUTO_TOTEM

    elseif key == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible

    elseif key == Enum.KeyCode.Delete then
        warn("🛑 EMERGENCY STOP")
        AutoFish = false
        AutoSell = false
        AutoWeather = false
        AUTO_TOTEM = false
        FlyEnabled = false
        _G.FishItWORK = false
        pcall(stopFly)
        pcall(function() if gui then gui:Destroy() end end)
    end
end)

print("KEYBIND ACTIVE ✔️")



--========================================================--
-- PART 3C : STABILITY & FAILSAFE
--========================================================--

-- CHARACTER RESPAWN SAFE FLY
local function OnChar(char)
    task.spawn(function()
        char:WaitForChild("HumanoidRootPart",5)
        pcall(stopFly)
        task.wait(0.25)
        if FlyEnabled then pcall(startFly) end
    end)
end

if LP.Character then OnChar(LP.Character) end
LP.CharacterAdded:Connect(OnChar)


-- AUTO REFRESH PLAYER LIST
task.spawn(function()
    while _G.FishItWORK do
        task.wait(4)
        pcall(RefreshPlayers)
    end
end)


-- FAILSAFE if player leaving
LP.AncestryChanged:Connect(function(_, parent)
    if not parent then
        _G.FishItWORK = false
    end
end)


-- CONTROLLER RECOVERY
task.spawn(function()
    while _G.FishItWORK do
        task.wait(10)

        if AutoFish and not FishingController then
            pcall(function()
                FishingController = require(ReplicatedStorage.Controllers.FishingController)
            end)
        end
    end
end)


print("STABILITY SYSTEM ✔️")



--========================================================--
-- PART 3D : AUTO RECONNECT
--========================================================--

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local PLACE_ID = game.PlaceId
local MAX_PING = 650
local PING_HOLD = 20
local pingHighSince = nil


-- GET REAL PING
local Stats = game:GetService("Stats")
local function getPing()
    local net = Stats:FindFirstChild("Network")
    local server = net and net:FindFirstChild("ServerStatsItem")
    local ping = server and server:FindFirstChild("Data Ping")
    if ping then
        return ping:GetValue()
    end
end


local function safeReconnect()
    warn("🔄 Reconnecting...")
    repeat
        task.wait(1)
    until pcall(function()
        TeleportService:Teleport(PLACE_ID, LP)
    end)
end


task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)

        local ping = getPing()
        if not ping then continue end

        if ping > MAX_PING then
            if not pingHighSince then
                pingHighSince = tick()
            elseif tick() - pingHighSince >= PING_HOLD then
                warn("🚨 High Ping → Reconnect")
                safeReconnect()
                break
            end
        else
            pingHighSince = nil
        end
    end
end)


TeleportService.TeleportInitFailed:Connect(function()
    warn("⚠️ Teleport failed → retry")
    safeReconnect()
end)


print("AUTO RECONNECT ACTIVE ✔️")

