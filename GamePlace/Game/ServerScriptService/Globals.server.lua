local RunService = game:GetService("RunService")

local isStudio = RunService:IsStudio() == true

local globals = {
	Debug = false,
	print = function(...)
		if _G.Debug then
			warn("[DEBUG]", ...)
		end
	end,
}

do --> ### Carrega as variaveis globais do servidor.
	if isStudio then
		globals.Debug = true
	end

	_G = globals
	for index, value in globals do
		_G[index] = value
	end

	if globals.Debug then
		warn("[GLOBALS] Debug is enabled.")
	end
end

do --> ### Carrega os serviços do servidor.
	debug.profilebegin("Knit Start")
	local Knit = require(game.ReplicatedStorage.Packages.Knit)

	local Players = game:GetService("Players")

	for _, service in (game.ServerStorage:GetDescendants()) do
		debug.profilebegin(service.Name .. " Load")
		if not service:IsA("ModuleScript") then
			continue
		end
		if not service.Name:match("Service$") then
			continue
		end
		require(service)
		debug.profileend()
	end

	Knit.Start()
	debug.profileend()

	debug.profilebegin("CMDR Load")
	local Packages = game.ReplicatedStorage.Packages
	local Cmdr = require(Packages.cmdr)
	local CmdrCustom = game.ServerStorage:WaitForChild("CmdrCustom")

	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(CmdrCustom.Commands)
	Cmdr:RegisterHooksIn(CmdrCustom.Hooks)
	Cmdr:RegisterTypesIn(CmdrCustom.Types)
	debug.profileend()
end
