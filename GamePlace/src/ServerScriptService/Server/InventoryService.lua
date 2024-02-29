local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ServerStorage = game:GetService("ServerStorage")

local PlayerManager

local InventoryService = Knit.CreateService({
	Name = "InventoryService",
	Client = {
		CreateItem = Knit.CreateSignal(),
		RemoveItem = Knit.CreateSignal(),
	},
})

local GameData = require(ServerStorage.GameData)

function InventoryService:AddItem(player: Player, item: string)
	local Data = PlayerManager:GetPlayerData(player)

	local lastId = 0
	for id, info in pairs(Data.Inventory) do
		lastId = info.Id
	end

	Data.Inventory[lastId + 1] = {
		Id = lastId + 1,
		Name = item,
		Amount = 1,
	}

	self.Client.CreateItem:Fire(player, item)
end

function InventoryService:RemoveItem(player: Player, item: string)
	local Data = PlayerManager:GetPlayerData(player)

	local id
	for _id, info in pairs(Data.Inventory) do
		if info.Name == item then
			Data.Inventory[id] = nil
			id = _id
		end
	end

	self.Client.RemoveItem:Fire(player, {
		Name = item,
		Id = id,
	})
end

InventoryService.Equip = {}
function InventoryService.Equip:Melee() end

function InventoryService:EquipFromData(playerData)
	local equiped = playerData.Equiped
	local weaponData = GameData.gameWeapons[equiped.Weapon]
end

function InventoryService.KnitStart()
	PlayerManager = Knit.GetService("PlayerManager")
end

return InventoryService
