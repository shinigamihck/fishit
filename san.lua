--==============================
-- FISH IT | SIMPLE FINAL + WEBHOOK
--==============================

if getgenv().FISHIT_FINAL then return end
getgenv().FISHIT_FINAL = true

pcall(function()
	game.CoreGui.FishItSimpleFinal:Destroy()
end)

-- SERVICES
local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

--==============================
-- CONFIG
--==============================
_G.CFG = {
	AutoFish = false,
	AutoSell = false,
	AutoWeather = false,
	AntiAFK = false,

	CastDelay = 1.8,
	ReelDelay = 0.9,
	SellDelay = 60,
	Weather = "Storm", -- Windy / Cloudy / Storm
}

--==============================
-- WEBHOOK
--==============================
local WEBHOOK = {
	Enabled = true,
	URL = "PASTE_WEBHOOK_URL",
	Name = "Fish It Logger"
}

local function SendLog(title, msg)
	if not WEBHOOK.Enabled or WEBHOOK.URL == "" then return end
	pcall(function()
		HttpService:PostAsync(
			WEBHOOK.URL,
			HttpService:JSONEncode({
				username = WEBHOOK.Name,
				embeds = {{
					title = title,
					description = msg,
					color = 4886754,
					timestamp = DateTime.now():ToIsoDate()
				}}
			}),
			Enum.HttpContentType.ApplicationJson
		)
	end)
end

--==============================
-- UI
--==============================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FishItSimpleFinal"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,270,0,270)
main.Position = UDim2.new(0.05,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(20,22,30)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-60,0,36)
title.Position = UDim2.new(0,10,0,0)
title.Text = "Fish It | Simple"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(0,200,255)
title.BackgroundTransparency = 1
title.TextXAlignment = Left

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,28,0,28)
close.Position = UDim2.new(1,-32,0,4)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(50,50,70)
close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", close)

local mini = Instance.new("TextButton", main)
mini.Size = UDim2.new(0,28,0,28)
mini.Position = UDim2.new(1,-64,0,4)
mini.Text = "-"
mini.Font = Enum.Font.GothamBold
mini.TextSize = 18
mini.BackgroundColor3 = Color3.fromRGB(50,50,70)
mini.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", mini)

local float = Instance.new("TextButton", gui)
float.Size = UDim2.new(0,48,0,48)
float.Position = UDim2.new(0.02,0,0.5,0)
float.Text = "🎣"
float.Visible = false
float.Active = true
float.Draggable = true
float.BackgroundColor3 = Color3.fromRGB(0,200,255)
float.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", float).CornerRadius = UDim.new(1,0)

mini.MouseButton1Click:Connect(function()
	main.Visible = false
	float.Visible = true
end)

float.MouseButton1Click:Connect(function()
	main.Visible = true
	float.Visible = false
end)

close.MouseButton1Click:Connect(function()
	SendLog("Panel Closed", player.Name.." closed panel")
	gui:Destroy()
	getgenv().FISHIT_FINAL = nil
end)

--==============================
-- UI HELPERS
--==============================
local function Btn(txt,y)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(1,-20,0,32)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = txt
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.BackgroundColor3 = Color3.fromRGB(40,42,60)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b)
	return b
end

local function Box(ph,y,val)
	local t = Instance.new("TextBox", main)
	t.Size = UDim2.new(1,-20,0,30)
	t.Position = UDim2.new(0,10,0,y)
	t.PlaceholderText = ph
	t.Text = val
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	t.BackgroundColor3 = Color3.fromRGB(35,35,50)
	t.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", t)
	return t
end

--==============================
-- CONTROLS
--==============================
local bFish = Btn("Auto Fishing : OFF",40)
local bSell = Btn("Auto Sell : OFF",75)
local bWea  = Btn("Auto Weather : OFF",110)
local bAFK  = Btn("Anti AFK : OFF",145)

local dCast = Box("Cast Delay",185,"1.8")
local dReel = Box("Reel Delay",220,"0.9")

bFish.MouseButton1Click:Connect(function()
	_G.CFG.AutoFish = not _G.CFG.AutoFish
	bFish.Text = "Auto Fishing : "..(_G.CFG.AutoFish and "ON" or "OFF")
	SendLog("Auto Fish", bFish.Text)
end)

bSell.MouseButton1Click:Connect(function()
	_G.CFG.AutoSell = not _G.CFG.AutoSell
	bSell.Text = "Auto Sell : "..(_G.CFG.AutoSell and "ON" or "OFF")
	SendLog("Auto Sell", bSell.Text)
end)

bWea.MouseButton1Click:Connect(function()
	_G.CFG.AutoWeather = not _G.CFG.AutoWeather
	bWea.Text = "Auto Weather : "..(_G.CFG.AutoWeather and "ON" or "OFF")
	SendLog("Auto Weather", bWea.Text.." (".._G.CFG.Weather..")")
end)

bAFK.MouseButton1Click:Connect(function()
	_G.CFG.AntiAFK = not _G.CFG.AntiAFK
	bAFK.Text = "Anti AFK : "..(_G.CFG.AntiAFK and "ON" or "OFF")
end)

dCast.FocusLost:Connect(function()
	_G.CFG.CastDelay = tonumber(dCast.Text) or _G.CFG.CastDelay
end)

dReel.FocusLost:Connect(function()
	_G.CFG.ReelDelay = tonumber(dReel.Text) or _G.CFG.ReelDelay
end)

--==============================
-- LOOPS (TEMPLATE REMOTE READY)
--==============================
task.spawn(function()
	while task.wait(0.2) do
		if _G.CFG.AutoFish then
			VIM:SendMouseButtonEvent(0,0,0,true,game,0)
			task.wait(0.05)
			VIM:SendMouseButtonEvent(0,0,0,false,game,0)
			task.wait(_G.CFG.CastDelay)

			VIM:SendMouseButtonEvent(0,0,0,true,game,0)
			task.wait(0.05)
			VIM:SendMouseButtonEvent(0,0,0,false,game,0)
			task.wait(_G.CFG.ReelDelay)
		end
	end
end)

task.spawn(function()
	while task.wait(_G.CFG.SellDelay) do
		if _G.CFG.AutoSell then
			-- Sell Remote Here
			SendLog("Auto Sell", "Sell executed")
		end
	end
end)

task.spawn(function()
	while task.wait(15) do
		if _G.CFG.AutoWeather then
			-- Buy Weather Remote Here
		end
	end
end)

task.spawn(function()
	while task.wait(30) do
		if _G.CFG.AntiAFK then
			VIM:SendKeyEvent(true,"A",false,game)
			task.wait(0.1)
			VIM:SendKeyEvent(false,"A",false,game)
		end
	end
end)

SendLog("Script Loaded", player.Name.." loaded Fish It Simple Final")
print("Fish It Simple Final Loaded")
