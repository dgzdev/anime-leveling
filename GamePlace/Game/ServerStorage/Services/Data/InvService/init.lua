local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolsFolder = ReplicatedStorage.Models.Tools
local InvService = Knit.CreateService({
	Name = "InvService",
	Client = {},
})

local PlayerService
local ToolService
local ItemService

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
	["1"]: false | ItemData,
	["2"]: false | ItemData,
	["3"]: false | ItemData,
	["4"]: false | ItemData,
	["5"]: false | ItemData,
	["6"]: false | ItemData,
	["7"]: false | ItemData,
	["8"]: false | ItemData,
	["9"]: false | ItemData,
}

export type InventoryData = {
	[number]: ItemData,
}


--[[ 
	Gerencia a inserção e remoção de itens do inventario e hotbar do player
]]


-- Pega a quantidade de posições disponiveis na hotbar
function InvService:GetHotbarSize(hotbar : HotbarData) : number	
	local Counter = 0
	for i,v in pairs(hotbar) do
		if v then
			Counter += 1 
		end
	end
	return Counter
end

-- Pega o Index da hotbar que está disponivel, caso haja um, se não retorna nil
function InvService:GetHotbarAvailableIndex(hotbar: HotbarData)	: string?
	local Counter = 0
	for i,v in pairs(hotbar) do
		if not v then
			return i 
		end
	end
end

-- Retorna o Index em que um ItemId está na hotbar, caso nao esteja na hotbar, ele retorna nil
function InvService:GetItemIndexInHotbar(hotbar : HotbarData, ItemId: string) : string?
	local Counter = 0
	for i,v in pairs(hotbar) do
		if v == ItemId then
			return i
		end
	end
end

-- Pega um Item a partir de uma propriedade dele @SinceVoid
function InvService:GetItemByAttribute(Player: Player, Name: string, Value: any)
	local PlayerData = PlayerService:GetData(Player)
	for _, Item : ItemData in PlayerData.Inventory do
		if Item[Name] == Value then
			return Item
		end
	end
end

function InvService:GetItemById(Player: Player, ItemId: string) : ItemData
	return InvService:GetItemByAttribute(Player, "Id", ItemId)
end

function InvService:GetItemByName(Player: Player, Name: string) : ItemData
	return InvService:GetItemByAttribute(Player, "Name", Name)
end

-- remover item da data
function InvService:RemoveItemFromInventory(Player: Player, ItemId: string) : nil
	local PlayerData = PlayerService:GetData(Player)
	local ItemData = InvService:GetItemById(Player, ItemId)

	local Index = table.find(PlayerData.Inventory, ItemData)
	if Index then
		table.remove(PlayerData.Inventory, Index)
	end

	local IndexInHotbar = InvService:GetItemIndexInHotbar(PlayerData.Hotbar, ItemId)
	if IndexInHotbar then
		PlayerData.Hotbar[IndexInHotbar] = nil
	end
end

----Verifica se tem o Item no inventario, se tiver, soma nele, caso esteja
function InvService:AddItemToInventory(Player: Player, Item: ItemData)
	local PlayerData = PlayerService:GetData(Player)
	local PossibleItem = InvService:GetItemByName(Player, Item.Name)

	if PossibleItem then
		local PossibleItemInData = ItemService:GetItemFromData(Item.Name)
		if PossibleItemInData.MaxAmount <= Item.Amount then
			table.insert(PlayerData.Inventory, Item)
		else
			if PossibleItemInData.MaxAmount <= (PossibleItem.Amount + Item.Amount) then
				PossibleItem.Amount = PossibleItemInData.MaxAmount
				Item.Amount = (PossibleItem.Amount + Item.Amount) - PossibleItemInData.MaxAmount
				if Item.Amount > 0 then
					table.insert(PlayerData.Inventory, Item)
				end
			else
				PossibleItem.Amount += Item.Amount
			end
		end
	else
		table.insert(PlayerData.Inventory, Item)
	end
end

function InvService:AddItemToHotbar(Player: Player, ItemId: string, Index: number?)
	local PlayerData = PlayerService:GetData(Player)
	local HotbarSize = InvService:GetHotbarSize(PlayerData.Hotbar)

	if HotbarSize < 9 then
		local AvailableIndex = InvService:GetHotbarAvailableIndex(PlayerData.Hotbar)
		if AvailableIndex then 
			PlayerData.Hotbar[AvailableIndex] = ItemId
		else
			if Index and Index <= 9 then
				PlayerData.Hotbar[tostring(Index)] = ItemId
			end
		end
	else
		if Index and Index <= 9 then
			PlayerData.Hotbar[tostring(Index)] = ItemId
		end
	end
end

function InvService:RemoveItemFromHotbarByIndex(Player: Player, Index: number)
	local PlayerData = PlayerService:GetData(Player)
	PlayerData.Hotbar[Index] = nil
end

function InvService:RemoveItemFromHotbarById(Player: Player, ItemId: string)
	local PlayerData = PlayerService:GetData(Player)
	local Index = InvService:GetItemIndexInHotbar(PlayerData.Hotbar, ItemId)
	if Index then
		PlayerData.Hotbar[Index] = nil
	end
end


function InvService:AddItemToPlayer(Player: Player, Item: ItemData, Index: number?) 
	local PlayerData = PlayerService:GetData(Player)
	if PlayerData then
		local HotbarSize = InvService:GetHotbarSize(PlayerData.Hotbar)

		InvService:AddItemToInventory(Player, Item)
		InvService:AddItemToHotbar(Player, Item.Id, Index)
	end
end

function InvService:KnitStart()
	PlayerService = Knit.GetService("PlayerService")
	ToolService = Knit.GetService("ToolService")
	ItemService = Knit.GetService("ItemService")
end

return InvService
