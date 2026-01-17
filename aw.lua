local Players = game:GetService("Players")
local LP = Players.LocalPlayer

pcall(function()
    LP.PlayerGui:FindFirstChild("FishItUI_HUB"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "FishItUI_HUB"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

-- MAIN WINDOW (Fluent)
local Main = Instance.new("Frame", gui)
Main.Size = UDim2.new(0, 650, 0, 420)
Main.Position = UDim2.new(0.5, -325, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 27, 34)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Fish It | Fluent Hub"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15

-- SIDEBAR (Fluent)
local Sidebar = Instance.new("Frame", Main)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.Size = UDim2.new(0, 160, 1, -40)
Sidebar.BackgroundColor3 = Color3.fromRGB(23, 25, 32)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 8)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop = UDim.new(0, 12)
SidebarPadding.PaddingLeft = UDim.new(0, 12)
SidebarPadding.PaddingRight = UDim.new(0, 12)

-- CONTENT PANEL
local Content = Instance.new("ScrollingFrame", Main)
Content.Position = UDim2.new(0, 160, 0, 40)
Content.Size = UDim2.new(1, -160, 1, -40)
Content.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
Content.BorderSizePixel = 0
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 6

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentPadding = Instance.new("UIPadding", Content)
ContentPadding.PaddingTop = UDim.new(0, 12)
ContentPadding.PaddingLeft = UDim.new(0, 12)
ContentPadding.PaddingRight = UDim.new(0, 12)
ContentPadding.PaddingBottom = UDim.new(0, 12)

Tabs = {}
local CurrentTab

local function CreateTab(tabName)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.Text = tabName
    Btn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.BorderSizePixel = 0

    local c = Instance.new("UICorner", Btn)
    c.CornerRadius = UDim.new(0, 6)

    -- page
    local Page = Instance.new("Frame", Content)
    Page.Size = UDim2.new(1, -10, 0, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false

    local layout = Instance.new("UIListLayout", Page)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    Tabs[tabName] = Page

    Btn.MouseEnter:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
    end)
    Btn.MouseLeave:Connect(function()
        if CurrentTab ~= tabName then
            Btn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
        end
    end)

    Btn.MouseButton1Click:Connect(function()
        for name, pg in pairs(Tabs) do
            pg.Visible = false
        end
        for _, b in ipairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
            end
        end

        Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        Page.Visible = true
        CurrentTab = tabName

        task.wait()
        Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 40)
    end)

    return Page
end

-- create tabs
TabAutomation = CreateTab("Automation")
TabTeleport   = CreateTab("Teleport")
TabShop       = CreateTab("Shop")
TabFly        = CreateTab("Fly")
TabSettings   = CreateTab("Settings")

Tabs["Automation"].Visible = true
CurrentTab = "Automation"

-- =====================================================
-- PART 2 : FLUENT UI COMPONENTS
-- =====================================================

local function AutoSize(frame)
    local layout = frame:FindFirstChildOfClass("UIListLayout")
    if layout then
        frame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 6)
    end
end

-- SECTION
function CreateSection(parent, title)
    local Sec = Instance.new("Frame", parent)
    Sec.Size = UDim2.new(1, 0, 0, 40)
    Sec.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Sec)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = title
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(180, 200, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13

    local Holder = Instance.new("Frame", Sec)
    Holder.Position = UDim2.new(0, 0, 0, 24)
    Holder.Size = UDim2.new(1, 0, 0, 0)
    Holder.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", Holder)
    layout.Padding = UDim.new(0, 8)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Holder.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
        Sec.Size = UDim2.new(1, 0, 0, Holder.AbsoluteSize.Y + 28)
    end)

    return Holder
end

-- TOGGLE
function CreateToggle(parent, text, default, callback)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, 0, 0, 38)
    Box.BackgroundColor3 = Color3.fromRGB(40, 43, 55)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", Box)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Text = text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(235,235,235)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12

    local Btn = Instance.new("TextButton", Box)
    Btn.Size = UDim2.new(0, 44, 0, 22)
    Btn.Position = UDim2.new(1, -54, 0.5, -11)
    Btn.Text = default and "ON" or "OFF"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.BackgroundColor3 = default and Color3.fromRGB(0,160,120) or Color3.fromRGB(120,60,60)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = state and "ON" or "OFF"
        Btn.BackgroundColor3 = state and Color3.fromRGB(0,160,120) or Color3.fromRGB(120,60,60)
        if callback then callback(state) end
    end)

    return Box
end

-- BUTTON
function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,8)

    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Btn
end

-- SLIDER
function CreateSlider(parent, text, min, max, default, callback)
    local Holder = Instance.new("Frame", parent)
    Holder.Size = UDim2.new(1, 0, 0, 48)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Holder)
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = text .. " : " .. default
    Label.TextColor3 = Color3.fromRGB(230,230,230)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12

    local Bar = Instance.new("Frame", Holder)
    Bar.Position = UDim2.new(0,0,0,24)
    Bar.Size = UDim2.new(1,0,0,10)
    Bar.BackgroundColor3 = Color3.fromRGB(70,70,90)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(0,140,255)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

    Bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local x = math.clamp((i.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
            local val = math.floor(min + (max-min)*x)
            Fill.Size = UDim2.new(x,0,1,0)
            Label.Text = text .. " : " .. val
            if callback then callback(val) end
        end
    end)

    return Holder
end


-- =====================================================
-- PART 3 : UI → LOGIC MAPPING
-- =====================================================

-- AUTOMATION
local AutoSec = CreateSection(TabAutomation, "AUTO FARM")
CreateToggle(AutoSec, "Auto Fish", AutoFish, function(v) AutoFish = v end)
CreateToggle(AutoSec, "Auto Sell", AutoSell, function(v) AutoSell = v end)
CreateSlider(AutoSec, "Sell Interval", 1, 30, SellInterval, function(v) SellInterval = v end)

local WeatherSec = CreateSection(TabAutomation, "WEATHER")
CreateToggle(WeatherSec, "Auto Weather", AutoWeather, function(v) AutoWeather = v end)
CreateSlider(WeatherSec, "Weather Delay", 1, 20, WeatherDelay, function(v) WeatherDelay = v end)

-- SHOP
local ShopSec = CreateSection(TabShop, "SHOP")
CreateToggle(ShopSec, "Auto Totem", AUTO_TOTEM, function(v) AUTO_TOTEM = v end)
CreateButton(ShopSec, "Open Merchant", function()
    local g = LP.PlayerGui:FindFirstChild("Merchant")
    if g then g.Enabled = not g.Enabled end
end)

-- FLY
local FlySec = CreateSection(TabFly, "FLY")
CreateToggle(FlySec, "Fly Enabled", FlyEnabled, function(v)
    FlyEnabled = v
    if v then startFly() else stopFly() end
end)
CreateSlider(FlySec, "Fly Speed", 50, 800, FlySpeed, function(v) FlySpeed = v end)


-- =====================================================
-- PART 5 : SETTINGS
-- =====================================================

local TeleportService = game:GetService("TeleportService")

local SetSec = CreateSection(TabSettings, "SYSTEM")

CreateButton(SetSec, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LP)
end)

CreateButton(SetSec, "Close UI", function()
    _G.FishItWORK = false
    gui:Destroy()
end)
