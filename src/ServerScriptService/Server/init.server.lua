local Players = game:GetService("Players")
--!strict
-- Author: @SinceVoid
-- Esse é o arquivo principal do servidor, onde todos os módulos serão carregados.

-- ====================================================================================================
--// Modules
-- ====================================================================================================

require(script:WaitForChild("Players"))
require(script:WaitForChild("Inventory"))

local function OnPlayerAdded(plr: Player) end
local function OnPlayerRemoving(plr: Player) end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
