local Players = game:GetService("Players")
local PlayerManager = require(script:WaitForChild("PlayerManager"))

local plrs = {}
local Profiles = {}

plrs.OnPlayerAdded = function(player: Player)
	local playerManager: PlayerManager.PlayerManager = PlayerManager.new(player)
	if not playerManager then
		return player:Kick("[Players] Error while loading player manager.")
	end

	local Profile = playerManager.Profile
	Profiles[player] = Profile
	Profile:ListenToRelease(function()
		Profiles[player] = nil
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

	print(Profile)
end
plrs.OnPlayerRemoving = function(player: Player)
	local Profile = Profiles[player]
	if Profile then
		Profile:Release()
		Profiles[player] = nil
	end
end

Players.PlayerAdded:Connect(plrs.OnPlayerAdded)
Players.PlayerRemoving:Connect(plrs.OnPlayerRemoving)

return plrs
