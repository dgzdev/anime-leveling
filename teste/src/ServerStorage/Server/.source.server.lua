local Knit = require(game.ReplicatedStorage.Modules.Knit.Knit)
local Players = game:GetService("Players")
--!strict
-- Author: @SinceVoid
-- Esse é o arquivo principal do servidor, onde todos os módulos serão carregados.

-- ====================================================================================================
--// Modules
-- ====================================================================================================
task.spawn(function()
	require(script:WaitForChild("Requests"))
	require(script:WaitForChild("Players"))
	require(script:WaitForChild("Inventory"))
	require(script:WaitForChild("NPC")):Start()
end)
local combat = require(script:WaitForChild("CombatSystem"))

for _, service in ipairs(game.ServerScriptService:GetDescendants()) do
	if not service:IsA("ModuleScript") then
		continue
	end
	if not service.Name:match("Service$") then
		continue
	end
	require(service)
end

Knit.Start():andThen(function()
	print("Knit started")
end)

local function OnPlayerAdded(plr: Player)
	combat:Equip(plr)
	plr.CharacterAdded:Connect(function(character)
		combat:Equip(plr)
	end)
end
local function OnPlayerRemoving(plr: Player) end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
