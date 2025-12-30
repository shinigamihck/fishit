--====================================================
-- FISH IT | CHLOE FULL PANEL VERSION
-- Panel + Floating Button + Full Features
--====================================================

pcall(function()
	game.CoreGui.FishItChloe:Destroy()
end)

--====================
-- SERVICES
--====================
local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

--====================
-- CONFIG
--====================
_G.FishIt = {
	AutoFish = false,
	AutoReel = false,
	AntiAFK = false,
	AutoEquip = true,
	Humanize = true,
	CastDelay = 1.8,
	ReelDelay = 0.9
}

--====================
-- GUI ROOT
--====================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FishItChloe"

--====================
-- MAIN PANEL
--====================
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0,460,0,380)
panel.Position = UDim2.new(0.05,0,0.22,0)
panel.BackgroundColor3 = Color3.fromRGB(16,18,25)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,18)

-- TITLE
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1,-60,0,46)
title.Position = UDim2.new(0,16,0,0)
title.Text = "🎣 Fish It | Chloe Panel"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Left
title.TextColor3 = Color3.fromRGB(0,220,255)
title.BackgroundTransparency = 1

-- MINIMIZE
local minimize = Instance.new("TextButton", panel)
minimize.Size = UDim2.new(0,34,0,34)
minimize.Position = UDim2.new(1,-42,0,6)
minimize.Text = "—"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundColor3 = Color3.fromRGB(45,45,65)
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BorderSizePixel = 0
Instance.new("UICorner", minimize)

--====================
-- TAB BAR
--====================
local tabBar = Instance.new("Frame", panel)
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.Position = UDim2.new(0,0,0,48)
tabBar.BackgroundTransparency = 1

local function Tab(text,x)
	local b = Instance.new("TextButton", tabBar)
	b.Size = UDim2.new(0,100,0,30)
	b.Position = UDim2.new(0,x,0,5)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(35,35,50)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)
	return b
end

local tFish = Tab("Fishing",10)
local tTP   = Tab("Teleport",120)
local tMisc = Tab("Misc",230)
local tSet  = Tab("Settings",340)

--====================
-- PAGES
--====================
local function Page()
	local f = Instance.new("Frame", panel)
	f.Size = UDim2.new(1,-20,1,-100)
	f.Position = UDim2.new(0,10,0,95)
	f.BackgroundTransparency = 1
	f.Visible = false
	return f
end

local pFish = Page()
local pTP   = Page()
local pMisc = Page()
local pSet  = Page()
pFish.Visible = true

local function Switch(p)
	pFish.Visible=false
	pTP.Visible=false
	pMisc.Visible=false
	pSet.Visible=false
	p.Visible=true
end

tFish.MouseButton1Click:Connect(function() Switch(pFish) end)
tTP.MouseButton1Click:Connect(function() Switch(pTP) end)
tMisc.MouseButton1Click:Connect(function() Switch(pMisc) end)
tSet.MouseButton1Click:Connect(function() Switch(pSet) end)

--====================
-- UI HELPERS
--====================
local function Button(parent,text,y)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,0,0,38)
	b.Position = UDim2.new(0,0,0,y)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(38,38,58)
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
	l.TextColor3 = Color3.fromRGB(170,170,170)
	l.BackgroundTransparency = 1
	return l
end

--====================
-- FISHING TAB
--====================
local bAutoFish = Button(pFish,"Auto Cast : OFF",0)
local bAutoReel = Button(pFish,"Auto Reel : OFF",45)
local bEquip    = Button(pFish,"Auto Equip Rod : ON",90)

Label(pFish,
"Delay Cast : ".._G.FishIt.CastDelay..
"\nDelay Reel : ".._G.FishIt.ReelDelay..
"\nMode : Humanized",140,60)

bAutoFish.MouseButton1Click:Connect(function()
	_G.FishIt.AutoFish = not _G.FishIt.AutoFish
	bAutoFish.Text = "Auto Cast : "..(_G.FishIt.AutoFish and "ON" or "OFF")
end)

bAutoReel.MouseButton1Click:Connect(function()
	_G.FishIt.AutoReel = not _G.FishIt.AutoReel
	bAutoReel.Text = "Auto Reel : "..(_G.FishIt.AutoReel and "ON" or "OFF")
end)

bEquip.MouseButton1Click:Connect(function()
	_G.FishIt.AutoEquip = not _G.FishIt.AutoEquip
	bEquip.Text = "Auto Equip Rod : "..(_G.FishIt.AutoEquip and "ON" or "OFF")
end)

--====================
-- TELEPORT TAB
--====================
Label(pTP,"Safe Teleport Template\n(Add your own spots)",0,60)

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
	_G.FishIt.AntiAFK = not _G.FishIt.AntiAFK
	bAFK.Text = "Anti AFK : "..(_G.FishIt.AntiAFK and "ON" or "OFF")
end)

bHuman.MouseButton1Click:Connect(function()
	_G.FishIt.Humanize = not _G.FishIt.Humanize
	bHuman.Text = "Humanize Delay : "..(_G.FishIt.Humanize and "ON" or "OFF")
end)

--====================
-- SETTINGS
--====================
Label(pSet,"Fish It Coding Panel\nChloe Version\nExecutor Enabled Map",0,80)

--====================
-- FLOATING BUTTON
--====================
local float = Instance.new("TextButton", gui)
float.Size = UDim2.new(0,56,0,56)
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
		if _G.FishIt.AutoEquip then
			local c = player.Character
			if c then
				local tool = player.Backpack:FindFirstChildWhichIsA("Tool")
				if tool then tool.Parent = c end
			end
		end
	end
end)

--====================
-- AUTO CAST / REEL
--====================
task.spawn(function()
	while task.wait(0.2) do
		if _G.FishIt.AutoFish then
			VIM:SendMouseButtonEvent(0,0,0,true,game,0)
			task.wait(0.05)
			VIM:SendMouseButtonEvent(0,0,0,false,game,0)
			task.wait(_G.FishIt.CastDelay + (_G.FishIt.Humanize and math.random()*0.15 or 0))
		end

		if _G.FishIt.AutoReel then
			VIM:SendMouseButtonEvent(0,0,0,true,game,0)
			task.wait(0.05)
			VIM:SendMouseButtonEvent(0,0,0,false,game,0)
			task.wait(_G.FishIt.ReelDelay + (_G.FishIt.Humanize and math.random()*0.15 or 0))
		end
	end
end)

--====================
-- ANTI AFK
--====================
task.spawn(function()
	while task.wait(40) do
		if _G.FishIt.AntiAFK then
			cam.CFrame = cam.CFrame * CFrame.Angles(0,math.rad(0.3),0)
		end
	end
end)

print("Fish It Chloe Panel Loaded")
