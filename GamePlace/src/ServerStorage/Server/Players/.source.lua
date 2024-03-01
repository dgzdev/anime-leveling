local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local PlayerManager = require(script:WaitForChild("PlayerManager"))

local GameData = require(ServerStorage.GameData)

local plrs = {}

local Profiles = {}
local PlayerManagers = {}

plrs.OnCharacterAdded = function(playerManager: PlayerManager.PlayerManager, character: Model)
	local Profile = playerManager.Profile
	if not Profile then
		return
	end

	local Data = Profile.Data

	local Slot = Data.Slots[Data.Selected_Slot]
	if Slot == "false" then
		return
	end
end
plrs.OnPlayerAdded = function(player: Player)
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

	local character = player.Character or player.CharacterAdded:Wait()
	plrs.OnCharacterAdded(playerManager, character)

	player.CharacterAdded:Connect(function(c: Model)
		plrs.OnCharacterAdded(playerManager, c)
	end)
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

function plrs:GetPlayerData(player)
	if player:IsA("Model") then
		local _Player = Players:GetPlayerFromCharacter(player)

		if _Player then
			repeat
				task.wait()
			until PlayerManagers[_Player] or not _Player:IsDescendantOf(Players)

			local playerManager = PlayerManagers[_Player]

			local Slot = playerManager:GetCurrentSlot()
			return Slot.Data
		else
			local Data = player:FindFirstChild("Data", true)
			if Data then
				return require(Data)
			else
				return error("[Enemy] Data module not found in enemy model.")
			end
		end
	end

	repeat
		task.wait()
	until PlayerManagers[player] or not player:IsDescendantOf(Players)

	local playerManager = PlayerManagers[player]

	local Slot = playerManager:GetCurrentSlot()
	return Slot.Data
end

function plrs:GetPlayerManager(player: Player)
	if player:IsA("Model") then
		local _Player = Players:GetPlayerFromCharacter(player)

		if _Player then
			repeat
				task.wait()
			until PlayerManagers[player] or not player:IsDescendantOf(Players)
			return PlayerManagers[player]
		else
			local Data = player:FindFirstChild("Data", true)
			if Data then
				return require(Data)
			else
				return error("[Enemy] Data module not found in enemy model.")
			end
		end
	end
	repeat
		task.wait()
	until PlayerManagers[player] or not player:IsDescendantOf(Players)
	return PlayerManagers[player]
end

Players.PlayerAdded:Connect(plrs.OnPlayerAdded)
Players.PlayerRemoving:Connect(plrs.OnPlayerRemoving)

return plrs
