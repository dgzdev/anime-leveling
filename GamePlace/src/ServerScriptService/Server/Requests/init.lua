local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Requests = {}

local PlayersManager = require(script.Parent.Players)
local CombatSystem = require(script.Parent.CombatSystem)
local GameData = require(ServerStorage.GameData)

Requests.Events = {
	["Profile"] = function(player: Player)
		local PlayerManager = PlayersManager:GetPlayerManager(player)
		if not PlayerManager then
			return
		end

		local Profile = PlayerManager.Profile
		if not Profile then
			return
		end

		local Data = Profile.Data
		if not Data then
			return
		end

		return Data
	end,
	["Weapons"] = function(player: Player, ItemID: number)
		return GameData.gameWeapons
	end,
	["Respawn"] = function(player: Player)
		local PlayerManager = PlayersManager:GetPlayerManager(player)
		if not PlayerManager then
			return
		end
		PlayerManager:LoadCharacter()
	end,
	["Equip_Hotbar"] = function(player: Player)
		local PlayerManager = PlayersManager:GetPlayerManager(player)
		if not PlayerManager then
			return
		end

		local Profile = PlayerManager.Profile
		if not Profile then
			return
		end

		local Data = Profile.Data
		if not Data then
			return
		end

		local InventoryItem = nil
		local InventoryItemName = nil
		for ItemName, itemProperties in pairs(Data.Inventory) do
			if itemProperties.Id == Data.Equiped.Id then
				InventoryItem = itemProperties
				InventoryItemName = ItemName
				break
			end
		end

		if not InventoryItem then
			return
		end

		Data.Equiped = {
			Weapon = InventoryItemName,
			Id = InventoryItem.Id,
		}

		CombatSystem:Equip(player)

		return Data
	end,
}

function Requests:Receive(player: Player, request: string, ...)
	local Event = self.Events[request]
	if Event then
		return Event(player, ...)
	else
		return error("Event not found.")
	end
end

ReplicatedStorage.Events.Requests.OnServerInvoke = function(...)
	return Requests:Receive(...)
end

return Requests
