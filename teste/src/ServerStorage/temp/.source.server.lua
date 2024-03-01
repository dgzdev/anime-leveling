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
		local m = require(Module)
		if m.Init then
			m:Init(Modules)
		end
	end)
end
