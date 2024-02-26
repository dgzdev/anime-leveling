local Players = game:GetService("Players")
local Knit = require(game.ReplicatedStorage.Modules.Knit.Knit)

if not game:IsLoaded() then
	game.Loaded:Wait()
end

for i, v in ipairs(script:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Controller$") then
		require(v)
	end
end

Knit.Start({ ServicePromises = false }):catch(warn):await()

local spawn = task.spawn
local Modules = {}

for _, Module: ModuleScript in ipairs(script:WaitForChild("Modules"):GetChildren()) do
	if not (Module:IsA("ModuleScript")) then
		continue
	end

	Modules[Module.Name] = Module
end

for _, Module: ModuleScript in ipairs(script:WaitForChild("Scripts"):GetChildren()) do
	if not (Module:IsA("ModuleScript")) then
		continue
	end

	spawn(function()
		require(Module):Init(Modules)
	end)
end
