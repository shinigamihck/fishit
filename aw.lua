--====================================================
-- FISHIT HUB — PART 1/5 (CORE SYSTEM)
--====================================================

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

------------------------------------------------------
-- NET PACKAGE (WAJIB)
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

-- Player Data
local Data = Replion.Client:WaitReplion("Data")

------------------------------------------------------
-- GLOBAL STATE (UI TOGGLES)
------------------------------------------------------
local AutoFish = false
local AutoSell = false
local AutoWeather = false
local AUTO_TOTEM = false
local FlyEnabled = false

local FlySpeed = 80
local FishDelay = 0.13
local SellInterval = 5
local WeatherDelay = 5

------------------------------------------------------
-- FLY ENGINE VARIABLES
------------------------------------------------------
local flyConn = nil
local bv = nil
local bg = nil

------------------------------------------------------
-- FISHING CONTROLLER (WAJIB)
------------------------------------------------------
local FishingController = nil

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

------------------------------------------------------
-- ANTI AFK
------------------------------------------------------
local VirtualUser = game:GetService("VirtualUser")

LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("✔ PART 1/5 Loaded | Core System Initialized")

--====================================================
-- FISHIT HUB — PART 2/5 (GLASS UI)
--====================================================

------------------------------------------------------
-- REMOVE OLD UI
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
-- GLASS BLUR (SAFE)
------------------------------------------------------
local blur = Instance.new("BlurEffect")
blur.Name = "FishItHubBlur"
blur.Size = 14
blur.Parent = Lighting

------------------------------------------------------
-- THEME (GLASS MINIMAL)
------------------------------------------------------
local THEME = {
    BG = Color3.fromRGB(18,18,22),
    PANEL = Color3.fromRGB(25,25,30),
    BUTTON = Color3.fromRGB(35,35,40),
    ACTIVE = Color3.fromRGB(80,160,255),
    TEXT = Color3.fromRGB(235,235,245),
    DIM = Color3.fromRGB(160,160,170),
    BORDER = Color3.fromRGB(255,255,255)
}

------------------------------------------------------
-- MAIN WINDOW
------------------------------------------------------
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 600, 0, 360)
main.Position = UDim2.new(0.5,-300,0.4,-180)
main.BackgroundColor3 = THEME.BG
main.BackgroundTransparency = 0.15
main.Active = true
main.Draggable = true
main.BorderSizePixel = 0

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = THEME.BORDER
stroke.Transparency = 0.75

------------------------------------------------------
-- TITLE BAR
------------------------------------------------------
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,36)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Text = "FishIt Hub — Glass Minimal"
title.Size = UDim2.new(1,-40,1,0)
title.Position = UDim2.new(0,14,0,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = THEME.TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

local close = Instance.new("TextButton", titleBar)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-34,0,3)
close.Text = "×"
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.TextColor3 = THEME.TEXT
close.BackgroundTransparency = 1

close.MouseButton1Click:Connect(function()
    _G.FishItHubLoaded = false
    pcall(function() blur:Destroy() end)
    gui:Destroy()
end)

------------------------------------------------------
-- SIDEBAR
------------------------------------------------------
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,140,1,-40)
sidebar.Position = UDim2.new(0,0,0,40)
sidebar.BackgroundColor3 = THEME.PANEL
sidebar.BackgroundTransparency = 0.2
sidebar.BorderSizePixel = 0

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0,6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

------------------------------------------------------
-- PAGE CONTAINER
------------------------------------------------------
local pages = Instance.new("Frame", main)
pages.Size = UDim2.new(1,-160,1,-40)
pages.Position = UDim2.new(0,160,0,40)
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
-- TAB BUTTON
------------------------------------------------------
local function createTab(name)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1,-20,0,32)
    b.Text = name
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextColor3 = THEME.TEXT
    b.BackgroundColor3 = THEME.BUTTON
    b.BackgroundTransparency = 0.25
    b.BorderSizePixel = 0

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
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

createTab("Main")
createTab("Players")
createTab("Spots")
createTab("Visual")
createTab("Misc")

------------------------------------------------------
-- TOGGLE BUILDER
------------------------------------------------------
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,260,0,32)
    btn.BackgroundColor3 = THEME.BUTTON
    btn.BackgroundTransparency = 0.25
    btn.TextColor3 = THEME.TEXT
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Text = text .. " : OFF"

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and THEME.ACTIVE or THEME.BUTTON
        callback(state)
    end)
end

------------------------------------------------------
-- FLOATING TOGGLE
------------------------------------------------------
local floatBtn = Instance.new("ImageButton", gui)
floatBtn.Size = UDim2.new(0,46,0,46)
floatBtn.Position = UDim2.new(0.03,0,0.4,0)
floatBtn.Image = "rbxassetid://72407089659970"
floatBtn.BackgroundColor3 = Color3.fromRGB(120,160,255)
floatBtn.BackgroundTransparency = 0.25
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.BorderSizePixel = 0

Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0,12)
local fs = Instance.new("UIStroke", floatBtn)
fs.Color = THEME.BORDER
fs.Transparency = 0.6

local visible = true
floatBtn.MouseButton1Click:Connect(function()
    visible = not visible
    main.Visible = visible
end)

print("✔ PART 2/5 Loaded | Glass UI Ready")

--====================================================
-- FISHIT HUB — PART 3/5 (ENGINE LOGIC)
--====================================================

------------------------------------------------------
-- FLY ENGINE (FINAL OLD STABLE)
------------------------------------------------------
local function stopFly()
    FlyEnabled = false
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

_G.StopFly = stopFly

local function startFly()
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

_G.StartFly = startFly


------------------------------------------------------
-- AUTO FISH ENGINE
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
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


------------------------------------------------------
-- AUTO SELL ENGINE
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(SellInterval)

        if AutoSell and sellRF then
            pcall(function()
                sellRF:InvokeServer()
            end)
        end
    end
end)


------------------------------------------------------
-- AUTO WEATHER ENGINE
------------------------------------------------------
local WeatherList = {"Storm","Cloudy","Wind"}

task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(WeatherDelay)

        if AutoWeather then
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
-- LOW GFX SAFE MODE (LIGHTWEIGHT)
------------------------------------------------------
task.spawn(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.FogEnd = 999999

    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("DepthOfFieldEffect")
        or v:IsA("ColorCorrectionEffect") then
            v.Enabled = false
        end
    end
end)


------------------------------------------------------
-- CLEAN FISHING UI (ONLY KEEP "You got:")
------------------------------------------------------
task.spawn(function()
    local pg = LP:WaitForChild("PlayerGui")

    local function hide(label)
        if not label:IsA("TextLabel") then return false end
        if not label.Text or label.Text == "" then return false end

        local t = label.Text:lower()

        if t:match("^%s*you%s+got%s*:") then return false end
        if t:match("^1%s+in%s+%d+") then return true end
        if t:find("kg") then return true end
        if t:find("lvl") then return true end
        if label.TextSize >= 26 then return true end

        return false
    end

    while _G.FishItHubLoaded do
        task.wait(2)

        local fx = pg:FindFirstChild("FishingUI")
        if not fx then continue end

        for _,obj in ipairs(fx:GetDescendants()) do
            if hide(obj) then obj.Visible = false end
        end
    end
end)


------------------------------------------------------
-- REAL PING MONITOR (SHIFT+F3 ACCURATE)
------------------------------------------------------
task.spawn(function()
    local pingLabel = Instance.new("TextLabel", gui)
    pingLabel.Size = UDim2.new(0,140,0,20)
    pingLabel.Position = UDim2.new(1,-150,1,-30)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Font = Enum.Font.Gotham
    pingLabel.TextSize = 12
    pingLabel.TextColor3 = THEME.DIM
    pingLabel.Text = "Ping: --"

    local function getPing()
        local net = Stats:FindFirstChild("Network")
        if not net then return nil end

        local server = net:FindFirstChild("ServerStatsItem")
        if not server then return nil end

        local ping = server:FindFirstChild("Data Ping")
        if not ping then return nil end

        return ping:GetValue()
    end

    while _G.FishItHubLoaded do
        task.wait(1)

        local p = getPing()
        if not p then
            pingLabel.Text = "Ping: --"
        else
            pingLabel.Text = string.format("Ping: %.1f ms", p)
        end
    end
end)

print("✔ PART 3/5 Loaded | Engine Logic Active")

--====================================================
-- FISHIT HUB — PART 4/5 (AUTO TOTEM + TELEPORT)
--====================================================

------------------------------------------------------
-- AUTO TOTEM ENGINE (FINAL CLEAN VERSION)
------------------------------------------------------
local COOLDOWN = 0
local TRY_INTERVAL = 300    -- retry 5 menit
local retryWait = false

-- Ambil UUID Totem
local function GetTotemUUID()
    local inv = Data:Get({"Inventory","Totems"})
    if inv then
        for _,item in ipairs(inv) do
            return item.UUID
        end
    end
    return nil
end

-- Server confirm → cooldown baru
TotemSpawned.OnClientEvent:Connect(function()
    COOLDOWN = 3600

    task.delay(0.3, function()
        pcall(function()
            EquipToolFromHotbar:FireServer(1)
        end)
    end)
end)

-- Loop Auto Totem
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(1)

        if not AUTO_TOTEM then continue end

        -- cooldown aktif
        if COOLDOWN > 0 then
            COOLDOWN -= 1
            continue
        end

        -- retry countdown
        if retryWait then
            if os.clock() < retryWait then
                continue
            else
                retryWait = false
            end
        end

        -- dapatkan UUID
        local uuid = GetTotemUUID()
        if not uuid then
            task.wait(5)
            continue
        end

        -- attempt spawn
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



------------------------------------------------------
-- TELEPORT PLAYER LIST (FUNCTION USED BY UI)
------------------------------------------------------
function _G.RefreshPlayerList(parent, THEME)
    for _,v in ipairs(parent:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local b = Instance.new("TextButton", parent)
            b.Size = UDim2.new(0, 260, 0, 30)
            b.Text = plr.Name
            b.Font = Enum.Font.Gotham
            b.TextColor3 = THEME.TEXT
            b.BackgroundColor3 = THEME.BUTTON
            b.AutoButtonColor = false

            local c = Instance.new("UICorner", b)
            c.CornerRadius = UDim.new(0,6)

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
-- TELEPORT SPOTS (FULL A-Z LIST)
------------------------------------------------------
local SpotList = {
    { Name = "Ancient Jungle", CFrame = CFrame.new(1562.54, 6.62, -233.16) },
    { Name = "Ancient Ruin", CFrame = CFrame.new(6076.29, -585.92, 4625.92) },
    { Name = "Captain Jones (Quest)", CFrame = CFrame.new(3312.16, 9.09, 3681.58) },
    { Name = "Coral Reefs", CFrame = CFrame.new(-2752.8, 4.0, 2165.78) },
    { Name = "Crater Island", CFrame = CFrame.new(1027.12, 2.89, 5148.10) },
    { Name = "Deadman Compass (Quest)", CFrame = CFrame.new(-3437.02, -22.36, -1500.29) },
    { Name = "Esoteric Depths", CFrame = CFrame.new(3249.08, -1301.52, 1373.68) },
    { Name = "Fisherman Island", CFrame = CFrame.new(73.35, 9.53, 2709.50) },
    { Name = "Kohana", CFrame = CFrame.new(-595.69, 19.25, 429.86) },
    { Name = "Kohana Volcano", CFrame = CFrame.new(-559.59, 21.22, 153.75) },
    { Name = "Kuil Suci", CFrame = CFrame.new(1471.79, -22.12, -607.50) },
    { Name = "Pirate Cove", CFrame = CFrame.new(3398.70, 10.34, 3491.11) },
    { Name = "Pirate Treasure Room", CFrame = CFrame.new(3340.80, -301.51, 3090.66) },
    { Name = "Sisyphus Statue", CFrame = CFrame.new(-3745.26, -135.07, -1008.68) },
    { Name = "Traveling Merchant", CFrame = CFrame.new(-133.94, 3.18, 2767.25) },
    { Name = "Treasure Room", CFrame = CFrame.new(-3597.20, -280.11, -1633.28) },
    { Name = "Tropical Grove", CFrame = CFrame.new(-2128.62, 53.48, 3637.66) },
    { Name = "Weather Machine", CFrame = CFrame.new(-1527.67, 2.87, 1914.66) },
}

_G.RefreshSpotList = function(parent, THEME)
    for _,v in ipairs(parent:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,spot in ipairs(SpotList) do
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0, 260, 0, 30)
        b.Text = spot.Name
        b.Font = Enum.Font.Gotham
        b.TextColor3 = THEME.TEXT
        b.BackgroundColor3 = THEME.BUTTON
        b.AutoButtonColor = false

        local c = Instance.new("UICorner", b)
        c.CornerRadius = UDim.new(0,6)

        b.MouseButton1Click:Connect(function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spot.CFrame + Vector3.new(0,5,0)
            end
        end)
    end
end


print("✔ PART 4/5 Loaded | Auto Totem + Teleport Ready")
--====================================================
-- FISHIT HUB — PART 5/5 (UI ↔ ENGINE INTEGRATION)
--====================================================

------------------------------------------------------
-- SYNC TOGGLES DARI UI
------------------------------------------------------
_G.ToggleMap = {
    ["Auto Fish"] = function(v) AutoFish = v end,
    ["Auto Sell"] = function(v) AutoSell = v end,
    ["Auto Weather"] = function(v) AutoWeather = v end,
    ["Fly"] = function(v)
        FlyEnabled = v
        if v then startFly() else stopFly() end
    end,
    ["Auto Totem"] = function(v) AUTO_TOTEM = v end,
}

function _G.ApplyToggle(name, state)
    if _G.ToggleMap[name] then
        _G.ToggleMap[name](state)
    end
end


------------------------------------------------------
-- AUTO FISH MAIN LOOP
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
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


------------------------------------------------------
-- AUTO SELL
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(SellInterval)
        if AutoSell then
            pcall(function()
                sellRF:InvokeServer()
            end)
        end
    end
end)



------------------------------------------------------
-- AUTO WEATHER ENGINE
------------------------------------------------------
local WeatherList = {"Storm", "Cloudy", "Wind"}

task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(WeatherDelay)

        if not AutoWeather then continue end

        for _,weather in ipairs(WeatherList) do
            pcall(function()
                purchaseRF:InvokeServer(weather)
            end)
            task.wait(1.4)
        end
    end
end)



------------------------------------------------------
-- CLEAN FISHING UI (FPS MODE)
------------------------------------------------------
local function shouldHideFishLabel(lb)
    if not lb:IsA("TextLabel") then return false end
    if not lb.Text or lb.Text == "" then return false end

    local t = lb.Text:lower()

    if t:match("^%s*you%sgot") then return false end
    if t:match("^1%sin") then return true end
    if t:find("kg") then return true end
    if t:find("lvl") then return true end

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
        task.wait(1.8)
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
-- LOW GFX MODE
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
        or fx:IsA("ColorCorrectionEffect") then
            fx.Enabled = false
        end
    end
end)



------------------------------------------------------
-- REAL PING MONITOR (MINIMAL)
------------------------------------------------------
task.spawn(function()
    local PingLabel = Instance.new("TextLabel", gui)
    PingLabel.Size = UDim2.new(0,150,0,22)
    PingLabel.Position = UDim2.new(1,-160,1,-32)
    PingLabel.BackgroundTransparency = 1
    PingLabel.Font = Enum.Font.Gotham
    PingLabel.TextSize = 12
    PingLabel.TextColor3 = THEME.TEXT_DIM
    PingLabel.Text = "Ping: --"

    local function getPing()
        local net = Stats:FindFirstChild("Network")
        if not net then return nil end
        local server = net:FindFirstChild("ServerStatsItem")
        if not server then return nil end
        local ping = server:FindFirstChild("Data Ping")
        if not ping then return nil end
        return ping:GetValue()
    end

    while _G.FishItHubLoaded do
        task.wait(1)
        local p = getPing()
        PingLabel.Text = p and string.format("Ping: %.1f ms", p) or "Ping: --"
    end
end)



------------------------------------------------------
-- UI FINAL STYLE PASS (GLASS MINIMAL)
------------------------------------------------------
local function applyStyle(obj)
    if obj:IsA("Frame") then
        obj.BackgroundTransparency = 0.15
        obj.BackgroundColor3 = THEME.BG

    elseif obj:IsA("TextButton") then
        obj.BackgroundColor3 = THEME.BUTTON
        obj.TextColor3 = THEME.TEXT
        obj.AutoButtonColor = false

    elseif obj:IsA("TextLabel") then
        obj.TextColor3 = THEME.TEXT
    end

    if (obj:IsA("Frame") or obj:IsA("TextButton")) and not obj:FindFirstChild("UICorner") then
        local c = Instance.new("UICorner", obj)
        c.CornerRadius = UDim.new(0, 8)
    end

    if (obj:IsA("Frame") or obj:IsA("TextButton")) then
        if not obj:FindFirstChild("UIStroke") then
            local s = Instance.new("UIStroke", obj)
            s.Color = THEME.BORDER
            s.Thickness = 1
            s.Transparency = 0.72
        end
    end
end

for _,v in ipairs(gui:GetDescendants()) do
    applyStyle(v)
end





------------------------------------------------------
-- SAFE EXIT (CLOSE BUTTON SUPPORT)
------------------------------------------------------
function _G.CloseHub()
    _G.FishItHubLoaded = false
    FlyEnabled = false

    pcall(stopFly)
    pcall(function() if gui then gui:Destroy() end end)
    pcall(function()
        if Lighting:FindFirstChild("TabHubBlur") then
            Lighting.TabHubBlur:Destroy()
        end
    end)
end

print("✔ PART 5/5 Loaded | Hub Fully Operational")
