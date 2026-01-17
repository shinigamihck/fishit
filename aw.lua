--====================================================
-- CLEAN MODERN MINIMAL UI — CORE SYSTEM ONLY
--====================================================

if _G.TabHubLoaded then return end
_G.TabHubLoaded = true

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")

------------------------------------------------------
-- REMOVE OLD UI
------------------------------------------------------
pcall(function()
    LP.PlayerGui:FindFirstChild("TabHubUI"):Destroy()
end)

------------------------------------------------------
-- SCREEN GUI
------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "TabHubUI"
gui.ResetOnSpawn = false
gui.Parent = LP.PlayerGui


------------------------------------------------------
-- GLASS BLUR EFFECT (SAFE)
------------------------------------------------------

local Lighting = game:GetService("Lighting")

local blur = Instance.new("BlurEffect")
blur.Name = "TabHubBlur"
blur.Size = 14
blur.Parent = Lighting


------------------------------------------------------
-- THEME : GLASS / FROSTED
------------------------------------------------------
local THEME = {
    BG = Color3.fromRGB(18, 18, 22),
    PANEL = Color3.fromRGB(25, 25, 30),
    BUTTON = Color3.fromRGB(35, 35, 40),
    BUTTON_ACTIVE = Color3.fromRGB(80, 160, 255),
    TEXT = Color3.fromRGB(235, 235, 245),
    TEXT_DIM = Color3.fromRGB(160,160,170),
    BORDER = Color3.fromRGB(255,255,255),
}


------------------------------------------------------
-- MAIN FRAME
------------------------------------------------------
local main = Instance.new("Frame", gui)
main.Name = "MainWindow"
main.Size = UDim2.new(0, 580, 0, 360)
main.Position = UDim2.new(0.5, -290, 0.4, -180)
main.BackgroundTransparency = 0.15
main.BackgroundColor3 = THEME.BG
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", main)
stroke.Color = THEME.BORDER
stroke.Thickness = 1
stroke.Transparency = 0.75



------------------------------------------------------
-- TITLE BAR
------------------------------------------------------
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.Text = "FishIt Hub — Minimal"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = THEME.TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1

local close = Instance.new("TextButton", titleBar)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -34, 0, 3)
close.Text = "×"
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.TextColor3 = THEME.TEXT
close.BackgroundTransparency = 1

close.MouseButton1Click:Connect(function()
    _G.TabHubLoaded = false
    if blur then blur:Destroy() end
    gui:Destroy()
end)


------------------------------------------------------
-- LEFT SIDEBAR
------------------------------------------------------
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 130, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundTransparency = 0.2
sidebar.BackgroundColor3 = THEME.PANEL
sidebar.BorderSizePixel = 0

local sideCorner = Instance.new("UICorner", sidebar)
sideCorner.CornerRadius = UDim.new(0, 8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.FillDirection = Enum.FillDirection.Vertical
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder


------------------------------------------------------
-- PAGES CONTAINER
------------------------------------------------------
local pages = Instance.new("Frame", main)
pages.Size = UDim2.new(1, -150, 1, -40)
pages.Position = UDim2.new(0, 150, 0, 40)
pages.BackgroundTransparency = 1


------------------------------------------------------
-- PAGE SYSTEM
------------------------------------------------------
local PageList = {}
local function createPage(name)
    local f = Instance.new("Frame", pages)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundTransparency = 1
    f.Visible = false

    -- auto layout inside pages
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0,10)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    PageList[name] = f
    return f
end

local function switchPage(name)
    for n,p in pairs(PageList) do
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
    b.Size = UDim2.new(1, -20, 0, 32)
    b.Text = name
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextColor3 = THEME.TEXT
    b.BackgroundColor3 = THEME.BUTTON
    b.BackgroundTransparency = 0.25

    local bc = Instance.new("UICorner", b)
    bc.CornerRadius = UDim.new(0,6)

    local bs = Instance.new("UIStroke", b)
    bs.Color = Color3.fromRGB(255,255,255)
    bs.Transparency = 0.85
    bs.Thickness = 1

    b.MouseButton1Click:Connect(function()
        for _,x in ipairs(sidebar:GetChildren()) do
            if x:IsA("TextButton") then
                x.BackgroundColor3 = THEME.BUTTON
                x.BackgroundTransparency = 0.25
            end
        end

        b.BackgroundColor3 = THEME.BUTTON_ACTIVE
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
-- UNIVERSAL TOGGLE CREATOR (MINIMAL)
------------------------------------------------------
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0, 250, 0, 32)
    btn.BackgroundTransparency = 0.25
    btn.BackgroundColor3 = THEME.BUTTON
    btn.Text = text .. " : OFF"
    btn.TextColor3 = THEME.TEXT
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12

    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0,6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and THEME.BUTTON_ACTIVE or THEME.BUTTON
        callback(state)
    end)
end



------------------------------------------------------
-- FLOATING BUTTON (MINIMAL)
------------------------------------------------------
local floatBtn = Instance.new("ImageButton", gui)
floatBtn.Size = UDim2.new(0, 46, 0, 46)
floatBtn.Position = UDim2.new(0.03,0,0.4,0)
floatBtn.Image = "rbxassetid://72407089659970"
floatBtn.BackgroundColor3 = Color3.fromRGB(120,160,255)
floatBtn.BackgroundTransparency = 0.25
floatBtn.Active = true
floatBtn.Draggable = true
floatBtn.BorderSizePixel = 0

local fc = Instance.new("UICorner", floatBtn)
fc.CornerRadius = UDim.new(0,12)

local fs = Instance.new("UIStroke", floatBtn)
fs.Color = Color3.fromRGB(255,255,255)
fs.Transparency = 0.6
fs.Thickness = 1



local hubVisible = true
floatBtn.MouseButton1Click:Connect(function()
    hubVisible = not hubVisible
    main.Visible = hubVisible
end)

print("UI FRAMEWORK: Minimal Clean Loaded ✓")

------------------------------------------------------
-- ENGINE STATE (terhubung ke toggle UI)
------------------------------------------------------
local AutoFish = false
local AutoSell = false
local AutoWeather = false
local FlyEnabled = false
local FlySpeed = 80
local AUTO_TOTEM = false

local SellInterval = 5
local WeatherDelay = 5

------------------------------------------------------
-- CONNECT TOGGLE BUTTONS KE PAGE
------------------------------------------------------

-- MAIN PAGE
createToggle(MainPage, "Auto Fish", function(v)
    AutoFish = v
end)

createToggle(MainPage, "Auto Sell", function(v)
    AutoSell = v
end)

createToggle(MainPage, "Auto Weather", function(v)
    AutoWeather = v
end)


-- MISC PAGE
createToggle(MiscPage, "Fly", function(v)
    FlyEnabled = v
    if v then startFly() else stopFly() end
end)

createToggle(MiscPage, "Auto Totem", function(v)
    AUTO_TOTEM = v
end)


------------------------------------------------------
-- PLAYER PAGE — PLAYER TELEPORT LIST
------------------------------------------------------
local playerScroll = Instance.new("ScrollingFrame", PlayerPage)
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.CanvasSize = UDim2.new(0,0,0,0)
playerScroll.Size = UDim2.new(1,-20,1,-20)
playerScroll.Position = UDim2.new(0,10,0,10)
playerScroll.ScrollBarThickness = 4
playerScroll.BackgroundTransparency = 1

local plLayout = Instance.new("UIListLayout", playerScroll)
plLayout.Padding = UDim.new(0,8)

local function refreshPlayers()
    for _,v in ipairs(playerScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local b = Instance.new("TextButton", playerScroll)
            b.Size = UDim2.new(0, 260, 0, 30)
            b.Text = plr.Name
            b.Font = Enum.Font.Gotham
            b.TextColor3 = THEME.TEXT
            b.BackgroundColor3 = THEME.BUTTON

            local c = Instance.new("UICorner", b)
            c.CornerRadius = UDim.new(0,6)

            b.MouseButton1Click:Connect(function()
                local myhrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local tar = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if myhrp and tar then
                    myhrp.CFrame = tar.CFrame * CFrame.new(0,0,-3)
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()


------------------------------------------------------
-- SPOT PAGE — TELEPORT SPOTS
------------------------------------------------------
local spotScroll = Instance.new("ScrollingFrame", SpotPage)
spotScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
spotScroll.CanvasSize = UDim2.new(0,0,0,0)
spotScroll.Size = UDim2.new(1,-20,1,-20)
spotScroll.Position = UDim2.new(0,10,0,10)
spotScroll.ScrollBarThickness = 4
spotScroll.BackgroundTransparency = 1

local spLayout = Instance.new("UIListLayout", spotScroll)
spLayout.Padding = UDim.new(0,8)

local Spots = {
    {Name="Kohana", CFrame=CFrame.new(-595,19,429)},
    {Name="Pirate Cove", CFrame=CFrame.new(3398,10,3491)},
    {Name="Ancient Jungle", CFrame=CFrame.new(1562,6,-233)},
    {Name="Crater Island", CFrame=CFrame.new(1027,3,5148)},
    {Name="Coral Reefs", CFrame=CFrame.new(-2752,4,2165)},
}

for _,spot in ipairs(Spots) do
    local b = Instance.new("TextButton", spotScroll)
    b.Size = UDim2.new(0, 260, 0, 30)
    b.Text = spot.Name
    b.Font = Enum.Font.Gotham
    b.TextColor3 = THEME.TEXT
    b.BackgroundColor3 = THEME.BUTTON

    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0,6)

    b.MouseButton1Click:Connect(function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = spot.CFrame + Vector3.new(0,4,0)
        end
    end)
end


------------------------------------------------------
-- FLY ENGINE MINIMAL
------------------------------------------------------
local UIS = game:GetService("UserInputService")
local flyConn
local bv, bg

function stopFly()
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

function startFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    stopFly()

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.P = 8000
    bg.CFrame = hrp.CFrame

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Velocity = Vector3.zero

    flyConn = RunService.RenderStepped:Connect(function()
    
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


LP.CharacterAdded:Connect(function()
    task.wait(0.3)
    stopFly()
end)


------------------------------------------------------
-- AUTO FISH ENGINE
------------------------------------------------------
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

task.spawn(function()
    while _G.TabHubLoaded do
        task.wait(0.13)

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
-- AUTO SELL ENGINE
------------------------------------------------------
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")

task.spawn(function()
    while _G.TabHubLoaded do
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
local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")
local WeatherList = {"Storm", "Cloudy", "Wind"}

task.spawn(function()
    while _G.TabHubLoaded do
        task.wait(WeatherDelay)

        if AutoWeather then
            for _,weather in ipairs(WeatherList) do
                pcall(function()
                    purchaseRF:InvokeServer(weather)
                end)
                task.wait(1.2)
            end
        end
    end
end)


------------------------------------------------------
-- AUTO TOTEM ENGINE
------------------------------------------------------
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
    return nil
end

TotemSpawned.OnClientEvent:Connect(function()
    COOLDOWN = 3600
    task.wait(0.3)
    pcall(function()
        EquipToolFromHotbar:FireServer(1)
    end)
end)

task.spawn(function()
    while _G.TabHubLoaded do
        task.wait(1)

        if not AUTO_TOTEM then continue end
        if COOLDOWN > 0 then COOLDOWN-=1 continue end

        if retryWait and os.clock() < retryWait then continue end
        retryWait = false

        local uuid = GetTotemUUID()
        if not uuid then task.wait(5) continue end

        local success = false
        local conn

        conn = TotemSpawned.OnClientEvent:Connect(function()
            success = true
            conn:Disconnect()
        end)

        SpawnTotem:FireServer(uuid)
        task.wait(0.4)

        if conn then conn:Disconnect() end
        if not success then retryWait = os.clock() + TRY_INTERVAL end
    end
end)


------------------------------------------------------
-- CLEAN FISHING UI
------------------------------------------------------
task.spawn(function()
    local pg = LP:WaitForChild("PlayerGui")

    local function shouldHide(label)
        if not label:IsA("TextLabel") then return false end
        if not label.Text or label.Text == "" then return false end

        local txt = label.Text:lower()
        if txt:match("^%s*you%s+got%s*:") then return false end
        if txt:match("^1%s+in%s+%d+") then return true end
        if txt:find("kg") then return true end
        if txt:find("lvl") then return true end
        if label.TextSize >= 26 then return true end

        return false
    end

    while _G.TabHubLoaded do
        task.wait(2)
        local fishUI = pg:FindFirstChild("FishingUI")
        if not fishUI then continue end

        for _,obj in ipairs(fishUI:GetDescendants()) do
            if shouldHide(obj) then obj.Visible = false end
        end
    end
end)


------------------------------------------------------
-- LOW GFX SAFE MODE
------------------------------------------------------
task.spawn(function()
    local Lighting = game:GetService("Lighting")

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
        or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect")
        or v:IsA("ColorCorrectionEffect") then
            v.Enabled = false
        end
    end
end)


------------------------------------------------------
-- REAL PING MONITOR
------------------------------------------------------
task.spawn(function()
    local Stats = game:GetService("Stats")

    local pingLabel = Instance.new("TextLabel", gui)
    pingLabel.Size = UDim2.new(0,140,0,20)
    pingLabel.Position = UDim2.new(1,-150,1,-30)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Font = Enum.Font.Gotham
    pingLabel.TextSize = 12
    pingLabel.TextColor3 = THEME.TEXT_DIM
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

    while _G.TabHubLoaded do
        task.wait(1)

        local p = getPing()
        if not p then
            pingLabel.Text = "Ping: --"
        else
            pingLabel.Text = string.format("Ping: %.1f ms", p)
        end
    end
end)

