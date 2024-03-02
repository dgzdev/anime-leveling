local Knit = require(game.ReplicatedStorage.Packages.Knit)

local npcController = Knit.CreateController({
	Name = "npcController",
})

local QuestController

function npcController.PromptClick(prompt: ProximityPrompt)
	if prompt:GetAttribute("quest") then
		QuestController:CreatePrompt(prompt:GetAttribute("quest"))
	end
end

function npcController:KnitStart()
	QuestController = Knit.GetController("QuestController")
end

return npcController
