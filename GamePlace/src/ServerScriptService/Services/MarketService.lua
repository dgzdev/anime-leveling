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

function MarketService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return MarketService
