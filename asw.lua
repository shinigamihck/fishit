--// Anti duplicate
if _G.FishItLoaded then return end
_G.FishItLoaded = true

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

--// SETTINGS
_G.S = {
	AutoFish = false,
	AntiAFK = true,
	DelayFishing = 1.8,
	DelayReel = 0.8
}

--// Anti AFK
if _G.S.AntiAFK then
	LP.Idled:Connect(function()
		RunService.Heartbeat:Wait()
	end)
end

--// UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FishItPanel"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.28,0.4)
main.Position = UDim2.fromScale(0.36,0.3)
main.BackgroundColor3 = Color3.fromRGB(18,18,24)
main.Active = true
main.Draggable = true
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

--// Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0.12,0)
title.Text = "Fish It | Simple Panel"
title.TextColor3 = Color3.fromRGB(0,170,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

--// Helper
local function createLabel(text,y)
	local l = Instance.new("TextLabel", main)
	l.Size = UDim2.new(0.9,0,0.08,0)
	l.Position = UDim2.new(0.05,0,y,0)
	l.Text = text
	l.TextColor3 = Color3.new(1,1,1)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.Gotham
	l.TextScaled = true
	return l
end

local function createBox(default,y,callback)
	local b = Instance.new("TextBox", main)
	b.Size = UDim2.new(0.9,0,0.1,0)
	b.Position = UDim2.new(0.05,0,y,0)
	b.Text = tostring(default)
	b.ClearTextOnFocus = false
	b.Font = Enum.Font.Gotham
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(35,35,45)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

	b.FocusLost:Connect(function()
		local v = tonumber(b.Text)
		if v then callback(v) else b.Text = tostring(default) end
	end)
end

local function createButton(text,y,callback)
	local btn = Instance.new("TextButton", main)
	btn.Size = UDim2.new(0.9,0,0.12,0)
	btn.Position = UDim2.new(0.05,0,y,0)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

--// UI CONTENT
createLabel("Delay Fishing (detik)",0.15)
createBox(_G.S.DelayFishing,0.22,function(v)
	_G.S.DelayFishing = math.clamp(v,0.1,10)
end)

createLabel("Delay Reel (detik)",0.34)
createBox(_G.S.DelayReel,0.41,function(v)
	_G.S.DelayReel = math.clamp(v,0.1,10)
end)

local autoBtn
autoBtn = createButton("Auto Fish : OFF",0.55,function()
	_G.S.AutoFish = not _G.S.AutoFish
	autoBtn.Text = "Auto Fish : "..(_G.S.AutoFish and "ON" or "OFF")
end)

createButton("Close Panel",0.7,function()
	gui:Destroy()
end)

--// AUTO FISH LOOP (DUMMY / SIAP DISAMBUNG REMOTE)
task.spawn(function()
	while task.wait() do
		if _G.S.AutoFish then
			print("Fishing...")
			task.wait(_G.S.DelayFishing)
			print("Reel...")
			task.wait(_G.S.DelayReel)
		end
	end
end)

print("Fish It Panel Loaded")
