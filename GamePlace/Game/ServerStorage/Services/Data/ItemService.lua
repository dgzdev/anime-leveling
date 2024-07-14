local HttpService = game:GetService("HttpService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ItemService = Knit.CreateService({
    Name = "ItemService",
})

local ItemsIndex = require(game.ServerStorage.GameData.Items)

function ItemService:DeepCopyTable(t)
	local copy = {}
	for key, value in pairs(t) do
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

function ItemService:GenerateId()
    return HttpService:GenerateGUID(false):sub(1, 12)
end

function ItemService:CreateItem(ItemName: string, Amount: number?)
    local ItemTable = ItemsIndex[ItemName]
    local MaxAmount = ItemTable.MaxAmount or 1
    if not ItemTable then return end
    local Item = ItemService:DeepCopyTable(ItemTable)
    Item.MaxAmount = MaxAmount
    local Amount = math.min(Amount or 1, MaxAmount)

    Item.Amount = Amount

    Item.Id = ItemService:GenerateId()
    return Item
end

return ItemService