local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local QuestService

local PromptService = Knit.CreateService({
	Name = "PromptService",
	Client = {},
})

function PromptService:Prompt(player: Player, prompt: ProximityPrompt)
	--[[


    ]]
end

function PromptService.Client:Prompt(player: Player, prompt: ProximityPrompt)
	return self.Server:Prompt(player, prompt)
end

function PromptService.KnitStart()
	QuestService = Knit.GetService("QuestService")
end

return PromptService
