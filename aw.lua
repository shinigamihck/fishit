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
    { Name = "Ancient Jungle", CFrame = CFrame.new(1562.54028,6.6,-233.16) },
    { Name = "Ancient Ruin", CFrame = CFrame.new(6076.29,-585.92,4625.92) },
    { Name = "Coral Reefs", CFrame = CFrame.new(-2752.80,4.0,2165.78) },
    { Name = "Crater Island", CFrame = CFrame.new(1027.12,2.89,5148.10) },
    { Name = "Fisherman Island", CFrame = CFrame.new(73.35,9.53,2709.50) },
    { Name = "Esoteric Depths", CFrame = CFrame.new(3249,-1301,1373) },
    { Name = "Kohana", CFrame = CFrame.new(-595,19,429) },
    { Name = "Weather Machine", CFrame = CFrame.new(-1527,2,1914) },
    -- (List penuh bisa ditambah lagi)
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

-- MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 480, 0, 320)
main.Position = UDim2.new(0.32, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
main.BackgroundTransparency = 0.25
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 1
stroke.Transparency = 0.6

-- =========================================================
-- TOP BAR
-- =========================================================
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
topBar.BackgroundTransparency = 0.1

local topCorner = Instance.new("UICorner", topBar)
topCorner.CornerRadius = UDim.new(0, 10)

local list = Instance.new("UIListLayout", topBar)
list.FillDirection = Enum.FillDirection.Horizontal
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Padding = UDim.new(0, 6)

-- =========================================================
-- CONTENT PANEL
-- =========================================================
local panel = Instance.new("Frame", main)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.Size = UDim2.new(1, -20, 1, -60)
panel.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
panel.BackgroundTransparency = 0.15

local pc = Instance.new("UICorner", panel)
pc.CornerRadius = UDim.new(0, 10)

local scroll = Instance.new("ScrollingFrame", panel)
scroll.Position = UDim2.new(0,10,0,10)
scroll.Size = UDim2.new(1,-20,1,-20)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 3
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

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

local UIS = game:GetService("UserInputService")

local function makeResizable(frame)
    local minW, minH = 120, 60

    local handle = Instance.new("Frame", frame)
    handle.Size = UDim2.new(0,18,0,18)
    handle.Position = UDim2.new(1,-18,1,-18)
    handle.BackgroundColor3 = Color3.fromRGB(100,100,120)
    handle.Active = true
    handle.Draggable = true

    Instance.new("UICorner", handle).CornerRadius = UDim.new(0,6)

    handle.MouseMoved:Connect(function()
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local m = UIS:GetMouseLocation()
            local x = math.max(minW, m.X - frame.AbsolutePosition.X)
            local y = math.max(minH, m.Y - frame.AbsolutePosition.Y)
            frame.Size = UDim2.new(0, x, 0, y)
        end
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

    -- allow resize
    makeResizable(pingPanel)
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
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.Text = name
    btn.TextSize = 13
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

makeResizable(main)
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
pingLabel.Position = UDim2.new(1,-150,1,-24)
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
-- MOBILE SCALE FIX (FINAL)
-- =====================================

local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local scale = gui:FindFirstChildOfClass("UIScale")
if not scale then
    scale = Instance.new("UIScale", gui)
end

local function applyScale()
    if not UIS.TouchEnabled then
        scale.Scale = 1
        return
    end

    local w = Camera.ViewportSize.X
    if w <= 360 then scale.Scale = 0.45
    elseif w <= 400 then scale.Scale = 0.5
    elseif w <= 480 then scale.Scale = 0.6
    elseif w <= 600 then scale.Scale = 0.7
    else scale.Scale = 0.8 end
end

applyScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)


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


