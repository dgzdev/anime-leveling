local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

if not (game:IsLoaded()) then
	game.Loaded:Wait()
end

local spawn = task.spawn
local Modules = {}

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, false)

for _, Module: ModuleScript in ipairs(script:WaitForChild("Scripts"):GetChildren()) do
	if not (Module:IsA("ModuleScript")) then
		continue
	end

	spawn(function()
		local m = require(Module)
		if m.Init then
			m:Init(Modules)
		end
	end)
end
