local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VolatileModules: { [number]: Module } = {}
local ModuleManager = {}

local Events = ReplicatedStorage:WaitForChild("Events")
local Profiles = require(ReplicatedStorage.Modules.Profiles)

local Modules: { [number]: ModuleScript } = script:GetChildren()

if not (Players:GetAttribute("Loaded")) then
	Players:GetAttributeChangedSignal("Loaded"):Wait()
end

ModuleManager.EnableModule = function(self, Module: ModuleScript)
	if Module:IsA("ModuleScript") == false then
		return
	end
	task.spawn(function()
		require(Module)
	end)
end

for _, Module in ipairs(Modules) do
	ModuleManager:EnableModule(Module)
end

export type Module = {}
