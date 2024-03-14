local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")

for _, service in (ServerScriptService:GetDescendants()) do
	if not service:IsA("ModuleScript") then
		continue
	end
	if not service.Name:match("Service$") then
		continue
	end
	require(service)
end

Knit.Start()

local Packages = ReplicatedStorage.Packages
local Cmdr = require(Packages.cmdr)
local CmdrCustom = game.ServerStorage:WaitForChild("CmdrCustom")

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterCommandsIn(CmdrCustom.Commands)
Cmdr:RegisterHooksIn(CmdrCustom.Hooks)
Cmdr:RegisterTypesIn(CmdrCustom.Types)
