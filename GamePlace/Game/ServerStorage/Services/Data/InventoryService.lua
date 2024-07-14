local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local PlayerService
local HotbarService

local InventoryService = Knit.CreateService({
	Name = "InventoryService",
	Client = {},
})

local GameData = require(ServerStorage.GameData)

function InventoryService:GetItemById(Player: Player, Id: string): boolean
	local Inventory = InventoryService:GetPlayerInventory(Player)

	for _, item in Inventory do
		if item.Id == Id then
			return item
		end
	end

	return false
end

function InventoryService:AddItemToHotbar(Player, itemId, posInHotbar)
	local Data = PlayerService:GetData(Player)
	if not InventoryService:GetItemById(Player, itemId) then
		return
	end

	if table.find(Data.Hotbar, itemId) then
		local posInHotbar = tostring(posInHotbar)
		if Data.Hotbar[posInHotbar] then
			local CurrentPos = table.find(Data.Hotbar, itemId)
			local TargetPos = table.find(Data.Hotbar, posInHotbar)

			Data.Hotbar[tostring(CurrentPos)] = Data.Hotbar[tostring(TargetPos)]
			Data.Hotbar[tostring(TargetPos)] = itemId
			self.Client.HotbarUpdate:Fire(Player, Data)
			return Data.Hotbar
		end
		return
	end

	Data.Hotbar[posInHotbar] = itemId
end

function InventoryService:GetPlayerInventory(Player)
	local Data = PlayerService:GetData(Player)
	return Data.Inventory or {}
end

function InventoryService.Client:GetPlayerInventory(player)
	return self.Server:GetPlayerInventory(player)
end

function InventoryService.Client:AddItemToHotbar(Player, itemName, posInHotbar)
	return self.Server:AddItemToHotbar(Player, itemName, posInHotbar)
end

function InventoryService:AddItem(player: Player, item)
	local Data = PlayerService:GetData(player)

	local firstpos
	for i,v in Data.Hotbar do
		if v == nil then
			firstpos = i
			break
		end
	end

	table.insert(Data.Inventory, item)
	if firstpos then
		InventoryService:AddItemToHotbar(player, item.Id, firstpos )
	end

	HotbarService:RenderItems(player)
	
end

function InventoryService:RemoveItem(player: Player, item: string)
	local Data = PlayerService:GetData(player)

	local id
	for _id, info in Data.Inventory do
		if info.Name == item then
			Data.Inventory[id] = nil
			id = _id
		end
	end

end

function InventoryService:GetGameWeapons()
	return GameData.gameWeapons, GameData.rarity
end

function InventoryService.Client:GetGameWeapons()
	return self.Server:GetGameWeapons()
end

function InventoryService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
	HotbarService = Knit.GetService("HotbarService")
end

return InventoryService