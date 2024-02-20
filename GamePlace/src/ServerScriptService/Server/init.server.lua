local Players = game:GetService("Players")
--!strict
-- Author: @SinceVoid
-- Esse é o arquivo principal do servidor, onde todos os módulos serão carregados.

-- ====================================================================================================
--// Modules
-- ====================================================================================================
task.spawn(function()
	require(script:WaitForChild("Players"))
	require(script:WaitForChild("Inventory"))
	require(script:WaitForChild("Enemies"))
	require(script:WaitForChild("NPC")):Start()
end)

local combat = require(script:WaitForChild("CombatSystem"))

local function OnPlayerAdded(plr: Player)
	combat:Equip(plr)
end
local function OnPlayerRemoving(plr: Player) end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
