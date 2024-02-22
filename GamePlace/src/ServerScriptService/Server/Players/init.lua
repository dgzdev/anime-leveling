local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PlayerManager = require(script:WaitForChild("PlayerManager"))

local plrs = {}

local Profiles = {}
local PlayerManagers = {}

plrs.OnPlayerAdded = function(player: Player)
	-- Create a HumanoidDescription

	local humanoidDescription = Instance.new("HumanoidDescription")

	humanoidDescription.Shirt = 12244089619
	humanoidDescription.Pants = 12244095027

	--[[
	humanoidDescription:SetAccessories({
		{
			Order = 1,
			AssetId = 12296044398,
			Puffiness = 0.5,
			AccessoryType = Enum.AccessoryType.Front,
		},
		{
			Order = 2,
			AssetId = 12296065618,
			Puffiness = 0.5,
			AccessoryType = Enum.AccessoryType.Hat,
		},

		{
			Order = 3,
			AssetId = 12296048589,
			Puffiness = 0.5,
			AccessoryType = Enum.AccessoryType.Waist,
		},
		{
			Order = 4,
			AssetId = 12296053142,
			Puffiness = 0.5,
			AccessoryType = Enum.AccessoryType.Shoulder,
		},
		{
			Order = 5,
			AssetId = 12296057334,
			Puffiness = 0.5,
			AccessoryType = Enum.AccessoryType.Back,
		},
		{
			Order = 6,
			AssetId = 12296061546,
			Puffiness = 0.5,
			AccessoryType = Enum.AccessoryType.Hat,
		},
	}, false)
	]]
	player:LoadCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	character:WaitForChild("Humanoid"):ApplyDescription(humanoidDescription)

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
