local HttpService = game:GetService("HttpService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ItemService = Knit.CreateService({
	Name = "ItemService",
})

local ItemsIndex = require(game.ServerStorage.GameData.Items)

local AllItems = {}

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

function ItemService:DeepCopyTable(t)
	local copy = {}
	for key, value in t do
		if type(value) == "table" then
			copy[key] = ItemService:DeepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

function ItemService:DeleteItem(Item)
	for i in pairs(Item) do
		Item[i] = nil
	end
	Item = nil
end

function ItemService:GetItemFromData(ItemName: string)
	return AllItems[ItemName]
end

function ItemService:GenerateId()
	return HttpService:GenerateGUID(false):sub(1, 16)
end

function ItemService:CreateItem(ItemName: string, Amount: number?)
	local ItemTable = ItemsIndex[ItemName]
	local MaxAmount = ItemTable.MaxAmount or 1
	if not ItemTable then
		return
	end
	local ItemClone = ItemService:DeepCopyTable(ItemTable)

	local Item = {}
	local Amount = math.min(Amount or 1, MaxAmount)
	Item.Name = ItemClone.Name
	Item.DisplayName = ItemClone.DisplayName
	Item.Class = ItemClone.Class
	Item.Type = ItemClone.Type
	Item.Rank = ItemClone.Rank
	Item.Amount = Amount
	Item.Id = ItemService:GenerateId()

	return Item
end

function ItemService.KnitInit()
	for _, Module in game.ServerStorage.GameData.Items:GetChildren() do
		if not Module:IsA("ModuleScript") then
			continue
		end

		for i,v in require(Module) do
			AllItems[v.Name] = v
		end
	end
end

return ItemService
