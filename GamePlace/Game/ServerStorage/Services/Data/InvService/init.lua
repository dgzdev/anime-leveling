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

export type HotbarData = {
	Pos: number,
	ItemId: string
}

-- Hotbar ={["1"] = {}}

-- Hotbar = {[1] = idDoItemNaPosicao1, [3] = idDoItemNaPosicao1}
export type InventoryData = {
	[number]: ItemData,
}
-- Gerenciar movimentacao, insercao e remocao de itens do inventario do player

local function CheckObjSize(obj)	
	local Counter = 0
	for i,v in pairs(obj) do
		Counter += 1 
	end
	return Counter
end

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

-- remover item da data
function InvService:RemoveItemData(Player: Player, ItemId: string)
	local PlayerData = PlayerService:GetData(Player)
	local ItemData = InvService:GetItemById(Player, ItemId)

	local Index = table.find(PlayerData.Inventory, ItemData)
	if Index then
		table.remove(PlayerData.Inventory, Index)
	end
end


function InvService:AddItemToInventory(Player: Player, Item: ItemData)
	local PlayerData = PlayerService:GetData(Player)
	if PlayerData then
		table.insert(PlayerData.Inventory, Item)
	end
end

-- se tiver espaco na hotbar add la, se nao no inventário.
function InvService:AddItemToPlayer(Player: Player, Item: ItemData, hpos: number?) 
	local PlayerData = PlayerService:GetData(Player)
	if PlayerData then
		local HotbarSize = CheckObjSize(PlayerData.Hotbar)
		if HotbarSize < 9 then
			table.insert(Player.Hotbar, Item)
		else
			if hpos then
				local currentPosId = PlayerData.Hotbar[hpos]
				self:GetItemById(currentPosId)
			end
		end
	end
end

function InvService:KnitStart()
	PlayerService = Knit.GetService("PlayerService")
	ToolService = Knit.GetService("ToolService")
end

return InvService
