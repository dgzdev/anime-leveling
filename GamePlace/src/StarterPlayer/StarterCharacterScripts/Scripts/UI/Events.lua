local Events = {}

local CameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CAMERA")
local SoundService = game:GetService("SoundService")

Events.Buttons = {
	["Close"] = function(Gui: GuiButton)
		Gui:FindFirstAncestorWhichIsA("ScreenGui").Enabled = false
		CameraEvent:Fire("Lock")
	end,
	["Default"] = function(Gui: GuiButton)
		SoundService:WaitForChild("SFX"):WaitForChild("UIClick"):Play()
	end,
}
Events.Hover = {
	["Default"] = function(Gui: GuiButton)
		if Gui:GetAttribute("Ignore") then
			return
		end
		SoundService:WaitForChild("SFX"):WaitForChild("UIHover"):Play()
	end,
}

return Events
