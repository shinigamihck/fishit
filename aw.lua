-- =========================================================
-- FISH IT | FINAL DARK UI (HOHO STYLE)
-- FILE: PART 1 / UI SKELETON
-- =========================================================

if _G.__FISH_UI_INIT then return end
_G.__FISH_UI_INIT = true

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local pg = LP:WaitForChild("PlayerGui")

local Core = _G.FishCore
if not Core then
    warn("FishCore not found")
    return
end

-- CLEAN OLD UI
pcall(function()
    local old = pg:FindFirstChild("FishItUI")
    if old then old:Destroy() end
end)

-- =========================================================
-- SCREEN GUI
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FishItUI"
gui.ResetOnSpawn = false
gui.Parent = pg

-- =========================================================
-- THEME (DARK)
-- =========================================================
local THEME = {
    BG_MAIN = Color3.fromRGB(18,18,22),
    BG_SIDE = Color3.fromRGB(24,24,30),
    BG_PANEL = Color3.fromRGB(32,32,40),
    BTN = Color3.fromRGB(42,42,54),
    BTN_HOVER = Color3.fromRGB(52,52,66),
    TEXT = Color3.fromRGB(230,230,255),
    SUBTEXT = Color3.fromRGB(180,180,200),
    ACCENT = Color3.fromRGB(0,170,255)
}

-- =========================================================
-- NOTIFICATION SYSTEM
-- =========================================================
local function notify(msg)
    local box = Instance.new("Frame", gui)
    box.Size = UDim2.new(0,240,0,38)
    box.Position = UDim2.new(1,-260,1,-90)
    box.BackgroundColor3 = Color3.fromRGB(25,25,30)
    box.BackgroundTransparency = 0.05
    box.ZIndex = 100
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

    local txt = Instance.new("TextLabel", box)
    txt.Size = UDim2.new(1,-12,1,0)
    txt.Position = UDim2.new(0,12,0,0)
    txt.BackgroundTransparency = 1
    txt.Text = msg
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 13
    txt.TextColor3 = THEME.TEXT
    txt.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        for i = 1,40 do
            task.wait(0.03)
            box.BackgroundTransparency += 0.02
            txt.TextTransparency += 0.02
        end
        box:Destroy()
    end)
end

-- =========================================================
-- MAIN WINDOW
-- =========================================================
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(640,380)
main.Position = UDim2.new(0.5,-320,0.5,-190)
main.BackgroundColor3 = THEME.BG_MAIN
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

-- ==============================================
-- RESIZE HANDLE (DRAG TO RESIZE MAIN PANEL)
-- ==============================================
local UserInputService = game:GetService("UserInputService")
local resizing = false
local startPos
local startSize

-- Handle kecil di bawah panel
local handle = Instance.new("Frame", main)
handle.Size = UDim2.new(1, 0, 0, 12)
handle.Position = UDim2.new(0, 0, 1, -12)
handle.BackgroundColor3 = Color3.fromRGB(40,40,50)
handle.BackgroundTransparency = 0.3
Instance.new("UICorner", handle).CornerRadius = UDim.new(0,6)

handle.InputBegan:Connect(function(input)
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
        
        -- Resize VERTICAL ONLY
        main.Size = UDim2.new(startSize.X.Scale, startSize.X.Offset,
                              startSize.Y.Scale, startSize.Y.Offset + dy)
    end
end)



local stroke = Instance.new("UIStroke", main)
stroke.Color = THEME.ACCENT
stroke.Thickness = 1
stroke.Transparency = 0.6

-- =========================================================
-- SIDEBAR
-- =========================================================
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,150,1,0)
sidebar.BackgroundColor3 = THEME.BG_SIDE
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,10)

local sideList = Instance.new("UIListLayout", sidebar)
sideList.Padding = UDim.new(0,6)
Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0,10)

-- =========================================================
-- CONTENT PANEL
-- =========================================================
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,160,0,10)
content.Size = UDim2.new(1,-170,1,-20)
content.BackgroundColor3 = THEME.BG_PANEL
Instance.new("UICorner", content).CornerRadius = UDim.new(0,10)

local contentList = Instance.new("UIListLayout", content)
contentList.Padding = UDim.new(0,8)
Instance.new("UIPadding", content).PaddingTop = UDim.new(0,10)

-- =========================================================
-- CONTENT UTILS
-- =========================================================
local function clearContent()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
end

local function label(text)
    local l = Instance.new("TextLabel", content)
    l.Size = UDim2.new(1,-20,0,24)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextColor3 = THEME.TEXT
end

local function contentButton(text, callback)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1,-20,0,36)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextColor3 = THEME.TEXT
    b.BackgroundColor3 = THEME.BTN
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = THEME.BTN_HOVER
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = THEME.BTN
    end)

    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
end

local function sideButton(name, build)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1,-12,0,34)
    b.Text = name
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextColor3 = THEME.TEXT
    b.BackgroundColor3 = THEME.BTN
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    b.MouseButton1Click:Connect(function()
        clearContent()
        build()
    end)
end

-- =========================================================
-- FLOATING TOGGLE (ASSET KAMU)
-- =========================================================
local floatBtn = Instance.new("ImageButton", gui)
floatBtn.Size = UDim2.new(0,48,0,48)
floatBtn.Position = UDim2.new(0.03,0,0.45,0)
floatBtn.Image = "rbxassetid://72407089659970"
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
-- PLACEHOLDER TABS (LOGIC MASUK DI PART 2)
-- =========================================================
sideButton("Auto", function()
    label("Auto Features")
    label("Loading...")
end)

sideButton("Spots", function()
    label("Teleport Spots")
    label("Loading...")
end)

sideButton("Players", function()
    label("Players")
    label("Loading...")
end)

sideButton("Shop", function()
    label("Shop & Totem")
    label("Loading...")
end)

sideButton("Misc", function()
    label("Performance")
    label("Loading...")
end)

sideButton("System", function()
    label("System")
    label("Loading...")
end)

-- OPEN DEFAULT
sidebar:GetChildren()[3].MouseButton1Click:Fire()

-- EXPORT UI HELPERS FOR PART 2
_G.__FISH_UI = {
    Notify = notify,
    SideButton = sideButton,
    ContentButton = contentButton,
    Label = label,
    Clear = clearContent,
    Theme = THEME,
    Content = content,
    Main = main
}
-- =========================================================
-- AUTO TAB (AutoFish, AutoSell, AutoWeather)
-- =========================================================

UI.SideButton("Auto", function()
    UI.Clear()
    UI.Label("Auto Features")

    local autoFish = false
    local autoSell = false
    local autoWeather = false

    -- AUTO FISH
    UI.ContentButton("Auto Fish: OFF", function(btn)
        autoFish = not autoFish
        Core.AutoFish(autoFish)
        btn.Text = "Auto Fish: " .. (autoFish and "ON" or "OFF")
        UI.Notify("Auto Fish: " .. (autoFish and "ON" or "OFF"))
    end)

    -- AUTO SELL
    UI.ContentButton("Auto Sell: OFF", function(btn)
        autoSell = not autoSell
        Core.AutoSell(autoSell)
        btn.Text = "Auto Sell: " .. (autoSell and "ON" or "OFF")
        UI.Notify("Auto Sell: " .. (autoSell and "ON" or "OFF"))
    end)

    -- AUTO WEATHER
    UI.ContentButton("Auto Weather: OFF", function(btn)
        autoWeather = not autoWeather
        Core.AutoWeather(autoWeather)
        btn.Text = "Auto Weather: " .. (autoWeather and "ON" or "OFF")
        UI.Notify("Auto Weather: " .. (autoWeather and "ON" or "OFF"))
    end)
end)
-- =========================================================
-- SPOTS TAB
-- =========================================================

UI.SideButton("Spots", function()
    UI.Clear()
    UI.Label("Teleport Spots")

    for _,spot in ipairs(Core.Spots) do
        UI.ContentButton(spot.Name, function()
            local char = LP.Character or LP.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = spot.CFrame + Vector3.new(0,4,0)
            UI.Notify("Teleported to: " .. spot.Name)
        end)
    end
end)
-- =========================================================
-- PLAYERS TAB
-- =========================================================

UI.SideButton("Players", function()
    local function build()
        UI.Clear()
        UI.Label("Teleport to Player")

        UI.ContentButton("🔄 Refresh List", function()
            build()
        end)

        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                UI.ContentButton(plr.Name, function()
                    local myChar = LP.Character or LP.CharacterAdded:Wait()
                    local hrp = myChar:WaitForChild("HumanoidRootPart")

                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                        UI.Notify("Teleported to " .. plr.Name)
                    end
                end)
            end
        end
    end

    build()
end)
-- =========================================================
-- SHOP TAB (Auto Totem)
-- =========================================================

UI.SideButton("Shop", function()
    UI.Clear()
    UI.Label("Shop & Totem")

    local autoTotem = false

    UI.ContentButton("Auto Totem: OFF", function(btn)
        autoTotem = not autoTotem
        Core.AutoTotem(autoTotem)
        btn.Text = "Auto Totem: " .. (autoTotem and "ON" or "OFF")
        UI.Notify("Auto Totem: " .. (autoTotem and "ON" or "OFF"))
    end)

    UI.ContentButton("Open Merchant UI", function()
        local m = LP.PlayerGui:FindFirstChild("Merchant")
        if m then
            m.Enabled = true
            task.delay(3, function()
                m.Enabled = false
            end)
        end
    end)
end)
-- =========================================================
-- MISC TAB (Performance)
-- =========================================================

UI.SideButton("Misc", function()
    UI.Clear()
    UI.Label("Performance & Utility")

    local lowPerf = false
    local function applyLow(state)
        lowPerf = state
        if state then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            local L = game:GetService("Lighting")
            L.GlobalShadows = false
            UI.Notify("Low Performance: ON")
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            local L = game:GetService("Lighting")
            L.GlobalShadows = true
            UI.Notify("Low Performance: OFF")
        end
    end

    UI.ContentButton("Low Performance: OFF", function(btn)
        lowPerf = not lowPerf
        applyLow(lowPerf)
        btn.Text = "Low Performance: " .. (lowPerf and "ON" or "OFF")
    end)
end)
-- =========================================================
-- SYSTEM TAB
-- =========================================================

local pingPanel

local function togglePingPanel()
    if pingPanel then
        pingPanel:Destroy()
        pingPanel = nil
        return
    end

    pingPanel = Instance.new("Frame", gui)
    pingPanel.Size = UDim2.new(0,180,0,60)
    pingPanel.Position = UDim2.new(1,-200,1,-120)
    pingPanel.BackgroundColor3 = UI.Theme.BG_SIDE
    Instance.new("UICorner", pingPanel).CornerRadius = UDim.new(0,10)

    local txt = Instance.new("TextLabel", pingPanel)
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.new(1,0,1,0)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 16
    txt.TextColor3 = UI.Theme.TEXT

    task.spawn(function()
        while pingPanel do
            task.wait(1)
            txt.Text = "Ping: " .. math.floor(Core.GetPing()) .. " ms"
        end
    end)
end

UI.SideButton("System", function()
    UI.Clear()
    UI.Label("System & Debug")

    UI.ContentButton("Show Ping Panel", function()
        togglePingPanel()
    end)

    UI.ContentButton("Rejoin Server", function()
        local tp = game:GetService("TeleportService")
        tp:Teleport(game.PlaceId, LP)
    end)

    UI.ContentButton("Close UI", function()
        _G.FishItWORK = nil
        gui:Destroy()
    end)
end)

-- =========================================================
-- FINAL LINKER (WAJIB)
-- =========================================================

local UI = _G.__FISH_UI
if not UI then
    warn("UI Core not loaded")
    return
end

------------------------------------------------------------
-- APPLY SIDEBAR TABS (RE-BIND, FIX URUTAN)
------------------------------------------------------------

-- === AUTO TAB ===
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
        UI.Notify("Auto Fish: " .. (autoFish and "ON" or "OFF"))
    end)

    UI.ContentButton("Auto Sell: OFF", function(btn)
        autoSell = not autoSell
        Core.AutoSell(autoSell)
        btn.Text = "Auto Sell: " .. (autoSell and "ON" or "OFF")
        UI.Notify("Auto Sell: " .. (autoSell and "ON" or "OFF"))
    end)

    UI.ContentButton("Auto Weather: OFF", function(btn)
        autoWeather = not autoWeather
        Core.AutoWeather(autoWeather)
        btn.Text = "Auto Weather: " .. (autoWeather and "ON" or "OFF"))
        UI.Notify("Auto Weather: " .. (autoWeather and "ON" or "OFF"))
    end)
end)

-- === SPOTS TAB ===
UI.SideButton("Spots", function()
    UI.Clear()
    UI.Label("Teleport Spots")

    for _,spot in ipairs(Core.Spots) do
        UI.ContentButton(spot.Name, function()
            local char = LP.Character or LP.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart").CFrame = spot.CFrame + Vector3.new(0,4,0)
            UI.Notify("Teleported to: " .. spot.Name)
        end)
    end
end)

-- === PLAYERS TAB ===
UI.SideButton("Players", function()
    local function build()
        UI.Clear()
        UI.Label("Teleport Players")

        UI.ContentButton("🔄 Refresh", build)

        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                UI.ContentButton(plr.Name, function()
                    local hrp = LP.Character.HumanoidRootPart
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                        UI.Notify("Teleported to " .. plr.Name)
                    end
                end)
            end
        end
    end

    build()
end)

-- === SHOP TAB ===
UI.SideButton("Shop", function()
    UI.Clear()
    UI.Label("Shop & Totem")

    local autoTotem = false

    UI.ContentButton("Auto Totem: OFF", function(btn)
        autoTotem = not autoTotem
        Core.AutoTotem(autoTotem)
        btn.Text = "Auto Totem: " .. (autoTotem and "ON" or "OFF"))
        UI.Notify("Auto Totem: " .. (autoTotem and "ON" or "OFF"))
    end)

    UI.ContentButton("Open Merchant UI", function()
        local m = LP.PlayerGui:FindFirstChild("Merchant")
        if m then
            m.Enabled = true
            task.delay(3, function() m.Enabled = false end)
        end
    end)
end)

-- === MISC TAB ===
UI.SideButton("Misc", function()
    UI.Clear()
    UI.Label("Performance")

    local lowPerf = false

    UI.ContentButton("Low Performance: OFF", function(btn)
        lowPerf = not lowPerf
        if lowPerf then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            game:GetService("Lighting").GlobalShadows = false
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            game:GetService("Lighting").GlobalShadows = true
        end
        btn.Text = "Low Performance: " .. (lowPerf and "ON" or "OFF"))
        UI.Notify("Low Performance: " .. (lowPerf and "ON" or "OFF"))
    end)
end)

-- === SYSTEM TAB ===
local pingPanel

local function togglePingPanel()
    if pingPanel then
        pingPanel:Destroy()
        pingPanel = nil
        return
    end

    pingPanel = Instance.new("Frame", gui)
    pingPanel.Size = UDim2.new(0,180,0,60)
    pingPanel.Position = UDim2.new(1,-200,1,-140)
    pingPanel.BackgroundColor3 = UI.Theme.BG_SIDE
    Instance.new("UICorner", pingPanel).CornerRadius = UDim.new(0,10)

    local txt = Instance.new("TextLabel", pingPanel)
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.new(1,0,1,0)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 16
    txt.TextColor3 = UI.Theme.TEXT

    task.spawn(function()
        while pingPanel and task.wait(0.8) do
            txt.Text = "Ping: " .. math.floor(Core.GetPing()) .. " ms"
        end
    end)
end

UI.SideButton("System", function()
    UI.Clear()
    UI.Label("System Tools")

    UI.ContentButton("Ping Panel", togglePingPanel)

    UI.ContentButton("Rejoin Server", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end)

    UI.ContentButton("Close UI", function()
        _G.FishItWORK = nil
        gui:Destroy()
    end)
end)

------------------------------------------------------------
-- OPEN DEFAULT TAB
------------------------------------------------------------
task.wait(0.1)
main.Visible = true
UI.Notify("Fish It Dark UI Loaded")

print("FISH IT | DARK UI | LOADED")
