local Players = game:GetService("Players")
local PlayerManager = require(script:WaitForChild("PlayerManager"))

local plrs = {}

local Profiles = {}
local PlayerManagers = {}

plrs.OnPlayerAdded = function(player: Player)
	-- Create a HumanoidDescription
	local humanoidDescription = Instance.new("HumanoidDescription")
	humanoidDescription.HatAccessory = "12642904224"

	humanoidDescription.BodyTypeScale = 0.1
	humanoidDescription.Face = "20722130"
	humanoidDescription.Shirt = "5249995464"
	humanoidDescription.Pants = "13223845819"

	humanoidDescription.HeadColor = Color3.new(0.7, 0.7, 0.7)
	humanoidDescription.TorsoColor = Color3.new(0.7, 0.7, 0.7)
	humanoidDescription.LeftArmColor = Color3.new(0.7, 0.7, 0.7)
	humanoidDescription.RightArmColor = Color3.new(0.7, 0.7, 0.7)
	humanoidDescription.LeftLegColor = Color3.new(0.7, 0.7, 0.7)
	humanoidDescription.RightLegColor = Color3.new(0.7, 0.7, 0.7)

	player:LoadCharacterWithHumanoidDescription(humanoidDescription)

	local playerManager: PlayerManager.PlayerManager = PlayerManager.new(player)
	if not playerManager then
		return player:Kick("[Players] Error while loading player manager.")
	end

	local Profile = playerManager.Profile
	Profiles[player] = Profile
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

	PlayerManagers[player] = playerManager
end
plrs.OnPlayerRemoving = function(player: Player)
	local Profile = Profiles[player]
	if Profile then
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
