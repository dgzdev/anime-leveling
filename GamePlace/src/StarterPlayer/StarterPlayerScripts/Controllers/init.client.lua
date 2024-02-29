local Controllers = script:GetDescendants()

local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))

if not game:IsLoaded() then
	game.Loaded:Wait()
end

for i, v in ipairs(Controllers) do
	if not v:IsA("ModuleScript") then
		continue
	end

	if v.Name:match("Controller") then
		require(v)
	end
end

Knit.Start({ ServicePromises = false }):catch(warn)
