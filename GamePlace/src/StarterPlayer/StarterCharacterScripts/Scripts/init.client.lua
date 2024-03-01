local ModuleManager = {}

if not (game:IsLoaded()) then
	game.Loaded:Wait()
end

local Modules: { [number]: ModuleScript } = script:GetChildren()

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
