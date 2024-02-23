local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PlayerManager = require(script:WaitForChild("PlayerManager"))

local plrs = {}

local Profiles = {}
local PlayerManagers = {}

plrs.OnPlayerAdded = function(player: Player)
	local playerManager: PlayerManager.PlayerManager = PlayerManager.new(player)
	if not playerManager then
		return player:Kick("[Players] Error while loading player manager.")
	end

	local Profile = playerManager.Profile
	Profiles[player] = Profile
	if not (RunService:IsStudio()) then
		Profile:ListenToRelease(function()
			Profiles[player] = nil
			PlayerManagers[player] = nil
			playerManager = nil
			Profile = nil
			player:Kick()
		end)

		local isBanned = Profile:GetMetaTag("Banned") == true
		if isBanned then
			player:Kick("[Players] You are banned from this game.")
			Profile:Release()
			return
		end
	end

	PlayerManagers[player] = playerManager
end
plrs.OnPlayerRemoving = function(player: Player)
	local Profile = Profiles[player]
	if Profile and not (RunService:IsStudio()) then
		Profile:Release()
		Profiles[player] = nil
	end
end

function plrs:GetPlayerProfile(player: Player)
	return Profiles[player]
end

function plrs:GetPlayerManager(player: Player)
	repeat
		task.wait()
	until PlayerManagers[player] or not player:IsDescendantOf(Players)
	return PlayerManagers[player]
end

Players.PlayerAdded:Connect(plrs.OnPlayerAdded)
Players.PlayerRemoving:Connect(plrs.OnPlayerRemoving)

return plrs
