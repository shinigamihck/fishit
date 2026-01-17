-- =========================================================
--  FISH IT | CORE SYSTEM (NO UI) — FULL & CLEAN
-- =========================================================

if _G.FishItWORK then return end
_G.FishItWORK = true

-- SERVICES (SATU KALI SAJA)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =========================================================
-- NETWORK
-- =========================================================
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")
local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")
local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipToolFromHotbar = Net:RemoteEvent("EquipToolFromHotbar")

-- =========================================================
-- STATE VARIABLES (DONT TOUCH)
-- =========================================================
local AutoFish = false
local AutoSell = false
local AutoWeather = false
local AUTO_TOTEM = false

local WeatherDelay = 5
local SellInterval = 30
local FishDelay = 0.13

-- =========================================================
-- ANTI AFK
-- =========================================================
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- =========================================================
-- REAL PING READER
-- =========================================================
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

-- =========================================================
-- FISHING CONTROLLER (SAFE LOAD)
-- =========================================================
local FishingController
task.spawn(function()
    repeat
        task.wait(0.25)
        local ok, ctrl = pcall(function()
            return require(ReplicatedStorage.Controllers.FishingController)
        end)
        if ok and ctrl then
            FishingController = ctrl
        end
    until FishingController
end)

-- =========================================================
-- AUTO FISH LOOP
-- =========================================================
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
                pcall(function()
                    FishingController:FishingMinigameClick()
                end)
            end
        end
    end
end)

-- =========================================================
-- AUTO SELL LOOP
-- =========================================================
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

-- =========================================================
-- AUTO WEATHER LOOP
-- =========================================================
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

-- =========================================================
-- AUTO TOTEM SYSTEM (FULL)
-- =========================================================
local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")

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
        if not uuid then continue end

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

-- =========================================================
-- TELEPORT SPOTS (FULL LIST)
-- =========================================================

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

-- =========================================================
-- EXPORT CORE API (DIPAKAI UI)
-- =========================================================

_G.FishCore = {
    AutoFish = function(v) AutoFish = v end,
    AutoSell = function(v) AutoSell = v end,
    AutoWeather = function(v) AutoWeather = v end,
    AutoTotem = function(v) AUTO_TOTEM = v end,
    GetPing = getRealPing,
    Spots = Locations,
}

-- =========================================================
--  UI DARK MODE | HOHO STYLE | SIDEBAR KIRI
-- =========================================================

local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")
local Core = _G.FishCore

pcall(function()
    local old = pg:FindFirstChild("FishItUI")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "FishItUI"
gui.ResetOnSpawn = false
gui.Parent = pg

------------------------------------------------------------
-- GLOBAL UI SCALE
------------------------------------------------------------

local uiScale = Instance.new("UIScale", gui)
local UI_MODE = "AUTO"

local function applyGlobalScale()
    local w = workspace.CurrentCamera.ViewportSize.X
    if UIS.TouchEnabled then
        if w < 350 then uiScale.Scale = .45
        elseif w < 400 then uiScale.Scale = .55
        elseif w < 480 then uiScale.Scale = .65
        elseif w < 600 then uiScale.Scale = .75
        else uiScale.Scale = .85 end
    else
        uiScale.Scale = .9
    end
end

applyGlobalScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyGlobalScale)

------------------------------------------------------------
-- THEME
------------------------------------------------------------

local THEME = {
    BG_MAIN = Color3.fromRGB(18,18,22),
    BG_SIDE = Color3.fromRGB(24,24,30),
    BG_PANEL = Color3.fromRGB(32,32,40),

    PANEL = Color3.fromRGB(20,24,30), -- panel apply
    BTN = Color3.fromRGB(42,42,54),
    BTN_HVR  = Color3.fromRGB(52,52,66),

    TEXT = Color3.fromRGB(235,235,255),
    ACCENT = Color3.fromRGB(0,170,255),
    BORDER = Color3.fromRGB(0,170,220),
}



------------------------------------------------------------
-- MAIN FRAME
------------------------------------------------------------

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(640, 380)
main.Position = UDim2.new(0.5,-320,0.5,-190)
main.BackgroundColor3 = THEME.BG_MAIN
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke", main)
stroke.Color = THEME.ACCENT
stroke.Thickness = 1
stroke.Transparency = 0.6

------------------------------------------------------------
-- SIDEBAR (KIRI)
------------------------------------------------------------

local sidebar = Instance.new("Frame", main)
sidebar.ZIndex = 2
sidebar.Size = UDim2.new(0,150,1,0)
sidebar.BackgroundColor3 = THEME.BG_SIDE
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,12)


local sideList = Instance.new("UIListLayout", sidebar)
sideList.Padding = UDim.new(0,6)
sideList.FillDirection = Enum.FillDirection.Vertical
sideList.SortOrder = Enum.SortOrder.LayoutOrder

Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0,10)


------------------------------------------------------------
-- CONTENT PANEL
------------------------------------------------------------

local content = Instance.new("ScrollingFrame", main)
content.ZIndex = 1
content.Name = "Content"
content.Position = UDim2.new(0,160,0,10)
content.Size = UDim2.new(1,-170,1,-20)
content.CanvasSize = UDim2.new(0,0,0,0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollBarThickness = 4
content.ScrollBarImageTransparency = 0.2
content.BackgroundColor3 = THEME.BG_PANEL
content.ClipsDescendants = true

Instance.new("UICorner", content).CornerRadius = UDim.new(0,10)

local contentList = Instance.new("UIListLayout", content)
contentList.Padding = UDim.new(0,6)
contentList.SortOrder = Enum.SortOrder.LayoutOrder

local pad = Instance.new("UIPadding", content)
pad.PaddingTop = UDim.new(0,10)
pad.PaddingBottom = UDim.new(0,10)
pad.PaddingLeft = UDim.new(0,10)
pad.PaddingRight = UDim.new(0,10)



------------------------------------------------------------
-- CONTENT TOOLS
------------------------------------------------------------

local function Clear()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") and not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
            v:Destroy()
        end
    end
end


local function Label(t)
    local l = Instance.new("TextLabel", content)
    l.Size = UDim2.new(1,-20,0,22)
    l.Text = t
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.BackgroundTransparency = 1
    l.TextColor3 = THEME.TEXT
end

local function ContentButton(text, callback)
    local b = Instance.new("TextButton", content)
    b.ZIndex = content.ZIndex + 1
    b.Size = UDim2.new(1, -20, 0, 30) -- 🔥 lebih slim
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextColor3 = THEME.TEXT
    b.BackgroundColor3 = THEME.BTN
    b.AutoButtonColor = false

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = THEME.BTN_HVR
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = THEME.BTN
    end)

    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
end


local function SideButton(name, builder)
    local b = Instance.new("TextButton", sidebar)
    b.ZIndex = sidebar.ZIndex + 1
    b.Size = UDim2.new(1,-14,0,28) -- 🔥 lebih kecil
    b.Text = name
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextColor3 = THEME.TEXT
    b.BackgroundColor3 = THEME.BTN
    b.AutoButtonColor = false

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = THEME.BTN_HVR
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = THEME.BTN
    end)

    b.MouseButton1Click:Connect(function()
        Clear()
        builder()
    end)
end


------------------------------------------------------------
-- NOTIFY SYSTEM
------------------------------------------------------------

local function Notify(msg)
    local box = Instance.new("Frame", gui)
    box.Size = UDim2.new(0,240,0,38)
    box.Position = UDim2.new(1,-260,1,-100)
    box.BackgroundColor3 = Color3.fromRGB(24,24,30)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)

    local txt = Instance.new("TextLabel", box)
    txt.Size = UDim2.new(1,-12,1,0)
    txt.Position = UDim2.new(0,12,0,0)
    txt.Text = msg
    txt.TextColor3 = THEME.TEXT
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 13
    txt.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        for i = 1,35 do
            task.wait(.03)
            box.BackgroundTransparency += .02
            txt.TextTransparency += .02
        end
        box:Destroy()
    end)
end

------------------------------------------------------------
-- EXPORT UI
------------------------------------------------------------

_G.UI = {
    Clear = Clear,
    Label = Label,
    ContentButton = ContentButton,
    SideButton = SideButton,
    Notify = Notify,
    Content = content,
    Main = main,
}
_G.UI.Main.Sidebar = sidebar


-- =========================================================
-- PART 4 — TAB IMPLEMENTATION (AUTO / SPOTS / PLAYERS / SHOP / MISC / SYSTEM)
-- =========================================================

local UI = _G.UI
local Core = _G.FishCore
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- =======================
-- AUTO TAB
-- =======================
UI.SideButton("Auto", function()
    UI.Clear()
    UI.Label("Auto Features")

    local autoFish = false
    local autoSell = false
    local autoWeather = false

    UI.ContentButton("Auto Fish: OFF", function(btn)
        autoFish = not autoFish
        Core.AutoFish(autoFish)
        btn.Text = "Auto Fish: " .. (autoFish and "ON" or "OFF")
        UI.Notify(btn.Text)
    end)

    UI.ContentButton("Auto Sell: OFF", function(btn)
        autoSell = not autoSell
        Core.AutoSell(autoSell)
        btn.Text = "Auto Sell: " .. (autoSell and "ON" or "OFF")
        UI.Notify(btn.Text)
    end)

    UI.ContentButton("Auto Weather: OFF", function(btn)
        autoWeather = not autoWeather
        Core.AutoWeather(autoWeather)
        btn.Text = "Auto Weather: " .. (autoWeather and "ON" or "OFF")
        UI.Notify(btn.Text)
    end)
end)

-- =======================
-- SPOTS TAB
-- =======================
UI.SideButton("Spots", function()
    UI.Clear()
    UI.Label("Teleport Spots")

    for _,spot in ipairs(Core.Spots) do
        UI.ContentButton(spot.Name, function()
            local char = LP.Character or LP.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = spot.CFrame + Vector3.new(0,4,0)
            UI.Notify("Teleported: "..spot.Name)
        end)
    end
end)

-- =======================
-- PLAYERS TAB (FIXED SCROLL)
-- =======================
UI.SideButton("Players", function()

    local function build()
        UI.Clear()

        -- WAJIB supaya scrolling reset & UIListLayout tetap jalan
        UI.Content.CanvasSize = UDim2.new(0,0,0,0)

        UI.Label("Teleport Players")

        UI.ContentButton("🔄 Refresh", function()
            build()
        end)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                UI.ContentButton(plr.Name, function()
                    local myChar = LP.Character or LP.CharacterAdded:Wait()
                    local myHRP = myChar:WaitForChild("HumanoidRootPart")

                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        myHRP.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                        UI.Notify("Teleported to " .. plr.Name)
                    end
                end)
            end
        end
    end

    build()
end)


-- =======================
-- SHOP TAB
-- =======================
UI.SideButton("Shop", function()
    UI.Clear()
    UI.Label("Shop & Totem")

    local autoTotem = false

    UI.ContentButton("Auto Totem: OFF", function(btn)
        autoTotem = not autoTotem
        Core.AutoTotem(autoTotem)
        btn.Text = "Auto Totem: " .. (autoTotem and "ON" or "OFF")
        UI.Notify(btn.Text)
    end)

    UI.ContentButton("Open Merchant UI", function()
        local m = LP.PlayerGui:FindFirstChild("Merchant")
        if m then
            m.Enabled = true
            task.delay(3, function()
                if m then m.Enabled = false end
            end)
        end
    end)
end)

-- =======================
-- MISC TAB (PERFORMANCE)
-- =======================
UI.SideButton("Misc", function()
    UI.Clear()
    UI.Label("Performance & Utility")

    local lowPerf = false
    local ultra = false

    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    -- 🔥 LOW PERFORMANCE (bawaan)
    local function applyLow(state)
        if state then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            for _,e in ipairs(Lighting:GetChildren()) do
                if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("SunRaysEffect") then
                    e.Enabled = false
                end
            end
            UI.Notify("Low Performance: ON")
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
            for _,e in ipairs(Lighting:GetChildren()) do
                if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("SunRaysEffect") then
                    e.Enabled = true
                end
            end
            UI.Notify("Low Performance: OFF")
        end
    end

    -- 🔥 ULTRA LOW PERFORMANCE (baru)
    local function applyUltra(state)
        if state then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

            Lighting.GlobalShadows = false
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.FogEnd = 9e9

            for _,v in ipairs(Lighting:GetChildren()) do
                if v:IsA("BloomEffect")
                or v:IsA("BlurEffect")
                or v:IsA("SunRaysEffect")
                or v:IsA("ColorCorrectionEffect")
                or v:IsA("DepthOfFieldEffect") then
                    v.Enabled = false
                end
            end

            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end

            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") then
                    obj.Enabled = false
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false
                    obj.Material = Enum.Material.Plastic
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                end
            end

            UI.Notify("ULTRA Low Performance: ON")
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
            UI.Notify("ULTRA Low Performance: OFF")
        end
    end

    -- 🔘 LOW PERFORM
    UI.ContentButton("Low Performance: OFF", function(btn)
        lowPerf = not lowPerf
        applyLow(lowPerf)
        btn.Text = "Low Performance: " .. (lowPerf and "ON" or "OFF")
    end)

    -- 🔥 ULTRA LOW PERFORM BUTTON
    UI.ContentButton("ULTRA Low Performance: OFF", function(btn)
        ultra = not ultra
        applyUltra(ultra)
        btn.Text = "ULTRA Low Performance: " .. (ultra and "ON" or "OFF")
    end)
end)


-- =======================
-- SYSTEM TAB
-- =======================
local pingPanel
local function togglePing()
    if pingPanel then
        pingPanel:Destroy()
        pingPanel = nil
        return
    end

    pingPanel = Instance.new("Frame", UI.Main.Parent)
    pingPanel.Size = UDim2.new(0,180,0,60)
    pingPanel.Position = UDim2.new(1,-200,1,-120)
    pingPanel.BackgroundColor3 = Color3.fromRGB(25,28,35)
    Instance.new("UICorner", pingPanel).CornerRadius = UDim.new(0,10)

    local txt = Instance.new("TextLabel", pingPanel)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 15
    txt.TextColor3 = Color3.fromRGB(255,255,255)

    task.spawn(function()
        while pingPanel do
            task.wait(1)
            txt.Text = "Ping: "..math.floor(Core.GetPing()).." ms"
        end
    end)
end

UI.SideButton("System", function()
    UI.Clear()
    UI.Label("System")

    UI.ContentButton("Show Ping Panel", function()
        togglePing()
    end)

    UI.ContentButton("Rejoin Server", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end)

    UI.ContentButton("Close UI", function()
        _G.FishItWORK = nil
        UI.Main.Parent:Destroy()
    end)
end)





-- =========================================================
-- PART 5 — FLOATING BUTTON + REAL PING UI + FISH UI CLEANER
-- =========================================================

local gui = pg:FindFirstChild("FishItUI")
if not gui then return end

local main = _G.UI.Main

-- =========================================================
-- FLOAT TOGGLE BUTTON
-- =========================================================

local floatBtn = Instance.new("ImageButton", gui)
floatBtn.Size = UDim2.new(0,48,0,48)
floatBtn.Position = UDim2.new(0.03,0,0.45,0)
floatBtn.Image = "rbxassetid://72407089659970" -- ASSET MU
floatBtn.BackgroundColor3 = Color3.fromRGB(0,140,180)
floatBtn.BorderSizePixel = 0
floatBtn.Active = true
floatBtn.Draggable = true
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0,12)

local visible = true
floatBtn.MouseButton1Click:Connect(function()
    visible = not visible
    main.Visible = visible
end)

-- =========================================================
-- REAL PING TEXT DI MAIN PANEL
-- =========================================================

local pingLabel = Instance.new("TextLabel", main)
pingLabel.Size = UDim2.new(0,140,0,18)
pingLabel.AnchorPoint = Vector2.new(1,1)
pingLabel.Position = UDim2.new(1,-10,1,-8)
pingLabel.BackgroundTransparency = 1
pingLabel.Font = Enum.Font.Gotham
pingLabel.TextSize = 11

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)
        local p = Core.GetPing()
        pingLabel.Text = string.format("Ping: %.0f ms", p)
        if p <= 80 then
            pingLabel.TextColor3 = Color3.fromRGB(0,255,120)
        elseif p <= 150 then
            pingLabel.TextColor3 = Color3.fromRGB(255,200,0)
        else
            pingLabel.TextColor3 = Color3.fromRGB(255,80,80)
        end
    end
end)

-- =========================================================
-- THEME APPLY (FIXED)
-- =========================================================


for _,v in ipairs(main:GetDescendants()) do

    -- BASIC COLOR APPLY
    if v:IsA("Frame") and v ~= main then
        v.BackgroundColor3 = THEME.PANEL

    elseif v:IsA("TextButton") then
        v.BackgroundColor3 = THEME.BTN
        v.TextColor3 = THEME.TEXT
        v.TextTransparency = 0

    elseif v:IsA("TextLabel") then
        v.TextColor3 = THEME.TEXT
        v.TextTransparency = 0
    end

    -- CORNER
    if (v:IsA("Frame") or v:IsA("TextButton")) and not v:FindFirstChild("UICorner") then
        Instance.new("UICorner", v).CornerRadius = UDim.new(0,6)
    end

    -- STROKE
    if (v:IsA("Frame") or v:IsA("TextButton")) 
        and not v:FindFirstChildOfClass("UIStroke")
        and v ~= main then

        local s = Instance.new("UIStroke", v)
        s.Color = THEME.BORDER
        s.Thickness = 1
        s.Transparency = 0.6
    end
end

-- =========================================================
-- CLEAN FISH UI (KEEP "You got:")
-- =========================================================

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


print("FISH IT — FINAL UI MERGED SCRIPT LOADED")
-- =========================================================
-- PART 6 — RESIZE PANEL + FINAL POLISHING
-- =========================================================

local UserInputService = game:GetService("UserInputService")
local resizing = false
local startPos
local startSize

local resizeHandle = Instance.new("Frame", main)
resizeHandle.Size = UDim2.new(1,0,0,12)
resizeHandle.Position = UDim2.new(0,0,1,-12)
resizeHandle.BackgroundColor3 = Color3.fromRGB(40,40,50)
resizeHandle.BackgroundTransparency = 0.35
Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0,6)

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        startPos = UserInputService:GetMouseLocation()
        startSize = main.Size
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouse = UserInputService:GetMouseLocation()
        local dy = mouse.Y - startPos.Y

        main.Size = UDim2.new(startSize.X.Scale, startSize.X.Offset,
                              startSize.Y.Scale, startSize.Y.Offset + dy)
    end
end)

-- =========================================================
-- PART 7 — AUTO OPEN DEFAULT TAB (AUTO)
-- =========================================================

task.delay(0.1, function()
    for _,btn in ipairs(_G.UI.Main.Sidebar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn:Activate() -- ✅ BENAR
            break
        end
    end
end)
-- =========================================================
-- PART 8 — SAFETY EXIT & CLEANUP
-- =========================================================

local function safeShutdown()
    _G.FishItWORK = false
    pcall(function()
        gui:Destroy()
    end)
end

_G.FISHIT_SHUTDOWN = safeShutdown

-- =========================================================
-- SCRIPT SELESAI
-- =========================================================

print("FISH IT — COMPLETE SCRIPT MERGED SUCCESSFULLY")
-- =========================================================

-- =========================================================
-- END OF FILE
-- =========================================================
