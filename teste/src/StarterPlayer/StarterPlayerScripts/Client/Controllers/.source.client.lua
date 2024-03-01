local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Controllers = {}
for _, script in ipairs(script:GetDescendants()) do
	if not script:IsA("ModuleScript") then
		continue
	end
	if script.Name:match("Controller$") then
		table.insert(Controllers, script)
	end
end

for _, script in ipairs(Character:GetDescendants()) do
	if not script:IsA("ModuleScript") then
		continue
	end
	if script.Name:match("Controller$") then
		table.insert(Controllers, script)
	end
end

for i, v in ipairs(Controllers) do
	require(v)
end

Knit.Start({ ServicePromises = false }):catch(warn)
