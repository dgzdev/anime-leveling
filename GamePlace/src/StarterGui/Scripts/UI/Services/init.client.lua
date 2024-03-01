if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))
Knit.OnStart():await()

local services = script:GetChildren()

for _, value in ipairs(services) do
	if not value:IsA("ModuleScript") then
		continue
	end

	local service = require(value)
	if service.Init then
		service:Init()
	end
end
