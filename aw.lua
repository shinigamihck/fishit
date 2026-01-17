-- ==========================================
--  SANZHUY CUSTOM ORION UI (LOCAL VERSION)
--  100% DELTA COMPATIBLE
--  STYLE A — ORION KLASIK (SIDEBAR + TABS)
-- ==========================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Hapus UI lama
pcall(function()
    if PlayerGui:FindFirstChild("SanzhuyUI") then
        PlayerGui:FindFirstChild("SanzhuyUI"):Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "SanzhuyUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- === MAIN WINDOW ===
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 600, 0, 380)
main.Position = UDim2.new(0.5, -300, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 150, 255)
stroke.Thickness = 2
stroke.Transparency = 0.4

-- === SIDEBAR ===
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 150, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout", sidebar)
listLayout.Padding = UDim.new(0, 5)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Title
local title = Instance.new("TextLabel", sidebar)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "SANZHUY HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0, 160, 255)

-- === CONTENT AREA ===
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0, 155, 0, 0)
content.Size = UDim2.new(1, -160, 1, 0)
content.BackgroundColor3 = Color3.fromRGB(25, 25, 32)

Instance.new("UICorner", content).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- TAB CREATOR
-- ==========================================

local Tabs = {}
local CurrentTab = nil

function CreateTab(name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.TextColor3 = Color3.fromRGB(200, 200, 255)

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local tabFrame = Instance.new("Frame", content)
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false

    local layout = Instance.new("UIListLayout", tabFrame)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    Tabs[name] = tabFrame

    btn.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Visible = false
        end
        CurrentTab = tabFrame
        CurrentTab.Visible = true
    end)

    if not CurrentTab then
        CurrentTab = tabFrame
        CurrentTab.Visible = true
    end

    return tabFrame
end

-- ==========================================
-- ELEMENT MAKERS (Toggle, Button, Slider)
-- ==========================================

function MakeButton(parent, name, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 250, 0, 32)
    b.Text = name
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    b.TextColor3 = Color3.fromRGB(220, 220, 255)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.MouseButton1Click:Connect(function()
        callback()
    end)
end

function MakeToggle(parent, name, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0, 250, 0, 30)
    frame.BackgroundTransparency = 1

    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(0.7, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.Font = Enum.Font.Gotham
    text.TextSize = 13
    text.TextColor3 = Color3.fromRGB(200, 200, 255)

    local btn = Instance.new("TextButton", frame)
    btn.Position = UDim2.new(0.7, 0, 0, 0)
    btn.Size = UDim2.new(0.3, -5, 1, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(60, 60, 80)
    btn.Text = default and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = default

    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)

        if state then
            btn.Text = "ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
end

function MakeSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0, 250, 0, 40)
    frame.BackgroundTransparency = 1

    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(1, 0, 0, 15)
    text.BackgroundTransparency = 1
    text.Text = name .. ": " .. tostring(default)
    text.Font = Enum.Font.Gotham
    text.TextColor3 = Color3.fromRGB(200, 200, 255)
    text.TextSize = 12

    local bar = Instance.new("Frame", frame)
    bar.Position = UDim2.new(0, 0, 0, 18)
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local dragging = false

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            text.Text = name .. ": " .. val
            callback(val)
        end
    end)
end

print("CUSTOM ORION UI LOADED ✓")
-- ==========================================
-- PART 2 — BUILD ALL ORION TABS & ELEMENTS
-- ==========================================

-- TAB LIST:
local TabMain     = CreateTab("Main")
local TabFarm     = CreateTab("Farm")
local TabUtility  = CreateTab("Utility")
local TabShop     = CreateTab("Shop")
local TabMisc     = CreateTab("Misc")
local TabTeleport = CreateTab("Teleport")

-- =====================================================
-- MAIN TAB
-- =====================================================

MakeToggle(TabMain, "Auto Fish", false, function(v)
    AutoFish = v
end)

MakeToggle(TabMain, "Auto Sell", false, function(v)
    AutoSell = v
end)

MakeToggle(TabMain, "Auto Weather", false, function(v)
    AutoWeather = v
end)

MakeSlider(TabMain, "Sell Interval", 1, 30, SellInterval, function(v)
    SellInterval = v
end)


-- =====================================================
-- FARM TAB
-- =====================================================

MakeSlider(TabFarm, "Fishing Delay", 0.05, 0.3, FishDelay, function(v)
    FishDelay = v
end)

MakeToggle(TabFarm, "Clean Fish UI (FPS Boost)", true, function(v)
    _G.CLEAN_FISH_UI = v
end)


-- =====================================================
-- UTILITY TAB
-- =====================================================

MakeToggle(TabUtility, "Fly", false, function(v)
    FlyEnabled = v
    if v then
        startFly()
    else
        stopFly()
    end
end)

MakeSlider(TabUtility, "Fly Speed", 50, 800, FlySpeed, function(v)
    FlySpeed = v
end)


-- =====================================================
-- SHOP TAB
-- =====================================================

MakeToggle(TabShop, "Auto Totem", false, function(v)
    AUTO_TOTEM = v
end)

MakeButton(TabShop, "Toggle Merchant Window", function()
    local gui = LP.PlayerGui:FindFirstChild("Merchant")
    if gui then
        gui.Enabled = not gui.Enabled
    end
end)


-- =====================================================
-- MISC TAB
-- =====================================================

MakeToggle(TabMisc, "Anti AFK", true, function(v)
    _G.ANTI_AFK = v
end)

MakeButton(TabMisc, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

MakeButton(TabMisc, "Hide / Show UI", function()
    gui.Enabled = not gui.Enabled
end)

MakeButton(TabMisc, "Unload Script", function()
    AutoFish = false
    AutoSell = false
    AutoWeather = false
    AUTO_TOTEM = false
    FlyEnabled = false
    pcall(stopFly)
    gui:Destroy()
    _G.FishItWORK = false
end)


-- =====================================================
-- TELEPORT TAB
-- =====================================================

MakeButton(TabTeleport, "Refresh Player List", function()
    for _,obj in ipairs(TabTeleport:GetChildren()) do
        if obj:IsA("TextButton") then obj:Destroy() end
    end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            MakeButton(TabTeleport, "To " .. plr.Name, function()
                local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local him = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if my and him then
                    my.CFrame = him.CFrame * CFrame.new(0,0,-3)
                end
            end)
        end
    end
end)

-- TELEPORT SPOTS (nanti di PART 3 lengkap)
-- ==========================================
-- PART 3 — LOGIC FULL SYSTEM
-- ==========================================

local TeleportService = game:GetService("TeleportService")

-- =====================================================
-- TELEPORT SPOT LIST
-- =====================================================

local Locations = {
    { Name = "Ancient Jungle", CFrame = CFrame.new(1562.54, 6.62, -233.16) },
    { Name = "Ancient Ruin", CFrame = CFrame.new(6076.29, -585.92, 4625.92) },
    { Name = "Coral Reefs", CFrame = CFrame.new(-2752.80, 4, 2165.78) },
    { Name = "Crater Island", CFrame = CFrame.new(1027.12, 2.89, 5148.10) },
    { Name = "Fisherman Island", CFrame = CFrame.new(73.35, 9.53, 2709.50) },
    { Name = "Kohana", CFrame = CFrame.new(-595.69, 19.25, 429.86) },
    { Name = "Pirate Cove", CFrame = CFrame.new(3398.70, 10.34, 3491.11) },
    { Name = "Treasure Room", CFrame = CFrame.new(-3597.20, -280.11, -1633.28) },
    { Name = "Tropical Grove", CFrame = CFrame.new(-2128.62, 53.48, 3637.66) },
    { Name = "Weather Machine", CFrame = CFrame.new(-1527.67, 2.87, 1914.66) },
}

-- Tambahkan ke TabTeleport
for _,spot in ipairs(Locations) do
    MakeButton(TabTeleport, spot.Name, function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = spot.CFrame + Vector3.new(0,5,0)
        end
    end)
end


-- =====================================================
-- AUTO FISH
-- =====================================================

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


-- =====================================================
-- AUTO SELL
-- =====================================================

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



-- =====================================================
-- AUTO WEATHER
-- =====================================================

task.spawn(function()
    local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")
    local WeatherList = { "Storm", "Cloudy", "Wind" }

    while _G.FishItWORK do
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



-- =====================================================
-- FLY SYSTEM AUTO FIX
-- =====================================================

task.spawn(function()
    while _G.FishItWORK do
        task.wait(0.15)
        if FlyEnabled and (not bv or not bg) then
            startFly()
        end
    end
end)



-- =====================================================
-- CLEAN FISH UI (FPS BOOST)
-- =====================================================

local function shouldHideLabel(label)
    if not label:IsA("TextLabel") then return false end
    if not label.Text then return false end

    local t = label.Text:lower()

    if t:match("^you%s+got") then return false end
    if t:match("%d+%.?%d*%s*kg") then return true end
    if t:match("lvl") then return true end
    if t:match("^1%s+in") then return true end

    if label.TextSize >= 26 then
        local y = label.AbsolutePosition.Y
        local cy = workspace.CurrentCamera.ViewportSize.Y

        if y > cy*0.2 and y < cy*0.65 then
            return true
        end
    end
    return false
end

task.spawn(function()
    while _G.FishItWORK do
        task.wait(1.3)
        if not _G.CLEAN_FISH_UI then continue end

        local pg = LP:FindFirstChild("PlayerGui")
        if not pg then continue end

        local f = pg:FindFirstChild("FishingUI")
        if not f then continue end

        for _,v in ipairs(f:GetDescendants()) do
            if shouldHideLabel(v) then
                v.Visible = false
            end
        end
    end
end)



-- =====================================================
-- AUTO TOTEM SYSTEM
-- =====================================================

local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")

local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local EquipTool = Net:RemoteEvent("EquipToolFromHotbar")

local COOLDOWN = 0
local retryWait = false
local RETRY_TIME = 300

local function GetTotemUUID()
    local inv = Data:Get({"Inventory", "Totems"})
    if inv and inv[1] then
        return inv[1].UUID
    end
    return nil
end

-- Auto Equip Rod
task.spawn(function()
    while _G.FishItWORK do
        task.wait(2.5)

        if AUTO_TOTEM then
            pcall(function()
                EquipTool:FireServer(1)
            end)
        end
    end
end)

TotemSpawned.OnClientEvent:Connect(function()
    COOLDOWN = 3600
end)

-- Totem Loop
task.spawn(function()
    while _G.FishItWORK do
        task.wait(1)

        if not AUTO_TOTEM then continue end

        if COOLDOWN > 0 then
            COOLDOWN -= 1
            continue
        end

        if retryWait and os.clock() < retryWait then continue end

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
        task.wait(0.6)

        if conn then conn:Disconnect() end

        if not success then
            retryWait = os.clock() + RETRY_TIME
        end
    end
end)


print("PART 3 LOADED ✓ — All Logic Active")
