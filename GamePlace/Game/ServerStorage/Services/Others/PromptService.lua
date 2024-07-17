local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local MainEvents = ReplicatedStorage.Events:FindFirstChild("MainEvents") :: RemoteEvent

local Knit = require(ReplicatedStorage.Packages.Knit)

local QuestService
local DropService
local PlayerService
local ItemService
local InventoryService

local PromptService = Knit.CreateService({
	Name = "PromptService",
	Client = {},
})

PromptService.Prompts = {
	["CheckLoot"] = function(prompt: ProximityPrompt, player: Player)
		local DropsInfo = DropService:GetDrop(prompt).Drops
		print(DropsInfo)
		for _, itemName in DropsInfo do
			local Item = ItemService:CreateItem(itemName, 1)
			print(Item)
			InventoryService:AddItem(player, Item)
		end

		print(PlayerService:GetData(player))

		MainEvents:FireClient(player, "CheckLoot", DropsInfo.Drops)
	end,
}

function PromptService.KnitStart()
	InventoryService = Knit.GetService("InventoryService")
	QuestService = Knit.GetService("QuestService")
	DropService = Knit.GetService("DropService")
	PlayerService = Knit.GetService("PlayerService")
	ItemService = Knit.GetService("ItemService")

	ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
		local event: string? = prompt:GetAttribute("Event")
		if PromptService.Prompts[event] then
			PromptService.Prompts[event](prompt, player)
		end
	end)
end

return PromptService
