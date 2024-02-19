local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local AssetProvider = game:GetService("AssetService")

local menu = StarterGui:WaitForChild("MainMenu")
menu:Clone()

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
menu.Parent = PlayerGui
menu.Enabled = false

local Background = menu:WaitForChild("Background")
local Button = Background:WaitForChild("Buttons")
local Whoosh = Background:WaitForChild("whoosh")
local Hover = Background:WaitForChild("hover")
local Click = Background:WaitForChild("click")

repeat
	task.wait(0.35)
until game:IsLoaded() and Whoosh.TimeLength > 0

ContentProvider:PreloadAsync(Background:GetChildren())

local function MenuTransition()
	local Title1 = Background:WaitForChild("Title1")
	local Title2 = Background:WaitForChild("Title2")

	local FirstDelay = 0.2
	local SecondDelay = 0.2
	local ThirdDelay = 0.6

	local backgroundAnimation = TweenService:Create(Background, TweenInfo.new(0.6), {
		Position = UDim2.fromScale(0, 0),
	})
	local title1Animation = TweenService:Create(
		Title1,
		TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false),
		{
			Position = UDim2.fromScale(0.5, 0.23),
		}
	)
	local title2Animation = TweenService:Create(
		Title2,
		TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false),
		{
			Position = UDim2.fromScale(0.5, 0.3),
		}
	)
	local buttonAnimation = TweenService:Create(
		Button,
		TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false),
		{
			Position = UDim2.fromScale(0.5, 0.5),
		}
	)

	local function Position()
		Background.Position = UDim2.fromScale(-1, 0)
		Title1.Position = UDim2.fromScale(-1, 0.23)
		Title2.Position = UDim2.fromScale(-1, 0.3)
		Button.Position = UDim2.fromScale(-1, 0.5)

		menu.Enabled = true
	end
	local function PlaySwoosh(delay: number)
		task.wait(delay)
		Whoosh:Play()
	end

	Position()

	task.wait(0.5)

	backgroundAnimation:Play()
	backgroundAnimation.Completed:Wait()
	PlaySwoosh(FirstDelay)
	title1Animation:Play()
	title1Animation.Completed:Wait()
	PlaySwoosh(SecondDelay)
	title2Animation:Play()
	title2Animation.Completed:Wait()
	task.wait(0.6)
	PlaySwoosh(ThirdDelay)
	buttonAnimation:Play()
	buttonAnimation.Completed:Wait()
end

local function HideMenu()
	local Start = ReplicatedStorage:WaitForChild("Start")
	Start:FireServer()

	TweenService:Create(
		Background,
		TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false, 0.3),
		{ Position = UDim2.fromScale(-1, 0) }
	):Play()
	task.wait(0.2)
	Whoosh:Play()
	Debris:AddItem(menu, 0.5)
end

local function OnMenuTransitionEnd()
	local Buttons = Button:GetChildren()
	for _, ButtonObject in ipairs(Buttons) do
		if not ButtonObject:IsA("TextButton") then
			continue
		end
		ButtonObject.MouseEnter:Connect(function(x, y)
			Hover:Play()
			local s = ButtonObject:WaitForChild("UIScale")
			TweenService:Create(s, TweenInfo.new(0.2), { Scale = 1.3 }):Play()
		end)
		ButtonObject.MouseLeave:Connect(function(x, y)
			local s = ButtonObject:WaitForChild("UIScale")
			TweenService:Create(s, TweenInfo.new(0.2), { Scale = 1 }):Play()
		end)
		ButtonObject.Activated:Connect(function(inputObject, clickCount)
			if ButtonObject.Name == "Button1" then
				Click:Play()
				HideMenu()
			end
		end)
	end
end

MenuTransition()
OnMenuTransitionEnd()
