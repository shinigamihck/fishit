------------------------------------------------------
-- 🔥 AUTO CLEAN FISHIT HUB | WAJIB DI PALING ATAS
------------------------------------------------------

-- Stop semua loop lama
for _,v in ipairs(getgc(true)) do
    if type(v) == "function" and islclosure(v) then
        local info = debug.getinfo(v)
        if info.source and info.source:find("FishItHub") then
            pcall(function()
                hookfunction(v, function() return end)
            end)
        end
    end
end

-- Reset global
_G.FishItHubLoaded = false
_G.AutoFish = false
_G.AutoSell = false
_G.AutoWeather = false
_G.AUTO_TOTEM = false
_G.FlyEnabled = false

-- Cleanup old GUI
pcall(function()
    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    if pg:FindFirstChild("FishItHubUI") then
        pg.FishItHubUI:Destroy()
    end
end)

-- Cleanup old blur
pcall(function()
    local Lighting = game:GetService("Lighting")
    if Lighting:FindFirstChild("FishItHubBlur") then
        Lighting.FishItHubBlur:Destroy()
    end
    if Lighting:FindFirstChild("TabHubBlur") then
        Lighting.TabHubBlur:Destroy()
    end
end)

print("✔ AUTO CLEAN DONE | Environment reset. Loading fresh FishIt Hub...")



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
-- NET PACKAGE
------------------------------------------------------
local Net = require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)

local sellRF = Net:RemoteFunction("SellAllItems")
local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")

local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipToolFromHotbar = Net:RemoteEvent("EquipToolFromHotbar")

local Data = Replion.Client:WaitReplion("Data")

------------------------------------------------------
-- GLOBAL STATE
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
-- FISHING CONTROLLER
------------------------------------------------------
local FishingController = nil

task.spawn(function()
    repeat
        task.wait(0.25)
        local ok, ctrl = pcall(function()
            return require(ReplicatedStorage.Controllers.FishingController)
        end)
        if ok and ctrl then FishingController = ctrl end
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

print("✔ PART 1/5 Loaded | Core Ready")



--====================================================
-- FISHIT HUB — PART 2/5 (UI SYSTEM)
--====================================================

pcall(function()
    LP.PlayerGui:FindFirstChild("FishItHubUI"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "FishItHubUI"
gui.ResetOnSpawn = false
gui.Parent = LP.PlayerGui

local blur = Instance.new("BlurEffect")
blur.Name = "FishItHubBlur"
blur.Size = 14
blur.Parent = Lighting

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
main.Size = UDim2.new(0,600,0,360)
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
title.Size = UDim2.new(1,-40,1,0)
title.Position = UDim2.new(0,14,0,0)
title.Text = "FishIt Hub — Glass Minimal"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = THEME.TEXT
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

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

local Pages = {}

local function createPage(name)
    local f = Instance.new("Frame", pages)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundTransparency = 1
    f.Visible = false

    local l = Instance.new("UIListLayout", f)
    l.Padding = UDim.new(0,10)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Left

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
-- SIDEBAR TAB BUTTONS
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
-- MAIN PAGE TOGGLES
------------------------------------------------------
createToggle(MainPage, "Auto Fish", function(v)
    _G.ApplyToggle("Auto Fish", v)
end)

createToggle(MainPage, "Auto Sell", function(v)
    _G.ApplyToggle("Auto Sell", v)
end)

createToggle(MainPage, "Auto Weather", function(v)
    _G.ApplyToggle("Auto Weather", v)
end)

createToggle(MainPage, "Fly", function(v)
    _G.ApplyToggle("Fly", v)
end)

createToggle(MainPage, "Auto Totem", function(v)
    _G.ApplyToggle("Auto Totem", v)
end)

------------------------------------------------------
-- FLOAT BUTTON (SHOW / HIDE UI)
------------------------------------------------------
local floatBtn = Instance.new("ImageButton", gui)
floatBtn.Size = UDim2.new(0,46,0,46)
floatBtn.Position = UDim2.new(0.03,0,0.4,0)
floatBtn.Image = "rbxassetid://72407089659970"
floatBtn.BackgroundColor3 = Color3.fromRGB(120,160,255)
floatBtn.BackgroundTransparency = 0.25
floatBtn.Active = true
floatBtn.Draggable = true

Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0,12)

local visible = true
floatBtn.MouseButton1Click:Connect(function()
    visible = not visible
    main.Visible = visible
end)

print("✔ PART 2/5 Loaded | UI Ready")
--====================================================
-- FISHIT HUB — PART 3/5 (ENGINE LOGIC)
--====================================================

------------------------------------------------------
-- FLY ENGINE (STABLE)
------------------------------------------------------
local flyConn, bv, bg

local function stopFly()
    FlyEnabled = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

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

------------------------------------------------------
-- AUTO FISH LOOP
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(FishDelay)
        if AutoFish and FishingController then
            local guid = FishingController:GetCurrentGUID()
            if not guid then
                pcall(function()
                    FishingController:RequestChargeFishingRod(
                        workspace.CurrentCamera.ViewportSize / 2, true
                    )
                end)
            else
                FishingController:FishingMinigameClick()
            end
        end
    end
end)

------------------------------------------------------
-- AUTO SELL LOOP
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
-- AUTO WEATHER LOOP
------------------------------------------------------
local WeatherList = {"Storm","Cloudy","Wind"}

task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(WeatherDelay)
        if AutoWeather then
            for _,w in ipairs(WeatherList) do
                pcall(function()
                    purchaseRF:InvokeServer(w)
                end)
                task.wait(1.3)
            end
        end
    end
end)

print("✔ PART 3/5 Loaded | Engine OK")

--====================================================
-- FISHIT HUB — PART 4/5 (AUTO TOTEM)
--====================================================

local COOLDOWN = 0
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

TotemSpawned.OnClientEvent:Connect(function()
    COOLDOWN = 3600
    task.delay(0.3, function()
        pcall(function()
            EquipToolFromHotbar:FireServer(1)
        end)
    end)
end)

task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(1)

        if not AUTO_TOTEM then continue end

        if COOLDOWN > 0 then
            COOLDOWN -= 1
            continue
        end

        if retryWait then
            if os.clock() < retryWait then
                continue
            else
                retryWait = false
            end
        end

        local uuid = GetTotemUUID()
        if not uuid then
            task.wait(5)
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

print("✔ PART 4/5 Loaded | Auto Totem OK")

--====================================================
-- FISHIT HUB — PART 5/5 (UI ↔ ENGINE INTEGRATION)
--====================================================

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
-- SAFE EXIT
------------------------------------------------------
function _G.CloseHub()
    _G.FishItHubLoaded = false
    FlyEnabled = false
    pcall(stopFly)
    pcall(function()
        if gui then gui:Destroy() end
    end)
    pcall(function()
        if Lighting:FindFirstChild("FishItHubBlur") then
            Lighting.FishItHubBlur:Destroy()
        end
    end)
end

print("✅ PART 5/5 Loaded | HUB FULLY WORKING")
print("🔥 FishIt Hub FINAL loaded cleanly")
