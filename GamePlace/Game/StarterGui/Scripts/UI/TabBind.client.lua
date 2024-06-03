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

	TabGui:WaitForChild("Inventory").Enabled = not TabGui:WaitForChild("Inventory").Enabled
	for _, a in TabGui:WaitForChild("Hotbar"):GetDescendants() do
		if not a:IsA("TextButton") then
			continue
		end

		local slotContainer = a:FindFirstChild("SlotContainer", true)
		if slotContainer then
			if #slotContainer:GetChildren() == 1 then
				a.Visible = TabGui:WaitForChild("Inventory").Enabled
			end
		end
	end
end

ContextActionService:BindAction("Menu_Tab", function(action, state)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	local TabGui = PlayerGui:WaitForChild("Inventory")

	toggleTabGui(TabGui)
end, false, Enum.KeyCode.Tab)
