--====================================================
-- FISH IT | FINAL CLEAN SCRIPT
-- UI BARU + LOGIC ASLI
--====================================================

--==============================
-- REMOVE OLD UI (SAFE)
--==============================
pcall(function()
    local pg = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    for _,v in ipairs(pg:GetChildren()) do
        if v.Name == "FishItWORKUI" or v.Name == "FishItFloatingToggle" then
            v:Destroy()
        end
    end
end)

if _G.FishItWORK then return end
_G.FishItWORK = true

--==============================
-- SERVICES
--==============================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

--==============================
-- STATE (LOGIC FLAGS)
--==============================
local AutoFish = false
local AutoSell = false
local AutoWeather = false
local AUTO_TOTEM = false

local FlyEnabled = false
local FlySpeed = 50

local SellInterval = 5
local WeatherDelay = 5

--==============================
-- NET / CONTROLLERS
--==============================
local Net = require(ReplicatedStorage.Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")
local purchaseWeatherRF = Net:RemoteFunction("PurchaseWeatherEvent")

-- Fishing Controller
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

--==============================
-- ANTI AFK
--==============================
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--==============================
-- FLY SYSTEM (ASLI)
--==============================
local flyConn, bv, bg

local function stopFly()
    FlyEnabled = false
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

local function startFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    bg = Instance.new("BodyGyro", hrp)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.CFrame = hrp.CFrame

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)

    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        bv.Velocity = move.Magnitude > 0 and move.Unit * FlySpeed or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(0.2)
    stopFly()
end)

--==============================
-- AUTO LOOPS (ASLI)
--==============================
-- Auto Fish
task.spawn(function()
    while _G.FishItWORK do
        task.wait(0.13)
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

-- Auto Sell
task.spawn(function()
    while _G.FishItWORK do
        task.wait(SellInterval)
        if AutoSell then
            pcall(function()
                sellRF:InvokeServer()
            end)
        end
    end
end)

-- Auto Weather
local WeatherList = {"Storm","Cloudy","Wind"}
task.spawn(function()
    while _G.FishItWORK do
        task.wait(WeatherDelay)
        if AutoWeather then
            for _,w in ipairs(WeatherList) do
                pcall(function()
                    purchaseWeatherRF:InvokeServer(w)
                end)
                task.wait(1.5)
            end
        end
    end
end)

--==============================
-- TELEPORT LOCATIONS (ASLI)
--==============================
local Locations = {
    {Name="Ancient Jungle",CFrame=CFrame.new(1562,6,-233)},
    {Name="Ancient Ruin",CFrame=CFrame.new(6076,-585,4625)},
    {Name="Fisherman Island",CFrame=CFrame.new(73,9,2709)},
    {Name="Tropical Grove",CFrame=CFrame.new(-2128,53,3637)},
    {Name="Weather Machine",CFrame=CFrame.new(-1527,2,1914)}
}

--====================================================
-- UI BARU (CLEAN)
--====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FishItWORKUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,420,0,260)
main.Position = UDim2.new(0.33,0,0.4,0)
main.BackgroundColor3 = Color3.fromRGB(15,18,25)
main.BackgroundTransparency = 0.25
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

-- Left Tabs
local tabs = Instance.new("Frame", main)
tabs.Size = UDim2.new(0,110,1,0)
tabs.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabs)
tabLayout.Padding = UDim.new(0,6)

-- Right Panel
local panel = Instance.new("Frame", main)
panel.Position = UDim2.new(0,120,0,10)
panel.Size = UDim2.new(1,-130,1,-20)
panel.BackgroundColor3 = Color3.fromRGB(30,35,45)
panel.BackgroundTransparency = 0.3
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1,0,0,26)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0,200,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Text = "Menu"

local content = Instance.new("ScrollingFrame", panel)
content.Position = UDim2.new(0,0,0,30)
content.Size = UDim2.new(1,0,1,-30)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 4
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", content).Padding = UDim.new(0,6)

local function clear()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel") then
            v:Destroy()
        end
    end
end

local function button(txt,cb)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1,-10,0,30)
    b.Text = txt
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.BackgroundColor3 = Color3.fromRGB(50,55,80)
    b.BackgroundTransparency = 0.3
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(cb)
end

local function tab(name,cb)
    local t = Instance.new("TextButton", tabs)
    t.Size = UDim2.new(1,-20,0,28)
    t.Text = name
    t.Font = Enum.Font.Gotham
    t.TextSize = 12
    t.BackgroundColor3 = Color3.fromRGB(40,45,60)
    t.BackgroundTransparency = 0.3
    t.TextColor3 = Color3.fromRGB(220,235,255)
    Instance.new("UICorner", t).CornerRadius = UDim.new(0,8)
    t.MouseButton1Click:Connect(function()
        title.Text = name
        clear()
        cb()
    end)
end

-- Tabs
tab("Auto", function()
    button("Auto Fish", function() AutoFish = not AutoFish end)
    button("Auto Sell", function() AutoSell = not AutoSell end)
    button("Auto Weather", function() AutoWeather = not AutoWeather end)
end)

tab("Teleport", function()
    for _,s in ipairs(Locations) do
        button(s.Name,function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = s.CFrame + Vector3.new(0,5,0) end
        end)
    end
end)

tab("Fly", function()
    button("Toggle Fly", function()
        FlyEnabled = not FlyEnabled
        if FlyEnabled then startFly() else stopFly() end
    end)
    button("+ Speed", function() FlySpeed += 50 end)
    button("- Speed", function() FlySpeed = math.max(50, FlySpeed-50) end)
end)

tab("System", function()
    button("Close UI", function()
        stopFly()
        _G.FishItWORK = false
        gui:Destroy()
    end)
end)

print("✅ FISH IT FINAL SCRIPT LOADED")
