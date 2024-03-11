local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local GameData = require(ServerStorage.GameData)

local PlayerService

local MarketService = Knit.CreateService({
	Name = "MarketService",
	Client = {
		BoughtItem = Knit.CreateSignal(),
		TransactionFailed = Knit.CreateSignal(),
	},
})


function MarketService:GetDiscountedItems(Market)
	local items = {}
	if not GameData.gameMarkets[Market] then return end

	for _,itemName in ipairs(GameData.gameMarkets[Market].DiscountItems) do
		table.insert(items, itemName)
	end

	for itemName,itemInfo in pairs(GameData.gameMarkets[Market].Items) do
		if itemInfo.DiscountTotal then	
			table.insert(items,itemName)
		end
	end

	return items
end

function MarketService:IsItemDiscounted(Market : string, itemName: string)

	if typeof(Market) ~= "string" then
		local errorMessage = string.format("Market name must be a string, received: %s", typeof(Market))
		error(errorMessage)
	end

	if typeof(itemName) ~= "string" then
		local errorMessage = string.format("itemName must be a string, received: %s", typeof(itemName))
		error(errorMessage)
	end
	
	if not GameData.gameMarkets[Market] then
		warn("Market not found: ", Market)
		return
	end
	if GameData.gameMarkets[Market].Items[itemName] then
		if table.find(GameData.gameMarkets[Market].DiscountItems, itemName, 1) then
			return GameData.gameMarkets[Market].DiscountTotal
		end
		if GameData.gameMarkets[Market].Items[itemName].DiscountTotal then
			return GameData.gameMarkets[Market].Items[itemName].DiscountTotal
		end
	end
end

function MarketService:GetItemPrice(Market : string, itemName)
	if not GameData.gameMarkets[Market] then
		return
	end
	if typeof(itemName) == "string" then
		local Market = GameData.gameMarkets[Market]
		if Market.Items[itemName] then
			local Discounted = self:IsItemDiscounted(Market, itemName)
			if Discounted then
				local TotalDiscount = Discounted
				return Market.Items[itemName].Price - (Market.Items[itemName].Price * TotalDiscount)
			end	
		end
	else
		local errorMessage = string.format("itemName must be a string, received: %s", typeof(itemName))
		error(errorMessage)
	end
end

function MarketService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return MarketService
