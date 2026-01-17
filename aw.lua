--====================================================
-- FISHIT HUB — FULL FINAL CLEAN VERSION
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
local VirtualUser = game:GetService("VirtualUser")

------------------------------------------------------
-- NET / DATA
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
-- STATE
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
-- ANTI AFK
------------------------------------------------------
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

------------------------------------------------------
-- FISHING CONTROLLER
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

------------------------------------------------------
-- UI SETUP
------------------------------------------------------
pcall(function()
    LP.PlayerGui:FindFirstChild("FishItHubUI"):Destroy()
end)

local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "FishItHubUI"
gui.ResetOnSpawn = false

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 14

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

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke", main).Transparency = 0.75

------------------------------------------------------
-- TITLE BAR
------------------------------------------------------
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,36)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Text = "FishIt Hub — Final Clean"
title.Size = UDim2.new(1,-40,1,0)
title.Position = UDim2.new(0,14,0,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = THEME.TEXT
title.BackgroundTransparency = 1
title.TextXAlignment = Left

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

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0,6)
sideLayout.HorizontalAlignment = Center

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
    f.Visible = false
    f.BackgroundTransparency = 1
    Instance.new("UIListLayout", f).Padding = UDim.new(0,10)
    Pages[name] = f
    return f
end

local function switchPage(name)
    for n,p in pairs(Pages) do
        p.Visible = (n == name)
    end
end

------------------------------------------------------
-- TOGGLE BUILDER (WAJIB DI ATAS)
------------------------------------------------------
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,260,0,32)
    btn.Text = text.." : OFF"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = THEME.TEXT
    btn.BackgroundColor3 = THEME.BUTTON
    btn.BackgroundTransparency = 0.25
    Instance.new("UICorner", btn)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." : "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and THEME.ACTIVE or THEME.BUTTON
        callback(state)
    end)
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
-- MAIN TOGGLES
------------------------------------------------------
createToggle(MainPage,"Auto Fish",function(v) AutoFish=v end)
createToggle(MainPage,"Auto Sell",function(v) AutoSell=v end)
createToggle(MainPage,"Auto Weather",function(v) AutoWeather=v end)
createToggle(MainPage,"Fly",function(v)
    FlyEnabled=v
    if v then _G.StartFly() else _G.StopFly() end
end)
createToggle(MainPage,"Auto Totem",function(v) AUTO_TOTEM=v end)

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
    Instance.new("UICorner", b)

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
                        workspace.CurrentCamera.ViewportSize/2,true)
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
        if AutoSell then pcall(function() sellRF:InvokeServer() end) end
    end
end)

------------------------------------------------------
-- AUTO WEATHER LOOP
------------------------------------------------------
task.spawn(function()
    while _G.FishItHubLoaded do
        task.wait(WeatherDelay)
        if AutoWeather then
            for _,w in ipairs({"Storm","Cloudy","Wind"}) do
                pcall(function() purchaseRF:InvokeServer(w) end)
                task.wait(1.3)
            end
        end
    end
end)

------------------------------------------------------
-- FLY ENGINE
------------------------------------------------------
local flyConn,bv,bg
function _G.StopFly()
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

function _G.StartFly()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    bg = Instance.new("BodyGyro",hrp)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)

    bv = Instance.new("BodyVelocity",hrp)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)

    flyConn = RS.RenderStepped:Connect(function()
        if not FlyEnabled then return end
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move+=Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move-=Vector3.yAxis end
        bv.Velocity = move.Magnitude>0 and move.Unit*FlySpeed or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end

print("✅ FishIt Hub FULL FINAL CLEAN loaded")
