local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))
local ServerStorage = game:GetService("ServerStorage")

local PlayerManager

local InventoryService = Knit.CreateService({
	Name = "InventoryService",
	Client = {
		UpdateInventory = Knit.CreateSignal(),
		CreateItem = Knit.CreateSignal(),
		RemoveItem = Knit.CreateSignal(),
	},
})

local GameData = require(ServerStorage.GameData)

function InventoryService:AddItem(player: Player, item: string)
	local Data: GameData.PlayerData2 = PlayerManager:GetPlayerData(player)

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
	local Data: GameData.PlayerData2 = PlayerManager:GetPlayerData(player)

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

function InventoryService.KnitStart()
	PlayerManager = Knit.GetService("PlayerManager")
end

return InventoryService
