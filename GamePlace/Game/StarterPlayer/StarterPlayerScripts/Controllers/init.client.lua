local ContentProvider = game:GetService("ContentProvider")
local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))

if not game:IsLoaded() then
	game.Loaded:Wait()
end

ContentProvider:PreloadAsync(script:GetDescendants())

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Controllers = {}
for _, script in (script:GetDescendants()) do
	if not script:IsA("ModuleScript") then
		continue
	end
	if script.Name:match("Controller$") then
		table.insert(Controllers, script)
	end
end

for _, script in (Character:GetDescendants()) do
	if not script:IsA("ModuleScript") then
		continue
	end
	if script.Name:match("Controller$") then
		table.insert(Controllers, script)
	end
end

for i, v in Controllers do
	require(v)
end

Knit.Start({ ServicePromises = false }):andThen(function()
	print("Knit client started")
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local GroupId = 3158193

local function isPlayerAdmin(player: Player)
	local rank
	local success
	local err

	repeat
		success, err = pcall(function()
			rank = player:GetRankInGroup(GroupId)
		end)

		if not success then
			warn("Failed to get player rank:", err)
		end

		RunService.RenderStepped:Wait()

	until success

	return rank >= 157
end

if isPlayerAdmin(game.Players.LocalPlayer) then
	Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
else
	Cmdr:SetActivationKeys({})
end