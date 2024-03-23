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

for _, Module: ModuleScript in (script:WaitForChild("Scripts"):GetChildren()) do
	if not (Module:IsA("ModuleScript")) then
		continue
	end

	Modules[Module.Name] = require(Module)
end

for i, m in Modules do
	task.spawn(function()
		if m.Init then
			m:Init(Modules)
		end
	end)
end
