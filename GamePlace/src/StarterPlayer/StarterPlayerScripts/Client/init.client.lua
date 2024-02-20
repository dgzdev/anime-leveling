local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local VolatileModules: { [number]: Module } = {}
local ModuleManager = {}

local Events = ReplicatedStorage:WaitForChild("Events")
local Profiles = require(ReplicatedStorage.Modules.Profiles)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, false)

if not (Players:GetAttribute("Loaded")) then
	Players:GetAttributeChangedSignal("Loaded"):Wait()
end

local Modules: { [number]: ModuleScript } = script:GetChildren()

ModuleManager.EnableModule = function(self, Module: ModuleScript)
	if Module:IsA("ModuleScript") == false then
		return
	end
	task.spawn(function()
		local Success, Error = pcall(function()
			require(Module)
		end)
		if not Success then
			warn("Failed to load module: " .. Module.Name)
			warn(Error)
		end
	end)
end

for _, Module in ipairs(Modules) do
	ModuleManager:EnableModule(Module)
end

export type Module = {}
