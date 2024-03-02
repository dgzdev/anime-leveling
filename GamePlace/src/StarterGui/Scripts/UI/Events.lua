local Events = {}

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CAMERA")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(game.ReplicatedStorage.Packages.Knit)
Knit.OnStart():await()

local QuestService = Knit.GetService("QuestService")

print(QuestService)


local function LockMouse(boolean: boolean)
	if boolean then
		CameraEvent:Fire("Lock")
	else
		CameraEvent:Fire("Unlock")
	end
end

local CanToggle = true
local function toggleTabGui(TabGui: ScreenGui)
	if not CanToggle then
		return
	end

	local Background: Frame = TabGui:WaitForChild("Background")

	CanToggle = false
	if TabGui.Enabled == true then
		local OriginalPosition = Background.Position
		local anim =
			TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
				Position = UDim2.fromScale(0.5, 1 + Background.Size.Y.Scale / 2),
			})
		anim:Play()
		anim.Completed:Wait()

		Background.Position = OriginalPosition

		TabGui.Enabled = false
		CanToggle = true
	elseif TabGui.Enabled == false then
		local OriginalPosition = Background.Position

		Background.Position = UDim2.fromScale(0.5, 1 + Background.Size.Y.Scale / 2)

		TabGui.Enabled = true
		local anim =
			TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
				Position = OriginalPosition,
			})
		anim:Play()
		anim.Completed:Wait()
		CanToggle = true
	end
end

Events.Buttons = {
	["Close"] = function(Gui: GuiButton)
		Gui:FindFirstAncestorWhichIsA("ScreenGui").Enabled = false
		CameraEvent:Fire("Lock")
	end,

	["Accept_Quest"] = function(Gui: GuiButton)
		Gui:FindFirstAncestorOfClass("ScreenGui").Enabled = false
		QuestService:AcceptQuest(game.Players.LocalPlayer)
		LockMouse(true)
	end,
	["Refuse_Quest"] = function(Gui: GuiButton)
		Gui:FindFirstAncestorOfClass("ScreenGui").Enabled = false
		QuestService:DenyQuest(game.Players.LocalPlayer)
		LockMouse(true)
	end,

	["Default"] = function(Gui: GuiButton)
		SoundService:WaitForChild("SFX"):WaitForChild("UIClick"):Play()
	end,
	["MenuGui"] = function(Gui: GuiButton)
		local Player = Players.LocalPlayer
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local TabGui = PlayerGui:WaitForChild("TabGui")
		toggleTabGui(TabGui)

		local g: ScreenGui = PlayerGui:WaitForChild("Menu_UI"):WaitForChild(Gui.Name)
		local gBackground: Frame = g:WaitForChild("Background")

		local OriginalPosition = UDim2.fromScale(0.5, 0.5)

		g.Enabled = true

		gBackground.Position = UDim2.fromScale(0.5, 1 + gBackground.Size.Y.Scale / 2)
		local a = TweenService:Create(gBackground, TweenInfo.new(0.25), {
			Position = OriginalPosition,
		})
		a:Play()
		a.Completed:Wait()
	end,
}
Events.Hover = {
	["Default"] = function(Gui: GuiButton)
		if Gui:GetAttribute("Ignore") then
			return
		end
		SoundService:WaitForChild("SFX"):WaitForChild("UIHover"):Play()
	end,

	["MenuGui"] = function(Gui: GuiButton)
		SoundService:WaitForChild("SFX"):WaitForChild("UIHover"):Play()
		local UIScale = Gui:FindFirstChildWhichIsA("UIScale")
		if UIScale then
			TweenService:Create(UIScale, TweenInfo.new(0.25), { Scale = 1.15 }):Play()
		end
	end,
}
Events.HoverEnd = {
	["MenuGui"] = function(Gui: GuiButton)
		local UIScale = Gui:FindFirstChildWhichIsA("UIScale")
		if UIScale then
			TweenService:Create(UIScale, TweenInfo.new(0.25), { Scale = 1 }):Play()
		end
	end,
}

return Events
