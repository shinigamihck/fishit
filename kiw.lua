--==================================================
-- FISH IT FINAL PANEL (ALL-IN-ONE)
-- Educational Executor UI
--==================================================

--====================
-- GLOBAL STATE
--====================
_G.Config = {
	AutoFish = false,
	AntiAFK = false,
	AutoEquip = true,
	Humanize = true,
	CastDelay = 1.88,
	ReelDelay = 0.88
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

--====================
-- GUI ROOT
--====================
pcall(function() game.CoreGui.FishItFinal:Destroy() end)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FishItFinal"

--====================
-- MAIN PANEL
--====================
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 420, 0, 360)
panel.Position = UDim2.new(0.05,0,0.25,0)
panel.BackgroundColor3 = Color3.fromRGB(18,18,22)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,16)

-- TITLE
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1,-60,0,42)
title.Position = UDim2.new(0,12,0,0)
title.Text = "🎣 Fish It | Final Coding Panel"
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextColor3 = Color3.fromRGB(0,220,255)
title.BackgroundTransparency = 1
title.TextXAlignment = Left

-- MINIMIZE
local minimize = Instance.new("TextButton", panel)
minimize.Size = UDim2.new(0,32,0,32)
minimize.Position = UDim2.new(1,-38,0,5)
minimize.Text = "—"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundColor3 = Color3.fromRGB(40,40,55)
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BorderSizePixel = 0
Instance.new("UICorner", minimize)

--====================
-- TAB BAR
--====================
local tabBar = Instance.new("Frame", panel)
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.Position = UDim2.new(0,0,0,42)
tabBar.BackgroundTransparency = 1

local function Tab(text, x)
	local b = Instance.new("TextButton", tabBar)
	b.Size = UDim2.new(0,95,0,30)
	b.Position = UDim2.new(0,x,0,5)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(35,35,45)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)
	return b
end

local tFish = Tab("Fishing",10)
local tTP   = Tab("Teleport",115)
local tMisc = Tab("Misc",220)
local tSet  = Tab("Settings",325)

--====================
-- CONTENT FRAMES
--====================
local function Page()
	local f = Instance.new("Frame", panel)
	f.Size = UDim2.new(1,-20,1,-100)
	f.Position = UDim2.new(0,10,0,90)
	f.BackgroundTransparency = 1
	f.Visible = false
	return f
end

local pFish = Page()
local pTP   = Page()
local pMisc = Page()
local pSet  = Page()
pFish.Visible = true

local function switch(p)
	pFish.Visible=false
	pTP.Visible=false
	pMisc.Visible=false
	pSet.Visible=false
	p.Visible=true
end

tFish.MouseButton1Click:Connect(function() switch(pFish) end)
tTP.MouseButton1Click:Connect(function() switch(pTP) end)
tMisc.MouseButton1Click:Connect(function() switch(pMisc) end)
tSet.MouseButton1Click:Connect(function() switch(pSet) end)

--====================
-- UI HELPERS
--====================
local function Button(parent,text,y)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,0,0,36)
	b.Position = UDim2.new(0,0,0,y)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(35,35,45)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)
	return b
end

local function Label(parent,text,y,h)
	local l = Instance.new("TextLabel", parent)
	l.Size = UDim2.new(1,0,0,h)
	l.Position = UDim2.new(0,0,0,y)
	l.TextWrapped = true
	l.Text = text
	l.Font = Enum.Font.Gotham
	l.TextSize = 12
	l.TextColor3 = Color3.fromRGB(180,180,180)
	l.BackgroundTransparency = 1
	return l
end

--====================
-- FISHING TAB
--====================
local bAutoFish = Button(pFish,"Auto Fishing : OFF",0)
local bAutoEquip = Button(pFish,"Auto Equip Rod : ON",45)
Label(pFish,"Cast Delay : ".._G.Config.CastDelay.."s\nReel Delay : ".._G.Config.ReelDelay.."s",95,50)

bAutoFish.MouseButton1Click:Connect(function()
	_G.Config.AutoFish = not _G.Config.AutoFish
	bAutoFish.Text = "Auto Fishing : "..(_G.Config.AutoFish and "ON" or "OFF")
end)

bAutoEquip.MouseButton1Click:Connect(function()
	_G.Config.AutoEquip = not _G.Config.AutoEquip
	bAutoEquip.Text = "Auto Equip Rod : "..(_G.Config.AutoEquip and "ON" or "OFF")
end)

--====================
-- TELEPORT TAB
--====================
Label(pTP,"Teleport Template (Safe)\nAdd your own spots",0,60)

local tpSpawn = Button(pTP,"Teleport To Spawn",70)
tpSpawn.MouseButton1Click:Connect(function()
	local c = player.Character
	if c and c:FindFirstChild("HumanoidRootPart") and workspace:FindFirstChild("SpawnLocation") then
		c.HumanoidRootPart.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0,5,0)
	end
end)

--====================
-- MISC TAB
--====================
local bAFK = Button(pMisc,"Anti AFK : OFF",0)
local bHuman = Button(pMisc,"Humanize Delay : ON",45)

bAFK.MouseButton1Click:Connect(function()
	_G.Config.AntiAFK = not _G.Config.AntiAFK
	bAFK.Text = "Anti AFK : "..(_G.Config.AntiAFK and "ON" or "OFF")
end)

bHuman.MouseButton1Click:Connect(function()
	_G.Config.Humanize = not _G.Config.Humanize
	bHuman.Text = "Humanize Delay : "..(_G.Config.Humanize and "ON" or "OFF")
end)

--====================
-- SETTINGS TAB
--====================
Label(pSet,"Educational Executor Panel\nFinal Version",0,60)

--====================
-- FLOATING BUTTON
--====================
local float = Instance.new("TextButton", gui)
float.Size = UDim2.new(0,54,0,54)
float.Position = UDim2.new(0.02,0,0.5,0)
float.Text = "🎣"
float.Font = Enum.Font.GothamBold
float.TextSize = 22
float.BackgroundColor3 = Color3.fromRGB(0,200,255)
float.TextColor3 = Color3.new(0,0,0)
float.BorderSizePixel = 0
float.Visible = false
float.Active = true
float.Draggable = true
Instance.new("UICorner", float).CornerRadius = UDim.new(1,0)

minimize.MouseButton1Click:Connect(function()
	panel.Visible=false
	float.Visible=true
end)

float.MouseButton1Click:Connect(function()
	panel.Visible=true
	float.Visible=false
end)

--====================
-- AUTO EQUIP
--====================
task.spawn(function()
	while task.wait(2) do
		if _G.Config.AutoEquip then
			local c = player.Character
			if c then
				local t = player.Backpack:FindFirstChildWhichIsA("Tool")
				if t then t.Parent = c end
			end
		end
	end
end)

--====================
-- AUTO FISH CORE
--====================
task.spawn(function()
	while task.wait(0.1) do
		if _G.Config.AutoFish then
			mouse1click()
			task.wait(_G.Config.CastDelay + (_G.Config.Humanize and math.random()*0.1 or 0))
			mouse1click()
			task.wait(_G.Config.ReelDelay + (_G.Config.Humanize and math.random()*0.1 or 0))
		end
	end
end)

--====================
-- ANTI AFK
--====================
task.spawn(function()
	while task.wait(45) do
		if _G.Config.AntiAFK then
			cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.2), 0)
		end
	end
end)

print("Fish It Final Panel Loaded")
