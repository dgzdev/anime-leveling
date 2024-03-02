local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local CameraEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA")

local function LockMouse(boolean: boolean)
	if boolean then
		CameraEvent:Fire("Lock")
	else
		CameraEvent:Fire("Unlock")
	end
end

local CanToggle = true
local function toggleTabGui(TabGui: ScreenGui)
	if not ReplicatedStorage:GetAttribute("FirstTimeAnimationEnd") then
		return
	end

	if PlayerGui:FindFirstChild("loadingScreen") then
		return
	end

	if not CanToggle then
		return
	end

	local Background: Frame = TabGui:WaitForChild("Background")
	local Blur = Lighting:FindFirstChildWhichIsA("BlurEffect") or Instance.new("BlurEffect")
	Blur.Parent = Lighting

	CanToggle = false
	if TabGui.Enabled == true then
		local OriginalPosition = Background.Position
		local anim =
			TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
				Position = UDim2.fromScale(0.5, 1 + Background.Size.Y.Scale / 2),
			})
		TweenService:Create(Blur, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			Size = 0,
		}):Play()
		anim:Play()
		anim.Completed:Wait()

		Background.Position = UDim2.fromScale(0.5, 0.5)

		TabGui.Enabled = false
		CanToggle = true
		Blur.Enabled = false

		LockMouse(true)
	elseif TabGui.Enabled == false then
		local OriginalPosition = UDim2.fromScale(0.5, 0.5)
		Background.Position = UDim2.fromScale(0.5, 1 + Background.Size.Y.Scale / 2)
		Blur.Size = 0
		Blur.Enabled = true

		TabGui.Enabled = true
		LockMouse(false)

		local anim =
			TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
				Position = OriginalPosition,
			})
		TweenService:Create(Blur, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			Size = 24,
		}):Play()
		anim:Play()
		anim.Completed:Wait()
		CanToggle = true
	end
end

ContextActionService:BindAction("Menu_Tab", function(action, state)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	local Player = Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui")

	local Menu_UI = PlayerGui:WaitForChild("Menu_UI")
	for index, value: ScreenGui in ipairs(Menu_UI:GetChildren()) do
		if value.Enabled then
			local Background: Frame = value:WaitForChild("Background")

			local Blur = Lighting:FindFirstChildWhichIsA("BlurEffect") or Instance.new("BlurEffect")
			Blur.Parent = Lighting

			local a = TweenService:Create(
				Background,
				TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
				{
					Position = UDim2.fromScale(0.5, 1 + Background.Size.Y.Scale / 2),
				}
			)
			TweenService:Create(Blur, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
				Size = 0,
			}):Play()
			a:Play()
			a.Completed:Wait()
			value.Enabled = false
			LockMouse(true)

			return
		end
	end

	local TabGui = PlayerGui:WaitForChild("TabGui")

	toggleTabGui(TabGui)
end, false, Enum.KeyCode.Tab)
