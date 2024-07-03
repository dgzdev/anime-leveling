local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local MainEvents = ReplicatedStorage.Events:FindFirstChild("MainEvents") :: RemoteEvent

local Knit = require(ReplicatedStorage.Packages.Knit)

local QuestService
local DropService

local PromptService = Knit.CreateService({
	Name = "PromptService",
	Client = {},
})

PromptService.Prompts = {
	["CheckLoot"] = function(prompt: ProximityPrompt, player: Player)
		local DropsInfo = DropService:GetDrop(prompt)
		
		MainEvents:FireClient(player, "CheckLoot", DropsInfo.Drops)
	end
}

function PromptService.KnitInit()
	QuestService = Knit.GetService("QuestService")
	DropService = Knit.GetService("DropService")

	ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
		local event: string? = prompt:GetAttribute("Event")
		if PromptService.Prompts[event] then
			PromptService.Prompts[event](prompt, player)
		end
	end)
end

return PromptService
