local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")

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

	local Inventory = TabGui:WaitForChild("Inventory")

	Inventory.Enabled = not Inventory.Enabled
	if Inventory.Enabled then
		if UserInputService.GamepadEnabled then
			GamepadService:EnableGamepadCursor(Inventory:WaitForChild("Background"))
		end
	else
		if UserInputService.GamepadEnabled then
			GamepadService:DisableGamepadCursor()
		end
	end

	for _, a in TabGui:WaitForChild("Hotbar"):GetDescendants() do
		if not a:IsA("TextButton") then
			continue
		end

		local slotContainer = a:FindFirstChild("SlotContainer", true)
		if slotContainer then
			if #slotContainer:GetChildren() == 0 then
				a.Visible = Inventory.Enabled
			end
		end
	end
end

local TabKeys = { Enum.KeyCode.Tab, Enum.KeyCode.ButtonY }

ContextActionService:BindAction("Menu_Tab", function(action, state)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	local TabGui = PlayerGui:WaitForChild("Inventory")

	toggleTabGui(TabGui)
end, false, table.unpack(TabKeys))
