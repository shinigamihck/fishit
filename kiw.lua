-- FISH IT | WORKING PANEL CORE

pcall(function()
	game.CoreGui.FishItUI:Destroy()
end)

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

_G.AutoFish = false
_G.AntiAFK = false

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FishItUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,300,0,200)
main.Position = UDim2.new(0.05,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,30)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "Fish It Panel"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local function Btn(text,y)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(1,-20,0,35)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.BackgroundColor3 = Color3.fromRGB(40,40,55)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b)
	return b
end

local auto = Btn("Auto Fish : OFF",50)
local afk  = Btn("Anti AFK : OFF",95)

auto.MouseButton1Click:Connect(function()
	_G.AutoFish = not _G.AutoFish
	auto.Text = "Auto Fish : "..(_G.AutoFish and "ON" or "OFF")
end)

afk.MouseButton1Click:Connect(function()
	_G.AntiAFK = not _G.AntiAFK
	afk.Text = "Anti AFK : "..(_G.AntiAFK and "ON" or "OFF")
end)

-- AUTO FISH LOOP
task.spawn(function()
	while task.wait(1) do
		if _G.AutoFish then
			VIM:SendMouseButtonEvent(0,0,0,true,game,0)
			task.wait(0.1)
			VIM:SendMouseButtonEvent(0,0,0,false,game,0)
		end
	end
end)

-- ANTI AFK
task.spawn(function()
	while task.wait(30) do
		if _G.AntiAFK then
			VIM:SendKeyEvent(true,"W",false,game)
			task.wait(0.1)
			VIM:SendKeyEvent(false,"W",false,game)
		end
	end
end)

print("Fish It WORKING loaded")
