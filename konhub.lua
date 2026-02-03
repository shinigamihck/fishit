--------------------------------------------------------
--   WINDUI BLATANT MAX SPEED + C++ + MINIMIZE FIX    --
--------------------------------------------------------

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "ROB HUB - Republic of Bluescreen",
    Icon = "anchor",
    Size = UDim2.fromOffset(550, 350),
    Theme = "Sky"
})




local Tab = Window:Tab({
    Title = "Fishing",
    Icon = "fish"
})


--------------------------------------------------------
-- AUTO FAVORITE SYSTEM (FINAL CLEAN VERSION)
--------------------------------------------------------

local RS_AF = game:GetService("ReplicatedStorage")
local NetAF = RS_AF.Packages._Index["sleitnick_net@0.2.0"].net
local FavEvent = NetAF:WaitForChild("RE/FavoriteItem")

local ItemUtilityAF = require(RS_AF.Shared.ItemUtility)
local TierUtilityAF = require(RS_AF.Shared.TierUtility)
local PlayerDataAF = require(RS_AF.Packages.Replion).Client:WaitReplion("Data")

local AutoFavEnabled = false

local SelectedTiers = {
    [5] = false, -- Legendary
    [6] = false, -- Mythic
    [7] = false, -- Secret
}
-- Custom favorite by Variant / Name
local CustomFavorites = {
    ["Ruby"] = false,       -- Ruby Fish
    ["Gemstone"] = false,   -- Gemstone Variant
}


local ItemDataCache = {}

local function GetDataCached(id)
    ItemDataCache[id] = ItemDataCache[id] or ItemUtilityAF:GetItemData(id)
    return ItemDataCache[id]
end

local function IsFavorited(uuid)
    for _, item in ipairs(PlayerDataAF:GetExpect({"Inventory","Items"})) do
        if item.UUID == uuid then
            return item.Favorited == true
        end
    end
    return false
end

local function GetTierAF(item)
    local data = GetDataCached(item.Id)
    if not data then return 0 end

    if data.Probability then
        local t = TierUtilityAF:GetTierFromRarity(data.Probability.Chance)
        return t and t.Tier or 0
    end

    return data.Data and data.Data.Tier or 0
end

function AutoFavNow(manual)
    if not manual and not AutoFavEnabled then return end

    local inv = PlayerDataAF:GetExpect({"Inventory","Items"})
    if not inv then return end

    for _, item in ipairs(inv) do
        local tier = GetTierAF(item)
        local data = GetDataCached(item.Id)
        local name = data and data.Data and data.Data.Name or ""

        if (
            SelectedTiers[tier]               -- Favorite by Tier
            or CustomFavorites[name]          -- Favorite Ruby/Gemstone
        ) and not IsFavorited(item.UUID) then

            FavEvent:FireServer(item.UUID)
            task.wait(0.12)
        end
    end
end



task.spawn(function()
    while task.wait(10) do
        if AutoFavEnabled then
            AutoFavNow(false)
        end
    end
end)

local AutoFavTab = Window:Tab({
    Title = "Auto Favorite",
    Icon = "star"
})

local FavSection = AutoFavTab:Section({
    Title = "Favorite Settings",
    Icon = "star"
})

FavSection:Toggle({
    Title = "Enable Auto Favorite",
    Callback = function(v)
        AutoFavEnabled = v
    end
})

FavSection:Toggle({
    Title = "Legendary ⭐",
    Callback = function(v)
        SelectedTiers[5] = v
    end
})

FavSection:Toggle({
    Title = "Mythic ✨",
    Callback = function(v)
        SelectedTiers[6] = v
    end
})

FavSection:Toggle({
    Title = "Secret 💎",
    Callback = function(v)
        SelectedTiers[7] = v
    end
})

FavSection:Toggle({
    Title = "Ruby Only ❤️",
    Callback = function(v)
        CustomFavorites["Ruby"] = v
        CustomFavorites["Gemstone"] = v
    end
})

FavSection:Button({
    Title = "⭐ Favorite Now",
    Callback = function()
        AutoFavNow(true)
    end
})
--------------------------------------------------------
--  NEW TABS
--------------------------------------------------------

local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "navigation" -- bebas pilih icon WindUI
})

local ShopTab = Window:Tab({
    Title = "Shop",
    Icon = "shopping-cart"
})

local WeatherSection = ShopTab:Section({
    Title = "Weather Machine",
    Icon = "cloud"
})

local AutoWeather = false
local WeatherDelay = 5

WeatherSection:Toggle({
    Title = "Auto Buy Weather",
    Callback = function(v)
        AutoWeather = v
    end
})

WeatherSection:Input({
    Title = "Weather Delay (seconds)",
    Placeholder = "5",
    Callback = function(v)
        local num = tonumber(v)
        if num and num >= 1 then
            WeatherDelay = num
        end
    end
})


local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "package"
})

local MiscSection = MiscTab:Section({
    Title = "Disable Effects",
    Icon = "eye-off"
})


local PerformanceMode = false
local DisableBigNotif = false
local DisableVFX = false
local DisableFishingAnim = false
local DisableTridentAnim = false
local DisableHarpoonAnim = false


MiscSection:Toggle({
    Title = "Performance Mode",
    Callback = function(v)
        PerformanceMode = v

        WindUI:Notify({
            Title = "Performance Mode",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })

        if v then
            -- FORCE ULTRA LOW GRAPHICS
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)

            local Lighting = game:GetService("Lighting")
            Lighting.GlobalShadows = false
            Lighting.Brightness = 0
            Lighting.FogStart = 0
            Lighting.FogEnd = 60
            Lighting.ExposureCompensation = -1
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0

            for _,fx in ipairs(Lighting:GetChildren()) do
                if fx:IsA("PostEffect") then fx.Enabled = false end
            end

            pcall(function()
                local t = workspace.Terrain
                t.WaterWaveSize = 0
                t.WaterWaveSpeed = 0
                t.WaterReflectance = 0
                t.WaterTransparency = 1
            end)

            task.spawn(function()
                for _,obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy() end
                end
            end)

            task.spawn(function()
                for _,p in ipairs(workspace:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Material = Enum.Material.SmoothPlastic
                        p.Reflectance = 0
                    end
                end
            end)

        else
            warn("⚠️ Performance Mode dimatikan — tidak bisa restore lighting.")
        end
    end
})



-- 1. OFF Big Notification
MiscSection:Toggle({
    Title = "OFF Big Notification",
    Callback = function(v)
        DisableBigNotif = v

        WindUI:Notify({
            Title = "OFF Big Notification",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })
    end
})


-- 2. OFF VFX Skin (particles/trails tool)
MiscSection:Toggle({
    Title = "OFF VFX Skin",
    Callback = function(v)
        DisableVFX = v

        WindUI:Notify({
            Title = "OFF VFX Skin",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })
    end
})


-- 3. OFF Fishing Animation
MiscSection:Toggle({
    Title = "NO Fishing Animation",
    Callback = function(v)
        DisableFishingAnim = v

        WindUI:Notify({
            Title = "NO Fishing Animation",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })
    end
})


-- 4. OFF Trident Animation
MiscSection:Toggle({
    Title = "Trident Animation",
    Callback = function(v)
        DisableTridentAnim = v

        WindUI:Notify({
            Title = "Trident Animation",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })
    end
})


-- 5. OFF Harpoon Animation
MiscSection:Toggle({
    Title = "Harpoon Animation",
    Callback = function(v)
        DisableHarpoonAnim = v

        WindUI:Notify({
            Title = "Harpoon Animation",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })
    end
})






--------------------------------------------------------
-- PATCH: HARD DISABLE BIG + SMALL POPUP (TOGGLE)
--------------------------------------------------------
task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    repeat task.wait() until RS:FindFirstChild("Controllers")

    local Controllers = RS.Controllers

    -- simpan fungsi ori
    local OriginalSmall = {}
    local OriginalLarge = {}

    -- first setup: ambil semua module controller
    for _,mod in ipairs(Controllers:GetChildren()) do
        if mod:IsA("ModuleScript") then
            local ok, m = pcall(function()
                return require(mod)
            end)

            if ok and type(m) == "table" then
                -- simpan fungsi ori (1x saja)
                if type(m.PlaySmallItemObtained) == "function" then
                    OriginalSmall[m] = m.PlaySmallItemObtained
                end
                if type(m.PlayLargeItemObtained) == "function" then
                    OriginalLarge[m] = m.PlayLargeItemObtained
                end
            end
        end
    end

    while task.wait(0.2) do
        for _,mod in ipairs(Controllers:GetChildren()) do
            if mod:IsA("ModuleScript") then
                local ok, m = pcall(function()
                    return require(mod)
                end)

                if ok and type(m) == "table" then

                    -- kalau OFF Big Notification → matikan kedua popup
                    if DisableBigNotif then
                        if type(m.PlaySmallItemObtained) == "function" then
                            m.PlaySmallItemObtained = function() end
                        end
                        if type(m.PlayLargeItemObtained) == "function" then
                            m.PlayLargeItemObtained = function() end
                        end

                    -- kalau dinonaktifkan kembali → restore original
                    else
                        if OriginalSmall[m] then
                            m.PlaySmallItemObtained = OriginalSmall[m]
                        end
                        if OriginalLarge[m] then
                            m.PlayLargeItemObtained = OriginalLarge[m]
                        end
                    end
                end
            end
        end
    end
end)




--------------------------------------------------------
-- PATCH: DISABLE SKIN VFX
--------------------------------------------------------
task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    repeat task.wait() until RS:FindFirstChild("Controllers")

    local ok, VFX = pcall(function()
        return require(RS.Controllers.VFXController)
    end)

    if not ok then return end

    local RA = VFX.RenderAtPoint
    local RI = VFX.RenderInstance
    local H  = VFX.Handle

    VFX.RenderAtPoint = function(...)
        if DisableVFX then return end
        return RA(...)
    end

    VFX.RenderInstance = function(...)
        if DisableVFX then return end
        return RI(...)
    end

    VFX.Handle = function(...)
        if DisableVFX then return end
        return H(...)
    end
end)

--------------------------------------------------------
-- PATCH: ANIMATION OVERRIDE (NO / TRIDENT / HARPOON)
--------------------------------------------------------
local RS = game:GetService("ReplicatedStorage")
local AnimCtrl = require(RS.Controllers.AnimationController)
local OriginalAnim = AnimCtrl.GetAnimationData

AnimCtrl.GetAnimationData = function(self, animName)
    if not animName then
        return OriginalAnim(self, animName)
    end

    -- 1. No Animation = disable all
    if DisableFishingAnim then
        return nil
    end

    -- 2. Trident animation
    if DisableTridentAnim then
        local tname = "Holy Trident - " .. tostring(animName)
        if RS.Modules.Animations:FindFirstChild(tname) then
            return OriginalAnim(self, tname)
        end
    end

    -- 3. Harpoon animation
    if DisableHarpoonAnim then
        local hname = "Oceanic Harpoon - " .. tostring(animName)
        if RS.Modules.Animations:FindFirstChild(hname) then
            return OriginalAnim(self, hname)
        end
    end

    return OriginalAnim(self, animName)
end



local UtilityTab = Window:Tab({
    Title = "Utility",
    Icon = "settings"
})
local UtilitySection = UtilityTab:Section({
    Title = "Rejoin",
    Icon = "server"
})

UtilitySection:Button({
    Title = "Rejoin Server",
    Callback = function()
        local tp = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        
        -- Rejoin ke server yang sama
        tp:Teleport(game.PlaceId, Players.LocalPlayer)
    end
})


local TPPlayerSection = TeleportTab:Section({
    Title = "Teleport Player",
    Icon = "user"
})

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local SelectedPlayer = nil

-- == DROPDOWN SELECT PLAYER ==
local PlayerDropdown = TPPlayerSection:Dropdown({
    Title = "Select Player",
    Values = {},
    Callback = function(selected)
        SelectedPlayer = selected
    end
})

-- == TELEPORT FUNCTION ==
local function TeleportToPlayer(name)
    local target = Players:FindFirstChild(name)
    local myhrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local thrp = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")

    if myhrp and thrp then
        myhrp.CFrame = thrp.CFrame * CFrame.new(0, 0, -3)
    end
end

-- == BUTTON: TELEPORT TO SELECTED ==
TPPlayerSection:Button({
    Title = "Teleport to Selected Player",
    Icon = "navigation",
    Callback = function()
        if SelectedPlayer then
            TeleportToPlayer(SelectedPlayer)
        end
    end
})

-- == FUNCTION REFRESH LIST ==
local function RefreshPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            table.insert(list, plr.Name)
        end
    end
    PlayerDropdown:Refresh(list)
end

-- == BUTTON: REFRESH LIST ==
TPPlayerSection:Button({
    Title = "Refresh Player List",
    Icon = "refresh-cw",
    Callback = function()
        RefreshPlayerList()
    end
})

-- Auto refresh when player join/leave
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

-- First load
RefreshPlayerList()


--------------------------------------------------------
-- FINAL WALK ON WATER TELEPORT (STABLE, NO SKY BUG)
--------------------------------------------------------

local EventTP = TeleportTab:Section({
    Title = "Event Teleport",
    Icon = "zap"
})

local Rep = game:GetService("ReplicatedStorage")
local Replion = require(Rep.Packages.Replion).Client
local EventRep = Replion:WaitReplion("Events")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local VALID_EVENTS = {
    ["Megalodon Hunt"] = true,
    ["Shark Hunt"] = true,
    ["Ghost Shark Hunt"] = true,
    ["Worm Hunt"] = true,
    ["Ghost Worm"] = true
}

local MonsterNameMap = {
    ["Megalodon Hunt"] = "Megalodon",
    ["Shark Hunt"] = "Shark",
    ["Ghost Shark Hunt"] = "Ghost Shark",
    ["Worm Hunt"] = "Worm",
    ["Ghost Worm"] = "Ghost Worm"
}

--------------------------------------------------------
-- GET EVENT LIST
--------------------------------------------------------

local function GetActiveEvents()
    local raw = EventRep:Get({"Events"}) or {}
    local list = {}
    for _,ev in ipairs(raw) do
        if VALID_EVENTS[ev] then table.insert(list, ev) end
    end
    return list
end

--------------------------------------------------------
-- FIND MONSTER
--------------------------------------------------------

local function FindMonster(keyword)
    keyword = keyword:lower()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find(keyword) then
            local hrp = v:FindFirstChild("HumanoidRootPart")
                or v:FindFirstChild("HRP")
                or v:FindFirstChildWhichIsA("BasePart")

            if hrp then return hrp end
        end
    end
    return nil
end

--------------------------------------------------------
-- FINAL WATER PLATFORM (XY FOLLOW ONLY)
--------------------------------------------------------

local WaterY = -1.3  -- tingginya air di game kamu (bisa ubah)
local WaterPart = Instance.new("Part")
WaterPart.Name = "WaterWalk"
WaterPart.Size = Vector3.new(14,1,14)
WaterPart.Anchored = true
WaterPart.CanCollide = true
WaterPart.Transparency = 1
WaterPart.Parent = workspace

local Follow = false

local function StartWaterWalk()
    if Follow then return end
    Follow = true

    task.spawn(function()
        while Follow do
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- PLATFORM HANYA IKUTI X & Z (BUKAN Y)
                WaterPart.CFrame = CFrame.new(
                    hrp.Position.X,
                    WaterY,     -- fix di permukaan air
                    hrp.Position.Z
                )
            end
            task.wait(0.03)
        end
    end)
end

local function StopWaterWalk()
    Follow = false
end

--------------------------------------------------------
-- TELEPORT SYSTEM
--------------------------------------------------------

EventTP:Button({
    Title = "Refresh Event List",
    Callback = function()
        EventDropdown:Refresh(GetActiveEvents())
        WindUI:Notify({Title="Event", Content="Refreshed!", Icon="circle-check", Duration=2})
    end
})

EventDropdown = EventTP:Dropdown({
    Title = "Select Event",
    Values = GetActiveEvents(),
    Callback = function(eventName)
        
        local key = MonsterNameMap[eventName]
        if not key then return end

        WindUI:Notify({
            Title = "Scanning...",
            Content = "Searching monster spawn...",
            Icon = "search",
            Duration = 2
        })

        task.spawn(function()
            local monsterHRP

            for i = 1,50 do
                monsterHRP = FindMonster(key)
                if monsterHRP then break end
                task.wait(0.1)
            end

            if not monsterHRP then
                return WindUI:Notify({
                    Title = "Failed",
                    Content = "Monster not found.",
                    Icon = "alert-circle",
                    Duration = 3
                })
            end

            local hrp = LP.Character:WaitForChild("HumanoidRootPart")

            -- TELEPORT NORMAL (TIDAK FLOAT, TIDAK SLOW)
            hrp.CFrame = monsterHRP.CFrame * CFrame.new(0, 35, 0)

            task.wait(0.1)

            -- AKTIFKAN WALK ON WATER
            StartWaterWalk()

            WindUI:Notify({
                Title = "Success",
                Content = "Teleported to "..eventName,
                Icon = "circle-check",
                Duration = 3
            })
        end)
    end
})

EventRep:OnArrayInsert("Events", function()
    EventDropdown:Refresh(GetActiveEvents())
end)

EventRep:OnArrayRemove("Events", function()
    EventDropdown:Refresh(GetActiveEvents())
end)





-- GUI Merchant (ambil sekali saja)
local merchantGui = LP.PlayerGui:WaitForChild("Merchant", 5)

local function TeleportToPlayer(plr)
    local me = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local target = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

    if me and target then
        me.CFrame = target.CFrame * CFrame.new(0,0,-3)
    end
end



local TPSpotSection = TeleportTab:Section({
    Title = "Teleport Spot",
    Icon = "map"
})

local SpotList = {
    { Name = "Ancient Jungle", CFrame = CFrame.new(1562.54, 6.62, -233.16) },
    { Name = "Ancient Ruin", CFrame = CFrame.new(6076.29, -585.92, 4625.92) },
    { Name = "Captain Jones (Quest)", CFrame = CFrame.new(3312.16, 9.09, 3681.58) },
    { Name = "Coral Reefs", CFrame = CFrame.new(-2752.8, 4.0, 2165.78) },
    { Name = "Crater Island", CFrame = CFrame.new(1027.12, 2.89, 5148.10) },
    { Name = "Crystal Depths", CFrame = CFrame.new(5746.54883, -904.82019, 15400.4971, 0.537457168, -3.72122457e-08, 0.843291044, 5.61740059e-08, 1, 8.32586267e-09, -0.843291044, 4.28962394e-08, 0.537457168) },
    { Name = "Deadman Compass (Quest)", CFrame = CFrame.new(-3437.02, -22.36, -1500.29) },
    { Name = "Esoteric Depths", CFrame = CFrame.new(3249.08, -1301.52, 1373.68) },
    { Name = "Fisherman Island", CFrame = CFrame.new(73.35, 9.53, 2709.50) },
    { Name = "Kohana", CFrame = CFrame.new(-595.69, 19.25, 429.86) },
    { Name = "Kohana Volcano", CFrame = CFrame.new(-559.59, 21.22, 153.75) },
    { Name = "Kuil Suci", CFrame = CFrame.new(1471.79, -22.12, -607.50) },
    { Name = "Pirate Cove", CFrame = CFrame.new(3398.70, 10.34, 3491.11) },
    { Name = "Pirate Treasure Room", CFrame = CFrame.new(3340.80, -301.51, 3090.66) },
    { Name = "Sisyphus Statue", CFrame = CFrame.new(-3745.26, -135.07, -1008.68) },
    { Name = "Traveling Merchant", CFrame = CFrame.new(-133.94, 3.18, 2767.25) },
    { Name = "Treasure Room", CFrame = CFrame.new(-3597.20, -280.11, -1633.28) },
    { Name = "Tropical Grove", CFrame = CFrame.new(-2128.62, 53.48, 3637.66) },
    { Name = "Weather Machine", CFrame = CFrame.new(-1527.67, 2.87, 1914.66) },
}



for _, spot in ipairs(SpotList) do
    TPSpotSection:Button({
        Title = spot.Name,
        Callback = function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spot.CFrame + Vector3.new(0,5,0)
            end
        end
    })
end

local ShopSection = ShopTab:Section({
    Title = "Merchant",
    Icon = "store"
})

local MerchantOpen = false -- status merchant

ShopSection:Button({
    Title = "Toggle Merchant",
    Callback = function()
        if not merchantGui then return end

        MerchantOpen = not MerchantOpen

        merchantGui.Enabled = MerchantOpen
        Window.Main.Visible = not MerchantOpen and WINDUI_OPEN
    end
})





--------------------------------------------------------
--  STATE
--------------------------------------------------------

local Max = false
local Cpp = false

local MaxComplete = 0.7
local MaxCancel = 0.3

local CppComplete = 0.15
local CppCancel = 0.05

local UIVisible = true            -- UI status
local EngineRunning = false       -- engine status

-- AUTO SELL STATE
local AutoSellRunning = false
local AutoSellDelay = 0

local AutoEquipRod = false
local AutoTotem = false

local TotemCooldown = 0
local RetryWait = false


--------------------------------------------------------
-- INSTANT FISHING (POSISI PALING ATAS)
--------------------------------------------------------

local InstantFishing_CompleteDelay = 1
local InstantFishing_Enabled = false
local InstantFishing_Perfect = true

local InstantSection = Tab:Section({
    Title = "Instant Fishing",
    Icon = "zap"
})

InstantSection:Toggle({
    Title = "Instant Fishing",
    Callback = function(v)
    InstantFishing_Enabled = v
    if v then
        Max = false
        Cpp = false
        EngineRunning = false
    end


        WindUI:Notify({
            Title = "Instant Fishing",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check",
            Duration = 3
        })
    end
})

InstantSection:Input({
    Title = "Complete Delay",
    Placeholder = "1",
    Callback = function(v)
        local num = tonumber(v)
        if num then
            InstantFishing_CompleteDelay = num
        end
    end
})

InstantSection:Toggle({
    Title = "Auto Perfect",
    Value = true,
    Callback = function(v)
        InstantFishing_Perfect = v
    end
})

--------------------------------------------------------
--  UI
--------------------------------------------------------

local Section = Tab:Section({
    Title = "Blatant V1",
    Icon = "zap"
})

Section:Toggle({
    Title = "Blatant V1",
    Callback = function(v)
        Max = v
        if v then Cpp = false end
        EngineRunning = v

        WindUI:Notify({
            Title = "Blatant V1",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })
    end
})



Section:Input({
    Title = "Complete Delay",
    Callback = function(v)
        v = tonumber(v)
        if v then MaxComplete = v end
    end
})

Section:Input({
    Title = "Cancel Delay",
    Callback = function(v)
        v = tonumber(v)
        if v then MaxCancel = v end
    end
})


local Section2 = Tab:Section({
    Title = "Blatant V2",
    Icon = "zap"
})

Section2:Toggle({
    Title = "Blatant V2",
    Callback = function(v)
        Cpp = v
        if v then Max = false end
        EngineRunning = v

        WindUI:Notify({
            Title = "Blatant V2",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })
    end
})



Section2:Input({
    Title = "Complete Delay",
    Callback = function(v)
        v = tonumber(v)
        if v then CppComplete = v end
    end
})

Section2:Input({
    Title = "Cancel Delay",
    Callback = function(v)
        v = tonumber(v)
        if v then CppCancel = v end
    end
})

--------------------------------------------------------
-- AUTO SELL (FISHING TAB)
--------------------------------------------------------

local AutoSellSection = AutoFavTab:Section({
    Title = "Auto Sell",
    Icon = "dollar-sign"
})

AutoSellSection:Toggle({
    Title = "Auto Sell",
    Callback = function(v)
        AutoSellRunning = v

        WindUI:Notify({
            Title = "Auto Sell",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })

        if v then
            pcall(function()
                sellRF:InvokeServer()
            end)
        end
    end
})

AutoSellSection:Input({
    Title = "Sell Delay (seconds)",
    Placeholder = "0",
    Callback = function(v)
        local num = tonumber(v)
        if num and num >= 1 then
            AutoSellDelay = num
        else
            AutoSellDelay = 0
        end
    end
})


----------------------------------------
-- auto equip rod totem
local EquipTotemSection = AutoFavTab:Section({
    Title = "Equip & Totem",
    Icon = "settings"
})

EquipTotemSection:Toggle({
    Title = "Auto Equip Rod",
    Callback = function(v)
        AutoEquipRod = v

        WindUI:Notify({
            Title = "Auto Equip Rod",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })
    end
})

EquipTotemSection:Toggle({
    Title = "Auto Totem",
    Callback = function(v)
        AutoTotem = v

        WindUI:Notify({
            Title = "Auto Totem",
            Content = v and "Enabled ✔" or "Disabled ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })

        if not v then
            TotemCooldown = 0
            RetryWait = false
        end
    end
})





local Data = require(game:GetService("ReplicatedStorage").Packages.Replion).Client
    :WaitReplion("Data")

local function GetTotemUUID()
    local inv = Data:Get({"Inventory","Totems"})
    if inv then
        for _,item in ipairs(inv) do
            return item.UUID
        end
    end
    return nil
end

--------------------------------------------------------
-- BLATANT OVERLAP HELPERS (WAJIB)
--------------------------------------------------------

local function BlatantCast(x)
    equip:FireServer(1)

    task.spawn(function()
        charge:InvokeServer(workspace:GetServerTimeNow())
        task.wait(0.004)
        minigame:InvokeServer(x or -0.75, 1)
    end)
end

local function BlatantReel(times, delay)
    task.spawn(function()
        for i = 1, times do
            complete:InvokeServer()
            task.wait(delay)
        end
    end)
end


--------------------------------------------------------
--  ENGINE
--------------------------------------------------------

local RS = game:GetService("ReplicatedStorage")
local net = RS.Packages._Index["sleitnick_net@0.2.0"].net
local BlatantCooldown = false
local charge   = net["RF/ChargeFishingRod"]
local minigame = net["RF/RequestFishingMinigameStarted"]
local complete = net["RF/CatchFishCompleted"]
local cancel   = net["RF/CancelFishingInputs"]
local equip    = net["RE/EquipToolFromHotbar"]
local Net = require(game:GetService("ReplicatedStorage").Packages.Net)
local sellRF = Net:RemoteFunction("SellAllItems")
local EquipToolFromHotbar = Net:RemoteEvent("EquipToolFromHotbar")
local SpawnTotem = Net:RemoteEvent("SpawnTotem")
local TotemSpawned = Net:RemoteEvent("TotemSpawned")
local purchaseRF = Net:RemoteFunction("PurchaseWeatherEvent")

--------------------------------------------------------
-- INSTANT FISHING ENGINE (NORMAL MODE ONLY - V4 LOGIC)
--------------------------------------------------------

local IF_IsFishing = false

local function IF_Cast()
    pcall(function()
        -- Equip rod
        equip:FireServer(1)
        task.wait(0.05)

        -- Charge rod
        charge:InvokeServer(workspace:GetServerTimeNow())
        task.wait(0.02)

        -- Normal cast (Rafcast)
        minigame:InvokeServer(
            1.2854545,  -- X cast
            1           -- Y cast
        )
    end)
end

local function IF_Reel()
    pcall(function()
        complete:InvokeServer()
    end)
end

task.spawn(function()
    while task.wait(0.05) do
        if not InstantFishing_Enabled then continue end
        if IF_IsFishing then continue end

        IF_IsFishing = true

        -- CAST
        IF_Cast()

        -- Wait user delay input
        task.wait(InstantFishing_CompleteDelay)

        -- Reel (normal)
        IF_Reel()

        -- cooldown kecil
        task.wait(0.15)

        IF_IsFishing = false
    end
end)



task.spawn(function()
    while true do
        task.wait(0.015)

        if not EngineRunning then
            continue
        end


-- MAX SPEED MODE (OVERLAP STABLE)
if Max and not Cpp and not BlatantCooldown then
    BlatantCooldown = true

    -- DOUBLE CAST
    BlatantCast(-0.75)
    task.wait(0.02)
    BlatantCast(-0.75)

    -- REEL PADAT & STABIL
    BlatantReel(6, 0.005)

    -- CANCEL LEBIH AMAN
    task.delay(0.14, function()
        if EngineRunning then
            cancel:InvokeServer()
        end
    end)

    -- COOLDOWN
    task.delay(0.06, function()
        BlatantCooldown = false
    end)
end





-- MODE C++ (OVERLAP FINAL)
if Cpp and not BlatantCooldown then
    BlatantCooldown = true

    -- TRIPLE CAST OVERLAP
    BlatantCast(-0.75)
    task.wait(0.015)
    BlatantCast(-0.75)
    task.wait(0.015)
    BlatantCast(-0.75)

    -- REEL PADAT (STABIL)
    BlatantReel(8, 0.005)

    -- CANCEL AMAN (ANTI ROLLBACK)
    task.delay(0.11, function()
        if EngineRunning then
            cancel:InvokeServer()
        end
    end)

    -- COOLDOWN MINIMAL (OVERLAP ON)
    task.delay(0.05, function()
        BlatantCooldown = false
    end)
end






-- AUTO SELL ENGINE (1-FILE LOGIC)
task.spawn(function()
    while true do
        task.wait(AutoSellDelay > 0 and 0.5 or 0.25)

        if AutoSellRunning then
            
            -- Jika delay = 0 → spam sell setiap tick
            if AutoSellDelay <= 0 then
                pcall(function()
                    sellRF:InvokeServer()
                end)
            
            -- Jika delay > 0 → gunakan modulus
            else
                if tick() % AutoSellDelay < 0.05 then
                    pcall(function()
                        sellRF:InvokeServer()
                    end)
                end
            end
        
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)

        if AutoEquipRod then
            local char = LP.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")

                if not tool or not tool.Name:lower():find("rod") then
                    pcall(function()
                        equip:FireServer(1)
                    end)
                end
            end
        end
    end
end)

TotemSpawned.OnClientEvent:Connect(function()
    TotemCooldown = 3600
    task.delay(0.2, function()
        equip:FireServer(1)
    end)
end)

local TRY_INTERVAL = 300 -- retry 5 menit

task.spawn(function()
    while true do
        task.wait(1)

        if not AutoTotem then
            continue
        end

        -- COOLDOWN
        if TotemCooldown > 0 then
            TotemCooldown -= 1
            continue
        end

        -- RETRY WAIT
        if RetryWait and os.clock() < RetryWait then
            continue
        end

        RetryWait = false

        -- Pastikan equip rod sebelum pasang totem
        pcall(function()
            equip:FireServer(1)
        end)
        task.wait(0.2)

        -- Ambil UUID
        local uuid = GetTotemUUID()
        if not uuid then
            RetryWait = os.clock() + 3
            continue
        end

        -- Pasang totem
        SpawnTotem:FireServer(uuid)
        task.wait(0.7)

        -- Jika server tidak respon → retry
        if TotemCooldown <= 0 then
            RetryWait = os.clock() + TRY_INTERVAL
        end
    end
end)




--------------------------------------------------------
--  PING + CPU PANEL (FINAL UNIVERSAL VERSION)
--------------------------------------------------------

task.wait(1)

local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GUI overlay
local OverlayGUI = Instance.new("ScreenGui")
OverlayGUI.Name = "WindUIPingPanel"
OverlayGUI.ResetOnSpawn = false
OverlayGUI.IgnoreGuiInset = false
OverlayGUI.Parent = LP.PlayerGui

-- PANEL
local Panel = Instance.new("Frame")
Panel.Size = UDim2.fromOffset(180, 60)
Panel.Position = UDim2.new(0, 10, 0, 60)
Panel.BackgroundColor3 = Color3.fromRGB(25,25,32)
Panel.BackgroundTransparency = 0.15
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.Parent = OverlayGUI

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", Panel)
stroke.Color = Color3.fromRGB(120,160,255)
stroke.Transparency = 0.4

-- ICON
local Icon = Instance.new("ImageLabel", Panel)
Icon.Size = UDim2.fromOffset(22,22)
Icon.Position = UDim2.new(0, 10, 0, 8)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://72407089659970"

-- PING TEXT
local PingText = Instance.new("TextLabel", Panel)
PingText.BackgroundTransparency = 1
PingText.Size = UDim2.new(1, -40, 0, 20)
PingText.Position = UDim2.new(0, 35, 0, 5)
PingText.Font = Enum.Font.GothamSemibold
PingText.TextSize = 14
PingText.TextColor3 = Color3.fromRGB(230,230,230)
PingText.Text = "Ping: -- ms"
PingText.TextXAlignment = Enum.TextXAlignment.Left

-- CPU TEXT
local CPUText = Instance.new("TextLabel", Panel)
CPUText.BackgroundTransparency = 1
CPUText.Size = UDim2.new(1, -40, 0, 20)
CPUText.Position = UDim2.new(0, 35, 0, 30)
CPUText.Font = Enum.Font.GothamSemibold
CPUText.TextSize = 14
CPUText.TextColor3 = Color3.fromRGB(230,230,230)
CPUText.Text = "CPU: -- ms"
CPUText.TextXAlignment = Enum.TextXAlignment.Left

--------------------------------------------------------
-- DRAGGING
--------------------------------------------------------
local dragging = false
local dragPos = nil

Panel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragPos = input.Position - Panel.AbsolutePosition
    end
end)

Panel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        Panel.Position = UDim2.fromOffset(
            input.Position.X - dragPos.X,
            input.Position.Y - dragPos.Y
        )
    end
end)

--------------------------------------------------------
-- UNIVERSAL CPU (FPS FRAME TIME → ms)
--------------------------------------------------------
local dt_ms = 16

RunService.Heartbeat:Connect(function(dt)
    dt_ms = dt * 1000   -- convert to milliseconds
end)

local function GetCPUms()
    return dt_ms        -- always valid
end

--------------------------------------------------------
-- REAL PING FETCH
--------------------------------------------------------
local function GetPing()
    local n = Stats:FindFirstChild("Network")
    local s = n and n:FindFirstChild("ServerStatsItem")
    local p = s and s:FindFirstChild("Data Ping")
    return p and p:GetValue()
end

--------------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------------
task.spawn(function()
    while task.wait(0.3) do
        if not Panel.Visible then continue end

        ------------------------------------------------
        -- PING (REAL + DYNAMIC COLORS)
        ------------------------------------------------
        local ping = GetPing()

        if ping then
            PingText.Text = "Ping: " .. math.floor(ping) .. " ms"

            if ping < 60 then
                PingText.TextColor3 = Color3.fromRGB(140,255,140) -- hijau
            elseif ping < 120 then
                PingText.TextColor3 = Color3.fromRGB(255,230,120) -- kuning
            else
                PingText.TextColor3 = Color3.fromRGB(255,120,120) -- merah
            end
        else
            PingText.Text = "Ping: -- ms"
            PingText.TextColor3 = Color3.fromRGB(230,230,230)
        end

        ------------------------------------------------
        -- CPU (ms FRAME TIME + COLORS)
        ------------------------------------------------
        local cpu = GetCPUms()

        CPUText.Text = string.format("CPU: %.2f ms", cpu)

        if cpu < 18 then
            CPUText.TextColor3 = Color3.fromRGB(140,255,140) -- hijau
        elseif cpu < 26 then
            CPUText.TextColor3 = Color3.fromRGB(255,230,120) -- kuning
        else
            CPUText.TextColor3 = Color3.fromRGB(255,120,120) -- merah
        end
    end
end)

--------------------------------------------------------
-- TOGGLE IN MISC
--------------------------------------------------------
local PingSection = MiscTab:Section({
    Title = "Network Tools",
    Icon = "wifi"
})

--------------------------------------------------------
-- BOOST FPS 
--------------------------------------------------------

local function BoostFPS()
    -- Ganti material
    task.spawn(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
    end)

    -- Lighting optimasi
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.FogEnd = 1e10

    -- Matikan post-processing
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end

    -- Terrain Air Optimasi
    pcall(function()
        local t = workspace.Terrain
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 1
    end)

    -- Turunkan grafik
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

PingSection:Toggle({
    Title = "Boost FPS",
    Callback = function(v)
        if v then
            BoostFPS()
            WindUI:Notify({
                Title = "FPS BOOST",
                Content = "Successfully increased FPS!",
                Icon = "zap",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "FPS Boost",
                Content = "Cannot restore Lighting (one-way optimization).",
                Icon = "alert-circle",
                Duration = 3
            })
        end
    end
})


PingSection:Toggle({
    Title = "Show Ping & CPU Panel",
    Callback = function(v)
        Panel.Visible = v

        WindUI:Notify({
            Title = "Ping & CPU Panel",
            Content = v and "Shown ✔" or "Hidden ✖",
            Icon = v and "circle-check" or "ban",
            Duration = 3
        })
    end
})


local WeatherList = {"Storm", "Cloudy", "Wind"}

task.spawn(function()
    while true do
        task.wait(WeatherDelay)

        if AutoWeather then
            for _,weather in ipairs(WeatherList) do
                pcall(function()
                    purchaseRF:InvokeServer(weather)
                end)
                task.wait(1.3)
            end
        end
    end
end)


--------------------------------------------------------
-- AUTO RECONNECT ENGINE (ROB HUB)
--------------------------------------------------------

task.spawn(function()
    local TP = game:GetService("TeleportService")
    local LP = game:GetService("Players").LocalPlayer

    LP.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Failed then
            TP:Teleport(game.PlaceId, LP)
        end
    end)

    while task.wait(3) do
        if not game:IsLoaded() then
            TP:Teleport(game.PlaceId, LP)
        end
    end
end)

--------------------------------------------------------
-- ANTI-AFK SYSTEM (ROB HUB)
--------------------------------------------------------

local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
    WindUI:Notify({
        Title = "Anti-AFK",
        Content = "You are protected from AFK kick ✔",
        Icon = "circle-check",
        Duration = 2
    })
end)


--========================================================--
--      WINDUI CLASSIC TOGGLE SYSTEM (VERSION A)         
--========================================================--

local UIS = game:GetService("UserInputService")
local TOGGLE_KEY = Enum.KeyCode.G   -- tombol toggle

-- state internal windui (classic)
local WINDUI_OPEN = true            -- default UI muncul
local LAST_FORCED = os.clock()      -- waktu terakhir UI dipaksa tampil

-- Fungsi untuk update UI real-time
local function ApplyUIState()
    if WINDUI_OPEN then
        Window.Main.Visible = true
    else
        Window.Main.Visible = false
    end
end

-- Toggle handler
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == TOGGLE_KEY then
        WINDUI_OPEN = not WINDUI_OPEN
        ApplyUIState()
        LAST_FORCED = os.clock()
    end
end)

-- NEW ANTI-HIDE ENGINE (SUPER STABLE)
task.spawn(function()
    while task.wait(0.05) do
        
        -- UI sedang ON, tapi hilang → force show
        if WINDUI_OPEN and Window.Main.Visible == false then
            Window.Main.Visible = true
        end

        -- UI sedang OFF, tapi muncul → force hide
        if not WINDUI_OPEN and Window.Main.Visible == true then
            Window.Main.Visible = false
        end

        -- GUI lain tidak boleh menimpa WindUI
        if WINDUI_OPEN then
            pcall(function()
                if Window.Main.Parent ~= LP.PlayerGui then
                    Window.Main.Parent = LP.PlayerGui
                    Window.Main.Visible = true
                end
            end)
        end
    end
end)


