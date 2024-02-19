local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
--!strict
-- Author: @SinceVoid
-- Esse é o arquivo principal do servidor, onde todos os módulos serão carregados.

-- ====================================================================================================
--// Modules
-- ====================================================================================================

require(script:WaitForChild("Players"))

local Characters = Workspace:WaitForChild("Characters")

local function OnPlayerAdded(plr: Player)
	for _, Character in ipairs(Characters:GetChildren()) do
		local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
		local Description = Players:GetHumanoidDescriptionFromUserId(plr.UserId)

		Description.Head = 0
		Description.LeftArm = 0
		Description.RightArm = 0
		Description.LeftLeg = 0
		Description.RightLeg = 0
		Description.Torso = 0

		Humanoid:ApplyDescription(Description, Enum.AssetTypeVerification.Always)
	end
end
local function OnPlayerRemoving(plr: Player) end

local Start = ReplicatedStorage:WaitForChild("Start")
Start.OnServerEvent:Connect(function(player)
	-- * Teleport Player
	if RunService:IsStudio() then
		return player:Kick("[Teleporting] You cannot teleport in studio.")
	end
	TeleportService:TeleportAsync(16437088851, { player })
end)

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
