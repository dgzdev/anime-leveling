local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")

task.spawn(function()
	require(script:WaitForChild("NPC")):Start()
end)

for _, service in ipairs(game.ServerScriptService:GetDescendants()) do
	if not service:IsA("ModuleScript") then
		continue
	end
	if not service.Name:match("Service$") then
		continue
	end
	require(service)
end

Knit.Start()
