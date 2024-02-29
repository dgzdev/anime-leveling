local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controlers = script:GetDescendants()

local Knit = require(ReplicatedStorage.Packages.Knit)

local Controllers = {}
for _, service in ipairs(Controlers) do
	if not service:IsA("ModuleScript") then
		continue
	end
	if not service.Name:match("Controller$") then
		continue
	end
	Controllers[#Controllers + 1] = require(service)
end

Knit.OnStart():await()

for _, controller in ipairs(Controllers) do
	controller.KnitInit()
end
