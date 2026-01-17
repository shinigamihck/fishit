--=========================================================
--  FISH IT | CORE SYSTEM — FINAL CLEAN & STABLE
--=========================================================

if _G.FishItWORK then return end
_G.FishItWORK = true

--=========================================================
-- SERVICES
--=========================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--=========================================================
-- NETWORK
--=========================================================
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")
local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")
local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipToolFromHotbar = Net:RemoteEvent("EquipToolFromHotbar")

--=========================================================
-- STATE VARIABLES
--=========================================================
local AutoFish = false
local AutoSell = false
local AutoWeather = false
local AUTO_TOTEM = false

local WeatherDelay = 5
local SellInterval = 30
local FishDelay = 0.13

--=========================================================
-- ANTI AFK
--=========================================================
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--=========================================================
-- REAL PING READER
--=========================================================
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

--=========================================================
-- FISHING CONTROLLER (SAFE LOAD)
--=========================================================
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

--=========================================================
-- AUTO FISH LOOP
--=========================================================
task.spawn(function()
    while _G.FishItWORK do
        task.wait(FishDelay)
        if AutoFish and FishingController then
            local guid = FishingController:GetCurrentGUID()
            if not guid then
                pcall(function()
                    FishingController:RequestChargeFishingRod(
                        Camera.ViewportSize/2, true
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

--=========================================================
-- AUTO SELL LOOP
--=========================================================
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

--=========================================================
-- AUTO WEATHER LOOP
--=========================================================
local WeatherList = {"Storm","Cloudy","Wind"}

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

--=========================================================
-- AUTO TOTEM SYSTEM
--=========================================================
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
    task.delay(.2, EquipRod)
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
        task.wait(.5)
        if conn then conn:Disconnect() end

        if not success then
            retryWait = os.clock() + TRY_INTERVAL
        end
    end
end)

--=========================================================
-- TELEPORT SPOTS (FULL LIST)
--=========================================================
local Locations = {
    {Name="Ancient Jungle",CFrame=CFrame.new(1562.54,6.62,-233.16)},
    {Name="Ancient Ruin",CFrame=CFrame.new(6076.29,-585.92,4625.92)},
    {Name="Coral Reefs",CFrame=CFrame.new(-2752.8,4,2165.78)},
    {Name="Crater Island",CFrame=CFrame.new(1027.12,2.89,5148.10)},
    {Name="Fisherman Island",CFrame=CFrame.new(73.35,9.53,2709.5)},
    {Name="Kohana",CFrame=CFrame.new(-595.69,19.25,429.86)},
    {Name="Kuil Suci",CFrame=CFrame.new(1471.79,-22.12,-607.50)},
    {Name="Volcano",CFrame=CFrame.new(-559.59,21.22,153.75)},
    {Name="Weather Machine",CFrame=CFrame.new(-1527.67,2.87,1914.66)},
    {Name="Tropical Grove",CFrame=CFrame.new(-2128.62,53.48,3637.66)},
}
--=========================================================
-- UI DARK MODE | FINAL CLEAN VERSION
--=========================================================

local pg = LP:WaitForChild("PlayerGui")
local Core = _G.FishCore

pcall(function()
    local old = pg:FindFirstChild("FishItUI")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "FishItUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = pg

--=========================================================
-- GLOBAL SCALE
--=========================================================
local uiScale = Instance.new("UIScale", gui)
local function applyScale()
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
applyScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)

--=========================================================
-- THEME
--=========================================================
local THEME = {
    BG_MAIN = Color3.fromRGB(18,18,22),
    BG_SIDE = Color3.fromRGB(24,24,30),
    BG_PANEL = Color3.fromRGB(32,32,40),
    BTN = Color3.fromRGB(42,42,54),
    BTN_HVR = Color3.fromRGB(52,52,66),
    TEXT = Color3.fromRGB(235,235,255),
    ACCENT = Color3.fromRGB(0,170,255),
}

--=========================================================
-- MAIN FRAME
--=========================================================
local main = Instance.new("Frame", gui)
main.ZIndex = 1
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

--=========================================================
-- SIDEBAR
--=========================================================
local sidebar = Instance.new("Frame", main)
sidebar.Name = "Sidebar"
sidebar.ZIndex = 3
sidebar.Size = UDim2.new(0,150,1,0)
sidebar.BackgroundColor3 = THEME.BG_SIDE
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,12)

local sideList = Instance.new("UIListLayout", sidebar)
sideList.Padding = UDim.new(0,6)
sideList.FillDirection = Enum.FillDirection.Vertical
sideList.SortOrder = Enum.SortOrder.LayoutOrder

Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0,10)

--=========================================================
-- CONTENT PANEL
--=========================================================
local content = Instance.new("ScrollingFrame", main)
content.Name = "Content"
content.ZIndex = 2
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

--=========================================================
-- UI BUILD FUNCTIONS
--=========================================================
local function Clear()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") then
            if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                v:Destroy()
            end
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
    b.ZIndex = 10
    b.Size = UDim2.new(1,-20,0,30)
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
    b.ZIndex = 10
    b.Size = UDim2.new(1,-14,0,28)
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
        for i=1,35 do
            task.wait(.03)
            box.BackgroundTransparency += .02
            txt.TextTransparency += .02
        end
        box:Destroy()
    end)
end

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

local UI = _G.UI
local Core = _G.FishCore

--=========================================================
-- AUTO TAB
--=========================================================
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

--=========================================================
-- SPOTS TAB
--=========================================================
UI.SideButton("Spots", function()
    UI.Clear()
    UI.Label("Teleport Spots")

    for _,spot in ipairs(Core.Spots) do
        UI.ContentButton(spot.Name, function()
            local char = LP.Character or LP.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = spot.CFrame + Vector3.new(0,4,0)
            UI.Notify("Teleported: " .. spot.Name)
        end)
    end
end)

--=========================================================
-- PLAYERS TAB
--=========================================================
UI.SideButton("Players", function()

    local function build()
        UI.Clear()
        UI.Label("Teleport Players")
        UI.Content.CanvasSize = UDim2.new(0,0,0,0)

        UI.ContentButton("🔄 Refresh", function()
            build()
        end)

        for _,plr in ipairs(Players:GetPlayers()) do
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

--=========================================================
-- SHOP TAB
--=========================================================
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

--=========================================================
-- MISC TAB (PERFORMANCE)
--=========================================================
UI.SideButton("Misc", function()
    UI.Clear()
    UI.Label("Performance & Utility")

    local lowPerf = false
    local ultra = false

    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    UI.ContentButton("Low Performance: OFF", function(btn)
        lowPerf = not lowPerf
        if lowPerf then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
        end
        btn.Text = "Low Performance: " .. (lowPerf and "ON" or "OFF")
    end)

    UI.ContentButton("ULTRA Low Performance: OFF", function(btn)
        ultra = not ultra
        if ultra then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
        end
        btn.Text = "ULTRA Low Performance: " .. (ultra and "ON" or "OFF")
    end)
end)

--=========================================================
-- SYSTEM TAB
--=========================================================
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
--=========================================================
-- FLOAT BUTTON
--=========================================================
local floatBtn = Instance.new("ImageButton", gui)
floatBtn.Size = UDim2.new(0,48,0,48)
floatBtn.Position = UDim2.new(0.03,0,0.45,0)
floatBtn.Image = "rbxassetid://72407089659970"
floatBtn.BackgroundColor3 = Color3.fromRGB(0,140,180)
floatBtn.BorderSizePixel = 0
floatBtn.Draggable = true
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0,12)

local visible = true
floatBtn.MouseButton1Click:Connect(function()
    visible = not visible
    main.Visible = visible
end)

--=========================================================
-- LIVE PING LABEL
--=========================================================
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
        pingLabel.TextColor3 =
            p <= 80 and Color3.fromRGB(0,255,120)
        or (p <= 150 and Color3.fromRGB(255,200,0))
        or Color3.fromRGB(255,80,80)
    end
end)

--=========================================================
-- RESIZE HANDLE
--=========================================================
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

--=========================================================
-- AUTO OPEN DEFAULT TAB
--=========================================================
task.delay(.2, function()
    for _,btn in ipairs(sidebar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.MouseButton1Click:Fire()
            break
        end
    end
end)

--=========================================================
-- SAFE EXIT
--=========================================================
local function safeShutdown()
    _G.FishItWORK = false
    pcall(function()
        gui:Destroy()
    end)
end
_G.FISHIT_SHUTDOWN = safeShutdown
