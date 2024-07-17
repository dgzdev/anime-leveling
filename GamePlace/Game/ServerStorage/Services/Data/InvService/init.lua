local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolsFolder = ReplicatedStorage.Models.Tools
local InvService = Knit.CreateService({
	Name = "InvService",
	Client = {},
})

local PlayerService
local ToolService

export type ItemData = {
	Id: string,
	Name: string,
	DisplayName: string,
	Class: string,
	Type: string,
	Rank: string,
	Amount: number,
	Params: {},
}

-- Hotbar = {[1] = idDoItemNaPosicao1, [3] = idDoItemNaPosicao1}
export type InventoryData = {
	[number]: ItemData,
}
-- Gerenciar movimentacao, insercao e remocao de itens do inventario do player

function InvService:GetItemByAttribute(Player: Player, Name: string, Value: any)
	local PlayerData = PlayerService:GetData(Player)
	for _, Item in PlayerData.Inventory do
		if Item[Name] == Value then
			return Item
		end
	end
end

function InvService:GetItemById(Player: Player, ItemId: string)
	return InvService:GetItemByAttribute(Player, "Id", ItemId)
end

function InvService:GetItemByName(Player: Player, Name: string)
	return InvService:GetItemByAttribute(Player, "Name", Name)
end

-- carregar inventario, criar tools -> backpack
function InvService:LoadPlayerItems(Player: Player)
	local PlayerData = PlayerService:GetData(Player)

	for index, itemData in pairs(PlayerData.Inventory) do
		InvService:AddItemToBackpack(Player, itemData)
	end
end

-- remover item da data
function InvService:RemoveItemData(Player: Player, ItemId: string)
	local PlayerData = PlayerService:GetData(Player)
	local ItemData = InvService:GetItemById(Player, ItemId)

	if ItemData then
		ItemData = nil
	end
end

--! NA DATA @caioband
function InvService:AddItemToInventory(Player: Player, Item: ItemData)
	if ReplicatedStorage:FindFirstChild(Item.Name) then
		local ItemClone = ReplicatedStorage:FindFirstChild(Item.Name, true):Clone()
		ItemClone.Parent = Player.Backpack
		-----botar parametros e etc
	end
end

-- se tiver espaco na hotbar add la, se nao no inventário.
function InvService:AddItemToPlayer(Player: Player, Item: ItemData) end

function InvService:KnitStart()
	PlayerService = Knit.GetService("PlayerService")
	ToolService = Knit.GetService("ToolService")
end

return InvService
