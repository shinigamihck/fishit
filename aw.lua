local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "Fish It | Sanzhuy Hub",
    LoadingTitle = "Sanzhuy Hub",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SanzhuyHub",
        FileName = "FishIt_Config"
    }
})

-------------------------------------------------------
-- MAIN TAB
-------------------------------------------------------

local MainTab = Window:CreateTab("Main", 4483362458)

local AutoFishToggle = MainTab:CreateToggle({
    Name = "Auto Fishing",
    CurrentValue = false,
    Callback = function(Value)
        AutoFish = Value
    end,
})

local AutoSellToggle = MainTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(Value)
        AutoSell = Value
    end,
})

local AutoWeatherToggle = MainTab:CreateToggle({
    Name = "Auto Weather",
    CurrentValue = false,
    Callback = function(Value)
        AutoWeather = Value
    end,
})

MainTab:CreateSlider({
    Name = "Sell Interval (Seconds)",
    Range = {1, 20},
    Increment = 1,
    Suffix = "s",
    CurrentValue = SellInterval,
    Callback = function(Value)
        SellInterval = Value
    end,
})

-------------------------------------------------------
-- FLY TAB
-------------------------------------------------------

local FlyTab = Window:CreateTab("Fly", 4483362458)

local FlyToggle = FlyTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Callback = function(Value)
        FlyEnabled = Value
        if FlyEnabled then
            startFly()
        else
            stopFly()
        end
    end,
})

FlyTab:CreateSlider({
    Name = "Fly Speed",
    Range = {50, 800},
    Increment = 10,
    Suffix = " speed",
    CurrentValue = FlySpeed,
    Callback = function(Value)
        FlySpeed = Value
    end,
})

-------------------------------------------------------
-- SHOP TAB (Totem / Merchant)
-------------------------------------------------------

local ShopTab = Window:CreateTab("Shop", 4483362458)

local TotemToggle = ShopTab:CreateToggle({
    Name = "Auto Totem",
    CurrentValue = false,
    Callback = function(Value)
        AUTO_TOTEM = Value
    end,
})

ShopTab:CreateButton({
    Name = "Toggle Merchant GUI",
    Callback = function()
        local merchantGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Merchant")
        if merchantGui then
            merchantGui.Enabled = not merchantGui.Enabled
        end
    end,
})

-------------------------------------------------------
-- TELEPORT TAB
-------------------------------------------------------

local TpTab = Window:CreateTab("Teleport", 4483362458)

TpTab:CreateSection("Teleport to Fishing Spots")

for _,spot in ipairs(Locations) do
    TpTab:CreateButton({
        Name = spot.Name,
        Callback = function()
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spot.CFrame + Vector3.new(0,5,0)
            end
        end,
    })
end

Rayfield:Notify({
    Title = "Sanzhuy Hub Loaded!",
    Content = "UI berhasil dibuat menggunakan Rayfield.",
    Duration = 5
})
