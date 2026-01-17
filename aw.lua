-- =========================================================
--  FISH IT | CORE SYSTEM (NO UI) — CLEAN & MODULAR
-- =========================================================

if _G.FishItWORK then return end
_G.FishItWORK = true

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- NETWORK
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")
local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")

-- STATE VARIABLES
local AutoFish = false
local AutoSell = false
local AutoWeather = false
local AUTO_TOTEM = false
local WeatherDelay = 5
local SellInterval = 30

-- ANTI AFK
local VirtualUser = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)



-- PING READER
local function getRealPing()
    local network = Stats:FindFirstChild("Network")
    if not network then return 0 end

    local serverStats = network:FindFirstChild("ServerStatsItem")
    if not serverStats then return 0 end

    local pingStat = serverStats:FindFirstChild("Data Ping")
    if not pingStat then return 0 end

    local v = pingStat:GetValue()
    return typeof(v) == "number" and v or 0
end

-- FISHING CONTROLLER
local FishingController
task.spawn(function()
    repeat
        task.wait(0.25)
        local ok, ctrl = pcall(function()
            return require(ReplicatedStorage.Controllers.FishingController)
        end)
        if ok then FishingController = ctrl end
    until FishingController
end)

-- AUTO FISH LOOP
local FishDelay = 0.13

task.spawn(function()
    while _G.FishItWORK do
        task.wait(FishDelay)
        if AutoFish and FishingController then
            local guid = FishingController:GetCurrentGUID()
            if not guid then
                pcall(function()
                    FishingController:RequestChargeFishingRod(
                        Camera.ViewportSize / 2,
                        true
                    )
                end)
            else
                FishingController:FishingMinigameClick()
            end
        end
    end
end)

-- AUTO SELL LOOP
task.spawn(function()
    while _G.FishItWORK do
        if AutoSell then
            pcall(function()
                sellRF:InvokeServer()
            end)
        end
        task.wait(SellInterval)
    end
end)

-- AUTO WEATHER LOOP
local WeatherList = {"Storm", "Cloudy", "Wind"}

task.spawn(function()
    while _G.FishItWORK do
        if AutoWeather then
            for _,w in ipairs(WeatherList) do
                pcall(function()
                    purchaseRF:InvokeServer(w)
                end)
                task.wait(1.5)
            end
        end
        task.wait(WeatherDelay)
    end
end)

-- AUTO TOTEM / MERCHANT
local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")
local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipToolFromHotbar = Net:RemoteEvent("EquipToolFromHotbar")

local COOLDOWN = 0
local RUNNING_TOTEM = true
local TRY_INTERVAL = 300
local retryWait = false

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

task.spawn(function()
    while _G.FishItWORK do
        if AUTO_TOTEM then
            pcall(EquipRod)
        end
        task.wait(2.5)
    end
end)

task.spawn(function()
    while RUNNING_TOTEM and _G.FishItWORK do
        task.wait(1)

        if not AUTO_TOTEM then continue end

        if COOLDOWN > 0 then
            COOLDOWN -= 1
            continue
        end

        if retryWait and os.clock() < retryWait then
            continue
        else
            retryWait = false
        end

        local uuid = GetTotemUUID()
        if not uuid then
            continue
        end

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
end)

-- TELEPORT SPOTS
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

-- EXPORTED FOR UI
_G.FishCore = {
    AutoFish = function(v) AutoFish = v end,
    AutoSell = function(v) AutoSell = v end,
    AutoWeather = function(v) AutoWeather = v end,
    AutoTotem = function(v) AUTO_TOTEM = v end,
    GetPing = getRealPing,
    Spots = Locations,
}


-- =========================================================
--  FISH IT | UI TOP BAR (MODERN CLEAN)
--  Connects To: CoreSystem.lua
-- =========================================================

local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

-- Load Core System
local Core = _G.FishCore

-- =========================================================
-- CLEAN OLD UI
-- =========================================================
pcall(function()
    local old = pg:FindFirstChild("FishItUI")
    if old then old:Destroy() end
end)

-- =========================================================
-- CREATE MAIN GUI
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FishItUI"
gui.ResetOnSpawn = false
gui.Parent = pg

-- =====================================
-- GLOBAL UI SCALE CONTROLLER (FINAL)
-- =====================================

local Camera = workspace.CurrentCamera

local uiScale = gui:FindFirstChild("UIScale")
if not uiScale then
    uiScale = Instance.new("UIScale")
    uiScale.Parent = gui
end

-- MODE:
-- "AUTO"  = otomatis (mobile / pc)
-- "SMALL" = kecil
-- "NORMAL"
-- "BIG"
local UI_MODE = "AUTO"

local function applyGlobalScale()
    local scale = 1

    if UI_MODE == "SMALL" then
        scale = 0.65

    elseif UI_MODE == "NORMAL" then
        scale = 0.8

    elseif UI_MODE == "BIG" then
        scale = 1

    elseif UI_MODE == "AUTO" then
        if UIS.TouchEnabled then
            local w = Camera.ViewportSize.X
            if w <= 360 then scale = 0.45
            elseif w <= 400 then scale = 0.5
            elseif w <= 480 then scale = 0.6
            elseif w <= 600 then scale = 0.7
            else scale = 0.8 end
        else
            scale = 0.85 -- PC default
        end
    end

    uiScale.Scale = scale
end

applyGlobalScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyGlobalScale)


-- MAIN FRAME
local main = Instance.new("Frame", gui)

main.Size = UDim2.fromOffset(420, 260)



main.Position = UDim2.new(0.32, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
main.BackgroundTransparency = 0.35
main.Active = true
main.Draggable = true


local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 1
stroke.Transparency = 0.6

-- =========================================================
-- CONTENT PANEL (BENAR)
-- =========================================================

local panel = Instance.new("Frame", main)
panel.ZIndex = 50
panel.Position = UDim2.new(0, 10, 0, 44)
panel.Size = UDim2.new(1, -20, 1, -54)
panel.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
panel.BackgroundTransparency = 0.30
panel.ClipsDescendants = true

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)


-- =========================================================
-- TOP BAR (DI DALAM PANEL)
-- =========================================================

local topBar = Instance.new("Frame", panel)
topBar.ZIndex = 60
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
topBar.BackgroundTransparency = 0.1

Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local list = Instance.new("UIListLayout", topBar)
list.FillDirection = Enum.FillDirection.Horizontal
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Padding = UDim.new(0, 6)
local pad = Instance.new("UIPadding", topBar)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.PaddingTop = UDim.new(0, 4)
pad.PaddingBottom = UDim.new(0, 4)


-- =========================================================
-- SCROLLING CONTENT (DI BAWAH TOPBAR)
-- =========================================================

local scroll = Instance.new("ScrollingFrame", panel)
scroll.ZIndex = 61
scroll.Position = UDim2.new(0, 10, 0, 42)   -- TURUN DI BAWAH TOPBAR
scroll.Size = UDim2.new(1, -20, 1, -52)     -- SESUAI KETINGGIAN PANEL
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 3
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder




-- PANEL UTILS
local function clearPanel()
    for _,v in ipairs(scroll:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
end

local function addButton(text, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -8, 0, 34)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextColor3 = Color3.fromRGB(230,230,255)
    b.BackgroundColor3 = Color3.fromRGB(40,45,60)

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
end


local function addLabel(text)
    local l = Instance.new("TextLabel", scroll)
    l.Size = UDim2.new(1, -8, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(180,185,200)
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
end


local function notify(msg)
    local n = Instance.new("Frame", gui)
    n.Size = UDim2.new(0,220,0,36)
    n.Position = UDim2.new(1,-240,1,-80)
    n.BackgroundColor3 = Color3.fromRGB(25,25,30)
    n.BackgroundTransparency = 0.2

    Instance.new("UICorner", n).CornerRadius = UDim.new(0,10)

    local txt = Instance.new("TextLabel", n)
    txt.Size = UDim2.new(1,-10,1,0)
    txt.Position = UDim2.new(0,10,0,0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 13
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.Text = msg
    txt.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        for i = 1,40 do
            task.wait(0.03)
            n.BackgroundTransparency += 0.02
            txt.TextTransparency += 0.02
        end
        n:Destroy()
    end)
end




---------------------------------------------------------
-- 📊 PING PANEL TOGGLE (FINAL FIX)
---------------------------------------------------------
local pingPanel

local function togglePingPanel()
    if pingPanel and pingPanel.Parent then
        pingPanel:Destroy()
        pingPanel = nil
        return
    end

    pingPanel = Instance.new("Frame", gui)
    pingPanel.Size = UDim2.new(0,160,0,60)
    pingPanel.Position = UDim2.new(1,-180,1,-100)
    pingPanel.BackgroundColor3 = Color3.fromRGB(25,28,35)
    pingPanel.BackgroundTransparency = 0.1
    pingPanel.Active = true
    pingPanel.Draggable = true

    Instance.new("UICorner", pingPanel).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", pingPanel).Color = Color3.fromRGB(0,170,255)

    local txt = Instance.new("TextLabel", pingPanel)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.Text = "Ping: ..."

    -- Auto update ping
    task.spawn(function()
        while pingPanel do
            task.wait(1)
            if not pingPanel then break end
            txt.Text = "Ping: " .. math.floor(Core.GetPing()) .. " ms"
        end
    end)


end


-- =========================================================
-- CREATE TOP TAB BUTTON
-- =========================================================
local THEME = {
    PANEL = Color3.fromRGB(20,24,30),
    BTN = Color3.fromRGB(30,34,42),
    TEXT = Color3.fromRGB(220,235,255),
    BORDER = Color3.fromRGB(0,170,220)
}
local currentTab = ""

local function newTab(name, callback)
    local btn = Instance.new("TextButton", topBar)
    btn.Size = UDim2.new(0, 80, 1, -8)
    btn.Text = name
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(200,200,255)

    btn.MouseButton1Click:Connect(function()
        currentTab = name
        clearPanel()
        callback()

        -- highlight
        for _,other in ipairs(topBar:GetChildren()) do
            if other:IsA("TextButton") then
                other.TextColor3 = THEME.TEXT
            end
        end
        btn.TextColor3 = THEME.BORDER
    end)
end




-- =========================================================
-- TAB: AUTO (dengan indikator ON/OFF)
-- =========================================================
newTab("Auto", function()
    addLabel("Auto Features")

    local autoFish = false
    local autoSell = false
    local autoWeather = false

    addButton("Auto Fish: OFF", function(btn)
        autoFish = not autoFish
        Core.AutoFish(autoFish)
        btn.Text = "Auto Fish: " .. (autoFish and "ON" or "OFF")
        notify("Auto Fish: " .. (autoFish and "ON" or "OFF"))
    end)

    addButton("Auto Sell: OFF", function(btn)
        autoSell = not autoSell
        Core.AutoSell(autoSell)
        btn.Text = "Auto Sell: " .. (autoSell and "ON" or "OFF")
        notify("Auto Sell: " .. (autoSell and "ON" or "OFF"))
    end)

    addButton("Auto Weather: OFF", function(btn)
        autoWeather = not autoWeather
        Core.AutoWeather(autoWeather)
        btn.Text = "Auto Weather: " .. (autoWeather and "ON" or "OFF")
        notify("Auto Weather: " .. (autoWeather and "ON" or "OFF"))
    end)
end)




-- =========================================================
-- TAB: TELEPORT SPOTS
-- =========================================================
newTab("Spots", function()
    addLabel("Teleport Spots")

    for _,spot in ipairs(Core.Spots) do
        addButton(spot.Name, function()
            local char = LP.Character or LP.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = spot.CFrame + Vector3.new(0,4,0)
        end)
    end
end)

-- =========================================================
-- TAB: PLAYERS
-- =========================================================
newTab("Players", function()
    local function buildPlayerList()
        clearPanel()
        addLabel("Teleport to Player")

        -- tombol refresh
        addButton("🔄  Refresh Player List", function()
            buildPlayerList()
        end)

        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                addButton(plr.Name, function()
                    local char = LP.Character or LP.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart")

                    local target = plr.Character
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                    end
                end)
            end
        end
    end

    buildPlayerList()
end)



-- =========================================================
-- TAB: SHOP (dengan indikator ON/OFF)
-- =========================================================
newTab("Shop", function()
    local autoTotem = AUTO_TOTEM
    local merchantGui = LP.PlayerGui:FindFirstChild("Merchant")

    addLabel("Shop & Totem")

    addButton("Auto Totem: " .. (autoTotem and "ON" or "OFF"), function(btn)
    autoTotem = not autoTotem
    Core.AutoTotem(autoTotem)
    btn.Text = "Auto Totem: " .. (autoTotem and "ON" or "OFF")
    notify("Auto Totem: " .. (autoTotem and "ON" or "OFF"))
end)

    addButton("Merchant UI (Auto Close 3s)", function(btn)
        if merchantGui then
            merchantGui.Enabled = true
            task.delay(3, function()
                merchantGui.Enabled = false
            end)
        end
    end)
end)

-- =========================================================
-- TAB: MISC (PERFORMANCE)
-- =========================================================
local lowPerfEnabled = false

local function ApplyLowPerformance(state)
    lowPerfEnabled = state

    if state then
        -- LOW PERFORMANCE ON (JALAN SEKALI)
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        local L = game:GetService("Lighting")
        L.GlobalShadows = false

        if L:FindFirstChildOfClass("BloomEffect") then
            L:FindFirstChildOfClass("BloomEffect").Enabled = false
        end
        if L:FindFirstChildOfClass("BlurEffect") then
            L:FindFirstChildOfClass("BlurEffect").Enabled = false
        end
        if L:FindFirstChildOfClass("SunRaysEffect") then
            L:FindFirstChildOfClass("SunRaysEffect").Enabled = false
        end

        notify("Low Performance Mode: ON")
    else
        -- RESTORE (JUGA SEKALI)
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

        local L = game:GetService("Lighting")
        L.GlobalShadows = true

        if L:FindFirstChildOfClass("BloomEffect") then
            L:FindFirstChildOfClass("BloomEffect").Enabled = true
        end
        if L:FindFirstChildOfClass("BlurEffect") then
            L:FindFirstChildOfClass("BlurEffect").Enabled = true
        end
        if L:FindFirstChildOfClass("SunRaysEffect") then
            L:FindFirstChildOfClass("SunRaysEffect").Enabled = true
        end

        notify("Low Performance Mode: OFF")
    end
end

newTab("Misc", function()
    addLabel("Performance & Utility")

    addButton("Low Performance Mode: OFF", function(btn)
        lowPerfEnabled = not lowPerfEnabled
        ApplyLowPerformance(lowPerfEnabled)
        btn.Text = "Low Performance Mode: " .. (lowPerfEnabled and "ON" or "OFF")
    end)
    addButton("UI Size: NORMAL", function(btn)
    if UI_MODE == "NORMAL" then
        UI_MODE = "SMALL"
        btn.Text = "UI Size: SMALL"
    elseif UI_MODE == "SMALL" then
        UI_MODE = "BIG"
        btn.Text = "UI Size: BIG"
    elseif UI_MODE == "BIG" then
        UI_MODE = "AUTO"
        btn.Text = "UI Size: AUTO"
    else
        UI_MODE = "NORMAL"
        btn.Text = "UI Size: NORMAL"
    end

    applyGlobalScale()
    notify("UI Size Mode: " .. UI_MODE)
end)
end)


-- =========================================================
-- TAB: SYSTEM
-- =========================================================
newTab("System", function()
    addLabel("System & Debug")

    addButton("Close UI", function()
    _G.FishItWORK = nil
    gui:Destroy()
end)


    addButton("Show Ping Panel", function()
    togglePingPanel()
    end)
    addButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
  end)
end)

-- OPEN DEFAULT TAB
task.wait(0.1)
local first = topBar:GetChildren()[1]
if first and first:IsA("TextButton") then
    first.MouseButton1Click:Fire()
end

print("UI TopBar Loaded | Clean | Modern | Working")


-- =====================================
-- FLOATING TOGGLE BUTTON (FULL FIXED)
-- =====================================

local guiRef = pg:FindFirstChild("FishItUI")
if not guiRef then return end

local mainFrame
for _,v in ipairs(guiRef:GetChildren()) do
    if v:IsA("Frame") then
        mainFrame = v
        break
    end
end
if not mainFrame then return end

local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "FishItFloatingToggle"
floatBtn.Parent = gui
floatBtn.Size = UDim2.new(0,48,0,48)
floatBtn.Position = UDim2.new(0.03,0,0.45,0)
floatBtn.Image = "rbxassetid://72407089659970"
floatBtn.BackgroundColor3 = Color3.fromRGB(0,140,180)
floatBtn.BorderSizePixel = 0
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.AutoButtonColor = false

local fc = Instance.new("UICorner", floatBtn)
fc.CornerRadius = UDim.new(0,12)

local panelVisible = true
floatBtn.MouseButton1Click:Connect(function()
    panelVisible = not panelVisible
    mainFrame.Visible = panelVisible
end)





-- =====================================
-- REAL PING UI
-- =====================================

local Stats = game:GetService("Stats")


local pingLabel = Instance.new("TextLabel", mainFrame)
pingLabel.Size = UDim2.new(0,140,0,18)
pingLabel.AnchorPoint = Vector2.new(1,1)
pingLabel.Position = UDim2.new(1,-10,1,-8)
pingLabel.BackgroundTransparency = 1
pingLabel.Font = Enum.Font.Gotham
pingLabel.TextSize = 11
pingLabel.TextColor3 = Color3.fromRGB(0,255,120)

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)
        local p = Core.GetPing()
        if p then
            pingLabel.Text = string.format("Ping: %.0f ms", p)
            if p <= 80 then
                pingLabel.TextColor3 = Color3.fromRGB(0,255,120)
            elseif p <= 150 then
                pingLabel.TextColor3 = Color3.fromRGB(255,200,0)
            else
                pingLabel.TextColor3 = Color3.fromRGB(255,80,80)
            end
        end
    end
end)


-- =====================================
-- CLEAN FISH UI (KEEP "You got:")
-- =====================================

local function shouldHide(label)
    if not label:IsA("TextLabel") then return false end
    if not label.Text then return false end

    local t = label.Text:lower()

    if t:match("^%s*you%s+got%s*:") then return false end
    if t:match("^1%s+in%s+%d+") then return true end
    if t:find("%(%s*[%d%.]+%s*kg") then return true end
    if t:find("lvl") then return true end
    if label.TextSize >= 26 then return true end

    return false
end

task.spawn(function()
    while _G.FishItWORK do
        task.wait(2)
        local fishUI = pg:FindFirstChild("FishingUI")
        if not fishUI then continue end

        for _,v in ipairs(fishUI:GetDescendants()) do
            if shouldHide(v) then
                v.Visible = false
            end
        end
    end
end)





-- =====================================
-- THEME APPLY (NO LOOP)
-- =====================================



for _,v in ipairs(gui:GetDescendants()) do
    if v:IsA("Frame") and v ~= main then -- jangan timpa main frame
        v.BackgroundColor3 = THEME.PANEL
    elseif v:IsA("TextButton") then
        v.BackgroundColor3 = THEME.BTN
        v.TextColor3 = THEME.TEXT
    elseif v:IsA("TextLabel") then
        v.TextColor3 = THEME.TEXT
    end

    if (v:IsA("Frame") or v:IsA("TextButton")) and not v:FindFirstChild("UICorner") then
        Instance.new("UICorner", v).CornerRadius = UDim.new(0,6)
    end

    if (v:IsA("Frame") or v:IsA("TextButton"))
and not v:FindFirstChildOfClass("UIStroke")
and v ~= topBar
and v ~= panel
then
        local s = Instance.new("UIStroke", v)
        s.Color = THEME.BORDER
        s.Thickness = 1
        s.Transparency = 0.6
    end
end


