local Player = game:GetService("Players").LocalPlayer
local Gui = Instance.new("ScreenGui")
Gui.Parent = Player:WaitForChild("PlayerGui")
Gui.Name = "FlatMinimalHub"
Gui.ResetOnSpawn = false

-- MAIN FRAME
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 380, 0, 290)
Main.Position = UDim2.new(0.5, -190, 0.4, -145)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 6)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(60,60,60)
Stroke.Thickness = 1
Stroke.Transparency = 0.4

-- TITLE BAR
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -40, 0, 28)
Title.Position = UDim2.new(0, 10, 0, 4)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(220,220,220)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Flat Minimal Hub"

-- CLOSE BUTTON
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 28, 0, 26)
Close.Position = UDim2.new(1, -32, 0, 6)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(25,25,25)
Close.TextColor3 = Color3.fromRGB(180,60,60)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.BorderSizePixel = 0
Instance.new("UICorner", Close)

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.Position = UDim2.new(0, 0, 0, 34)
TabBar.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 6)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

local Tabs = {}      -- Data container
local CurrentTab = nil

-- CREATE TAB FUNCTION
local function CreateTab(Name)
    local Btn = Instance.new("TextButton", TabBar)
    Btn.Size = UDim2.new(0, 100, 0, 28)
    Btn.Text = Name
    Btn.BackgroundColor3 = Color3.fromRGB(22,22,22)
    Btn.TextColor3 = Color3.fromRGB(210,210,210)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn)

    local TabFrame = Instance.new("Frame", Main)
    TabFrame.Size = UDim2.new(1, -20, 1, -80)
    TabFrame.Position = UDim2.new(0, 10, 0, 70)
    TabFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
    TabFrame.BorderSizePixel = 0
    Instance.new("UICorner", TabFrame)
    TabFrame.Visible = false

    local Stroke = Instance.new("UIStroke", TabFrame)
    Stroke.Color = Color3.fromRGB(50,50,50)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5

    -- Tab switching
    Btn.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Visible = false end
        CurrentTab = TabFrame
        TabFrame.Visible = true
    end)

    Tabs[Name] = TabFrame
    return TabFrame
end


local function CreateScrollArea(Parent)
    local Scroll = Instance.new("ScrollingFrame", Parent)
    Scroll.Size = UDim2.new(1, -10, 1, -10)
    Scroll.Position = UDim2.new(0, 5, 0, 5)
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Scroll.ScrollBarThickness = 4
    Scroll.BackgroundTransparency = 1

    local List = Instance.new("UIListLayout", Scroll)
    List.Padding = UDim.new(0,4)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    return Scroll
end



-- PLAYER TAB
local PlayerTab = CreateTab("Players")
local PlayerScroll = CreateScrollArea(PlayerTab)

-- Example button template for players
local function AddPlayerBtn(Name)
    local B = Instance.new("TextButton", PlayerScroll)
    B.Size = UDim2.new(1,0,0,26)
    B.BorderSizePixel = 0
    B.BackgroundColor3 = Color3.fromRGB(25,25,25)
    B.TextColor3 = Color3.fromRGB(230,230,230)
    B.Font = Enum.Font.Gotham
    B.TextSize = 11
    B.Text = Name
    Instance.new("UICorner", B)

    -- ❗ Kamu isi sendiri logic-nya
    B.MouseButton1Click:Connect(function()
        print("Clicked:", Name)
    end)
end

-- Tambahkan semua player
for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
    if p ~= Player then
        AddPlayerBtn(p.Name)
    end
end

-- SPOT TAB
local SpotTab = CreateTab("Spots")
local SpotScroll = CreateScrollArea(SpotTab)

local function AddSpotBtn(Name)
    local B = Instance.new("TextButton", SpotScroll)
    B.Size = UDim2.new(1,0,0,26)
    B.BackgroundColor3 = Color3.fromRGB(25,25,25)
    B.TextColor3 = Color3.fromRGB(230,230,230)
    B.Font = Enum.Font.Gotham
    B.TextSize = 11
    B.Text = Name
    B.BorderSizePixel = 0
    Instance.new("UICorner", B)

    -- ❗ Isi sendiri teleport logic
    B.MouseButton1Click:Connect(function()
        print("Teleport to:", Name)
    end)
end

-- Example spot list
local Spots = {"Kohana", "Pirate Cove", "Ancient Jungle", "Treasure Room"}
for _, spot in ipairs(Spots) do
    AddSpotBtn(spot)
end


-- Default open first tab
task.wait()
for name, frame in pairs(Tabs) do
    frame.Visible = true
    CurrentTab = frame
    break
end
